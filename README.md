# eLMIS (eLua MQTT IoT service platform)

A micro-service eLUA / MQTT platform for the IoT World with NodeMCU.

## Firmware requirements

In order to run eLMIS needs somes specific firmware modules, you may build such a
firmware from the [NodeMCU cloud build service](https://nodemcu-build.com). You need
to nclude the following modules: bit, cjson, cron, dht, file, gpio, i2c, mqtt, net,
node, ow, pwm, rtctime, tmr, u8g, uart, wifi, ws2812.

Many of these modules are only needed for some specific components of the framework,
so you can build a restrained firmware depending of your project.

## Base framework

The base framework consists of 2 modules:

* The first one (init.lua) initializes the WiFI network and then launches the framework.
The network credentials (SSID and password) are stored in the config_net.lua file.
* The second one (startup.lua) initializes the MQTT communications and registers all the
requested components. This module use 2 configuration file:
  * config_mqtt.lua
  * config_dev.lua

#### Firmware requirements

mqtt, net, tmr, wifi.

### init.lua

This component allow to first setup the WiFi connection and then launch the framework.
In order to avoid a PANIC loop it defines a 3 seconds pause (see
[NodeMCU init.lua](https://nodemcu.readthedocs.io/en/master/en/upload/#initlua)).

#### config_net.lua

This configuration file defines the SSID and password needed to connect to your WiFi
network.

### startup.lua

This component initializes the MQTT connection according to the parameters in
config_mqtt.lua configuration file. Next it initializes each component listed in the
config_dev.lua configuration file.

#### Framework component

Each component returns a description table with at least an initialisation function
(called by the framework), and a table defining all remote actions.

Each remote action can be remotely invoked by sending a message on the
${ctrl}/${device}/${method} topic. For example, the relay component defines 2 remote
actions allowing to remotely toggle or blink the relay by sending messages on
${ctrl}/relay/toggle or ${ctrl}/relay/blink topics.

A component can publishes datas on ${data}/${device}/${resource} topics. For example,
a DHT22 component will regularly publish messages on ${data}/dht22/temperature and
${data}/dht22/humidity topics.

#### config_mqtt.lua

This file contains the MQTT configuration:

* MQTT URI and credentials.
* The session's options.
* The unique device identifier (also used as MQTT client identifier).
* The topic tree convention.

```lua
mqtt_broker="192.168.1.80"
mqtt_port=1883
mqtt_user=nil
mqtt_password=nil
mqtt_clean=1
deviceID = "nodemcu01"
data="/dev/data/"..deviceID.."/"
ctrl="/dev/ctrl/"..deviceID.."/"
```

#### config_dev.lua

This file contains the declaration of a unique global variable devices_list defining the list of all components to initialize.

```lua
devices_list = { "device", "firmware", "led", "dht22", "relay" }
```

### MQTT conventions

## Build a new module

### X.lua

## Extended framework

Each component corresponds to a device, for example a Wemos shield.

### device.lua

### firmware.lua

## Additionnals component

### led.lua

### sht30.lua

### dht22.lua

### relay.lua
