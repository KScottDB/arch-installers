export WEBROOT=http://192.168.1.3 # change this ip to yours

rm inst.sh*
curl ${WEBROOT}/inst.sh > inst.sh
bash inst.sh