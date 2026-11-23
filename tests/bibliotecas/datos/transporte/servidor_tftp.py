# Servidor TFTP de prueba para prueba_transporte.cfv (tftpy).
import sys, tftpy, logging
logging.disable(logging.CRITICAL)
tftpy.TftpServer(sys.argv[1]).listen("127.0.0.1", int(sys.argv[2]))
