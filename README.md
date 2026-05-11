# Ubuntu Setup

A bash script to set up an Ubuntu machine with custom configurations.

## Usage

```bash
./ubuntu-setup.sh [OPTIONS]
  -c    Clean log directory
  -i    Setup option: init|rsnap|rtel|secure|dev|media|apps|shell|xfce|display-settings|all (required)
  -h    Show this help message
```

### Options

- `-c` - Clean log files from the `log/` directory
- `-i init` - Updates apt, creates keyrings directory
- `-i rsnap` - Completely removes Snap (stops/masks services, purges, holds package)
- `-i rtel` - Blocks telemetry sites in `/etc/hosts`, purges telemetry packages
- `-i secure` - Enables UFW firewall
- `-i dev` - Installs dev tools: Docker, VS Code, Java 21/25, Git, Kitty, Vim, Flatpak, SSH key setup
- `-i media` - FFmpeg, GIMP, Audacity, VLC
- `-i apps` - Firefox (Mozilla repo), Brave, Thunderbird, Steam
- `-i shell` - Installs Fish shell as default
- `-i xfce` - XFCE desktop environment
- `-i display-settings` - Dark mode, sets desktop background
- `-i all` - Run all setup options (in order: init → rsnap → rtel → secure → dev → media → apps → shell → display-settings)
- `-h` - Show help message

### Examples

```bash
# Show help
./ubuntu-setup.sh -h

# Run all setups
./ubuntu-setup.sh -i all

# Set up only development environment
./ubuntu-setup.sh -i dev

# Remove snap and set up dev environment
./ubuntu-setup.sh -i rsnap
./ubuntu-setup.sh -i dev

# Remove telemetry services
./ubuntu-setup.sh -i rtel

# Set up multiple specific options
./ubuntu-setup.sh -i init
./ubuntu-setup.sh -i secure
./ubuntu-setup.sh -i shell
./ubuntu-setup.sh -i xfce

# Clean log files
./ubuntu-setup.sh -c
```

## Prerequisites

Before running the setup, place your files in the following directories:

- **SSH keys**: Place your SSH private keys in the `keys/` directory. These will be copied to `~/.ssh/` during the `dev` setup.
- **Desktop background**: Place your background image in `images/` (default: `linux-desktop.jpg`). Used by the `display-settings` option.

## Adding New Setup Options

To add a new setup option:

1. Add a function named `install_<name>` in `ubuntu-setup.sh`:
   ```bash
   install_foo() {
       log "Setting up foo.."
       log "  - Installing foo tools"
   }
   ```

2. Add to the `SETUP_OPTIONS` associative array:
   ```bash
   declare -A SETUP_OPTIONS=(
       ["dev"]="install_dev"
       ["foo"]="install_foo"
   )
   ```

3. Add to the `SETUP_ORDER` array to control execution order:
   ```bash
   SETUP_ORDER=(init secure dev foo media apps shell xfce display-settings)
   ```

## Log Files

Log files are stored in `log/` with timestamp format: `ubuntu-setup-DD-MM-YYYY--HH-MM-SS.log`

Use `./ubuntu-setup.sh -c` to clean old log files.
