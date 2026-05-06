# Ubuntu Setup

A bash script to set up an Ubuntu machine with custom configurations.

## Usage

```bash
./ubuntu-setup.sh [OPTIONS]
  -c    Clean log directory
  -i    Setup option: dev|web|media|apps|all (default: all)
  -h    Show this help message
```

### Options

- `-c` - Clean log files from the `log/` directory
- `-i dev` - Set up development environment (build tools, Git, Python, Node.js, Docker, VS Code)
- `-i web` - Set up web server (Apache/Nginx, PHP, MySQL/MariaDB)
- `-i media` - Set up media tools (FFmpeg, GIMP, Blender, Audacity)
- `-i apps` - Set up applications (Slack, Discord, Chrome, Spotify)
- `-i all` - Run all setup options (default)
- `-h` - Show help message

### Examples

```bash
# Show help
./ubuntu-setup.sh -h

# Run all setups (default)
./ubuntu-setup.sh

# Set up only development environment
./ubuntu-setup.sh -i dev

# Set up web and media
./ubuntu-setup.sh -i web
./ubuntu-setup.sh -i media

# Clean log files
./ubuntu-setup.sh -c
```

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
       ["web"]="install_web"
       ["foo"]="install_foo"
   )
   ```

## Pushing to GitHub

```bash
# Create a new repository on GitHub, then:
git remote add origin https://github.com/<username>/<repo>.git
git branch -M main
git push -u origin main
```

## Log Files

Log files are stored in `log/` with timestamp format: `ubuntu-setup-DD-MM-YYYY--HH-MM-SS.log`

Use `./ubuntu-setup.sh -c` to clean old log files.