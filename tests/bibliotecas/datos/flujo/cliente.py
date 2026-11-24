# Cliente Kafka real (kafka-python) contra el broker de flujo: produce con
# claves, cabeceras e idempotencia y vuelve a leer todo. Escribe el
# resultado en JSON y crea el archivo de fin.
import sys, json
from kafka import KafkaProducer, KafkaConsumer
puerto, salida, fin = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    p = KafkaProducer(bootstrap_servers='127.0.0.1:' + puerto)
    fs = [p.send('pedidos', key=b'cliente-%d' % i, value=('pedido %d ñ' % i).encode(), headers=[('h', b'v%d' % i)]) for i in range(6)]
    p.flush()
    md = [[f.get(timeout=5).partition, f.get(timeout=5).offset] for f in fs]
    c = KafkaConsumer('pedidos', 'desde-cforge', bootstrap_servers='127.0.0.1:' + puerto, auto_offset_reset='earliest', group_id=None, consumer_timeout_ms=2000)
    rs = sorted([[r.topic, r.partition, r.offset, (r.key or b'').decode(), (r.value or b'').decode(), [[k, v.decode()] for k, v in r.headers]] for r in c])
    json.dump({"enviados": md, "leidos": rs}, open(salida, 'w'), ensure_ascii=False)
finally:
    open(fin, 'w').write('fin')
