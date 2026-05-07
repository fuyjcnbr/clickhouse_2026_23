#!/bin/sh

uv --directory /venv_airflow run airflow standalone &> /airflow.log 2>&1 &

sleep infinity
