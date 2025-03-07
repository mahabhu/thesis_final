openssl server:
works fine, state machine with 6 states, complete handshake

openssl client: statelearner server mode
no certificate provided from client side, handshake incomplete, client irresponsive (connectionclosed), only two state (i.e. no function)

tls attacker client:
3 states, custom protocol messages, client responds only for server hello done, 

testing client is slower since it needs to restart everytime (same for tls attacker server)

learn mtls handshake