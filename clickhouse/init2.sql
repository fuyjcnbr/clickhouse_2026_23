

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


--drop dictionary tbank.dict_instrument


create dictionary tbank.dict_instrument
(
	source String
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
primary key uid
source(clickhouse(database 'tbank' table 'instruments'))
lifetime(min 0 max 0)
layout(complex_key_hashed_array());


--system reload dictionary tbank.dict_instrument;




---------------------------statistics and metadata

--drop table if exists tbank.hist_instruments_trade;

create table tbank.hist_instruments_trade (
	dt Date
	,instrument_uid String
	,cnt UInt32
)
engine = ReplacingMergeTree()
order by (instrument_uid, dt);



--insert into tbank.hist_instruments_trade
--select toDate(dt)
--	,instrument_uid
--	,count(*)
--from tbank.upload_trade
--group by toDate(dt)
--	,instrument_uid



--drop table if exists tbank.hist_upload;

create table tbank.hist_upload (
	inserted_dt DateTime default now()
	,dt Date
	,file_type String
	,records_cnt UInt64
)
engine = ReplacingMergeTree(inserted_dt)
order by (file_type, dt);



---------------------------stats

--drop table if exists tbank.hist_stats;

create table tbank.hist_stats (
	dt Date
	,instrument_uid String
	,stat_name String -- e.g. 'hurst'
	,stat_value Float64
)
engine = ReplacingMergeTree()
order by (instrument_uid, dt, stat_name);






---------------------------upload




--drop table if exists tbank.upload_trade_pre;

create table tbank.upload_trade_pre (
	instrument_uid String
	,dt DateTime64(6)
	,price Float32
	,quantity UInt16
)
engine = MergeTree()
order by (instrument_uid, dt);





--drop table if exists tbank.upload_trade;

create table tbank.upload_trade (
	instrument_uid String
	,dt DateTime64(6)
	,price Float32
	,quantity UInt16
)
engine = MergeTree()
order by (instrument_uid, dt);


--truncate table tbank.upload_trade;
--
--with t as (
--	select instrument_uid
--		,toDateTime64(time, 6) as dt
--		,price
--		,quantity
--	from file('2026-02-17_tbank_trade.avro', Avro)
--)
--insert into tbank.upload_trade
--select *
--from t;




--drop table if exists tbank.upload_orderbook50;

create table tbank.upload_orderbook50 (
	instrument_uid String,
	dt DateTime64(6),

	bid_0_price  Float32,
	bid_0_quantity  UInt16,
	bid_1_price  Float32,
	bid_1_quantity  UInt16,
	bid_2_price  Float32,
	bid_2_quantity  UInt16,
	bid_3_price  Float32,
	bid_3_quantity  UInt16,
	bid_4_price  Float32,
	bid_4_quantity  UInt16,
	bid_5_price  Float32,
	bid_5_quantity  UInt16,
	bid_6_price  Float32,
	bid_6_quantity  UInt16,
	bid_7_price  Float32,
	bid_7_quantity  UInt16,
	bid_8_price  Float32,
	bid_8_quantity  UInt16,
	bid_9_price  Float32,
	bid_9_quantity  UInt16,
	bid_10_price  Float32,
	bid_10_quantity  UInt16,
	bid_11_price  Float32,
	bid_11_quantity  UInt16,
	bid_12_price  Float32,
	bid_12_quantity  UInt16,
	bid_13_price  Float32,
	bid_13_quantity  UInt16,
	bid_14_price  Float32,
	bid_14_quantity  UInt16,
	bid_15_price  Float32,
	bid_15_quantity  UInt16,
	bid_16_price  Float32,
	bid_16_quantity  UInt16,
	bid_17_price  Float32,
	bid_17_quantity  UInt16,
	bid_18_price  Float32,
	bid_18_quantity  UInt16,
	bid_19_price  Float32,
	bid_19_quantity  UInt16,
	bid_20_price  Float32,
	bid_20_quantity  UInt16,
	bid_21_price  Float32,
	bid_21_quantity  UInt16,
	bid_22_price  Float32,
	bid_22_quantity  UInt16,
	bid_23_price  Float32,
	bid_23_quantity  UInt16,
	bid_24_price  Float32,
	bid_24_quantity  UInt16,
	bid_25_price  Float32,
	bid_25_quantity  UInt16,
	bid_26_price  Float32,
	bid_26_quantity  UInt16,
	bid_27_price  Float32,
	bid_27_quantity  UInt16,
	bid_28_price  Float32,
	bid_28_quantity  UInt16,
	bid_29_price  Float32,
	bid_29_quantity  UInt16,
	bid_30_price  Float32,
	bid_30_quantity  UInt16,
	bid_31_price  Float32,
	bid_31_quantity  UInt16,
	bid_32_price  Float32,
	bid_32_quantity  UInt16,
	bid_33_price  Float32,
	bid_33_quantity  UInt16,
	bid_34_price  Float32,
	bid_34_quantity  UInt16,
	bid_35_price  Float32,
	bid_35_quantity  UInt16,
	bid_36_price  Float32,
	bid_36_quantity  UInt16,
	bid_37_price  Float32,
	bid_37_quantity  UInt16,
	bid_38_price  Float32,
	bid_38_quantity  UInt16,
	bid_39_price  Float32,
	bid_39_quantity  UInt16,
	bid_40_price  Float32,
	bid_40_quantity  UInt16,
	bid_41_price  Float32,
	bid_41_quantity  UInt16,
	bid_42_price  Float32,
	bid_42_quantity  UInt16,
	bid_43_price  Float32,
	bid_43_quantity  UInt16,
	bid_44_price  Float32,
	bid_44_quantity  UInt16,
	bid_45_price  Float32,
	bid_45_quantity  UInt16,
	bid_46_price  Float32,
	bid_46_quantity  UInt16,
	bid_47_price  Float32,
	bid_47_quantity  UInt16,
	bid_48_price  Float32,
	bid_48_quantity  UInt16,
	bid_49_price  Float32,
	bid_49_quantity  UInt16,

	ask_0_price  Float32,
	ask_0_quantity  UInt16,
	ask_1_price  Float32,
	ask_1_quantity  UInt16,
	ask_2_price  Float32,
	ask_2_quantity  UInt16,
	ask_3_price  Float32,
	ask_3_quantity  UInt16,
	ask_4_price  Float32,
	ask_4_quantity  UInt16,
	ask_5_price  Float32,
	ask_5_quantity  UInt16,
	ask_6_price  Float32,
	ask_6_quantity  UInt16,
	ask_7_price  Float32,
	ask_7_quantity  UInt16,
	ask_8_price  Float32,
	ask_8_quantity  UInt16,
	ask_9_price  Float32,
	ask_9_quantity  UInt16,
	ask_10_price  Float32,
	ask_10_quantity  UInt16,
	ask_11_price  Float32,
	ask_11_quantity  UInt16,
	ask_12_price  Float32,
	ask_12_quantity  UInt16,
	ask_13_price  Float32,
	ask_13_quantity  UInt16,
	ask_14_price  Float32,
	ask_14_quantity  UInt16,
	ask_15_price  Float32,
	ask_15_quantity  UInt16,
	ask_16_price  Float32,
	ask_16_quantity  UInt16,
	ask_17_price  Float32,
	ask_17_quantity  UInt16,
	ask_18_price  Float32,
	ask_18_quantity  UInt16,
	ask_19_price  Float32,
	ask_19_quantity  UInt16,
	ask_20_price  Float32,
	ask_20_quantity  UInt16,
	ask_21_price  Float32,
	ask_21_quantity  UInt16,
	ask_22_price  Float32,
	ask_22_quantity  UInt16,
	ask_23_price  Float32,
	ask_23_quantity  UInt16,
	ask_24_price  Float32,
	ask_24_quantity  UInt16,
	ask_25_price  Float32,
	ask_25_quantity  UInt16,
	ask_26_price  Float32,
	ask_26_quantity  UInt16,
	ask_27_price  Float32,
	ask_27_quantity  UInt16,
	ask_28_price  Float32,
	ask_28_quantity  UInt16,
	ask_29_price  Float32,
	ask_29_quantity  UInt16,
	ask_30_price  Float32,
	ask_30_quantity  UInt16,
	ask_31_price  Float32,
	ask_31_quantity  UInt16,
	ask_32_price  Float32,
	ask_32_quantity  UInt16,
	ask_33_price  Float32,
	ask_33_quantity  UInt16,
	ask_34_price  Float32,
	ask_34_quantity  UInt16,
	ask_35_price  Float32,
	ask_35_quantity  UInt16,
	ask_36_price  Float32,
	ask_36_quantity  UInt16,
	ask_37_price  Float32,
	ask_37_quantity  UInt16,
	ask_38_price  Float32,
	ask_38_quantity  UInt16,
	ask_39_price  Float32,
	ask_39_quantity  UInt16,
	ask_40_price  Float32,
	ask_40_quantity  UInt16,
	ask_41_price  Float32,
	ask_41_quantity  UInt16,
	ask_42_price  Float32,
	ask_42_quantity  UInt16,
	ask_43_price  Float32,
	ask_43_quantity  UInt16,
	ask_44_price  Float32,
	ask_44_quantity  UInt16,
	ask_45_price  Float32,
	ask_45_quantity  UInt16,
	ask_46_price  Float32,
	ask_46_quantity  UInt16,
	ask_47_price  Float32,
	ask_47_quantity  UInt16,
	ask_48_price  Float32,
	ask_48_quantity  UInt16,
	ask_49_price  Float32,
	ask_49_quantity  UInt16
)
engine = MergeTree()
primary key instrument_uid
order by (instrument_uid, dt);


--truncate table tbank.upload_orderbook50;
--
--with t as (
--	select instrument_uid
--		,toDateTime64(time, 6) as dt
--		,* except (figi, instrument_uid, time)
--	from file('2026-02-16_tbank_orderbook.avro', Avro)
--)
--insert into tbank.upload_orderbook50
--select *
--from t;



