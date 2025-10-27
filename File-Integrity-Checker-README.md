# Log File Integrity Monitoring Tool

## Project Overview
This tool verifies the integrity of log files to detect tampering. It uses SHA-256 hashing to ensure that log files remain unmodified. You can initialize, check, update, and even monitor files in real time. It’s a lightweight and practical approach to enhance system security.

---

## Features
- Initialize SHA-256 hashes for files or directories.  
- Check integrity by comparing current file hashes with stored hashes.  
- Update hashes after legitimate file modifications.  
- Real-time monitoring with alerts for modified files.  
- Handles unreadable files gracefully.  
- Secure hash storage in `~/.log_hashes`.  

---

## Installation
1. Clone or copy the `integrity-check` script to your system.  
2. Make it executable:

```bash
chmod +x integrity-check
````

3. (Optional) Move to `/usr/local/bin` for global access:

```bash
sudo mv integrity-check /usr/local/bin/
```

---

## Usage

### 1. Initialize Hashes

Create initial hashes for a file or directory:

```bash
sudo ./integrity-check init /var/log
```

**Sample Output:**

```
Initializing hashes for /var/log...
Hashes stored successfully.
```

---

### 2. Check Integrity

Check if files have been modified:

```bash
sudo ./integrity-check check /var/log
```

**Sample Output:**

```
Checking integrity for /var/log...
All files are unmodified.
```

---

### 3. Update Hashes

Update a hash for a file after legitimate changes:

```bash
sudo ./integrity-check update /var/log/cloud-init.log
```

**Sample Output:**

```
Hash updated successfully for /var/log/cloud-init.log.
```

---

### 4. Real-Time Monitoring

Continuously monitor a directory for changes:

```bash
sudo ./integrity-check watch /var/log
```

**Sample Output on Modification:**

```
[ALERT] File modified: /var/log/cloud-init.log
```

* Default check interval is **10 seconds**.
* Stop monitoring with **Ctrl+C**.

---

## Notes

* Use `sudo` when accessing root-owned logs in `/var/log`.
* Skips unreadable files and prints a message.
* Hash files are stored in `~/.log_hashes` and are named by replacing `/` with `_` in the original file path.

---

## Conclusion

This tool provides a lightweight, easy-to-use solution for monitoring log file integrity. It helps detect unauthorized changes, maintain security, and can serve as the foundation for more advanced file integrity monitoring systems.

---
