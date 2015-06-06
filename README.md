# rec-stats
chinachuの状態,
usbrhの温度・湿度,
HDDのspin up状態,
CPU・SSDの温度
などを確認するための自分用Web UI

## installation

1. Install ruby
2. `gem install bundler`
3. `bundle install --path vendor/bundler`
4. `bundle exec thin start` or `./start.sh` 

## crontab

~~~
*/10 * * * * cd ~/rec-stats && ./cron.sh >> cron.csv 2>> cron.log
~~~
