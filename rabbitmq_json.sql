create database IF NOT EXISTS test_db;

CREATE TABLE IF NOT EXISTS test_db.test_table (
    company_id           UInt32,
    product_id           UInt32,
    event_date           Date DEFAULT toDate(now())
) ENGINE=ReplicatedMergeTree(
         '/clickhouse/tables/{shard}/events_shard',
         '{replica}',
         event_date,
         (company_id),
         8192
);

CREATE TABLE IF NOT EXISTS test_db.event_queue (
     company_id           UInt32,
     product_id           UInt32,
     event_date           UInt32
) ENGINE=RabbitMQ() SETTINGS
    rabbitmq_host_port = 'rabbitmq:5672',
    rabbitmq_exchange_name = 'exchange_event',
    rabbitmq_format = 'JSONEachRow',
    rabbitmq_num_consumers = 1;

CREATE MATERIALIZED VIEW test_db.consumer  TO test_db.test_table
AS (SELECT company_id, product_id, toDate(event_date) FROM test_db.event_queue);
