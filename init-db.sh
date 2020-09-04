#!/bin/bash
set -e

echo "Wait rabbitMQ.."
sleep 5;

clickhouse client -n < /rabbitmq_json.sql
