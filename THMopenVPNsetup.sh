 #!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 <path_to_ovpn_file>"
    echo "Example: $0 ~/Downloads/myprofile.ovpn"
    exit 1
}

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (e.g., using sudo)."
    exit 1
fi

# Check for argument
if [ "$#" -ne 1 ]; then
    usage
fi

OVPN_FILE=$1

# Check if the .ovpn file exists
if [ ! -f "$OVPN_FILE" ]; then
    echo "The specified .ovpn file does not exist: $OVPN_FILE"
    exit 1
fi

# Update and install OpenVPN if not installed
echo "Updating system packages..."
apt-get update -y

echo "Installing OpenVPN..."
if ! command -v openvpn &>/dev/null; then
    apt-get install -y openvpn
else
    echo "OpenVPN is already installed."
fi

# Verify OpenVPN service
echo "Checking OpenVPN service..."
systemctl enable openvpn
systemctl start openvpn

# Connect to TryHackMe VPN
echo "Connecting to TryHackMe VPN using $OVPN_FILE..."
openvpn --config "$OVPN_FILE" --auth-nocache --daemon

# Check VPN connection
sleep 5
echo "Checking VPN connection..."
if ip addr | grep -q tun0; then
    echo "Successfully connected to TryHackMe VPN."
    echo "You can now access TryHackMe machines."
else
    echo "Failed to establish a VPN connection. Please check the .ovpn file and your internet connection."
fi
