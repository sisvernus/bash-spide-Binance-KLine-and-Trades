darwin=$(uname -a|grep Darwin)
linux=$(uname -a|grep Linux)
if [[ $darwin != "" ]]; then
day=$(date -v -2d '+%Y%m%d')
fi
if [[ $linux != "" ]]; then
day=$(date -d '2 days ago' '+%Y%m%d')
fi
echo $day
bash ./spider.trades.binance.sh $day 0
bash ./spider.klines.binance.sh $day 0