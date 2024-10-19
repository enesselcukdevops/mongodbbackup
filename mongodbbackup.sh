#!/bin/bash

# SSH baglantı bilgileri
remote_user="root"
remote_host="mongoclusternode1.test.io"
remote_backup_path="/var/backup/mongo"
local_backup_path="/qnap-directory/var/backup/mongo"

# MongoDB baglantı bilgileri
host1="mongoclusternode1.test.com"
host2="mongoclusternode2.test.com"
host3="mongoclusternode2.test.com"
port="27017"
mongo_user="dbuser"
mongo_password="password"

# E-posta bilgileri

to_email="mail-to@test.com"
from_email="mail-from@test.com"
subject="Mongodb Yedekleme Raporu"

# Master node'u bulma fonksiyonu
find_master() {
    for host in $host1 $host2 $host3
    do
        is_master=$( ssh -p8888 root@mongoclusternode1.test.io "mongo --host mongoclusternode1.test.com --port 27017 --quiet --eval 'db.isMaster().ismaster'" )
        if [ "$is_master" == "true" ]; then
            echo $host
            return
        fi
    done
}

# E-posta gönderme fonksiyonu
send_email() {
    local subject=$1
    local body=$2
    echo -e "To:$to_email\nFrom:$from_email\nSubject:$subject\n\n$body" | ssmtp $to_email
}

# 15 günden eski dosyaları silme fonksiyonu
cleanup_old_backups() {
    find $remote_backup_path -type f -mtime +15 -exec rm {} \;
}

# Master node'u bul
master_host=$(find_master)
if [ -z "$master_host" ]; then
    send_email "$subject" "No master node found in the cluster."
    exit 1
fi

# Tarih ve saat ekleyerek dosya adı oluştur
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_dir="$remote_backup_path/backup_$timestamp"

# Uzak sunucuya SSH ile bağlan ve yedekleme işlemi yap
backup_result=$(ssh -p8888 $remote_user@$remote_host <<EOF
    mongodump --host $master_host --port $port --username $mongo_user --password $mongo_password --authenticationDatabase admin --out $backup_dir
    if [ \$? -eq 0 ]; then
        echo "Backup successful"
    else
        echo "Backup failed"
        exit 1
    fi
    cleanup_old_backups
EOF
)

# SSH işleminin sonucunu kontrol et ve tek bir e-posta gönder
if [[ $backup_result == *"Backup successful"* ]]; then
    rsync -avz --delete -e 'ssh -p8888'  $remote_user@$remote_host:$backup_dir $local_backup_path

    if [ $? -eq 0 ]; then
        send_email "$subject" "Backup and sync from master node $master_host was successful."
    else
        send_email "$subject" "Backup from master node $master_host was successful, but sync to QNAP failed."
    fi
else
    send_email "$subject" "Backup from master node $master_host failed."
fi

