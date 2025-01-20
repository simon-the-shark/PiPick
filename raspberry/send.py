import paho.mqtt.client as mqtt

broker = "localhost"
# broker = "127.0.0.1"
# broker = "10.0.0.1"

# The MQTT client.
client = mqtt.Client()

client.connect(broker)
client.loop_start()

client.publish("pipick/logs", "")