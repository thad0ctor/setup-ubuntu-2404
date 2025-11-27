#!/bin/bash
#
# Linux Setup Installation Script
# This script recreates your Linux installation setup including:
# - Samba network drive mounts
# - Windows NTFS drive mounts
# - File manager bookmarks
# - Essential applications (Remmina, VLC, VS Code, Cursor, Joplin, Sunshine, Moonlight, Extension Manager)
# - Nemo and Nautilus file managers with extensions
# - GNOME Shell extensions
# - Nemo context menu scripts
#

# Don't exit on error - continue installation even if individual packages fail
# set -e  # Removed - we want to continue on errors

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should NOT be run as root (don't use sudo)"
   exit 1
fi

print_status "Starting Linux setup installation..."
echo ""

#######################################
# 1. INSTALL ESSENTIAL PACKAGES
#######################################

print_status "Installing essential packages..."

# Update package lists
print_status "Updating package lists..."
sudo apt update || print_warning "Failed to update package lists, continuing..."

# Install file managers
print_status "Installing Nemo and Nautilus file managers..."
sudo apt install -y nemo nemo-data nemo-fileroller || print_warning "Failed to install Nemo, continuing..."
sudo apt install -y nautilus nautilus-extension-gnome-terminal nautilus-sendto || print_warning "Failed to install Nautilus, continuing..."

# Install utilities needed by Nemo actions
print_status "Installing utilities for Nemo actions..."
sudo apt install -y zenity xclip || print_warning "Failed to install utilities, continuing..."

# Install applications
print_status "Installing Remmina (remote desktop client)..."
sudo apt install -y remmina remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-secret || print_warning "Failed to install Remmina, continuing..."

print_status "Installing VLC media player..."
sudo apt install -y vlc || print_warning "Failed to install VLC, continuing..."

print_status "Installing GNOME Extension Manager..."
sudo apt install -y gnome-shell-extension-manager || print_warning "Failed to install Extension Manager, continuing..."

print_status "Installing curl and wget..."
sudo apt install -y curl wget || print_warning "Failed to install curl/wget, continuing..."

print_status "Installing GitHub Desktop..."
if wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null; then
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ stable main" > /etc/apt/sources.list.d/shiftkey-packages.list'
    sudo apt update || true
    sudo apt install -y github-desktop || print_warning "Failed to install GitHub Desktop, continuing..."
else
    print_warning "Failed to add GitHub Desktop repository, continuing..."
fi

print_status "Installing Claude Code CLI..."
curl -fsSL https://claude.ai/install.sh | bash || print_warning "Failed to install Claude Code CLI, continuing..."

print_status "Installing Flameshot (screenshot tool)..."
sudo apt install -y flameshot || print_warning "Failed to install Flameshot, continuing..."

print_status "Installing Discord..."
sudo snap install discord || print_warning "Failed to install Discord, continuing..."

print_status "Installing Moonlight (game streaming client)..."
sudo snap install moonlight || print_warning "Failed to install Moonlight, continuing..."

print_status "Installing Visual Studio Code..."
sudo snap install --classic code || print_warning "Failed to install VS Code, continuing..."

print_status "Installing Cursor AI Editor..."
curl -fsS https://cursor.com/install | bash || print_warning "Failed to install Cursor, continuing..."

print_status "Installing Joplin (note-taking app)..."
wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash || print_warning "Failed to install Joplin, continuing..."

print_status "Installing CIFS utilities for Samba mounting..."
sudo apt install -y cifs-utils || print_warning "Failed to install CIFS utilities, continuing..."

print_status "Installing NTFS support..."
sudo apt install -y ntfs-3g || print_warning "Failed to install NTFS support, continuing..."

# Check if Sunshine should be installed
if [ -f "$SCRIPT_DIR/sunshine.deb" ]; then
    print_status "Installing Sunshine from local package..."
    sudo dpkg -i "$SCRIPT_DIR/sunshine.deb" || sudo apt --fix-broken install -y

    # Configure Sunshine to restart every hour (prevents memory leaks)
    print_status "Configuring Sunshine auto-restart (hourly)..."
    mkdir -p ~/.config/systemd/user/sunshine.service.d
    cat > ~/.config/systemd/user/sunshine.service.d/restart.conf <<'EOF'
[Service]
Restart=always
RestartSec=10
RuntimeMaxSec=3600
EOF

    # Reload systemd user daemon
    systemctl --user daemon-reload || print_warning "Failed to reload systemd user daemon, continuing..."
    print_success "Sunshine configured to restart every hour"
else
    print_warning "Sunshine package not found. You'll need to download and install it separately."
    print_warning "Visit: https://github.com/LizardByte/Sunshine/releases"
fi

print_success "Essential packages installed"
echo ""

#######################################
# 2. INSTALL DEVELOPMENT TOOLS & CUDA
#######################################

read -p "Do you want to install development tools (gcc, cmake) and CUDA Toolkit? (y/n): " INSTALL_CUDA
if [[ "$INSTALL_CUDA" =~ ^[Yy]$ ]]; then
    print_status "Installing development tools..."
    sudo apt install -y gcc g++ make cmake build-essential || print_warning "Failed to install development tools, continuing..."

    print_status "Installing system monitoring tools..."
    sudo apt install -y htop nvtop || print_warning "Failed to install monitoring tools, continuing..."

    print_status "Installing CUDA Toolkit 13.0..."

    # Download and install CUDA keyring
    print_status "Adding NVIDIA CUDA repository..."
    cd /tmp
    if wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb; then
        sudo dpkg -i cuda-keyring_1.1-1_all.deb || print_warning "Failed to install CUDA keyring, continuing..."
    else
        print_warning "Failed to download CUDA keyring, skipping CUDA installation..."
        cd "$SCRIPT_DIR"
    fi

    # Update package lists with CUDA repo (only if keyring was installed)
    if [ -f /tmp/cuda-keyring_1.1-1_all.deb ]; then
        print_status "Updating package lists..."
        sudo apt-get update || print_warning "Failed to update package lists, continuing..."

        # Install CUDA Toolkit
        print_status "Installing CUDA Toolkit 13.0 (this may take several minutes)..."
        sudo apt-get install -y cuda-toolkit-13-0 || print_warning "Failed to install CUDA Toolkit, continuing..."

        # Install NVIDIA open kernel modules
        print_status "Installing NVIDIA open kernel modules..."
        sudo apt-get install -y nvidia-open || print_warning "Failed to install NVIDIA open modules, continuing..."
    fi

    # Add CUDA to PATH
    print_status "Configuring CUDA environment variables..."
    if ! grep -q "CUDA" ~/.bashrc; then
        echo '' >> ~/.bashrc
        echo '# CUDA Toolkit' >> ~/.bashrc
        echo 'export PATH=/usr/local/cuda-13.0/bin${PATH:+:${PATH}}' >> ~/.bashrc
        echo 'export LD_LIBRARY_PATH=/usr/local/cuda-13.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
    fi

    # Clean up
    rm -f /tmp/cuda-keyring_1.1-1_all.deb
    cd "$SCRIPT_DIR"

    print_success "CUDA Toolkit and development tools installed"
    print_warning "You may need to reboot for NVIDIA drivers to load properly"
else
    print_status "Skipping CUDA installation"
fi

echo ""

#######################################
# 3. CONFIGURE NETWORK DRIVES (SAMBA)
#######################################

print_status "Configuring Samba network drives..."

# Prompt for Samba server IP
read -p "Enter your Samba server IP address (default: 192.168.0.3): " SAMBA_IP
SAMBA_IP=${SAMBA_IP:-192.168.0.3}

# Create mount points
print_status "Creating mount points..."
sudo mkdir -p /mnt/samba/{MISC-M2-4TB,AI-M2-2TB,T9,Training,Desktop,Ubuntu-Root}

# Backup existing fstab
print_status "Backing up /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)

# Add Samba mounts to fstab (if not already present)
print_status "Adding Samba mounts to /etc/fstab..."

SAMBA_MOUNTS="
# Samba shares from $SAMBA_IP (automount - won't block boot)
//$SAMBA_IP/MISC-M2-4TB /mnt/samba/MISC-M2-4TB cifs guest,noauto,x-systemd.automount,_netdev,x-systemd.mount-timeout=30,uid=1000,gid=1000,file_mode=0775,dir_mode=0775 0 0
//$SAMBA_IP/AI-M2-2TB /mnt/samba/AI-M2-2TB cifs guest,noauto,x-systemd.automount,_netdev,x-systemd.mount-timeout=30,uid=1000,gid=1000,file_mode=0775,dir_mode=0775 0 0
//$SAMBA_IP/T9 /mnt/samba/T9 cifs guest,noauto,x-systemd.automount,_netdev,x-systemd.mount-timeout=30,uid=1000,gid=1000,file_mode=0775,dir_mode=0775 0 0
//$SAMBA_IP/Training /mnt/samba/Training cifs guest,noauto,x-systemd.automount,_netdev,x-systemd.mount-timeout=30,uid=1000,gid=1000,file_mode=0775,dir_mode=0775 0 0
//$SAMBA_IP/Desktop /mnt/samba/Desktop cifs guest,noauto,x-systemd.automount,_netdev,x-systemd.mount-timeout=30,uid=1000,gid=1000,file_mode=0775,dir_mode=0775 0 0
//$SAMBA_IP/Ubuntu-Root /mnt/samba/Ubuntu-Root cifs guest,noauto,x-systemd.automount,_netdev,x-systemd.mount-timeout=30,uid=1000,gid=1000,file_mode=0775,dir_mode=0775 0 0
"

# Check if Samba mounts already exist in fstab
if ! grep -q "Samba shares from" /etc/fstab; then
    echo "$SAMBA_MOUNTS" | sudo tee -a /etc/fstab > /dev/null
    print_success "Samba mounts added to /etc/fstab"
else
    print_warning "Samba mounts already exist in /etc/fstab, skipping..."
fi

# Reload systemd to recognize new mounts
print_status "Reloading systemd daemon..."
sudo systemctl daemon-reload || print_warning "Failed to reload systemd, continuing..."

print_success "Samba drives configured"
echo ""

#######################################
# 4. CONFIGURE WINDOWS NTFS DRIVES
#######################################

print_status "Configuring Windows NTFS drives..."

read -p "Do you want to configure Windows NTFS drive mounts? (y/n): " CONFIGURE_WINDOWS
if [[ "$CONFIGURE_WINDOWS" =~ ^[Yy]$ ]]; then
    print_warning "You need to find the UUIDs of your Windows drives first."
    print_status "Run: sudo blkid"
    print_status "Then look for NTFS partitions and note their UUIDs"
    echo ""

    read -p "Enter Windows SSD UUID (or press Enter to skip): " WINDOWS_SSD_UUID
    read -p "Enter Games drive UUID (or press Enter to skip): " GAMES_UUID

    # Create mount points
    sudo mkdir -p /mnt/windows/{Windows-SSD,Games}

    WINDOWS_MOUNTS=""

    if [ ! -z "$WINDOWS_SSD_UUID" ]; then
        WINDOWS_MOUNTS+="# Windows NTFS drives (nofail - won't block boot if unavailable)\n"
        WINDOWS_MOUNTS+="UUID=$WINDOWS_SSD_UUID /mnt/windows/Windows-SSD ntfs-3g defaults,nofail,uid=1000,gid=1000,dmask=022,fmask=133 0 0\n"
    fi

    if [ ! -z "$GAMES_UUID" ]; then
        if [ -z "$WINDOWS_MOUNTS" ]; then
            WINDOWS_MOUNTS+="# Windows NTFS drives (nofail - won't block boot if unavailable)\n"
        fi
        WINDOWS_MOUNTS+="UUID=$GAMES_UUID /mnt/windows/Games ntfs-3g defaults,nofail,uid=1000,gid=1000,dmask=022,fmask=133 0 0\n"
    fi

    if [ ! -z "$WINDOWS_MOUNTS" ]; then
        if ! grep -q "Windows NTFS drives" /etc/fstab; then
            echo -e "$WINDOWS_MOUNTS" | sudo tee -a /etc/fstab > /dev/null
            print_success "Windows drive mounts added to /etc/fstab"
            sudo systemctl daemon-reload || print_warning "Failed to reload systemd, continuing..."
        else
            print_warning "Windows drive mounts already exist in /etc/fstab"
        fi
    fi
fi

print_success "Windows drives configured"
echo ""

#######################################
# 5. INSTALL NEMO ACTIONS AND SCRIPTS
#######################################

print_status "Installing Nemo context menu actions and scripts..."

# Create Nemo actions and scripts directories
mkdir -p ~/.local/share/nemo/actions
mkdir -p ~/.local/share/nemo/scripts

# Copy Nemo actions from package
if [ -d "$SCRIPT_DIR/nemo-scripts" ] && [ "$(ls -A $SCRIPT_DIR/nemo-scripts)" ]; then
    print_status "Installing Nemo actions and helper scripts..."

    # Copy .nemo_action files to actions directory
    find "$SCRIPT_DIR/nemo-scripts" -name "*.nemo_action" -exec cp {} ~/.local/share/nemo/actions/ \;

    # Install helper scripts to user's .local/bin directory
    mkdir -p ~/.local/bin

    # Copy shell scripts (but not .nemo_action files or README)
    find "$SCRIPT_DIR/nemo-scripts" -type f -name "*.sh" -exec cp {} ~/.local/bin/ \;
    chmod +x ~/.local/bin/*.sh 2>/dev/null || true

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Update merge_gguf.nemo_action to use ~/.local/bin instead of /bin
    if [ -f ~/.local/share/nemo/actions/merge_gguf.nemo_action ]; then
        sed -i 's|/bin/merge_gguf.sh|'$HOME'/.local/bin/merge_gguf.sh|g' ~/.local/share/nemo/actions/merge_gguf.nemo_action
    fi


    print_success "Nemo actions and helper scripts installed"

    # Check for dependencies
    if ! command -v zenity &> /dev/null; then
        print_warning "zenity is required for some Nemo actions but not installed"
    fi
    if ! command -v xclip &> /dev/null; then
        print_warning "xclip is required for 'Copy Path' action but not installed"
    fi
else
    print_warning "No Nemo scripts found in package. Add them to: $SCRIPT_DIR/nemo-scripts/"
fi

echo ""

#######################################
# 6. INSTALL NAUTILUS SCRIPTS
#######################################

print_status "Installing Nautilus scripts..."

# Create Nautilus scripts directory
mkdir -p ~/.local/share/nautilus/scripts

# Copy scripts from package
if [ -d "$SCRIPT_DIR/nautilus-scripts" ] && [ "$(ls -A $SCRIPT_DIR/nautilus-scripts)" ]; then
    print_status "Copying Nautilus scripts..."
    cp -r "$SCRIPT_DIR/nautilus-scripts/"* ~/.local/share/nautilus/scripts/
    chmod +x ~/.local/share/nautilus/scripts/*
    print_success "Nautilus scripts installed"
else
    print_warning "No Nautilus scripts found in package."
fi

echo ""

#######################################
# 7. CONFIGURE FILE MANAGER BOOKMARKS
#######################################

print_status "Configuring file manager bookmarks..."

# Create GTK bookmarks file
mkdir -p ~/.config/gtk-3.0

BOOKMARKS="file:///home/$USER/Documents
file:///home/$USER/Downloads
file:///home/$USER/Music
file:///home/$USER/Pictures
file:///home/$USER/Videos
file:///mnt/samba/AI-M2-2TB AI-M2-2TB
file:///mnt/samba/Desktop Server-Desktop
file:///mnt/samba/MISC-M2-4TB MISC-M2-4TB
file:///mnt/samba/T9 T9
file:///mnt/samba/Training Training
file:///mnt/samba/Ubuntu-Root Ubuntu-Root
file:///mnt/windows/Games Games
file:///mnt/windows/Windows-SSD Windows-SSD"

echo "$BOOKMARKS" > ~/.config/gtk-3.0/bookmarks

print_success "File manager bookmarks configured"
echo ""

#######################################
# 8. INSTALL GNOME EXTENSIONS
#######################################

print_status "GNOME Extensions information..."

print_warning "The following GNOME extensions were detected on your original system:"
echo "  - appindicatorsupport@rgcjonas.gmail.com"
echo "  - dash-to-dock@micxgx.gmail.com"
echo "  - dash-to-panel@jderose9.github.com"
echo "  - EasyScreenCast@iacopodeenosee.gmail.com"
echo "  - extension-list@tu.berry"
echo "  - show-desktop-applet@valent-in"
echo "  - tiling-assistant@ubuntu.com (Ubuntu default)"
echo "  - ding@rastersoft.com (Ubuntu default)"
echo ""

print_status "You can install these extensions using GNOME Extension Manager:"
print_status "1. Open 'Extension Manager' from your applications"
print_status "2. Search for and install the extensions listed above"
print_status "3. Enable them in the Extension Manager"
echo ""
print_status "Alternatively, visit: https://extensions.gnome.org/"

echo ""

#######################################
# 9. FINAL STEPS
#######################################

print_status "Installation complete!"
echo ""
print_success "Summary of what was configured:"
echo "  ✓ File managers: Nemo and Nautilus with extensions"
echo "  ✓ Applications: Remmina, VLC, Extension Manager, GitHub Desktop, Claude Code CLI, VS Code, Cursor, Joplin, Flameshot, Discord, Moonlight"
if [[ "$INSTALL_CUDA" =~ ^[Yy]$ ]]; then
echo "  ✓ Development tools: gcc, cmake, build-essential"
echo "  ✓ System monitoring: htop, nvtop"
echo "  ✓ CUDA Toolkit 13.0 and NVIDIA drivers"
fi
echo "  ✓ Samba network drives configured in /etc/fstab"
echo "  ✓ File manager bookmarks created"
echo "  ✓ Nemo and Nautilus scripts installed"
echo ""

print_warning "Next steps:"
echo "  1. Reboot your system to activate all mount points"
if [[ "$INSTALL_CUDA" =~ ^[Yy]$ ]]; then
echo "  2. After reboot, verify CUDA: nvidia-smi and nvcc --version"
echo "  3. Install GNOME extensions using Extension Manager"
echo "  4. Configure Sunshine if needed: https://docs.lizardbyte.dev/projects/sunshine/"
echo "  5. Verify all Samba drives are accessible after reboot"
else
echo "  2. Install GNOME extensions using Extension Manager"
echo "  3. Configure Sunshine if needed: https://docs.lizardbyte.dev/projects/sunshine/"
echo "  4. Verify all Samba drives are accessible after reboot"
fi
echo ""

read -p "Would you like to reboot now? (y/n): " REBOOT_NOW
if [[ "$REBOOT_NOW" =~ ^[Yy]$ ]]; then
    print_status "Rebooting in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    sudo reboot
else
    print_status "Remember to reboot later to activate all changes!"
fi
