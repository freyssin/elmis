-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 - 2018 ScalAgent Distributed Technologies

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
  print("recv "..dev_id..", "..method)
  execute(dev_id, method, msg)
end

local function publish(dev, rsrc, msg)
  if connected then
    -- Avoids to send a message when disconnected (can cause a panic).
    -- May be we should postpone this message with a timer.
    m:publish(data..dev.."/"..rsrc, msg, 0, 1)
  end
end

local function register(name)
  -- Load the module
  if (file.exists(name..".lua")) then
    devices[name] = require(name)
    -- Initialize the module registering accessible commands
    devices[name].init(name, publish)
  else
    print("cannot load "..name..".lua")
  end
end

local function register_all()
  -- Load all registered modules
  for i in pairs(devices_list) do
    dev = devices_list[i]
    print("Register "..dev)
    register(dev)
  end
end

local function on_connect(client, first)
  print ("MQTT connected")
  connected = true
  if first then
    m:subscribe(ctrl.."#",0, function(client) print("subscribe success") end)
    register_all()
  end
  m:publish(data.."status", "on", 0, 1)
end

function handle_mqtt_error(client, reason)
  print("failed reason: "..reason)
  connected = false
  tmr.create():alarm(1000, tmr.ALARM_SINGLE, function(client) do_mqtt_connect(client, false) end)
end

function do_mqtt_connect(client, first)
  if wifi.sta.status() ~= wifi.STA_GOTIP then
    print("Wait IP..")
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, function(client) do_mqtt_connect(client, first) end)
  else
    print("MQTT connect..")
    -- m:connect("server", function(client) print("connected") end, handle_mqtt_error)
    m:connect(mqtt_broker, mqtt_port, 0, 0, function(client) on_connect(client, first) end, handle_mqtt_error)
  end
end

local function mqtt_connect()
  m = mqtt.Client(deviceID, 120, mqtt_user, mqtt_password, mqtt_clean)
  m:lwt(data.."status", "off", 0, 1)
  m:on("offline", function(client) handle_mqtt_error(client, "offline") end)
  m:on("message", function(client, topic, msg) on_message(client, topic, msg) end)
  do_mqtt_connect(m, true)
end

mqtt_connect()
