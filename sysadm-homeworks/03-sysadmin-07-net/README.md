[Задание](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/03-sysadmin-07-net/README.md)

---
##### 1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
Windows
- `ipconfig /all`

Linux 
- `ip link show`
- `ifconfig -a`

---
##### 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?

LLDP - Link Layer Discovery Protocol
Пакет `lldpd` необходимо установить и активировать как службу:
```shell
apt install lldpd
systemctl enable lldpd && systemctl start lldpd
```
После этого для обнаружения необходимо воспользоваться командой `lldpctl`

`lldpcli sh stat sum` покажет общую статистику по всем интерфейсам: переданные, полученные пакеты и тд.

`lldpcli sh int` покажет информацию по интерфейсам, на которых запущен lldpd.

---
##### 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.

VLAN - Virtual Local Area Network

Пакет `vlan`

Добавление vlan (deprecated):
```shell
vconfig add eth0 2
```
Добавление vlan через iproute2
```shell
ip link add link DEVNAME name VLANNAME type vlan id VLAN-ID
```
Для просмотра информации о влан-интерфейсе в команде ip link show необходимо задать ключ -d[etails]:
```shell
ip -details link show dev DEVNAME
```
Для изменения параметров влан-интерфейса используется команда ip link set, с обязательным указанием type vlan:
```shell
ip link set dev VLANNAME type vlan OPTION VALUE
```
Удаление влан-интерфейса:
```shell
ip link del VLANNAME
```
Пример конфига:
```shell
network:
  ethernets:
    enp1s0:
      dhcp4: false
      addresses:
        - 192.168.122.201/24
      gateway4: 192.168.122.1
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]

    vlans:
        enp1s0.100:
            id: 100
            link: enp1s0
            addresses: [192.168.100.2/24]
```

---
##### 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

LAG - Link Aggregation Group

В Linux - bonding. Для балансировки используется опция `mode`, которая может использовать одно из 7 значений. Посмотреть какие типы агрегации предлает bond можно в информации о модуле ядра:
```shell
# modinfo bonding | grep mode:
parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
```

Их можно разбить на две категории:

1) active-backup и broadcast обеспечивают только отказоустойчивость
2) balance-tlb, balance-alb, balance-rr, balance-xor и 802.3ad обеспечат отказоустойчивость и балансировку

Рабочие конфиги (файл /etc/network/interfaces):

active-backup на отказоустойчивость:
```shell
auto bond0
iface bond0 inet dhcp
        bond-slaves eth0 eth1
        bond-mode active-backup
        bond-miimon 100
        bond-primary eth0 eth1

```

balance-tlb, балансировка
```shell
iface bond0 inet static
address 10.0.1.5
netmask 255.255.255.0
network 10.0.1.0
gateway 10.0.1.254
bond_mode balance-tlb
bond_miimon 100
bond_downdelay 200
bond_updelay 200
slaves eth0 eth1
```

---
##### 5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24

8 IP адресов, включая адрес сети и широковещательный адрес.

В сети с маской /24 256 адресов, в сети /29 - 8. 256/8=32. То есть получить можно 32 подсети.

Примеры:
- 10.10.10.7/29
- 10.10.10.48/29
- 10.10.10.184/29
- 10.10.10.232/29

---
##### 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

Для 40-50 хостов подходит маска /26, которая вмещает 62 хоста.
Можно взять адреса из сети для CGNAT - 100.64.0.0/10
```shell
# ipcalc  -b 100.64.0.0/10 -s 50
Address:   100.64.0.0
Netmask:   255.192.0.0 = 10
Wildcard:  0.63.255.255
=>
Network:   100.64.0.0/10
HostMin:   100.64.0.1
HostMax:   100.127.255.254
Broadcast: 100.127.255.255
Hosts/Net: 4194302               Class A

1. Requested size: 50 hosts
Netmask:   255.255.255.192 = 26
Network:   100.64.0.0/26
HostMin:   100.64.0.1
HostMax:   100.64.0.62
Broadcast: 100.64.0.63
Hosts/Net: 62                    Class A

Needed size:  64 addresses.
Used network: 100.64.0.0/26
```

---
##### 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?

Проверить таблицу ARP:
- Linux: `ip neigh`, `arp -n`
- Windows: `arp -a`

Очистить ARP кеш:
- Linux: `ip neigh flush`
- Windows: `arp -d *`

Удалить один IP так:
- Linux: `ip neigh delete <IP> dev <INTERFACE>`, `arp -d <IP>`
- Windows: `arp -d <IP>`

---
##### 8. Установите эмулятор EVE-ng. Выполните задания на lldp, vlan, bonding в эмуляторе EVE-ng.

Справился только с установкой и то через боль, т.к. без vpn была ограничена скорость скачивания с репозиториев до 20 kB/s, а VMWare Workstaion Player не хотел запускать образ eve-ng рядом с WSL. В итоге на другом ПК с отключенным WSL всё запустилось нормально.