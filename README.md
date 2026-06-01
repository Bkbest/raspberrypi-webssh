# WebSSH Deployment

WebSSH is a web-based SSH client that allows you to access your Raspberry Pi (or any Linux server) via a web browser.

## Requirements

- Raspberry Pi or Linux server
- SSH access to the server
- sudo privileges

## Installation

1. Upload the files to your server:
   - `deploy.sh`
   - `webssh.conf`

2. Edit `webssh.conf` and set your password:
   ```json
   {
       "address": "0.0.0.0",
       "port": 8888,
       "credential": "bkbest21:your_password_here",
       "debug": true
   }
   ```

3. Make the script executable and run it:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## Usage

After installation, open your browser and navigate to:

```
http://<server-ip>:8888
```

Example:
```
http://192.168.1.100:8888
```

Enter the credentials from your `webssh.conf` to connect.

## Service Management

```bash
# Check status
sudo systemctl status webssh

# View logs
sudo journalctl -u webssh -f

# Restart
sudo systemctl restart webssh

# Stop
sudo systemctl stop webssh

# Start
sudo systemctl start webssh
```

## Configuration

Edit these variables in `deploy.sh` before running:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVICE_NAME` | webssh | Service name |
| `RUN_USER` | bkbest21 | User to run the service |
| `PORT` | 8888 | WebSSH port |
| `CONFIG_FILE` | /home/{RUN_USER}/webssh.conf | Config file location |

## Security Notes

- Change the default password in `webssh.conf`
- Consider using HTTPS (SSL) for production
- Restrict access via firewall if needed
