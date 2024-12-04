#!/bin/bash

# Оновлення системи та встановлення необхідного пакета
sudo yum update -y
sudo yum install -y cronie

# Запуск та увімкнення crond
sudo systemctl start crond
sudo systemctl enable crond

# Створення скрипта sysinfo.sh
cat << 'EOF' > /root/sysinfo.sh
#!/bin/bash

LOG_FILE="/var/log/sysinfo"

# Збираємо інформацію
echo "-------------------------------------" >> $LOG_FILE
echo "Дата та час: $(date)" >> $LOG_FILE
echo "Системний аптайм, користувачі, навантаження CPU:" >> $LOG_FILE
w >> $LOG_FILE
echo "Використання пам'яті:" >> $LOG_FILE
free -m >> $LOG_FILE
echo "Використання дискового простору:" >> $LOG_FILE
df -h >> $LOG_FILE
echo "Відкриті TCP порти:" >> $LOG_FILE
ss -tulpn >> $LOG_FILE
echo "Перевірка зв'язку з ukr.net:" >> $LOG_FILE
ping -c1 -w1 ukr.net >> $LOG_FILE
echo "Список програм з SUID правами:" >> $LOG_FILE
find / -perm /4000 -type f 2>/dev/null >> $LOG_FILE
EOF

# Робимо скрипт виконуваним
sudo chmod +x /root/sysinfo.sh

# Налаштування cron job
echo "* * * * 1-5 root /root/sysinfo.sh" | sudo tee -a /etc/crontab

# Перезапуск crond для застосування змін
sudo systemctl restart crond
