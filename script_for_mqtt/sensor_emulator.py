import paho.mqtt.client as mqtt
import time
import random

broker = "broker.emqx.io"
port = 1883
topic = "weathertracker/nazar/sensor1"
client_id = "python_sensor_nazar_001"

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id)

print(f"Підключення до брокера {broker}...")
client.connect(broker, port)
print("Підключено! Починаю генерацію погоди...\n")

try:
    while True:
        temperature = random.randint(18, 30)
        
        payload = f"{temperature}°C"
        
        client.publish(topic, payload)
        print(f"Відправлено в топік '{topic}': {payload}")
        time.sleep(5) 

except KeyboardInterrupt:
    client.disconnect()