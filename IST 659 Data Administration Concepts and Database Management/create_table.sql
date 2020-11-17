-- Table: ticker
CREATE TABLE ticker
(
    ticker_key  INTEGER NOT NULL PRIMARY KEY,
    ticker_symbol varchar(200) NOT NULL UNIQUE
)

-- Table: daily_data
CREATE TABLE daily_data
(
    daily_data_key  INTEGER NOT NULL PRIMARY KEY,
    ticker_key INTEGER NOT NULL,
     "day" date NOT NULL,
    CONSTRAINT ticker_key_fk FOREIGN KEY (ticker_key)
         REFERENCES ticker (ticker_key)
         ON UPDATE CASCADE
         ON DELETE CASCADE
)

-- Table: time_series_daily
CREATE TABLE time_series_daily
(
    time_series_daily_key  INTEGER NOT NULL PRIMARY KEY,
    daily_data_key integer NOT NULL,
    "open" float NOT NULL,
    "close" float NOT NULL,
    high float NOT NULL,
    low float NOT NULL,
     CONSTRAINT tma_daily_data_fk FOREIGN KEY (daily_data_key)
        REFERENCES daily_data (daily_data_key)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

-- Table: bbands
CREATE TABLE bbands
(
    bbands_key INTEGER NOT NULL PRIMARY KEY,
    real_middle_band float NOT NULL,
    real_upper_band float NOT NULL,
    real_lower_band float NOT NULL,
    daily_data_key INTEGER NOT NULL,
     CONSTRAINT bbands_daily_data_fk FOREIGN KEY (daily_data_key)
        REFERENCES daily_data (daily_data_key)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

-- Table: ema
CREATE TABLE ema
(
    ema_key  INTEGER NOT NULL PRIMARY KEY,
    ema float NOT NULL,
      daily_data_key integer NOT NULL,
     CONSTRAINT ema_daily_data_fk FOREIGN KEY (daily_data_key)
        REFERENCES daily_data (daily_data_key)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

-- Table: macd
CREATE TABLE macd
(
    macd_key  INTEGER NOT NULL PRIMARY KEY,
    macd_hist float,
    macd_signal float,
    macd float NOT NULL,
     daily_data_key integer NOT NULL,
     CONSTRAINT macd_daily_data_fk FOREIGN KEY (daily_data_key)
        REFERENCES daily_data (daily_data_key)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)


-- Table: recommendation_strategy
CREATE TABLE recommendation_strategy
(
    recommendation_strategy_key  INTEGER NOT NULL PRIMARY KEY,
    trend varchar(200) check (trend = 'BULLISH' OR trend = 'BEARISH'),
    name varchar(200) not null,
    description varchar(200)
 )

-- Table: recommendation_strategy_version
CREATE TABLE recommendation_strategy_version
(
    recommendation_strategy_version_key  INTEGER NOT NULL PRIMARY KEY,
    recommendation_strategy_key integer NOT NULL,
    version integer not null,
     CONSTRAINT recommendation_strategy_fk FOREIGN KEY (recommendation_strategy_key)
        REFERENCES recommendation_strategy (recommendation_strategy_key)
        ON UPDATE CASCADE
        ON DELETE CASCADE
 )

-- Table: backtest_result
create table backtest_result
(
    backtest_result_key  INTEGER NOT NULL PRIMARY KEY,
    recommendation_strategy_version_key integer not null,
    ticker_key integer not null,
    date_tested date not null,
    days_to_hold integer not null,
    biggest_loss float not null,
    successes integer not null,
    failures integer not null,
    fizzles integer not null,
    total integer not null,
    percent_success float not null,
    percent_not_failed float not null,

    CONSTRAINT backtest_ticker_key_fk FOREIGN KEY (ticker_key)
         REFERENCES ticker (ticker_key)
         ON UPDATE CASCADE
         ON DELETE CASCADE,

    CONSTRAINT recommendation_strategy_version_fk FOREIGN KEY (recommendation_strategy_version_key)
         REFERENCES recommendation_strategy_version (recommendation_strategy_version_key)
         ON UPDATE CASCADE
         ON DELETE CASCADE

)

