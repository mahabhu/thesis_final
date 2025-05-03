```
openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -nodes
openssl s_server -key server.key -cert server.crt -accept 4433
openssl s_server -key server.key -cert server.crt -accept 4433

```