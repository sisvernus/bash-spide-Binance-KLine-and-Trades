# /bin/sh
# example:  sh spider.tick.binance.sh 20200909 0

all_assets=(BTC LTC ETH)
THE_USER=spider-api
THE_PWD=123456
THE_DB=spider
THE_HOST=127.0.0.1
THE_TABLE=spider_trade
PSQL=psql

dir=./binance_data
[ -d $dir ] || mkdir $dir

init_date=$1
init_count=$2

i=0
sha_url='https://data.binance.vision/data/futures/um/daily/trades/BTCUSDT/BTCUSDT-trades-2023-01-09.zip.CHECKSUM'
zip_url='https://data.binance.vision/data/futures/um/daily/trades/BTCUSDT/BTCUSDT-trades-2023-01-09.zip'
while [ $i -le $init_count ]
do
    darwin=$(uname -a|grep Darwin)
    linux=$(uname -a|grep Linux)
    if [[ $darwin != "" ]]; then
    day=$(eval "date -v -"$i"d -jf "%Y%m%d" $init_date +'%Y-%m-%d'")
    fi
    if [[ $linux != "" ]]; then
    day=$(eval 'date -d "$init_date $i days ago"  "+%Y-%m-%d"')
    fi
    echo $day
    for asset in ${all_assets[@]}; do
    u1=$(echo $sha_url| sed -e "s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/$day/g"| sed -e "s/BTCUSDT/${asset}USDT/g")
    u2=$(echo $zip_url| sed -e "s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/$day/g"| sed -e "s/BTCUSDT/${asset}USDT/g")
    file=$dir/$(basename $u2)
    exists=$(ls $dir|grep trades|grep $day|grep $asset)
    if [[ $exists == "" ]]; then
        sha=$(curl $u1)
        aria2c -x 5 $u2 -d $dir
        sha256_str=${sha% *}
        shafile=${sha#*  }
        sha256=$(openssl dgst -sha256 $file)
        sha256=${sha256#*= }
        if [ $sha256_str == "$sha256" ]; then
            unzip -n $file -d $dir
            rm -f $file
            csv=${file%.zip*}.csv
            echo $csv
            awk  -F, '
{
    if (NR == 1) {
        print "id","tick","price","base_asset","quote_asset"
    } else {
        if (last != $2 && p[last]>0) {
            delete p[last];            
        }
        if (p[$2]++==0) {
            print $1,$5,$2,"'$asset'","USDT"
            
        }
        last=$2
        
    }
}

' $csv > $csv".1"


            THE_FILE=$csv".1"
PGPASSWORD=$THE_PWD ${PSQL} -h $THE_HOST -U ${THE_USER} ${THE_DB} <<OMG
\COPY ${THE_TABLE} FROM '${THE_FILE}' delimiter ' ' csv HEADER;
OMG
            rm -f $THE_FILE
        else
            echo "wrong sha256"
            echo "sha256_str:"$sha256_str
            echo $sha256
            rm -f $file
        fi
    fi
    done
    ((i=i+1))
done