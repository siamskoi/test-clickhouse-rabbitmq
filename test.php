<?php
require 'vendor/autoload.php';

use PhpAmqpLib\Channel\AMQPChannel;
use PhpAmqpLib\Connection\AMQPStreamConnection;
use PhpAmqpLib\Message\AMQPMessage;

class Queue
{
    private string $subject = 'exchange_event';
    private AMQPChannel $channel;

    public function __construct()
    {
        $connection = new AMQPStreamConnection('rabbitmq', 5672, 'guest', 'guest');
        $this->channel = $connection->channel();
    }

    public function listen(): void
    {
    }

    public function publish($totalMsg = 1000): void
    {
        $i = 0;
        while (true) {
            $i++;

            $data = $this->getJsonData();

            $this->sendToRabbit($data);

            if ($i % 1000 === 0) {
                print $i . PHP_EOL;
            }

            if ($i % $totalMsg === 0) {
                return;
            }
        }
    }

    private function getJsonData(): string
    {
        $data = [
            'company_id' => PHP_INT_MAX,
            'product_id' => PHP_INT_MAX,
            'event_date' => (new \DateTimeImmutable())->getTimestamp(),
        ];

        return json_encode($data, JSON_THROW_ON_ERROR);
    }

    private function sendToRabbit(string $data): void
    {
        $properties = [
//            'delivery_mode' => AMQPMessage::DELIVERY_MODE_PERSISTENT,
        ];

        $amqpMessage = new AMQPMessage($data, $properties);
        $this->channel->basic_publish($amqpMessage, $this->subject, 'key');
    }
}

$queue = new Queue();
echo "Send {$argv[1]} messages:" . PHP_EOL;
$queue->publish($argv[1]);
echo "Done" . PHP_EOL;
