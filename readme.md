

## Собираем docker с clickhous'ом

```commandline
docker build --no-cache --squash -t test-clickhouse -f clickhouse/Dockerfile .
```


## Собираем docker с airflow

```commandline
docker build --no-cache --squash -t test-airflow -f airflow/Dockerfile .
```

## Подготавливаем дополнительные файлы

В директории certs должен быть сертификат russian_trusted_root_ca_pem.crt

В директории .secrets должны быть файлы:

    tbank_token - с токеном т-банка

    clickhouse_default_password - с паролем для пользователя default в clickhouse

## Запускаем docker compose

```commandline
docker compose -f docker-compose.yml up --force-recreate
```

## Создаём нужные таблицы в контейнере clickhouse

```commandline
cat /init_upload.sql | clickhouse-client -mn --ask-password
```

Проверяем, что таблица появилась

```sql
select *
from tbank.instruments
limit 30
```


## Проверка

Airflow будет доступен на http://localhost:7080 admin/admin

Запускаем DAG upload_tickers_info


Clickhouse будет доступен на localhost:18123 default/пароль для default

Проверяем заполнение таблицы tbank.instruments

```sql
select *
from tbank.instruments
limit 30
```



