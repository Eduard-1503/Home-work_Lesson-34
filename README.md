ДЗ № 9: Пишем скрипт
Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.
Необходимая информация в письме:
- Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Ошибки веб-сервера/приложения c момента последнего запуска (данный пункт не выполнен в задании не приложен файл error.log);
- Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
- Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.

Для проверки представлен файл конфигурационный скрипт pars_acc_log.sh.
