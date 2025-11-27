# Quick Start Guide

Get your new Linux PC set up in minutes!

## Prerequisites

- Fresh Ubuntu installation (24.04 or similar)
- This setup package copied to ~/Desktop/
- Network access to your Samba server (if using network drives)
- Windows drives connected (if setting up dual-boot)

## Step-by-Step Installation

### 1. Collect Your Scripts (If on Current PC)

If you're running this on your current PC with access to the old installation:

```bash
cd ~/Desktop/linux-setup-package
./collect-scripts.sh
```

Follow the prompts to gather all your Nemo and Nautilus scripts.

### 2. Download Sunshine (Optional)

If you use Sunshine for game streaming:

```bash
cd ~/Desktop/linux-setup-package
wget https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-24.04-amd64.deb -O sunshine.deb
```

### 3. Run the Installer

```bash
cd ~/Desktop/linux-setup-package
./install.sh
```

The script will:
- ✓ Update your system
- ✓ Install Nemo, Nautilus, Remmina, VLC, Extension Manager, GitHub Desktop, Claude Code CLI, VS Code, Cursor, Joplin, Flameshot, Discord, Moonlight
- ✓ Install curl and wget
- ✓ Optionally install CUDA Toolkit, gcc, cmake, htop, nvtop
- ✓ Configure Samba network drives
- ✓ Set up Windows drive mounts (if requested)
- ✓ Install all Nemo and Nautilus scripts
- ✓ Create file manager bookmarks
- ✓ Provide GNOME extension installation instructions

### 4. Answer Prompts

You'll be asked:
- Whether to install CUDA Toolkit and development tools (y/n)
- Samba server IP address (default: 192.168.0.3)
- Whether to configure Windows drives (y/n)
- UUIDs for Windows drives (if configuring)
- Whether to reboot now (y/n)

### 5. Reboot

After installation, reboot to activate all mount points:

```bash
sudo reboot
```

### 6. Install GNOME Extensions

After reboot:
1. Open "Extension Manager" from applications
2. Search and install extensions from the list
3. See `gnome-extensions/EXTENSIONS.md` for the full list

### 7. Verify Everything Works

Check that all drives are mounted:
```bash
ls /mnt/samba/
ls /mnt/windows/
```

Check file manager bookmarks - open Nemo or Nautilus and look at the sidebar.

## Creating a Portable Package

To package everything for transfer to another PC:

```bash
cd ~/Desktop/linux-setup-package
./create-archive.sh
```

This creates `linux-setup-package.tar.gz` on your desktop.

## Transfer to New PC

1. Copy `linux-setup-package.tar.gz` to new PC via USB, network, etc.

2. Extract on the new PC:
   ```bash
   cd ~/Desktop
   tar -xzf linux-setup-package.tar.gz
   cd linux-setup-package
   ```

3. Run the installer:
   ```bash
   ./install.sh
   ```

## Troubleshooting

### "Permission denied" errors
Make sure scripts are executable:
```bash
chmod +x install.sh collect-scripts.sh create-archive.sh
```

### Samba drives not accessible
Test connection to server:
```bash
ping 192.168.0.3
smbclient -L //192.168.0.3 -N
```

Trigger automount:
```bash
ls /mnt/samba/Ubuntu-Root
```

### Windows drives not mounting
Check UUIDs:
```bash
sudo blkid | grep ntfs
```

Verify fstab entries:
```bash
cat /etc/fstab
```

Try manual mount:
```bash
sudo mount -a
```

### Scripts don't appear in Nemo
Restart Nemo:
```bash
nemo -q
nemo &
```

Check scripts are executable:
```bash
ls -la ~/.local/share/nemo/scripts/
```

## What's Configured

After installation, your system will have:

**File Managers**
- Nemo with custom scripts
- Nautilus with extensions

**Applications**
- Remmina (remote desktop)
- VLC (media player)
- Extension Manager
- Sunshine (if added)

**Network Drives** (automounted)
- /mnt/samba/MISC-M2-4TB
- /mnt/samba/AI-M2-2TB
- /mnt/samba/T9
- /mnt/samba/Training
- /mnt/samba/Desktop
- /mnt/samba/Ubuntu-Root

**Windows Drives** (if configured)
- /mnt/windows/Windows-SSD
- /mnt/windows/Games

**Bookmarks**
- All network and local drives in file manager sidebar

## Next Steps

1. Configure Sunshine (if installed)
   - Run `sunshine` from applications
   - Set up PIN for pairing
   - Configure streaming settings

2. Set up Remmina connections
   - Add your RDP/VNC connections
   - Save credentials if desired

3. Customize GNOME
   - Install and configure extensions
   - Set up workspaces
   - Customize themes

4. Test all scripts
   - Right-click in Nemo to see custom scripts
   - Verify they work as expected

Enjoy your newly configured Linux PC!
