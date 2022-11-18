#!/bin/bash

source variables.sh

### функция логирования
logf() {
  ( echo -e "=====\n"$LOG_DATE"\n"$1"\n=====\n" >> $LOG_FILE )  2>/dev/null
}

### функция проверки существования файла
exist_file() {
  if [ ! -f "$1" ]
  then
    logf "необходимый файл $1 отсутствует"
    touch "$1" > /dev/null 2>&1
    exit 1
  fi
}

### функция проверки пустой ли файл
empty_file() {
  if [ ! -s "$1" ]
  then
    logf "файл $1 пустой"
    exit 1
  fi
}

### функция проверки чтения файла
read_file() {
  if [ ! -r "$1" ]
  then
    logf "файл $1 не читается"
    exit 1
  fi
}

### проверяем сущуствуют ли конфигурационные файлы
check_exist_file() {
#  exist_file $SENDER && \
  exist_file "device.list" && \
  exist_file "z_server.list" && \
  exist_file "z_hostname" && \
  exist_file "z_touch.list"
}

### проверяем пустые ли конфигурационные файлы
check_empty_file() {
  empty_file "device.list" && \
  empty_file "z_server.list" && \
  empty_file "z_hostname" #&& \
#  empty_file "z_touch.file"
}

### проверяем можем ли прочитать данные из файлов
check_read_file() {
  read_file "device.list" && \
  read_file "z_server.list" && \
  read_file "z_hostname" && \
  read_file "z_touch.list"
}

### функция создания файла , тихая , ошибки в девнул
check_touch() {
  touch $1/$2 > /dev/null 2>&1 && rm $1/$2 > /dev/null 2>&1
}

### функция отправки в zabbix 
z_sender() {
  for SRV in ${ZSERVERS[@]}
  do
#    $SENDER -z $SRV -s $ZHOSTNAME -k "$1" -o "$2"
    echo "-z $SRV -s $ZHOSTNAME -k "$1" -o "$2"" # "$GRP""
  done
}
