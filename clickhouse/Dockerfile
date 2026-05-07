FROM clickhouse/clickhouse-server

ENV CLICKHOUSE_SKIP_USER_SETUP=1


RUN apt-get update
RUN apt -y install python3 python3-pip
RUN pip3 install clickhouse-driver

COPY clickhouse/z_log_disable.xml /etc/clickhouse-server/config.d/z_log_disable.xml
COPY clickhouse/init_upload.sql /init_upload.sql

COPY clickhouse/start.sh /start.sh
RUN chmod a+x /start.sh

