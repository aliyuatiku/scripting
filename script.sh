#!/bin/bash
print_header() {
  echo -e "\n==================== $1 ====================\n"
}

# 1️⃣ System Information
print_header "SYSTEM INFORMATION"
echo "Hostname        : $(hostname)"
echo "OS Version      : $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
echo "Kernel Version  : $(uname -r)"
echo "Uptime          : $(uptime -p)"
echo "Load Average    : $(uptime | awk -F'load average:' '{ print $2 }')"
echo "Logged-in Users : $(who | wc -l)"
echo "Current Time    : $(date)"

# 2️⃣ CPU Usage
print_header "CPU USAGE"
# Using mpstat if available, else fallback to top
if command -v mpstat &> /dev/null; then
  mpstat | awk '/all/ {printf "User: %.1f%%, System: %.1f%%, Idle: %.1f%%, Total Usage: %.1f%%\n", $3, $5, $12, 100-$12}'
else
  cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
  cpu_usage=$(echo "100 - $cpu_idle" | bc)
  echo "Total CPU Usage: $cpu_usage%"
fi

# 3️⃣ Memory Usage
print_header "MEMORY USAGE"
free -h
echo
free | awk '/Mem:/ {
  printf("Used: %.2f GB (%.1f%%) | Free: %.2f GB (%.1f%%)\n",
  $3/1024/1024, ($3/$2)*100, $4/1024/1024, ($4/$2)*100)
}'

# 4️⃣ Disk Usage
print_header "DISK USAGE"
df -h --total | grep -E 'Filesystem|total'
echo
df -h --total | awk '/total/ {
  print "Used: "$3" | Free: "$4" | Usage: "$5
}'

# 5️⃣ Top 5 Processes by CPU Usage
print_header "TOP 5 PROCESSES BY CPU USAGE"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

# 6️⃣ Top 5 Processes by Memory Usage
print_header "TOP 5 PROCESSES BY MEMORY USAGE"
"stat.sh" 64L, 1931B    
