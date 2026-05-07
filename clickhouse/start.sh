#!/bin/sh

clickhouse-client --query "create user if not exists user1 identified with sha256_password by '$(cat $CLICKHOUSE_USER1_PASSWORD)'"

DEFAULT_SHA256=`echo -n "$(cat $CLICKHOUSE_DEFAULT_PASSWORD)" | sha256sum | awk '{print $1}'`

sed -i -e "s|<password></password>|<password_sha256_hex>$DEFAULT_SHA256</password_sha256_hex>|g" /etc/clickhouse-server/users.xml

clickhouse-client --query "system reload config"


