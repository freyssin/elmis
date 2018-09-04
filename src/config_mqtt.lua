-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 - 2018 ScalAgent Distributed Technologies

-- Define MQTT URI
-- mqtt_broker="xx.xx.xx.xx"
mqtt_broker="192.168.1.80"
mqtt_port=1883

-- Define MQTT credentials
mqtt_user=nil
mqtt_password=nil

-- Define session parameters (Shall be false)
mqtt_clean=0

-- Define device identifier
deviceID = "nodemcu01"

-- Define the MQTT topics paths for datas and control
data="/dev/data/"..deviceID.."/"
ctrl="/dev/ctrl/"..deviceID.."/"
