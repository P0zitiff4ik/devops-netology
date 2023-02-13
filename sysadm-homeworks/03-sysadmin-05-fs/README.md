[Задание](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/03-sysadmin-05-fs/README.md)

---
##### 1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/Разрежённый_файл) (разряженных) файлах.
Разрежённый файл (sparse file) - это файл, в котором есть пустые участки, но в них не содержатся заполняющие их нулевые байты. При этом информация о данных участках пишется в метаданные файловой системы. Такие участки называются дырами (holes) и не занимают физического места на диске. Данная особенность может быть полезна, когда используется большой по размеру файл с большим к-вом нулей. В Википедии приводятся в пример образы дисков ВМ и резервные копии дисков. Также как пример - загрузка файлов через протокол BitTorrent, когда сначала создаётся пустой разреженный файл, а потом в процессе загрузки он заполняется скачанной информацией.  

Источники: Википедия и Stackoverflow

---
##### 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?
Нет, потому что хардлинк является по сути отражением исходного файла, а точнее inode, с которой он связан. Изменение содержимого, а также прав и владельца одного хардлинка повлечёт за собой изменение и всех других жёстких ссылок. 

Источники: лекция, man и Википедия

---
##### 3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile
Уничтожил текущий конфиг, забекапил и заменил vagrantfile. Запустил инстанс, новое имя машины sysadm-fs 

----
##### 4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
```shell
root@sysadm-fs:~# fdisk /dev/sdb
  n
  p
  1
  
  +2G
  n
  p
  2
  
  
  w
```
```shell
root@sysadm-fs:~# fdisk -l /dev/sdb
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x76559661

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux
```

---
##### 5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.

```shell
sfdisk -d /dev/sdb | sfdisk /dev/sdc
```

---
##### 6. Соберите mdadm RAID1 на паре разделов 2 Гб.

```shell
root@sysadm-fs:~# mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
```

---
##### 7. Соберите mdadm RAID0 на второй паре маленьких разделов.

```shell
mdadm --create --verbose /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
```

---
##### 8. Создайте 2 независимых PV на получившихся md-устройствах.

```shell
root@sysadm-fs:~# pvcreate /dev/md0
root@sysadm-fs:~# pvcreate /dev/md1
```

---
##### 9. Создайте общую volume-group на этих двух PV.

```shell
root@sysadm-fs:~# vgcreate test_vg /dev/md0 /dev/md1
```

---
##### 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

```shell
root@sysadm-fs:~# lvcreate -L 100M -n test_lv test_vg /dev/md1
```

---
##### 11. Создайте mkfs.ext4 ФС на получившемся LV.

```shell
mkfs.ext4 /dev/test_vg/test_lv
```

---
##### 12. Смонтируйте этот раздел в любую директорию, например, /tmp/new.

```shell
root@sysadm-fs:~# mkdir /tmp/new
root@sysadm-fs:~# mount /dev/test_vg/test_lv /tmp/new
```

---
##### 13. Поместите туда тестовый файл.

```shell
wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
```

---
##### 14.Прикрепите вывод `lsblk`

```shell
root@sysadm-fs:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 61.9M  1 loop  /snap/core20/1328
loop1                       7:1    0 63.3M  1 loop  /snap/core20/1778
loop2                       7:2    0 67.2M  1 loop  /snap/lxd/21835
loop3                       7:3    0 91.9M  1 loop  /snap/lxd/24061
loop4                       7:4    0 49.6M  1 loop  /snap/snapd/17883
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part  /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─test_vg-test_lv     253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─test_vg-test_lv     253:1    0  100M  0 lvm   /tmp/new
```

---
##### 15. Протестируйте целостность файла

```shell
root@sysadm-fs:~# gzip -t /tmp/new/test.gz
root@sysadm-fs:~# echo $?
0
```

---
##### 16. Используя `pvmove`, переместите содержимое PV с RAID0 на RAID1

```shell
root@sysadm-fs:~# pvmove /dev/md1 /dev/md0
```

---
##### 17. Сделайте --fail на устройство в вашем RAID1 md.

```shell
root@sysadm-fs:~# mdadm --fail /dev/md0 /dev/sdc1
```

---
##### 18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

```shell
[ 2729.474042] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[ 2729.474049] ext4 filesystem being mounted at /tmp/new supports timestamps until 2038 (0x7fffffff)
[ 3835.681666] md/raid1:md0: Disk failure on sdc1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

---
##### 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

```shell
root@sysadm-fs:~# gzip -t /tmp/new/test.gz
root@sysadm-fs:~# echo $?
0
```

---
##### 20. Погасите тестовый хост

```commandline
C:\Users\***\Vagrant>vagrant destroy
```