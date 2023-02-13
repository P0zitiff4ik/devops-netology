# Домашнее задание к занятию «2.4. Инструменты Git»  
  
### 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.  
>	$ git show -s aefea

commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545

Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>

Date:   Thu Jun 18 10:29:58 2020 -0400

   Update CHANGELOG.md

  
### 2. Какому тегу соответствует коммит `85024d3`?  
>	$ git show -s 85024d3

commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)

Author: tf-release-bot <terraform@hashicorp.com>

Date:   Thu Mar 5 20:56:10 2020 +0000

   v0.12.23


### 3.  Сколько родителей у коммита `b8d720`? Напишите их хеши.
2 родителя:
>	$ git show -s --pretty=format:"%P" b8d720

56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b


### 4.  Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.
>	$ git log v0.12.23...v0.12.24 --oneline

33ff1c03b (tag: v0.12.24) v0.12.24

b14b74c49 [Website] vmc provider links

3f235065b Update CHANGELOG.md

6ae64e247 registry: Fix panic when server is unreachable

5c619ca1b website: Remove links to the getting started guide's old location

06275647e Update CHANGELOG.md

d5f9411f5 command: Fix bug when using terraform login on Windows

4b6d06cc5 Update CHANGELOG.md

dd01a3507 Update CHANGELOG.md

225466bc3 Cleanup after v0.12.23 release


### 5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточего перечислены аргументы).
>	$ git log -SproviderSource --oneline

5e06e39fc Use registry alias to fetch providers

***! Определение функции в описании вопроса выглядит некорректно. Необходимо изменить задание! Вот все совпадения:***
>	$ git grep --heading -n -p providerSource

plugin/discovery/get.go

110=func (i *ProviderInstaller) Get(provider addrs.Provider, req Constraints) (PluginMeta, tfdiags.Diagnostics, error) {

156:    providerSource := allVersions.ID

207:    downloadURLs, err := i.listProviderDownloadURLs(providerSource, versionMeta.Version)

235:    printedProviderName := fmt.Sprintf("%q (%s)", provider.LegacyString(), providerSource)


### 6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`
**Определяем файлы, в которых есть эта функция:**

> $ git grep --heading -n -p "func globalPluginDirs("

plugins.go

3=import (

16:func globalPluginDirs() []string {

**Теперь выполняем поиск коммитов, в которых изменялся файл *plugins.go***

>	$ git log -L :globalPluginDirs:plugins.go -s --pretty=oneline

* 52dbf94834cb970b510f2fba853a5b49ad9b1a46 keep .terraform.d/plugins for discovery
* 41ab0aef7a0fe030e84018973a64135b11abcd70 Add missing OS_ARCH dir to global plugin paths
* 66ebff90cdfaa6938f26f908c7ebad8d547fea17 move some more plugin search path logic to command
* 8364383c359a6b738a436d1b7745ccdce178df47 Push plugin discovery down into command package


### 7. Кто автор функции `synchronizedWriters`?
Martin Atkins
>	$ git log -S "func synchronizedWriters(" --pretty="%h - %an, %ar: %s"

5ac311e2a - Martin Atkins, 5 лет назад: main: synchronize writes to VT100-faker on Windows
