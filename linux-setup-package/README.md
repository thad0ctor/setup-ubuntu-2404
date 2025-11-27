# Linux Setup Package

This package contains everything you need to recreate your Linux installation setup on a new PC.

## What This Package Includes

- **install.sh**: Main installation script that automates the entire setup
- **nemo-scripts/**: Directory for Nemo file manager context menu scripts
- **nautilus-scripts/**: Directory for Nautilus file manager scripts
- **configs/**: Additional configuration files
- **gnome-extensions/**: Information about GNOME extensions to install

## What Gets Installed/Configured

1. **File Managers**
   - Nemo file manager with extensions
   - Nautilus file manager with GNOME Terminal extension

2. **Applications**
   - Remmina (remote desktop client with RDP and VNC support)
   - VLC media player
   - GNOME Extension Manager
   - GitHub Desktop (git GUI client)
   - Claude Code CLI (AI coding assistant)
   - Visual Studio Code (code editor)
   - Cursor (AI-powered code editor)
   - Joplin (note-taking and to-do application)
   - Flameshot (screenshot tool)
   - Discord (communication platform)
   - Moonlight (game streaming client)
   - curl and wget (download utilities)
   - Sunshine (if sunshine.deb is present in this package)
     - Includes auto-restart configuration (hourly) to prevent memory leaks

3. **Development Tools (Optional)**
   - gcc, g++, make, cmake, build-essential
   - htop and nvtop (system monitoring)
   - CUDA Toolkit 13.0
   - NVIDIA open kernel modules

4. **Network Storage**
   - Samba/CIFS network drives (automount configuration)
   - Bookmarks for all network shares in file manager

5. **Windows Drive Mounts**
   - NTFS-3g support
   - Automatic mounting of Windows drives (optional)

6. **Context Menu Scripts**
   - Nemo right-click menu scripts
   - Nautilus scripts

7. **GNOME Extensions**
   - Instructions for installing your preferred extensions

## Before Running the Installation

### 1. Gather Nemo Scripts from Your Current PC

If you have access to your current Ubuntu installation at `/mnt/samba/Ubuntu-Root`, run:

```bash
cd ~/Desktop/linux-setup-package
./collect-scripts.sh
```

This will copy all Nemo and Nautilus scripts from your existing installation.

### 2. Download Sunshine (Optional)

If you use Sunshine for game streaming:

```bash
cd ~/Desktop/linux-setup-package
wget https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-24.04-amd64.deb -O sunshine.deb
```

### 3. Identify Windows Drive UUIDs (Optional)

If you want to mount Windows drives automatically, run on the target PC:

```bash
sudo blkid
```

Note the UUIDs of your Windows (NTFS) partitions.

## Installation Instructions

### On a New PC:

1. Copy this entire `linux-setup-package` directory to your new PC's desktop

2. Open a terminal and navigate to the package:
   ```bash
   cd ~/Desktop/linux-setup-package
   ```

3. Run the installation script:
   ```bash
   ./install.sh
   ```

4. Follow the prompts:
   - Choose whether to install CUDA Toolkit and development tools
   - Enter your Samba server IP address (default: 192.168.0.3)
   - Choose whether to configure Windows drive mounts
   - Provide UUIDs if configuring Windows drives

5. After installation completes, reboot your PC

6. After reboot:
   - If you installed CUDA, verify with: `nvidia-smi` and `nvcc --version`
   - Install GNOME extensions:
   - Open "Extension Manager" from applications
   - Search for and install your preferred extensions

## Network Configuration

### Samba Shares

The script configures the following Samba shares from your server:

- `/mnt/samba/MISC-M2-4TB`
- `/mnt/samba/AI-M2-2TB`
- `/mnt/samba/T9`
- `/mnt/samba/Training`
- `/mnt/samba/Desktop` (labeled as "Server-Desktop")
- `/mnt/samba/Ubuntu-Root`

These are configured as automounts and won't block your boot process if the server is unavailable.

### Windows Drives

Optional NTFS mounts:
- `/mnt/windows/Windows-SSD`
- `/mnt/windows/Games`

These use the `nofail` option, so they won't block boot if drives are disconnected.

## GNOME Extensions Detected

Your original system had these extensions:
- **App Indicator Support** (appindicatorsupport@rgcjonas.gmail.com)
- **Dash to Dock** (dash-to-dock@micxgx.gmail.com)
- **Dash to Panel** (dash-to-panel@jderose9.github.com)
- **EasyScreenCast** (EasyScreenCast@iacopodeenosee.gmail.com)
- **Extension List** (extension-list@tu.berry)
- **Show Desktop Applet** (show-desktop-applet@valent-in)
- **Tiling Assistant** (tiling-assistant@ubuntu.com) - Ubuntu default
- **Desktop Icons NG** (ding@rastersoft.com) - Ubuntu default

Install these via Extension Manager or from https://extensions.gnome.org/

## Customization

### Adding Your Own Nemo Scripts

Place executable scripts in the `nemo-scripts/` directory before running the installer.

Common script ideas:
- Open terminal here
- Convert images
- Compress files
- Send to device
- Custom file operations

### Adding Nautilus Scripts

Place executable scripts in the `nautilus-scripts/` directory.

## Troubleshooting

### Samba Drives Not Mounting

1. Check if the server is accessible:
   ```bash
   ping 192.168.0.3
   ```

2. Verify the share names are correct:
   ```bash
   smbclient -L //192.168.0.3 -N
   ```

3. Manually trigger mount:
   ```bash
   ls /mnt/samba/Ubuntu-Root
   ```

### Windows Drives Not Mounting

1. Verify the UUID is correct:
   ```bash
   sudo blkid
   ```

2. Check fstab for errors:
   ```bash
   cat /etc/fstab
   ```

3. Try manual mount:
   ```bash
   sudo mount -a
   ```

## Package Structure

```
linux-setup-package/
├── install.sh                 # Main installation script
├── collect-scripts.sh         # Helper to collect scripts from existing PC
├── README.md                  # This file
├── nemo-scripts/             # Nemo context menu scripts
├── nautilus-scripts/         # Nautilus scripts
├── configs/                  # Additional configuration files
├── gnome-extensions/         # Extension information
└── sunshine.deb             # (Optional) Sunshine package
```

## Creating a Portable Archive

To create a tarball for easy transfer:

```bash
cd ~/Desktop
tar -czf linux-setup-package.tar.gz linux-setup-package/
```

Transfer to new PC and extract:

```bash
tar -xzf linux-setup-package.tar.gz
cd linux-setup-package
./install.sh
```

## Notes

- The script requires sudo access for system-level changes
- All mount configurations use automount/nofail to prevent boot issues
- UID/GID are hardcoded to 1000 (default for first user)
- File permissions for Samba: 0775 (rwxrwxr-x)
- The script backs up `/etc/fstab` before making changes

## Support

For issues or questions about this setup package, refer to your Claude Code chat history or the original configuration on your existing PC.
