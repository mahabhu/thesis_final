#!/bin/bash
# openssl genpkey -algorithm X25519 -out client-ephemeral-private.key
# openssl pkey -noout -text -in client-ephemeral-private.key
# clienthello=010000E20303044949C41D532BA5E818C114A250FDF38B9C3551CF0689107D3DEFD97E08C947202BB9FA21B48E137C5E70BDECE63A590909D875C7600379B60D4EA01983089EEB000A130113021303130413050100008F0000000E000C0000096C6F63616C686F7374000B000403000102000A000C000A001D0017001E00190018002300000016000000170000000D001E001C040305030603080708080809080A080B080408050806040105010601002B0003020304002D00020101003300260024001D00209FD7AD6DCFF4298DD3F96D5B1B2AF910A0535B1488D7F8FABB349A982880B615
# serverhello=020000760303C92CF7E125457809706135F51DEF7A9952EBF9B7B9F291235A0E4153B7CB4302209D79D9E883F855DE67CBBE0D723B2EA22AB6135943279046D5F9B7B1C0F5BB7F130100002E00330024001D0020D63E7DAC41DC384D2A99405E079F8E883E44899F90A54E31E42A3D4E309BFC46002B00020304
# clientprivatekey=909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAF
# serverpublickey=D63E7DAC41DC384D2A99405E079F8E883E44899F90A54E31E42A3D4E309BFC46
# recdata=1703030035
# authtag=ADC44358181162275705A1EBCBED5905
# recordnum=4
# encryptedData=4200426A4C57ED93C7057CE7C76DC250B6AD1AC79B229034A7BC2CAFEB76069B9672C2861C

clienthello=$1
serverhello=$2
clientprivatekey=$3
serverpublickey=$4
recordnum=$5
recdata=$6
encryptedData=$7
authtag=$8

echo $encryptedData | xxd -r -p > /tmp/msg1

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
# echo hssec: $handshake_secret
# echo ssec: $ssecret
# echo csec: $csecret
# echo skey: $server_handshake_key
# echo siv: $server_handshake_iv
# echo ckey: $client_handshake_key
# echo civ: $client_handshake_iv


# key=$server_handshake_key
# iv=$server_handshake_iv

if [ "$9" = "client" ]; then
    key=$server_handshake_key
    iv=$server_handshake_iv
else
    key=$client_handshake_key
    iv=$client_handshake_iv
fi

### from this record
### may need to add -I and -L flags for include and lib dirs
cc -o $dir/aes_256_gcm_decrypt $dir/aes_256_gcm_decrypt.c -lssl -lcrypto
cat /tmp/msg1 \
  | $dir/aes_256_gcm_decrypt $iv $recordnum $key $recdata $authtag \
  | xxd -p -c 64