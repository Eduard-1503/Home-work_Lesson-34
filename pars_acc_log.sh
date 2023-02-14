#!/bin/bash
# clear
# set -x

# Создаю переменные
    # Переменная для запуска утилиты отправки почтового сообщения
mailcmd="/usr/bin/mail"
    # Заголовок почтового сообщения
email_subject="Server statistics"
    # Путь к файлу в который собираю информации, которая в дальнейшем будет передана почтовым сообщением 
email="email.txt"
    # Адрес на который отправляю почтовое сообщение
adr="baded@mail.ru"
    # Путь к access.log
access="access-4560-644067.log"
# echo $access
    # Путь к error.log
error="error-4560-644067.log"
    # Вычисляю имя данного скрипта
script=`echo $0 | sed -r 's/.{,2}//'`


# Функция сбора данных статистики для email при первом запуске скрипта или повторном запуске в случаях отсутствия или 
# повреждения (отсутствия в файле email.txt данных о последнем старте) файла со статистикой сформированного предыдущим запуском
function first_start {

    # Дату/время последней строки в файле access.log текущего старта 
    DATA=`cat $access | tail -n1 | awk '{print $4}' | sed 's/^.//'`


    I=3
    i=1
    echo $DATA > $email
    echo "" >> $email
    echo "Топ "$I" IP адресов по колличеству запросов" >> $email

    while (( $i <= $I ))
    do
        IP=`cat $access | awk '{print $1}' | sort -n | uniq -c | sort -nr | awk '{print $2}' | head -n$i | tail -n1`
        COL_IP=`cat $access | awk '{print $1}' | sort -n | uniq -c | sort -nr | awk '{print $1}' | head -n$i | tail -n1`
        RES_IP="С ip адреса "$IP" - "$COL_IP"."
        echo $RES_IP >> $email
        i=`expr $i + 1`
    done


    I=3
    i=1

    echo "" >> $email
    echo "Топ "$I" запрашиваемых URL-адресов по колличеству запросов" >> $email

    while (( $i <= $I ))
    do
        URL=`cat $access | grep GET | awk '{print $11}' | grep -wv - | sort | uniq -c | sort -nr | awk '{print $2}' | head -n$i | tail -n1`
        COL_URL=`cat $access | grep GET | awk '{print $11}' | grep -wv - | sort | uniq -c | sort -nr | awk '{print $1}' | head -n$i | tail -n1`
        RES_URL="URL-адрес "$URL" - "$COL_URL"."
        echo $RES_URL >> $email
        i=`expr $i + 1`
    done


    I=`cat $access | grep POST | awk '{print $9}' | sort -n | uniq -c | wc -l`
    i=1

    echo "" >> $email
    echo "Список всех кодов HTTP ответа с указанием их кол-ва" >> $email

    while (( $i <= $I ))
    do
        COD=`cat $access | grep POST | awk '{print $9}' | sort -n | uniq -c | awk '{print $2}' | head -n$i | tail -n1`
        COL_COD=`cat $access | grep POST | awk '{print $9}' | sort -n | uniq -c | awk '{print $1}' | head -n$i | tail -n1`
        RES_COD="Кодов HTTP ответа "$COD" - "$COL_COD"."
        echo $RES_COD >> $email
        i=`expr $i + 1`
    done

    cat $email | $mailcmd -s $email_subject $adr

}

# Функция сбора данных статистики для email при повторном запуске скрипта
function second_start {

    # Вычисляю дату/время последнего старта скрипта. берется из файла с данными на отправку
    DATA_LS=`head -n1 $email`
    # Вычисляем номер последней обработанной строки в файле access.log на предыдущем старте
    NSTR_LS=`cat $access | grep -n $DATA_LS | tail -n1 | awk '{print $1}' | sed 's/:/ /' | awk '{print $1}'`
    # Дату/время последней строки в файле access.log текущего старта 
    DATA=`cat $access | tail -n1 | awk '{print $4}' | sed 's/^.//'`


    I=3
    i=1
    echo $DATA > $email
    echo "" >> $email
    echo "Топ "$I" IP адресов по колличеству запросов" >> $email

    while (( $i <= $I ))
    do
        IP=`cat $access | tail -n$NSTR_LS | awk '{print $1}' | sort -n | uniq -c | sort -nr | awk '{print $2}' | head -n$i | tail -n1`
        COL_IP=`cat $access | tail -n$NSTR_LS | awk '{print $1}' | sort -n | uniq -c | sort -nr | awk '{print $1}' | head -n$i | tail -n1`
        RES_IP="С ip адреса "$IP" - "$COL_IP"."
        echo $RES_IP >> $email
        i=`expr $i + 1`
    done


    I=3
    i=1

    echo "" >> $email
    echo "Топ "$I" запрашиваемых URL-адресов по колличеству запросов" >> $email

    while (( $i <= $I ))
    do
        URL=`cat $access | tail -n$NSTR_LS | grep GET | awk '{print $11}' | grep -wv - | sort | uniq -c | sort -nr | awk '{print $2}' | head -n$i | tail -n1`
        COL_URL=`cat $access | tail -n$NSTR_LS | grep GET | awk '{print $11}' | grep -wv - | sort | uniq -c | sort -nr | awk '{print $1}' | head -n$i | tail -n1`
        RES_URL="URL-адрес "$URL" - "$COL_URL"."
        echo $RES_URL >> $email
        i=`expr $i + 1`
    done


    echo "" >> $email
    echo "Список всех кодов HTTP ответа с указанием их кол-ва" >> $email

    while (( $i <= $I ))
    do
        COD=`cat $access | tail -n$NSTR_LS | grep POST | awk '{print $9}' | sort -n | uniq -c | awk '{print $2}' | head -n$i | tail -n1`
        COL_COD=`cat $access | tail -n$NSTR_LS | grep POST | awk '{print $9}' | sort -n | uniq -c | awk '{print $1}' | head -n$i | tail -n1`
        RES_COD="Кодов HTTP ответа "$COD" - "$COL_COD"."
        echo $RES_COD >> $email
        i=`expr $i + 1`
    done

    cat $email | $mailcmd -s $email_subject $adr

}


# Т.к. при запуске скрипта создается один процесс непосредственно сам запущенный скрипт
# и еще один (дочерний) процесс - исполнение одной из утилит используемых в скрипте (в этом конкретном случае "TRU=`ps -a | grep $script | head | wc -l`"),
# принимаю за ключевое значение при проверке одновременный запуск нескольких копий скрипта, 3 и более процессов.

# Вычисляю имя данного скрипта
script=`echo $0 | sed -r 's/.{,2}//'`
# Вычисляю количество процессов запущенных от имени данного скрипта
TRU=`ps -a | grep $script | head | wc -l`

# Если процессов менее 3-х считаю, что предыдущий запуск скрипта завершен
# и по условию задания мы можен выполнить очередной запус
if (( $TRU < 3 ))
then

    if test -f $email
    then
        DATA_LS=`head -n1 $email`
        FSTR=`head -n1 $email | awk '/^[0-9]?[0-9][/][A-Z][a-z][a-z][/][0-9][0-9][0-9][0-9][:][0-9][0-9][:][0-9][0-9]/'`
        if [[ "$DATA_LS" == "$FSTR" ]]
        then
            second_start
        else
            first_start
        fi

    else
        first_start
    fi

else
    echo "Скрипт уже запущен. Дождитесь окончания выполнения скрипта."

fi

exit 0
