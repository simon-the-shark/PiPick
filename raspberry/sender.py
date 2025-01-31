#!/usr/bin/env python3

# pylint: disable=no-member

import sys
import time
import asyncio
import RPi.GPIO as GPIO
from config import *  # pylint: disable=unused-wildcard-import
from mfrc522 import MFRC522
import board
import neopixel
import datetime
import paho.mqtt.client as mqtt
import json

raspberry_config = json.load(open("config.json"))

broker = raspberry_config["broker"]
zone_id = raspberry_config["zoneId"]

client = mqtt.Client()



def call_worker(payload):
    client.publish(f"pipick/{zone_id}/logs", json.dumps(payload))

def connect_to_broker():
    client.connect(broker)
    call_worker({"msg": "Client connected"})


def disconnect_from_broker():
    call_worker({"msg": "Client disconnected"})
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
              
                call_worker({"num": num, "rfidCard": str(uid), "date": now_date.isoformat()})
                
               
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

def process_message(client, userdata, message):
    message_decoded = json.loads(message.payload.decode("utf-8"))
    
    if message_decoded["accessGranted"]:
        asyncio.run(access_granted(message_decoded))
    else:
        asyncio.run(access_denied(message_decoded))
        
async def access_granted(message_decoded):
    pixels.fill((0, 255, 0))
    pixels.show()

    buzzer(True)
    print(f"Access granted for card {message_decoded['rfidCard']} at {message_decoded['date']}")
    await asyncio.sleep(1)
    buzzer(False)

async def access_denied(message_decoded):
    print(f"Access denied for card {message_decoded['rfidCard']} at {message_decoded['date']}")
    pixels.fill((255, 0, 0))
    pixels.show()

    for i in range(0,4):
        even = i % 2 == 0
        buzzer(even)
        await asyncio.sleep(0.2)
        pixels.fill((255, 0, 0) if even else (0,0,0))
        pixels.show()

        
async def test():
    connect_to_broker()

    client.on_message = process_message

    client.subscribe(f"pipick/{zone_id}/access")
    print('\nThe RFID reader test.')
    print('Place the card close to the reader (on the right side of the set).')
    client.loop_start()
    while True:
        await rfidRead()

if __name__ == "__main__":
    try:
        asyncio.run(test())
    except KeyboardInterrupt:
        GPIO.cleanup()  # pylint: disable=no-member
        client.loop_stop()
        disconnect_from_broker()
        sys.exit(130)
