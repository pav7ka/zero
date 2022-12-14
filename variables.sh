#!/bin/bash

### имя файла для логов
LOG_FILE="zloi"
### программа отправки данных в zabbix
SENDER="/bin/zabbix_sender"
### файл который будет тачить
ZTCH="zaebix"
### массив каталогов , которые не прошли проверку
BAD_TOUCH=()
### переопределил формат даты
LOG_DATE=`date +%F_%T` #%H-%M-%ss`
### поиск атрибута "ro" в файле согласно списка девайсов
### если ошибки\пермишены все в девнул
### в дев листе один паттерн или регексп для поиска на строку
GREP_DEV=`( cat /proc/mounts | grep -s --file=device.list -s | grep -s "ro," ) 2> /dev/null`
### массив серверов из файла (один IP на строку)
readarray ZSERVERS <<< $( sed -e 's/^[ \t]*//;s/[ \t]*$//' z_server.list )
### имя хоста , которое должно совпадать с именем хоста в zabbix
### HNAME 0 читаем из файла, 1 берем из заббикс агента, 2 берем из хостнейм
HNAME="0"
ZHOSTNAME=""
ZA_FILE="/etc/zabbix/zabbix_agentd.conf"
#read -r ZHOSTNAME < z_hostname
### массив каталогов где тачить файлы (один каталог на строку)
readarray ZTOUCH <<< $( sed -e 's/^[ \t]*//;s/[ \t]*$//' z_touch.list )
