#!/bin/bash
wget -O Dynatrace-OneAgent-Linux-1.137.139.sh "${dynatrace_url}"
wget https://ca.dynatrace.com/dt-root.cert.pem ; ( echo 'Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg="sha-256"; boundary="--SIGNED-INSTALLER"'; echo ; echo ; echo '----SIGNED-INSTALLER' ; cat Dynatrace-OneAgent-Linux-1.137.139.sh ) | openssl cms -verify -CAfile dt-root.cert.pem > /dev/null
/bin/sh Dynatrace-OneAgent-Linux-1.137.139.sh  APP_LOG_CONTENT_ACCESS=1