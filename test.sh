#!/bin/bash

function help() {
  echo 'example: ./test.sh test 10000'
}

function start() {
  docker-compose up -d
}

function stop() {
  docker-compose down
}

function sendToQueue() {
  docker-compose run php php test.php $1
}

function seeCount() {
  echo "Rows in table test_db.test_table: "
  docker-compose exec clickhouse1 clickhouse-client --query "select count(*) from test_db.test_table;"
}

function test() {
  totalMsg="${1:-1000}"
  start
  echo -ne "Wait RabbitMQ and Clickhouse startup."
  for i in {1..10} ; do
    echo -ne "."
    sleep 1;
  done
  sendToQueue $totalMsg
  echo
#  docker-compose exec clickhouse1 bash -c "clickhouse client -n < /rabbitmq_json.sql"
  sleep 5
  seeCount
  stop
}


case $1 in
"")
  help
  ;;
*)
  "$@"
  ;;
esac
