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
disable_screen() {
    local display="$1"
    xrandr --output "$display" --off
}

# Function to enable the screen
enable_screen() {
    local display="$1"
    xrandr --output "$display" --auto
}

# Determine the output display
output_displays=$(xrandr --listmonitors | awk '/^[[:space:]]*[0-9]+:/ { print $4 }')

# Check if output displays are empty
if [ -z "$output_displays" ]; then
    echo "Error: Unable to determine output display."
    exit 1
fi

# Loop through each output display
while IFS= read -r output_display; do
    # Check the status of the lid every 0.3 seconds
    while true; do
        lid_status=$(cat /proc/acpi/button/lid/LID0/state | awk "{print \$2}")
        if [ "$lid_status" = "closed" ]; then
            disable_screen "$output_display"
            lid_closed=true
        elif [ "$lid_status" = "open" ] && [ "$lid_closed" = true ]; then
            enable_screen "$output_display"
            lid_closed=false
        fi
        sleep 0.3
    done &
done <<< "$output_displays"

wait
