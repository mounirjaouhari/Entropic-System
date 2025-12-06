#!/usr/bin/env python3
"""
Kafka Producer - Send customer messages to cache topic
"""
import json
import sys
from kafka import KafkaProducer
from datetime import datetime

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 produce.py '<json_message>'")
        sys.exit(1)

    try:
        message = json.loads(sys.argv[1])
    except json.JSONDecodeError as e:
        print(f"Invalid JSON: {e}")
        sys.exit(1)

    try:
        producer = KafkaProducer(
            bootstrap_servers=['broker:9092'],
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            acks='all',
            retries=3
        )

        # Send message
        future = producer.send('cache', value=message)
        record_metadata = future.get(timeout=10)

        print(f"Message sent to topic '{record_metadata.topic}' "
              f"partition {record_metadata.partition} "
              f"at offset {record_metadata.offset}")

        producer.flush()
        producer.close()

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
