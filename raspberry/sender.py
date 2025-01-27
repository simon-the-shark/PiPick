#!/usr/bin/env python3

# pylint: disable=no-member

import sys
import time
import RPi.GPIO as GPIO
from raspberry.config import *  # pylint: disable=unused-wildcard-import
from mfrc522 import MFRC522
import board
import neopixel
import datetime
import paho.mqtt.client as mqtt
import json
# The terminal ID - can be any string.
terminal_id = "T0"
# The broker name or IP address.
broker = "localhost"
# broker = "127.0.0.1"
# broker = "10.0.0.1"

# The MQTT client.
client = mqtt.Client()

def call_worker(payload):
    payload["client_name"] = "drzwi_01"
    client.publish("worker/name", json.dumps(payload))


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

def rfidRead():
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
                pixels.fill((255, 0, 0))
                pixels.show()
                call_worker({"num": num, "zoneId": 1, "rfidCard": str(uid), "date": now_date.isoformat()})
                
                buzzer(True)
                time.sleep(0.5)
                buzzer(False)

                
               
                read_success = True
    
    go_away = True

    while go_away:
        (status,uid) = MIFAREReader.MFRC522_Anticoll()
        if status != MIFAREReader.MI_OK:
            go_away = False
        else:
            print("HOLDING!!!")
            time.sleep(0.2)
            
        
    pixels.fill((0,0,0))
    pixels.show()

def test():
    connect_to_broker()
    print('\nThe RFID reader test.')
    print('Place the card close to the reader (on the right side of the set).')
    client.loop_start()
    while True:
        rfidRead()
        



if __name__ == "__main__":
    try:
        test()
    except KeyboardInterrupt:
        GPIO.cleanup()  # pylint: disable=no-member
        client.loop_stop()
        disconnect_from_broker()
        sys.exit(130)
