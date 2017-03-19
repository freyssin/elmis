-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- load MQTT configuration
dofile("config_mqtt.lua")
-- load modules configuration
dofile("config_dev.lua")

-- List of all device's modules registered by name
local devices = {}

local function execute(dev_id, method, param)
  device = devices[dev_id]
  if device  ~= nil then
    action = device.actions[method]
    if action  ~= nil then
      action(param)
    else
      print(dev_id.. " unknown method: "..method)
    end
  else
    print("Unknown device: "..dev_id)
  end
  
end

local function on_message(client, topic, msg)
  base = string.match(topic, "(.*/).*/.*")
  if base ~= ctrl then
    print("Receive message on bad topic: "..topic)
    return
  end
  dev_id = string.match(topic, ".*/(.*)/.*")
  method = string.match(topic, ".*/(.*)")
  execute(dev_id, method, msg)
end

local function publish(dev, rsrc, msg)
  m:publish(data..dev.."/"..rsrc, msg, 0, 1)
end

local function register()
  -- Load all registered modules
  for i in pairs(devices_list) do
    dev = devices_list[i]
    print("Register "..dev)
    -- Load each needed module
    devices[dev] = require(dev)
    -- Initialize each module registering accessible commands
    devices[dev].init(dev, publish)
  end
end

local function on_connect(client)
  print ("MQTT connected")

  m:subscribe(ctrl.."#",0, function(client) print("subscribe success") end)
  m:publish(data.."status", "on", 0, 1)
  
  register()
end

local function mqtt_connect()
  m = mqtt.Client(deviceID, 120, mqtt_user, mqtt_password, mqtt_clean)
  m:lwt(data.."status", "off", 0, 1)
  m:on("offline", function(client) print ("offline") end)
  m:on("message", function(client, topic, msg) on_message(client, topic, msg) end)
  m:connect(mqtt_broker, mqtt_port, 0, 1, function(client) on_connect(client) end,function(client, reason) print("failed reason: "..reason) end)
  print("MQTT connect.. ")
end

mqtt_connect()
