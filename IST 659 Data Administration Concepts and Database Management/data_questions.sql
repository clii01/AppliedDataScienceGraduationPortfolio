SELECT "day", "open" - "close" as difference
FROM daily_data 
join time_series_daily 
on daily_data.daily_data_key = time_series_daily.daily_data_key
where "day" > '2019-01-31'
and "day" < '2019-04-01'
order by "day" desc;

SELECT "day", (2*"open" + 3*"close" + "high" + "low")/7 as weighted daily price
FROM daily_data 
join time_series_daily 
on daily_data.daily_data_key = time_series_daily.daily_data_key
where "day" > '2019-01-31'
and "day" < '2019-04-01'
and daily_data.ticker_key = 1
order by "day" desc;

select * from daily_data order by "day";

SELECT  "day" = DATEADD(MONTH, DATEDIFF(MONTH, 0, "day"), 0),
		ticker_symbol,   
		AVG("open" - "close") as difference
FROM    daily_data
join time_series_daily 
on daily_data.daily_data_key = time_series_daily.daily_data_key
join ticker
on ticker.ticker_key = daily_data.ticker_key
WHERE   "day" >= '2018-12-31' 
AND     "day" < '2019-04-01'
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, "day"), 0), ticker_symbol;

SELECT "day", ticker_key, ("open" + "close")/2 as average
FROM  daily_data
join time_series_daily 
on daily_data.daily_data_key = time_series_daily.daily_data_key
WHERE   "day" >= '2018-12-31' 
AND     "day" < '2019-02-01'
AND ticker_key = 1
order by "day" desc;

SELECT min("day") as oldest_record, max("day") as newest_record
FROM  daily_data
join time_series_daily 
on daily_data.daily_data_key = time_series_daily.daily_data_key
WHERE   "day" >= '2018-12-31' 
AND     "day" < '2019-02-01'
AND ticker_key = 1;

SELECT *
FROM  daily_data
join time_series_daily 
on daily_data.daily_data_key = time_series_daily.daily_data_key
join ema
on daily_data.daily_data_key = ema.daily_data_key
join macd
on daily_data.daily_data_key = macd.daily_data_key;

insert into ticker values(3, 'MSFT')

SELECT TOP 1 * 
FROM backtest_result
ORDER BY backtest_result.percent_success desc;

select max((2*"open" + 3*"close" + "high" + "low")/7) as HIGHEST, MIN((2*"open" + 3*"close" + "high" + "low")/7) as LOWEST
from time_series_daily
inner join daily_data on daily_data.daily_data_key = time_series_daily.daily_data_key
where "day" > '2019-02-28'
and "day" < '2019-04-01'
and ticker_key = 1;

select "day", (2*"open" + 3*"close" + "high" + "low")/7 as Weighted_Stock_Price, real_lower_band, real_upper_band
 from daily_data
inner join time_series_daily on daily_data.daily_data_key = time_series_daily.daily_data_key
inner join bbands on bbands.daily_data_key = daily_data.daily_data_key
where ((2*"open" + 3*"close" + "high" + "low")/7 > real_upper_band
or (2*"open" + 3*"close" + "high" + "low")/7 < real_lower_band)
and ticker_key = 1;

select "day", (2*"open" + 3*"close" + "high" + "low")/7 as Weighted_Stock_Price, ema
 from daily_data
inner join time_series_daily on daily_data.daily_data_key = time_series_daily.daily_data_key
inner join ema on ema.daily_data_key = daily_data.daily_data_key
where ticker_key = 1
and (2*"open" + 3*"close" + "high" + "low")/7 < ema;