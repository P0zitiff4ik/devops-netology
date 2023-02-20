[Задание](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/04-script-03-yaml/README.md)

------

## Задание 1

Мы выгрузили JSON, который получили через API запрос к нашему сервису:

```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

### Ваш скрипт:
```json
    {
        "info" : "Sample JSON output from our service",
        "elements" :[
            {
                "name" : "first",
                "type" : "server",
                "ip" : 7175
            },
            {
                "name" : "second",
                "type" : "proxy",
                "ip" : "71.78.22.43"
            }
        ]
    }
```

---

## Задание 2

В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time
import yaml
import json

hosts = {'mail.ru':'94.100.180.200', 'vk.com':'87.240.137.164', 'yandex.ru':'5.255.255.5'}
while True:
    for host, ip in hosts.items():
        newip = socket.gethostbyname(host) 
        if newip != ip:
            print(f'[ERROR] {host} IP mismatch: {ip} {newip}')
            hosts[host] = newip
        else:
            print(f'{host} - {ip}')
            with open ('hostip.yaml', 'w') as ym:
                ym.write(yaml.dump(hosts, explicit_start=True, explicit_end=True))
            with open ('hostip.json', 'w') as js:
                js.write(json.dumps(hosts, indent=2))
    time.sleep(2)


```

### Вывод скрипта при запуске при тестировании:
```bash
$  /usr/bin/env /bin/python3 /home/user/.vscode-server/extensions/ms-python.python-2023.2.0/pythonFiles/lib/python/debugpy/adapter/../../debugpy/launcher 49529 -- /home/user/1.py 
[ERROR] mail.ru IP mismatch: 94.100.180.200 217.69.139.200
[ERROR] vk.com IP mismatch: 87.240.137.164 87.240.129.133
[ERROR] yandex.ru IP mismatch: 5.255.255.5 5.255.255.77
mail.ru - 217.69.139.200
vk.com - 87.240.129.133
yandex.ru - 5.255.255.77
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{
  "mail.ru": "217.69.139.200",
  "vk.com": "87.240.129.133",
  "yandex.ru": "5.255.255.77"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
mail.ru: 217.69.139.200
vk.com: 87.240.129.133
yandex.ru: 5.255.255.77
...

```

---

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
???
```

### Пример работы скрипта:
???