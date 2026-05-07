

--drop database if exists tbank;

create database tbank;



---------------------------instruments

--drop table if exists tbank.instruments;

create table tbank.instruments (
	dt DateTime default now()
	,source String default 'auto'
	,instrument_type String
	,name String
	,ticker String
	,figi String
	,uid String
	,trading_status String
	,bool_trading_status bool
	,buy_available_flag bool
	,sell_available_flag bool
	,short_enabled_flag bool
	,api_trade_available_flag bool
	,lot UInt32
	,min_price_increment Float32
	,currency String
)
engine = ReplacingMergeTree(dt)
order by (uid);
