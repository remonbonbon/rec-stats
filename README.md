# rec-stats
chinachuの状態,
usbrhの温度・湿度,
HDDのspin up状態,
CPU・SSDの温度
などを確認するための自分用Web UI

# crontab

~~~
*/10 * * * * cd ~/rec-stats && ./cron.sh >> cron.csv 2>> cron.log
~~~
