# eLMIS (*eL*ua *M*QTT *I*oT *S*ervice Platform)

A micro-service eLUA / MQTT platform for the IoT World with NodeMCU.

----

## Firmware requirements

**eLMIS** framwework depends on [NodeMCU](https://nodemcu.readthedocs.io/en/master/),
an eLua based firmware for the ESP8266 WiFi SOC from Espressif. In order to use eLMIS
you need somes specific firmware modules. You may build such a firmware from the
[NodeMCU cloud build service](https://nodemcu-build.com).

You need to include the following modules: bit, cjson, cron, dht, file, gpio, i2c,
mqtt, net, node, ow, pwm, rtctime, tmr, u8g, uart, wifi, ws2812.

Many of these modules are only needed for some specific components of the framework,
so you can build a restrained firmware depending of your project.

----

## Base framework

The base framework consists of 2 modules:

* The first one (init.lua) initializes the WiFI network and then launches the framework.
The network credentials (SSID and password) are stored in the config_net.lua file.
* The second one (startup.lua) initializes the MQTT communications and registers all the
requested components. This module use 2 configuration files:
  * config_mqtt.lua
  * config_dev.lua

#### Firmware requirements

mqtt, net, tmr, wifi.

### Initialisation component: *init.lua*

This component allow to first setup the WiFi connection and then launch the framework.
In order to avoid a PANIC loop it defines a 3 seconds pause that would allow you to
interrupt the sequence by e.g. deleting or renaming init.lua file (see
[NodeMCU init.lua](https://nodemcu.readthedocs.io/en/master/en/upload/#initlua)).

#### Configuration: *config_net.lua*

This configuration file defines the SSID and password needed to connect to your WiFi
network, for example:
```lua
ssid = "xxxxxxxx"
pwd = "xxxxxxxx"
```


### Base component: *startup.lua*

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

#### Configuration: *config_mqtt.lua*

This file contains the MQTT configuration:

* MQTT URI and credentials.
* The session's options.
* The unique device identifier (also used as MQTT client identifier).
* The topic tree convention.

For example:
```lua
-- Define MQTT URI
mqtt_broker="192.168.1.80"
mqtt_port=1883

-- Define MQTT credentials
mqtt_user=nil
mqtt_password=nil

-- Define session parameters
mqtt_clean=1

-- Define device identifier
deviceID = "nodemcu01"

-- Define the MQTT topics paths for datas and control
data="/dev/data/"..deviceID.."/"
ctrl="/dev/ctrl/"..deviceID.."/"
```

#### Configuration: *config_dev.lua*

This file contains the declaration of a unique global variable devices_list defining
the list of all components to initialize.

For example:
```lua
devices_list = { "device", "firmware", "led", "dht22", "relay" }
```

----

## Build a new module

This section explains how to build a new component using the eLMIS platform.

### X.lua

The X.lua file contains an empty component, you can use it as a canvas. To build
your own component from the X canvas you need:
1. Add the variables and functions needed by the X shield in the related
sections. Pay attention to declare local variables and functions to avoid
collision with declaration in other components.
  * If you need to send datas about X resources you may use the publish
  function. The first parameter is the name of yourdevice (contained in the
dev local variable), the second parameter is the name of the resource (for
example *temperature* or *humidity* for the DHT22 device), and the last
parameter is the message.
2. Add the initialisation code needed by the X shield in the init_x
functions.
3. Add the [remote actions](#framework-component) in the actions table.
  * Declare as *remote actions* each method that you want remotely invoked by
  sending a message.
  * if the key associated to the method in the *actions* table is m1,
  the method will be invoked each time a message will be sent on the
  *${ctrl}/${device}/X/m1* topic.
4. Add in the X table each method of the component that you want to use
from the outside. Remote actions don't need to be declared in this table,
from the framework point of view only init method and actions table are
needed.
5. Add the X component in the *devices_list table* of the *config_dev.lua* file.

For example, you can build an Hello component with specification below:
* Send regularly an *hello* message on the "hello" resource.
* Define a *remote actions* "set_hello" allowing to change the *hello* message.

```lua
-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Hello module

local Hello = {}

local dev, publish

-- Hello shield parameters

local period=10000
local timer = tmr.create()
local msg = "Hello world"

-- Declare component functions below

local function set_msg(m)
  print("set_msg: ".. m)
  msg = m
end

local function send_msg()
  publish(dev, "hello", msg)
end

-- Initialisation function
local function init_hello(d, p)
  dev = d
  publish = p
  -- Add the initialisation of the X shield if needed below
  timer:register(period, tmr.ALARM_AUTO, send_msg)
  timer:start()
end

-- Table of functions 
local actions = {
  ["init"] = init_hello,
  ["set_hello"] = set_msg
}

-- These 2 methods are needed by micro-service framework
Hello.init = init_hello
Hello.actions = actions
-- These methods below are only needed for external use of the X module
Hello.set_msg = set_msg
Hello.send_msg = send_msg

return Hello
```

----

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

----

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

This component correponds to the use of the old Wemos DHT shield based on DHT11
or DHT22.
It should be used as is with a DHT11 or DHT22 shield.

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

### dht12.lua

This component correponds to the use of the new Wemos DHT shield based on DHT12.
Be careful, this new Wemos DHT shield is not compatible with the relay shield.

#### Remote actions

Currently there is only one remote action defined, it allows to explicitly get
data from the corresponding sensor. In future we can whish methods allowing to
dynamically configure the component, for example to toggle it in observation mode,
or to fix the observation period.

* **get_data**: trigger the publication of the sensor's temperature and humidity
datas on the corresponding topics *${data}/${device}/dht12/temperature* and
*${data}/${device}/dht12/humidity*.

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

### WS2812.lua

This component correponds to the use of the Wemos WS2812 led shield.
Be careful, the Wemos WS2812 led shield is not compatible with i2c components
like SHT30 or DHT12.

The led state is defined first by its status (on | off), and second by its color.
There are 7 predefined colors: red, green, blue, yellow, magenta, cyan and
white.
At starting the led is off and its color is *green*.

#### Remote actions

* **on**: set on the RGB led with the color given in parameter. If there is no
parameter or if the color is not defined the color is not changed.
* **color**: change the color of the led with the color given in parameter. If
there is no parameter or if the color is not defined the color is not changed.
The color change will taken in account to the next state change.
* **toggle**: change the state of the RGB led (on -> off, and off -> on).
* **blink**: temporarily change during 1 second the state of the RGB led. The
period of change is defined in milliseconds by the delay local variable.
* **off**: set off the RGB led.

#### Published datas

Currently empty.

----
