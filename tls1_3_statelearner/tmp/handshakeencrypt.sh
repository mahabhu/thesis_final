#!/bin/bash
# openssl genpkey -algorithm X25519 -out client-ephemeral-private.key
# openssl pkey -in client-ephemeral-private.key -pubout -out client-ephemeral-public.key

# clienthello=010000f40303000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000813021303130100ff010000a30000001800160000136578616d706c652e756c666865696d2e6e6574000b000403000102000a00160014001d0017001e0019001801000101010201030104002300000016000000170000000d001e001c040305030603080708080809080a080b080408050806040105010601002b0003020304002d00020101003300260024001d0020358072d6365880d1aeea329adf9121383851ed21a28e3b75e965d0d2cd166254
# serverhello=020000760303707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f20e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff130200002e002b0002030400330024001d00209fd7ad6dcff4298dd3f96d5b1b2af910a0535b1488d7f8fabb349a982880b615
# clientprivatekey=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
# serverpublickey=9fd7ad6dcff4298dd3f96d5b1b2af910a0535b1488d7f8fabb349a982880b615
# recordnum=0
# recdata=1703030017
# mydata=08000002000016

clienthello=$1
serverhello=$2
clientprivatekey=$3
serverpublickey=$4
recordnum=$5
recdata=$6
mydata=$7

echo $mydata | xxd -r -p > /tmp/msg1

dir="/home/mashroor/Documents/4-2/thesis_final/tls1_3_statelearner/tmp"

# cc -o $dir/curve25519-mult $dir/curve25519-mult.c
shared_secret=$($dir/curve25519-mult $clientprivatekey $serverpublickey)
hello_hash=$((echo -n "$clienthello" | xxd -r -p; echo -n "$serverhello" | xxd -r -p) | openssl dgst -sha384 | cut -d ' ' -f 2)
zero_key=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
early_secret=$($dir/hkdf-384.sh extract 00 $zero_key)
empty_hash=$(openssl sha384 < /dev/null | sed -e 's/.* //')
derived_secret=$($dir/hkdf-384.sh expandlabel $early_secret "derived" $empty_hash 48)
handshake_secret=$($dir/hkdf-384.sh extract $derived_secret $shared_secret)
csecret=$($dir/hkdf-384.sh expandlabel $handshake_secret "c hs traffic" $hello_hash 48)
ssecret=$($dir/hkdf-384.sh expandlabel $handshake_secret "s hs traffic" $hello_hash 48)
client_handshake_key=$($dir/hkdf-384.sh expandlabel $csecret "key" "" 32)
server_handshake_key=$($dir/hkdf-384.sh expandlabel $ssecret "key" "" 32)
client_handshake_iv=$($dir/hkdf-384.sh expandlabel $csecret "iv" "" 12)
server_handshake_iv=$($dir/hkdf-384.sh expandlabel $ssecret "iv" "" 12)




if [ "$8" = "server" ]; then
    key=$server_handshake_key
    iv=$server_handshake_iv
else
    key=$client_handshake_key
    iv=$client_handshake_iv
fi

cc -o $dir/aes_256_gcm_encrypt $dir/aes_256_gcm_encrypt.c -lssl -lcrypto
cat /tmp/msg1 \
  | $dir/aes_256_gcm_encrypt $iv $recordnum $key $recdata \
  | xxd -p -c 128