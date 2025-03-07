#!/bin/bash

key=F5B8758D758E21B08578BA93D29F7090F0FE25C8DC8C6A77DA6351CA47D12E74
iv=A083E31E0D8CD99099FEE9B3
### from this record
recdata=1703030017
authtag=48B67F06CB40808D4F60EB23291B0A10
recordnum=0
### may need to add -I and -L flags for include and lib dirs
cc -o aes_256_gcm_decrypt aes_256_gcm_decrypt.c -lssl -lcrypto
echo "39 64 B2 F6 94 7B 6B" | xxd -r -p > /tmp/msg1
cat /tmp/msg1 \
  | ./aes_256_gcm_decrypt $iv $recordnum $key $recdata $authtag \
  | hexdump -C