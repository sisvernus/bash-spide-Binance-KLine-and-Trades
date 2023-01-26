# Postgres表结构

建数据库、表结构
```

CREATE USER "spider-api" WITH PASSWORD '123456';
CREATE DATABASE spider;
GRANT ALL PRIVILEGES ON DATABASE spider TO "spider-api";

\c spider;
set role to "spider-api";


DROP  TABLE  IF EXISTS spider_trade;
CREATE  TABLE spider_trade(
    id bigserial not null,
    tick BIGINT not null,
    price numeric(22,6) not null,
    base_asset varchar(100) not null,
    quote_asset varchar(100) not null
);
CREATE UNIQUE INDEX  spider_trade_uniq on spider_ticks(id,tick,price,base_asset,quote_asset);



DROP  TABLE  IF EXISTS spider_kline;
CREATE  TABLE spider_kline(
    interval varchar(20) not null,
    base_asset varchar(100) not null,
    quote_asset varchar(100) not null,
    open_time BIGINT not null,
    open numeric(22,6)  null,
    high numeric(22,6)  null,
    low numeric(22,6)  null,
    close numeric(22,6)  null,
    volume numeric(22,6)  null,
    close_time BIGINT  null,
    quote_volume numeric(22,6)  null,
    count numeric(22,6)  null,
    taker_buy_volume numeric(22,6)  null,
    taker_buy_quote_volume numeric(22,6)  null,
    ignore int
);
CREATE UNIQUE INDEX  spider_kline_uniq on spider_kline(interval,base_asset,quote_asset,open_time,open,volume);

```


# 目录结构
运行tradebot-crontask,生成crontask即可， 每6小时抓取最新数据（2 days ago ,定义在tradebot-crontask_detail.sh文件里）
```
.
├── binance_data
├── readme.md
├── spider.klines.binance.sh 
│    # 修改配置psql账号，数据库名
│    # 范例:
│    # bash spider.klines.binance.sh 20200909 0
├── spider.trades.binance.sh
│    # 修改配置psql账号，数据库名
│    # 范例:
│    # bash spider.trades.binance.sh 20200909 0
│    # 已去除相邻同价数据
├── tradebot-crontask.sh  
└── tradebot-crontask_detail.sh
```


# 修改抓取目标
* 修改spider.klines.binance.sh ， spider.trades.binance.sh 前2行 ， 设定抓取的交易对、时间间隔
  ```
    all_intervals=(12h 15m 1d 1h 1m 1mo 1w 2h 30m 3d 3m 4h 5m 6h 8h)
    all_assets=(BTC LTC ETH)
  ```



# 兼容性及其它
* 代码内设置了兼容Darwin和Linux的date函数
* 请使用bash，而不是sh执行
* 仅限USDT交易对
* 抓取其它天数据，单独运行spider.tick.binance.sh
   ```
   # 抓取包含20200909和之前1000天的tick数据
   bash spider.trades.binance.sh 20200909 1000
   # 抓取包含20200909和之前1000天的kline数据
   bash spider.klines.binance.sh 20200909 1000
   ``` 
  
# Postgres数据示例
```
croptoquant=> select * from spider_kline limit 10;
 interval | base_asset | quote_asset |   open_time   |     open     |     high     |     low      |    close     |     vo
lume     |  close_time   |    quote_volume    |     count      | taker_buy_volume | taker_buy_quote_volume | ignore
----------+------------+-------------+---------------+--------------+--------------+--------------+--------------+-------
---------+---------------+--------------------+----------------+------------------+------------------------+--------
 12h      | BTC        | USDT        | 1662681600000 | 19309.300000 | 21188.000000 | 19283.000000 | 20931.700000 |  58518
6.634000 | 1662724799999 | 11955696355.622140 | 3312044.000000 |    317618.925000 |      6486254577.229940 |      0
 12h      | BTC        | USDT        | 1662724800000 | 20931.700000 | 21666.000000 | 20912.200000 | 21352.000000 |  40731
0.466000 | 1662767999999 |  8639709896.948050 | 2475913.000000 |    211336.720000 |      4484444857.571150 |      0
 12h      | LTC        | USDT        | 1662681600000 |    57.930000 |    61.500000 |    57.660000 |    60.900000 | 216094
8.472000 | 1662724799999 |   129596233.213430 |  223109.000000 |   1146937.115000 |        68816025.392450 |      0
 12h      | LTC        | USDT        | 1662724800000 |    60.890000 |    61.950000 |    60.270000 |    61.090000 | 137731
5.333000 | 1662767999999 |    83996541.022770 |  179806.000000 |    699548.150000 |        42670372.085320 |      0
 12h      | ETH        | USDT        | 1662681600000 |  1634.230000 |  1718.000000 |  1629.250000 |  1699.330000 | 410566
7.542000 | 1662724799999 |  6927260213.170810 | 2636976.000000 |   2155659.904000 |      3637051658.580700 |      0
 12h      | ETH        | USDT        | 1662724800000 |  1699.340000 |  1746.300000 |  1694.500000 |  1717.480000 | 348619
7.378000 | 1662767999999 |  5988791821.691490 | 2599139.000000 |   1761166.760000 |      3025973614.578890 |      0
 15m      | BTC        | USDT        | 1662681600000 | 19309.300000 | 19346.600000 | 19283.000000 | 19339.100000 |    269
8.964000 | 1662682499999 |    52148189.318900 |   20343.000000 |      1447.720000 |        27971901.442900 |      0
 15m      | BTC        | USDT        | 1662682500000 | 19339.200000 | 19386.400000 | 19336.000000 | 19363.500000 |    377
0.982000 | 1662683399999 |    72999973.084400 |   24991.000000 |      1977.722000 |        38286032.621700 |      0
 15m      | BTC        | USDT        | 1662683400000 | 19363.500000 | 19380.000000 | 19330.300000 | 19347.900000 |    201
2.946000 | 1662684299999 |    38961892.893000 |   17463.000000 |       754.865000 |        14610829.340500 |      0
 15m      | BTC        | USDT        | 1662684300000 | 19347.900000 | 19373.800000 | 19345.400000 | 19355.900000 |    166
9.610000 | 1662685199999 |    32315978.980600 |   13286.000000 |       743.594000 |        14392864.792700 |      0
(10 rows)



croptoquant=>  select * from spider_trade  limit 20;
     id     |     tick      |    price     | base_asset | quote_asset
------------+---------------+--------------+------------+-------------
 2803764453 | 1662681600103 | 19309.300000 | BTC        | USDT
 2803764454 | 1662681600208 | 19309.400000 | BTC        | USDT
 2803764459 | 1662681603755 | 19309.300000 | BTC        | USDT
 2803764466 | 1662681603775 | 19309.400000 | BTC        | USDT
 2803764470 | 1662681603784 | 19309.300000 | BTC        | USDT
 2803764471 | 1662681603788 | 19309.400000 | BTC        | USDT
 2803764490 | 1662681603811 | 19309.300000 | BTC        | USDT
 2803764491 | 1662681603819 | 19309.400000 | BTC        | USDT
 2803764492 | 1662681603831 | 19309.300000 | BTC        | USDT
 2803764498 | 1662681603838 | 19309.400000 | BTC        | USDT
 2803764499 | 1662681603838 | 19309.300000 | BTC        | USDT
 2803764504 | 1662681603857 | 19309.400000 | BTC        | USDT
 2803764506 | 1662681603866 | 19309.300000 | BTC        | USDT
 2803764508 | 1662681603875 | 19309.400000 | BTC        | USDT
 2803764510 | 1662681603877 | 19309.300000 | BTC        | USDT
 2803764512 | 1662681603878 | 19309.400000 | BTC        | USDT
 2803764513 | 1662681603879 | 19309.300000 | BTC        | USDT
 2803764514 | 1662681603879 | 19309.400000 | BTC        | USDT
 2803764515 | 1662681603879 | 19309.300000 | BTC        | USDT
 2803764516 | 1662681603881 | 19309.400000 | BTC        | USDT
(20 rows)


```