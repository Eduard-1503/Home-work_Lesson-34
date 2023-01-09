#!/bin/bash
# Обновление пакетов
yum -y update

# Установка утилиты управления программными RAID 
yum -y install mdadm smartmontools hdparm gdisk

# Зануление суперблоков
mdadm --zero-superblock --force /dev/sd{b,c,d,e}

# Создание рейда 10 из 4 дисков
mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}

# Создание директории для конфигурационного файла
mkdir /etc/mdadm

# Создание конфигурационного файла
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
# sudo sh -c "echo 'DEVICE partitions' > /etc/mdadm/mdadm.conf"
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
# sudo mdadm --detail --scan --verbose | sudo sh -c "awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf"

# Создание разделов GPT
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart part_1 ext4 0% 20%
parted /dev/md0 mkpart part_2 ext4 20% 40%
parted /dev/md0 mkpart part_3 ext4 40% 60%
parted /dev/md0 mkpart part_4 ext4 60% 80%
parted /dev/md0 mkpart part_5 ext4 80% 100%

# Создание файловых систем 
mkfs.ext4 /dev/md0p1
mkfs.ext4 /dev/md0p2
mkfs.ext4 /dev/md0p3
mkfs.ext4 /dev/md0p4
mkfs.ext4 /dev/md0p5

# Создание точек монтирования
mkdir /mnt/part_1
mkdir /mnt/part_2
mkdir /mnt/part_3
mkdir /mnt/part_4
mkdir /mnt/part_5


# Добавление разделов в vfstab
# echo "/dev/md0p1 /mnt/part_1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "/dev/md0p1 /mnt/part_1 ext4 defaults 0 0" | tee -a /etc/fstab
echo "/dev/md0p2 /mnt/part_2 ext4 defaults 0 0" | tee -a /etc/fstab
echo "/dev/md0p3 /mnt/part_3 ext4 defaults 0 0" | tee -a /etc/fstab
echo "/dev/md0p4 /mnt/part_4 ext4 defaults 0 0" | tee -a /etc/fstab
echo "/dev/md0p5 /mnt/part_5 ext4 defaults 0 0" | tee -a /etc/fstab

# Перезагрузка ВМ
shutdown -r now
