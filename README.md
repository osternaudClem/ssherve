# 🐚 ssherve

**Interactive SSH connection manager — select a server from a list, and connect instantly.**

Ssherve is a lightweight, user-friendly CLI tool that lets you manage and connect to your SSH servers through a beautiful interactive menu powered by `fzf`. No more memorizing IPs, ports, or usernames!

## [![Release ssherve](https://github.com/osternaudClem/ssherve/actions/workflows/release.yml/badge.svg)](https://github.com/osternaudClem/ssherve/actions/workflows/release.yml)

## ✨ Features

- 🎯 **Interactive selection** with fuzzy search (powered by `fzf`)
- 🔐 **SSH key support** — use different identity files per server
- ⚙️ **Custom ports** — easily manage non-standard SSH ports
- 📝 **JSON configuration** — simple and human-readable
- 🎨 **Beautiful UI** — clean, modern interface with colors
- 🚀 **Fast installation** — one command to get started

---

## 🚀 Installation

```bash
curl -fsSL https://raw.githubusercontent.com/cl3tus/ssherve/main/install.sh | bash
```

This will:

- Install required dependencies (`jq`, `fzf`)
- Download the `ssherve` script to `/usr/local/bin`
- Create a config directory at `~/.config/ssherve`
- Generate an example configuration file

---

## 📦 Dependencies

The installer will automatically handle dependencies, but you can also install them manually:

- **jq** — JSON processor
- **fzf** — Fuzzy finder for the terminal

### macOS

```bash
brew install jq fzf
```

### Ubuntu/Debian

```bash
sudo apt install jq fzf
```

### Arch Linux

```bash
sudo pacman -S jq fzf
```

---

## 🎮 Usage

Simply run:

```bash
ssherve
```

This will open an interactive menu where you can:

- Navigate with arrow keys or fuzzy search
- Press `Enter` to connect
- Press `Esc` or `Ctrl+C` to cancel

---

## ⚙️ Configuration

The configuration file is located at `~/.config/ssherve/servers.json`.

### Example Configuration

```json
{
  "servers": [
    {
      "name": "Production Server",
      "ip": "192.168.1.10",
      "user": "admin",
      "port": 22
    },
    {
      "name": "Staging Database",
      "ip": "198.51.100.5",
      "user": "dbuser",
      "port": 2222,
      "identity": "~/.ssh/staging_key"
    },
    {
      "name": "Bastion Host",
      "ip": "203.0.113.1",
      "user": "ubuntu"
    }
  ]
}
```

### Configuration Fields

| Field      | Required | Default | Description                            |
| ---------- | -------- | ------- | -------------------------------------- |
| `name`     | ✅ Yes   | —       | Display name for the server            |
| `ip`       | ✅ Yes   | —       | IP address or hostname                 |
| `user`     | ❌ No    | —       | SSH username                           |
| `port`     | ❌ No    | `22`    | SSH port                               |
| `identity` | ❌ No    | —       | Path to SSH private key (supports `~`) |

---

## 🔧 Manual Installation

If you prefer to install manually:

1. **Clone or download the script:**

   ```bash
   curl -fsSL https://raw.githubusercontent.com/cl3tus/ssherve/main/ssherve.sh -o ssherve
   ```

2. **Make it executable:**

   ```bash
   chmod +x ssherve
   ```

3. **Move to a directory in your PATH:**

   ```bash
   sudo mv ssherve /usr/local/bin/
   ```

4. **Create the config directory:**

   ```bash
   mkdir -p ~/.config/ssherve
   ```

5. **Create your servers.json file:**
   ```bash
   nano ~/.config/ssherve/servers.json
   ```

---

## 📸 Screenshot

## !! SHOW SCREENSHOT

## 🛠️ Troubleshooting

### Config file not found

If you see "Config not found", the script will automatically create an example configuration at `~/.config/ssherve/servers.json`. Edit this file to add your servers.

### Dependencies missing

Make sure `jq` and `fzf` are installed:

```bash
command -v jq && command -v fzf
```

### Permission denied

If you get permission errors, ensure the script is executable:

```bash
chmod +x /usr/local/bin/ssherve
```

---

## 📝 License

MIT License - feel free to use and modify as you wish!

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

---

## 💡 Tips

- Use descriptive names for your servers to make them easier to find
- Take advantage of fuzzy search — just type part of the server name
- You can have multiple identity files for different servers
- The config file supports `~` for home directory expansion

---

**Made with ❤️ by cl3tus**
