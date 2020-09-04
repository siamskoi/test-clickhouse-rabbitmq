#!/bin/bash

function help() {
  echo 'example: ./test.sh test 10000'
}

function test() {
  docker-compose up -d
  echo -ne "Wait RabbitMQ and Clickhouse startup."
  for i in {1..10} ; do
    echo -ne "."
    sleep 1;
  done
  echo
  docker-compose run php php test.php $1
  sleep 2
  echo "In clickhouse table est_db.test_table: "
  docker-compose exec clickhouse1 clickhouse-client --query "select count(*) from test_db.test_table;"
  docker-compose down
}

case $1 in
"")
  help
  ;;
*)
  "$@" $@
  ;;
esac
