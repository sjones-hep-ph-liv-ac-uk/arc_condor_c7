openssl x509 -noout -modulus -in $1 | openssl md5
openssl rsa -noout -modulus -in $2 | openssl md5
