#!/bin/bash

source variables.sh
source functions.sh

groot

check_exist_file
check_empty_file
check_read_file

z_hostname
validIP

### проверяем , есть ли атрибут "ro" в файле /proc/mounts
if [ ! "$GREP_DEV" = "" ]
then
  z_sender "ro_fs" "$GREP_DEV"
else
  z_sender "ro_fs" ""
#  echo "атрибут ro в /proc/mounts отсутствует"
fi

### проверяем пустой ли файл , если да пропускаем проверку через touch
if [ -s "z_touch.list" ]
then
### пробегаемся по всем записям в файле
  for TCH in ${ZTOUCH[@]}
  do
### проверяем , существует ли каталог , указанный в файле
    if [ -d "$TCH" ]
    then
### если каталог существует пытаемся создать в нем файл
### если недостаточно прав также выдаст ошибку
### подумать нужна ли провека пермишенов и как ее сделать
      if ! check_touch "$TCH" "$ZTCH"
      then
        BAD_TOUCH+=("$TCH/$ZTCH")
        logf "не смогли потрогать $TCH/$ZTCH"
      fi
    else
      logf "каталога $TCH не существует"
    fi
  done
  if [[ ! ${#BAD_TOUCH[@]} -eq 0 ]]
  then
    z_sender "ro_touch" "${BAD_TOUCH[*]}"
  else
    z_sender "ro_touch" ""
  fi
#else
#  echo "файл z_touch.list пустой, нечего проверять"
fi

exit 0
