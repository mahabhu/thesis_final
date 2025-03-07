#!/bin/bash
# openssl genpkey -algorithm X25519 -out client-ephemeral-private.key
# clienthello=010000E20303BEFB348EB92951296E9FE7C30F95B8078D71C15AEAFF047482ADCDD12B8B5B1320EE742302E2CD427C424051E5893204C3F5AA64F0956D7E59DC4C6FBE8FDA7C95000A130113021303130413050100008F0000000E000C0000096C6F63616C686F7374000B000403000102000A000C000A001D0017001E00190018002300000016000000170000000D001E001C040305030603080708080809080A080B080408050806040105010601002B0003020304002D00020101003300260024001D0020E84C58D00662AA683E68F1F55078A73B00BCA1BC0E9BB2386AF472A5EC356D1E
# serverhello=020000760303406AE7656F04AD7D3FE1DFD45E6CBC69CE9E79F69659EACBA41A4D6CF541D1DE20EE742302E2CD427C424051E5893204C3F5AA64F0956D7E59DC4C6FBE8FDA7C95130200002E002B0002030400330024001D0020B7A23CA397351F2D1651B7BF3AE248A70856B1FA81660E6102B6EAA6335C1526
# clientprivatekey=808C9BCEB2141C6EF4B0957D87ECC0457C10731D414FB5D448847B78B0693374
# serverpublickey=B7A23CA397351F2D1651B7BF3AE248A70856B1FA81660E6102B6EAA6335C1526
# recdata=1703030017
# authtag=FBF4237EADE2CC5101D7E965ACD35E39
# recordnum=0
# encryptedData=A9F3B4AD89D25A

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

cc -o $dir/curve25519-mult $dir/curve25519-mult.c
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


key=$server_handshake_key
iv=$server_handshake_iv
### from this record
### may need to add -I and -L flags for include and lib dirs
cc -o $dir/aes_256_gcm_decrypt $dir/aes_256_gcm_decrypt.c -lssl -lcrypto
cat /tmp/msg1 \
  | $dir/aes_256_gcm_decrypt $iv $recordnum $key $recdata $authtag \
  | xxd -p -c 64