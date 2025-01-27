#!/usr/bin/env python3

# pylint: disable=no-member

import sys
import time
import asyncio
import RPi.GPIO as GPIO
from raspberry.config import *  # pylint: disable=unused-wildcard-import
from mfrc522 import MFRC522
import board
import neopixel
import datetime
import paho.mqtt.client as mqtt
import json

raspberry_config = json.load(open("config.json"))

# The broker name or IP address.
broker = "localhost"
# broker = "127.0.0.1"
# broker = "10.0.0.1"

# The MQTT client.
client = mqtt.Client()

def call_worker(payload):
    client.publish("pipick/logs", json.dumps(payload))


def connect_to_broker():
    # Connect to the broker.
    client.connect(broker)
    # Send message about conenction.
    call_worker({"msg": "Client connected"})


def disconnect_from_broker():
    # Send message about disconenction.
    call_worker({"msg": "Client disconnected"})
    # Disconnet the client.
    client.disconnect()



def buzzer(state):
    GPIO.output(buzzerPin, not state)

pixels = neopixel.NeoPixel(
        board.D18, 8, brightness=1.0/32, auto_write=False)

MIFAREReader = MFRC522()

registered_dates = []

async def rfidRead():
    read_success = False
    while not read_success:
        (status, TagType) = MIFAREReader.MFRC522_Request(MIFAREReader.PICC_REQIDL)
        if status == MIFAREReader.MI_OK:
            (status, uid) = MIFAREReader.MFRC522_Anticoll()
            if status == MIFAREReader.MI_OK:
                num = 0
                for i in range(0, len(uid)):
                    num += uid[i] << (i*8)
                now_date = datetime.datetime.now()
                print(f"Card read UID: {uid} > {num} - {now_date.isoformat()}")
              
                call_worker({"num": num, "zoneId": raspberry_config["zoneId"], "rfidCard": str(uid), "date": now_date.isoformat()})
                
               
                read_success = True
    
    go_away = True

    while go_away:
        (status,uid) = MIFAREReader.MFRC522_Anticoll()
        if status != MIFAREReader.MI_OK:
            go_away = False
        else:
            print("HOLDING!!!")
            await asyncio.sleep(0.5)
            
        
    pixels.fill((0,0,0))
    pixels.show()

async def process_message(client, userdata, message):
    # Decode message.
    message_decoded = json.loads(message.payload.decode("utf-8"))
    
    if message_decoded["zoneId"] == raspberry_config["zoneId"]:
        if message_decoded["accessGranted"]:
                
            pixels.fill((0, 255, 0))
            pixels.show()

            buzzer(True)
            print(f"Access granted for card {message_decoded['rfidCard']} at {message_decoded['date']}")
            await asyncio.sleep(1)
            buzzer(False)
        else:
            print(f"Access denied for card {message_decoded['rfidCard']} at {message_decoded['date']}")
            pixels.fill((255, 0, 0))
            pixels.show()
            buzzer(True)
            await asyncio.sleep(0.2)
            buzzer(False)
            await asyncio.sleep(0.2)
            buzzer(True)
            await asyncio.sleep(0.2)
            buzzer(False)
            await asyncio.sleep(0.2)
            buzzer(True)
            await asyncio.sleep(0.2)
            buzzer(False)
        
        


async def test():
    connect_to_broker()

    client.on_message = process_message

    client.subscribe("pipick/access")
    print('\nThe RFID reader test.')
    print('Place the card close to the reader (on the right side of the set).')
    client.loop_start()
    while True:
        await rfidRead()
        



if __name__ == "__main__":
    try:
        result = test()
    except KeyboardInterrupt:
        GPIO.cleanup()  # pylint: disable=no-member
        client.loop_stop()
        disconnect_from_broker()
        sys.exit(130)
