### zero

Очередная реализация мониторинга файловой системы linux, перешла ли она в режим read only.
Актуально для виртуальных машин, если отвалился СХД.

В скрипте используется два метода:
  - поиск атрибутов "ro" в файле /proc/mounts,
  - попытка выполнить "touch файл".

Информация об инциденте отправляется через утилиту zabbix sender.

#### возможности

Данный скрипт имеет следующие возможности:
  - список устройств, за которыми можно следить в /proc/mounts, выделен в отдельный файл device.list,
  - отсылка на несколько серверов zabbix, сервера указываются в списке z_server.list (есть проверка на валидность),
  - имя хоста (hostname) можно:
    - указывать в файле z_hostname,
    - брать из файла zabbix_agentd.conf (если данный пакет стоит на сервере),
    - брать из /etc/hostname (если имя сервера совпадает с именем хоста в zabbix),
  - можно указывать каталоги , в которых будет осуществляться проверка через touch (если файл пустой, проверка не выполняется).

#### актуальность

Данный срипт можно выкинуть, если у вас используется zabbix версии 6.4.0alpha1 и выше.
https://support.zabbix.com/browse/ZBXNEXT-1616

### настройка

#### cron
От рута тогда используем sudo, если от пользователя без, но тогда не во всех каталогах сможет выполнить touch. Имейте это ввиду. Если скрипт выполняется не от пользователя root тогда в каталоге скрипта появляется файл I_am_Groot, и исчезает (не создается) если скрипт будет запущен от пользователя root.

sudo crontab -e

*/5 * * * * cd /path/to/script && ./z_ro.sh #>> ./cron_log 2>&1

#### zabbix элемент данных
Два элемента данных (можете назвать как вам удобно) : ro_fs и ro_touch (Zabbix траппер, Текст)

#### zabbix триггер
{ubuntu_test:ro_fs.strlen()}<>0

{ubuntu_test:ro_touch.strlen()}<>0
