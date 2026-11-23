# Servidor FTP de prueba para prueba_transporte.cfv (pyftpdlib).
import sys
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer
a = DummyAuthorizer()
a.add_user("ana", "s3cr3t", sys.argv[1], perm="elradfmwMT")
a.add_anonymous(sys.argv[1])
h = FTPHandler; h.authorizer = a
FTPServer(("127.0.0.1", int(sys.argv[2])), h).serve_forever()
