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
#  exist_file "z_hostname" && \
  exist_file "z_touch.list"
}

### проверяем пустые ли конфигурационные файлы
check_empty_file() {
  empty_file "device.list" && \
  empty_file "z_server.list" # && \
#  empty_file "z_hostname" #&& \
#  empty_file "z_touch.file"
}

### проверяем можем ли прочитать данные из файлов
check_read_file() {
  read_file "device.list" && \
  read_file "z_server.list" && \
#  read_file "z_hostname" && \
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

### ZHOSTNAME
z_hostname() {
  case "$HNAME" in
### читаем из файла
  0 )
    if exist_file "z_hostname" && empty_file "z_hostname" && read_file "z_hostname"
    then
      ZHOSTNAME=$( head -n1 z_hostname | sed -e 's/^[ \t]*//;s/[ \t]*$//' )
    else
      logf "HNAME указан '0' но чтото пошлое не так"
      exit 1
    fi
  ;;
### берем из заббикс агента
  1 )
    if exist_file "$ZA_FILE" && read_file "$ZA_FILE"
    then
      ### -i grep специально не ставил , убираем (на всякий случай) в начале и в конце пробелы табуляцию
      ZHOSTNAME=$( cat $ZA_FILE | grep "Hostname=" | grep -v "^#" | awk -F "=" '{print $2}' | sed -e 's/^[ \t]*//;s/[ \t]*$//' )
      if [ "$ZHOSTNAME" = "" ]
      then
        logf "имя хоста пустое в файле $ZA_FILE"
        exit 1
      fi
    else
      logf "чтото пошло не так с чтением имени хоста из конфига заббикс агента\nнадеюсь, до выполнения этого кода не дойдет выполнение >_< =D"
    fi
  ;;
### hostname
  2 )
    ZHOSTNAME=`hostname`
    if [ "$ZHOSTNAME" = "" ]
    then
      logf "имя хоста пустое в файле /etc/hostname"
      exit 1
    fi
  ;;
### какая то хрень
  * )
    logf "недопустимое значение переменной HNAME"
    exit 1
  ;;
  esac
}

### validIP
validIP() {
  if exist_file "z_server.list" && empty_file "z_server.list" && read_file "z_server.list"
  then
    for SRV in ${ZSERVERS[@]}
    do
      readarray -td "." ZS <<< $SRV
      if ! [[ $SRV =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ && ${ZS[0]} -le 255 && ${ZS[1]} -le 255 && ${ZS[2]} -le 255 && ${ZS[3]} -le 255 ]]
      then
        logf "ip $SRV неправильный"
        exit 1
#      else
#        echo "ip $SRV правильный"
      fi
    done
  fi
}