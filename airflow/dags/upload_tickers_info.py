from typing import Optional
import datetime
import logging
import os
from dataclasses import dataclass, asdict
import pendulum

from airflow import DAG
from airflow.decorators import dag, task
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.models.baseoperator import chain

import clickhouse_connect


from t_tech.invest import Client, SecurityTradingStatus
from t_tech.invest.services import InstrumentsService
from t_tech.invest.utils import quotation_to_decimal, Quotation
from t_tech.invest.schemas import SecurityTradingStatus



ssl_path = os.environ["GRPC_DEFAULT_SSL_ROOTS_FILE_PATH"]
print(f"ssl_path={ssl_path}")


def get_secret(env_var_path: str) -> Optional[str]:
    if env_var_path not in os.environ.keys():
        return None
    file_path = os.environ[env_var_path]
    f = open(file_path, "r", encoding="UTF-8")
    line = f.readline()
    return line

TOKEN = get_secret("TBANK_TOKEN_PATH")

CLICKHOUSE_DEFAULT_PASSWORD = get_secret("CLICKHOUSE_DEFAULT_PASSWORD")

GRPC_SERVER = "sandbox-invest-public-api.tbank.ru:443"



DAG_ID = "update_tickers_info"


@dataclass
class TbankInstrument:
    source: str
    instrument_type: str
    name: str
    ticker: str
    figi: str
    uid: str
    trading_status: str
    bool_trading_status: bool
    buy_available_flag: bool
    sell_available_flag: bool
    short_enabled_flag: bool
    api_trade_available_flag: bool
    lot: int
    min_price_increment: float
    currency: str


    @staticmethod
    def quotation_to_float(q: Quotation) -> float:
        return q.units + float(q.nano / 1000000000)

    @staticmethod
    def trading_status_to_bool(ts: int) -> bool:
        se = {
            SecurityTradingStatus.SECURITY_TRADING_STATUS_NORMAL_TRADING,
            SecurityTradingStatus.SECURITY_TRADING_STATUS_DEALER_NORMAL_TRADING,
        }
        if SecurityTradingStatus(ts) in se:
            return True
        else:
            return False

    def fully_available(self):
        b = self.bool_trading_status and self.buy_available_flag \
            and self.sell_available_flag #and self.short_enabled_flag
        return b

    def to_csv_line(self) -> str:
        s = f"{self.source};{self.instrument_type};{self.name};{self.ticker};{self.figi};{self.uid};{self.trading_status}"
        s += f";{self.bool_trading_status};{self.buy_available_flag};{self.sell_available_flag}"
        s += f";{self.short_enabled_flag};{self.api_trade_available_flag};{self.lot};{self.min_price_increment}"
        s += f";{self.currency}"
        s += "\n"
        return s

    def to_tuple(self) -> tuple:
        tu = (
            self.source,
            self.instrument_type,
            self.name,
            self.ticker,
            self.figi,
            self.uid,
            self.trading_status,
            self.bool_trading_status,
            self.buy_available_flag,
            self.sell_available_flag,
            self.short_enabled_flag,
            self.api_trade_available_flag,
            self.lot,
            self.min_price_increment,
            self.currency,
        )
        return tu

    def to_dict(self) -> dict:
        d = {k: str(v) for k, v in asdict(self).items()}
        return d

logging.basicConfig(format="%(asctime)s %(levelname)s:%(message)s", level=logging.DEBUG)
logger = logging.getLogger(__name__)


def get_data() -> list[tuple]:
    """Example - How to get figi by name of ticker."""

    # ticker = "VTBR"  # "BRH3" "SBER" "VTBR"
    print(f"before client")
    # breakpoint()
    with Client(TOKEN, target=GRPC_SERVER) as client:
        print(f"in client")
        instruments: InstrumentsService = client.instruments
        tickers = []
        instrument_types = [
            "shares",
            "bonds",
            "etfs",
            "currencies",
            "futures",
        ]
        for method in instrument_types:
            for item in getattr(instruments, method)().instruments:
                tickers.append(
                    TbankInstrument(
                        source="airflow." + DAG_ID,
                        instrument_type=method,
                        name=item.name,
                        ticker=item.ticker,
                        figi=item.figi,
                        uid=item.uid,
                        trading_status=str(SecurityTradingStatus(item.trading_status).name),
                        bool_trading_status=TbankInstrument.trading_status_to_bool(item.trading_status),
                        buy_available_flag=item.buy_available_flag,
                        sell_available_flag=item.sell_available_flag,
                        short_enabled_flag=item.short_enabled_flag,
                        api_trade_available_flag=item.api_trade_available_flag,
                        lot=item.lot,
                        min_price_increment=TbankInstrument.quotation_to_float(item.min_price_increment),
                        currency=item.currency,
                    )
                )

        for t in tickers:
            print(t.to_csv_line())
        res = [ti.to_tuple() for ti in tickers]
        print(f"Client: res = {res}")
        return res


@dag(
    dag_id=DAG_ID,
    # start_date=datetime.datetime(2026, 2, 1),
    start_date=pendulum.datetime(2026, 2, 1, tz="Europe/Moscow"),
    # schedule="@daily",
    # schedule="0 9-21 * * 1-5",
    schedule="4 5,12 * * 1-5", # UTC
    catchup=False,
    max_active_runs=1,
    max_active_tasks=1,
)
def dag_steps():
    @task(task_id="load_data")
    def load_data(**kwargs) -> list[tuple]:
        logger.info("starting")
        li = get_data()
        return li

    @task(task_id="insert_into_clickhouse")
    def insert_into_clickhouse(rows: list[tuple], **kwargs):
        client = clickhouse_connect.get_client(
            host="test-clickhouse-host",
            port=8123,
            username="default",
            password=CLICKHOUSE_DEFAULT_PASSWORD,
        )
        target_fields = [
            "source",
            "instrument_type",
            "name",
            "ticker",
            "figi",
            "uid",
            "trading_status",
           "bool_trading_status",
            "buy_available_flag",
            "sell_available_flag",
            "short_enabled_flag",
            "api_trade_available_flag",
            "lot",
            "min_price_increment",
            "currency",
        ]
        client.insert("tbank.instruments", rows, column_names=target_fields)
        client.command("optimize table tbank.instruments final")
        client.close()

    li = load_data()
    insert_into_clickhouse(rows=li)


dag_steps()
