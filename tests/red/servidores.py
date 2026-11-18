"""Servidores locales para tests/red: HTTP, HTTPS, UDP (eco) y RESP (Redis)."""
import http.server, json, os, socket, socketserver, ssl, sys, threading

AQUI = os.path.dirname(os.path.abspath(__file__))

class Http(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    def log_message(self, *a): pass
    def responder(self, estado, cuerpo, extra=()):
        self.send_response(estado)
        for k, v in extra: self.send_header(k, v)
        self.send_header("Content-Length", str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)
    def do_GET(self):
        if self.path == "/redir":
            return self.responder(302, b"", [("Location", "/hola")])
        if self.path == "/chunked":
            self.send_response(200)
            self.send_header("Transfer-Encoding", "chunked")
            self.end_headers()
            for parte in [b"uno ", b"dos ", b"tres"]:
                self.wfile.write(b"%x\r\n%s\r\n" % (len(parte), parte))
            self.wfile.write(b"0\r\n\r\n")
            return
        if self.path == "/grande":
            return self.responder(200, b"x" * 200000)
        self.responder(200, ("hola desde " + self.path).encode(), [("X-Prueba", "ok")])
    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        d = self.rfile.read(n)
        cuerpo = json.dumps({"recibido": d.decode(), "tipo": self.headers.get("Content-Type"), "token": self.headers.get("X-Token")}, sort_keys=True).encode()
        self.responder(201, cuerpo)

class Resp(socketserver.BaseRequestHandler):
    datos = {}
    def handle(self):
        buf = b""
        while True:
            d = self.request.recv(65536)
            if not d: return
            buf += d
            while buf.startswith(b"*"):
                lineas = buf.split(b"\r\n")
                n = int(lineas[0][1:])
                if len(lineas) < 2 + 2 * n: break
                args = [lineas[2 + 2 * i].decode() for i in range(n)]
                buf = b"\r\n".join(lineas[1 + 2 * n:])
                c = args[0].upper()
                if c == "PING": out = b"+PONG\r\n"
                elif c == "SET": Resp.datos[args[1]] = args[2]; out = b"+OK\r\n"
                elif c == "GET":
                    v = Resp.datos.get(args[1])
                    out = b"$-1\r\n" if v is None else b"$%d\r\n%s\r\n" % (len(v.encode()), v.encode())
                elif c == "INCR":
                    Resp.datos[args[1]] = str(int(Resp.datos.get(args[1], "0")) + 1)
                    out = b":%s\r\n" % Resp.datos[args[1]].encode()
                else: out = b"-ERR desconocido\r\n"
                self.request.sendall(out)

def eco_udp(s):
    while True:
        d, a = s.recvfrom(65536)
        s.sendto(b"eco: " + d, a)

def iniciar():
    socketserver.ThreadingTCPServer.allow_reuse_address = True
    socketserver.ThreadingTCPServer.daemon_threads = True
    servidores = [socketserver.ThreadingTCPServer(("127.0.0.1", 0), Http),
                  socketserver.ThreadingTCPServer(("127.0.0.1", 0), Http),
                  socketserver.ThreadingTCPServer(("127.0.0.1", 0), Resp)]
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.load_cert_chain(os.path.join(AQUI, "certs", "servidor.pem"), os.path.join(AQUI, "certs", "servidor.key"))
    servidores[1].socket = ctx.wrap_socket(servidores[1].socket, server_side=True)
    for s in servidores:
        threading.Thread(target=s.serve_forever, daemon=True).start()
    u = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    u.bind(("127.0.0.1", 0))
    threading.Thread(target=eco_udp, args=(u,), daemon=True).start()
    return {"http": servidores[0].server_address[1], "https": servidores[1].server_address[1],
            "redis": servidores[2].server_address[1], "udp": u.getsockname()[1]}
