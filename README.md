# mongodbbackup

TÜRKÇE TANIMI 
Bu script cluster yapıdaki mongodb nodelarını kontrol ederek ve master node'u bularak yedekleme yapmaktadır. Yedekleme işlemleri Qnap cihazı üzerinden mongodb cluster sunucularının birine bağlanarak mongodump komutu yardımıyla dump olarak alınmasını ve o makinadan qnap cihazında belirtilen dizine dosyaları rsync ile kopyalamaktadır. Ayrıca yedekleme ile ilgili alınan hata vb sorun varsa bildirmektedir.
Not: SSH bağlantı portu 8888 olarak belirtilmiş eğer default portu kullanıyorsanız değiştirmeniz gerekmektedir.

ENGLISH DESCRIPTION
This script makes a backup by checking the mongodb nodes in the cluster structure and finding the master node. Backup operations involve connecting to one of the MongoDB cluster servers via the Qnap device, dumping it with the help of the mongodump command, and copying the files from that machine to the specified directory on the Qnap device with rsync. It also notifies you if there are any errors or problems with the backup.
Note: The SSH connection port is specified as 8888, if you are using the default port you need to change it.