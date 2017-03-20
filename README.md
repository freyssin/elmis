# eLMIS (**eL**ua **M**QTT **I**oT **S**ervice Platform)

A micro-service eLUA / MQTT platform for the IoT World with NodeMCU.

## Firmware requirements

In order to run eLMIS you need somes specific firmware modules. You may build such a
firmware from the [NodeMCU cloud build service](https://nodemcu-build.com).

You need to include the following modules: bit, cjson, cron, dht, file, gpio, i2c,
mqtt, net, node, ow, pwm, rtctime, tmr, u8g, uart, wifi, ws2812.

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

#### Published datas

The component publish retained messages on the ${data}/${device}/status topic:

* "on" after initialisation
* "off" in case of failure or shutdown (using the will MQTT functionnality).

#### Framework component

Each component *comp* returns a description table with at least an initialisation function
(called by the framework), and a table defining all remote actions.

Each remote action can be remotely invoked by sending a message on the
${ctrl}/${device}/${comp}/${method} topic. For example, the relay component defines
2 remote actions allowing to remotely toggle or blink the relay by sending messages
on ${ctrl/${device}}/relay/toggle or ${ctrl}/${device}/relay/blink topics.

A component can publishes datas on ${data}/${device}/${resource} topics. For example,
a DHT22 component will regularly publish messages on ${data}/dht22/temperature and
${data}/${device}/dht22/humidity topics.

#### config_mqtt.lua

This file contains the MQTT configuration:

* MQTT URI and credentials.
* The session's options.
* The unique device identifier (also used as MQTT client identifier).
* The topic tree convention.

For example:
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

This file contains the declaration of a unique global variable devices_list defining
the list of all components to initialize.

For example:
```lua
devices_list = { "device", "firmware", "led", "dht22", "relay" }
```

## Build a new module

This section explains how to build a new component using the eLMIS platform.

### X.lua

The X.lua file contains the canvas for an empty component, you can use it to define
your own components.

## Extended framework

The components below correspond to extended functionnaly of the platform, for example
giving extra informations about the device or its configuration, or allowing OTA
(Other The Air) configuration or updates.

### device.lua

This component allows to get information about the device and its configuration.

#### Remote actions

* **get_info**: Returns various informations about firmware version, chip and flash
identifiers. The request message is empty, the reply is sent as a unique message on
${data}/${device}/info topic.
* **get_fsinfo**: Returns informations about the filesystem.  The request message is
empty, the reply is sent as a unique message on ${data}/${device}/fsinfo topic.

#### Published datas

Currently empty.

### firmware.lua

This component allows to control the platorm, currently software updates and restart.

#### Remote actions

* **update**: Updates the requesting LUA file. The basename of file to update is given
in the first line of the message (without extension), the next lines of the message
contains the new file content.
* **restart**: Asks to restart the device.

#### Published datas

Currently empty.

#### Software updates

The update is made atomically, a file named *${basename}.tmp* is first created with the content of the message then renamed *${basename}.lua*.

## Additionnal components

Each component below corresponds to a device, for example a Wemos shield.

### led.lua

This component allows to play with the blue led on the NodeMCU board.
Be careful this component use GPIO2 also used by SHT30 shield.
 
#### Remote actions

* **toggle**: change the state of the GPIO2 associated to the blue led on boead. At
initialisation the state is *gpio.HIGH*.
* **blink**: temporarily change during 1 second the state of the GPIO2 associated to
the led. The period of change is defined in milliseconds by the delay local variable.

#### Published datas

Currently empty.

### sht30.lua

This component correponds to the use of the Wemos SHT30 shield.
Be careful, the Wemos SHT30 shield is not compatible with the relay shield.

#### Remote actions

Currently there is only one remote action defined, it allows to explicitly get
data from the corresponding sensor. In future we can whish methods allowing to
dynamically configure the component, for example to toggle it in observation mode,
or to fix the observation period.

* **get_data**: trigger the publication of the sensor's temperature and humidity
datas on the corresponding topics *${data}/${device}/sht30/temperature* and
*${data}/${device}/sht30/humidity*.

#### Published datas

If the component is initialized in observation mode it publishes regularly (see period
local variable) the sensor's temperature and humidity datas.

* **temperature**: 
* **humidity**: 

### dht22.lua

This component correponds to the use of the Wemos DHT22 shield.
It should be used as is with a DHT11 shield.

#### Remote actions

Currently there is only one remote action defined, it allows to explicitly get
data from the corresponding sensor. In future we can whish methods allowing to
dynamically configure the component, for example to toggle it in observation mode,
or to fix the observation period.

* **get_data**: trigger the publication of the sensor's temperature and humidity
datas on the corresponding topics *${data}/${device}/dht22/temperature* and
*${data}/${device}/dht22/humidity*.

#### Published datas

If the component is initialized in observation mode it publishes regularly (see period
local variable) the sensor's temperature and humidity datas.

* **temperature**: 
* **humidity**: 

### relay.lua

This component correponds to the use of the Wemos relay shield.
Be careful, the Wemos relay shield is not compatible with the SHT30 shield.

#### Remote actions

* **toggle**: change the state of the GPIO5 associated to the Wemos relay shield. At
starting the state is *gpio.LOW*.
* **blink**: temporarily change during 1 second the state of the GPIO5 associated to
the shield. The period of change is defined in milliseconds by the delay local variable.

#### Published datas

Currently empty.
