#!/usr/bin/env python3

import paho.mqtt.client as mqtt
import time


# The broker name or IP address.
broker = "localhost"
# broker = "127.0.0.1"
# broker = "10.0.0.1"

# The MQTT client.
client = mqtt.Client()

if len(message_decoded) >= 2 and message_decoded[0] != "Client connected" and message_decoded[0] != "Client disconnected":
    # Decode message.
    message_decoded = (str(message.payload.decode("utf-8"))).split(".")

    # Print message to console.
    if message_decoded[0] != "Client connected" and message_decoded[0] != "Client disconnected":
        print(time.ctime() + ", " +
              message_decoded[0] + " used the RFID card.")


    else:
        print(message_decoded[0] + " : " + message_decoded[1])



def connect_to_broker():
    # Connect to the broker.
    client.connect(broker)
    # Send message about connection.
    client.on_message = process_message
    # Starts client and subscribe.
    client.loop_start()
    client.subscribe("worker/name")


def disconnect_from_broker():
    # Disconnect the client.
    client.loop_stop()
    client.disconnect()


def run_receiver():
    connect_to_broker()

    try:
        while True:
            time.sleep(0.001)
    except KeyboardInterrupt:
        pass
    disconnect_from_broker()



if __name__ == "__main__":
    run_receiver()