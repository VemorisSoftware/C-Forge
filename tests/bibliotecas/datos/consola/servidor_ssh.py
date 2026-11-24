# Servidor SSH de prueba para prueba_consola_remota.cfv (paramiko).
# Uso: servidor_ssh.py <raíz sftp> <puerto> <clave de host> <clave pública autorizada>
import os, socket, sys, threading, paramiko
from paramiko import SFTPServer, SFTPServerInterface, SFTPAttributes, SFTPHandle, SFTP_OK, SFTP_NO_SUCH_FILE

RAIZ, PUERTO, HOST, AUTORIZADA = sys.argv[1], int(sys.argv[2]), sys.argv[3], open(sys.argv[4]).read().split()[1]
CLAVE_HOST = paramiko.Ed25519Key.from_private_key_file(HOST)

def real(p):
    p = os.path.normpath("/" + p.lstrip("/"))
    return os.path.join(RAIZ, p.lstrip("/"))

class Manejo(SFTPHandle):
    def stat(self):
        return SFTPAttributes.from_stat(os.fstat(self.readfile.fileno() if hasattr(self, "readfile") else self.writefile.fileno()))

class Sftp(SFTPServerInterface):
    def list_folder(self, path):
        r = []
        for n in os.listdir(real(path)):
            a = SFTPAttributes.from_stat(os.stat(os.path.join(real(path), n))); a.filename = n; r.append(a)
        return r
    def stat(self, path):
        try: return SFTPAttributes.from_stat(os.stat(real(path)))
        except OSError as e: return SFTPServer.convert_errno(e.errno)
    lstat = stat
    def open(self, path, flags, attr):
        try:
            modo = "rb"
            if flags & os.O_WRONLY: modo = "wb" if flags & os.O_TRUNC else "ab"
            elif flags & os.O_RDWR: modo = "r+b"
            f = open(real(path), modo)
        except OSError as e: return SFTPServer.convert_errno(e.errno)
        h = Manejo(flags); h.filename = real(path)
        if "r" in modo: h.readfile = f
        if "w" in modo or "a" in modo or "+" in modo: h.writefile = f
        return h
    def remove(self, path):
        try: os.remove(real(path))
        except OSError as e: return SFTPServer.convert_errno(e.errno)
        return SFTP_OK
    def rename(self, a, b):
        try: os.rename(real(a), real(b))
        except OSError as e: return SFTPServer.convert_errno(e.errno)
        return SFTP_OK
    def mkdir(self, path, attr):
        try: os.mkdir(real(path))
        except OSError as e: return SFTPServer.convert_errno(e.errno)
        return SFTP_OK
    def rmdir(self, path):
        try: os.rmdir(real(path))
        except OSError as e: return SFTPServer.convert_errno(e.errno)
        return SFTP_OK
    def canonicalize(self, path):
        return os.path.normpath("/" + path.lstrip("/"))

class Servidor(paramiko.ServerInterface):
    def check_auth_password(self, u, p):
        return paramiko.AUTH_SUCCESSFUL if (u, p) == ("javier", "clave secreta") else paramiko.AUTH_FAILED
    def check_auth_publickey(self, u, k):
        return paramiko.AUTH_SUCCESSFUL if u == "javier" and k.get_base64() == AUTORIZADA else paramiko.AUTH_FAILED
    def get_allowed_auths(self, u): return "password,publickey"
    def check_channel_request(self, kind, cid): return paramiko.OPEN_SUCCEEDED
    tuneles = set()
    def check_channel_direct_tcpip_request(self, cid, origen, destino):
        self.tuneles.add(cid); return paramiko.OPEN_SUCCEEDED
    def check_channel_exec_request(self, canal, cmd):
        threading.Thread(target=ejecutar, args=(canal, cmd.decode())).start(); return True

def ejecutar(canal, cmd):
    if cmd.startswith("echo "): canal.sendall((cmd[5:] + "\n").encode()); canal.send_exit_status(0)
    elif cmd == "falla": canal.sendall_stderr(b"algo fallo\n"); canal.send_exit_status(3)
    elif cmd == "cat":
        datos = b""
        while True:
            x = canal.recv(65536)
            if not x: break
            datos += x
        canal.sendall(datos); canal.send_exit_status(0)
    elif cmd == "grande": canal.sendall(bytes(range(256)) * 4000); canal.send_exit_status(0)
    else: canal.sendall_stderr(b"no existe\n"); canal.send_exit_status(127)
    canal.close()

def eco(canal):
    while True:
        x = canal.recv(65536)
        if not x: break
        canal.sendall(x.upper())
    canal.close()

def atender(c):
    t = paramiko.Transport(c); t.add_server_key(CLAVE_HOST)
    t.set_subsystem_handler("sftp", SFTPServer, Sftp)
    srv = Servidor(); t.start_server(server=srv)
    while t.is_active():
        canal = t.accept(1)
        if canal is not None and canal.get_id() in srv.tuneles: threading.Thread(target=eco, args=(canal,)).start()

s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); s.bind(("127.0.0.1", PUERTO)); s.listen(5)
while True:
    c, _ = s.accept(); threading.Thread(target=atender, args=(c,), daemon=True).start()
