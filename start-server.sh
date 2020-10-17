#!/bin/sh

# directly ported from batch (start_server.bat)

function print_ipv4s {
	# IPv4 grabber thing from Chris Seymour
	# (https://stackoverflow.com/a/13322549, CC BY-SA 3.0)
	ip address | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
}

echo
echo Currently active IPv4 addresses:
print_ipv4s
echo

# Main instructions
cat <<EOF
Before running the install script, take care to edit "bootstrap.sh",
typing your machine's local IP over "192.168.1.3".

To start the install script, boot the Arch Linux install disc and
type the following, replacing "SERVERIP" with the needed IP:

curl SERVERIP:8080/bootstrap.sh | sh

Press CTRL+C to stop server.

EOF

sudo python3 -m http.server 8080
