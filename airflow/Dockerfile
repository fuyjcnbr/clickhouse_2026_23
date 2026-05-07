FROM ubuntu:24.04

ENV PYTHON_VERSION=3.12


RUN apt update

############# uv
RUN apt -y install curl
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

############# python
RUN uv python pin $PYTHON_VERSION

RUN apt -y install ca-certificates git nano

ENV TZ=Europe/Moscow
# 24.04
RUN apt -y install --no-install-recommends tzdata

############# t-tech-investments
RUN git clone https://opensource.tbank.ru/invest/invest-python.git
RUN cd /invest-python && uvx migrate-to-uv --ignore-locked-versions --skip-lock


###### venv_airflow
RUN mkdir /venv_airflow
COPY airflow/pyproject_airflow.toml /venv_airflow/pyproject.toml

RUN uv sync --directory /venv_airflow



# RUN uv sync

RUN mkdir /certs
COPY certs/russian_trusted_root_ca_pem.crt /certs/russian_trusted_root_ca_pem.crt

RUN mkdir /src
ENV GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=/certs/russian_trusted_root_ca_pem.crt


############# airflow
RUN mkdir -p /airflow/dags
# COPY dags /airflow/dags
#
COPY airflow/start.sh /start.sh
RUN chmod a+x /start.sh

ENV AIRFLOW_HOME=/airflow
ENV AIRFLOW__CORE__LOAD_EXAMPLES=false

############# airflow 2.x
RUN uv --directory /venv_airflow run airflow db init

RUN sed -r -i "s@^#?default_timezone =.*@default_timezone = $TZ@g" $AIRFLOW_HOME/airflow.cfg

RUN uv --directory /venv_airflow run airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin

