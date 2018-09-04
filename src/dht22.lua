-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 - 2018 ScalAgent Distributed Technologies

-- Get temperature and humidity from DHT11/22 field

local DHT = {}

local dev, publish

-- DHT shield parameters
local pin_dht=4

-- Declare module functions below

local function get_data()
  -- get data
  status, temp, humi, temp_dec, humi_dec = dht.read(pin_dht)
  if status == dht.OK then
    print("temperature="..(temp).."."..(temp_dec)..", humidity="..(humi).."."..(humi_dec))
    -- send message
    msg=""..(temp).."."..(temp_dec)
    publish(dev, "temperature", msg)
    msg=""..(humi).."."..(humi_dec)
    publish(dev, "humidity", msg)
  elseif status == dht.ERROR_CHECKSUM then
    print( "DHT Checksum error." )
  elseif status == dht.ERROR_TIMEOUT then
    print( "DHT timed out." )
  end
end

-- If period set to 0 datas shall be get explicitly, otherwise the device
-- send data automatically. Set by default to 10s in init_dht.
local period=0
local timer = tmr.create()

local function register(p)
  if (p > 0) then
    if (p < 5000) then
      p = 5000
    end
    if (period > 0) then
      timer:interval(p)
    else
      timer:register(p, tmr.ALARM_AUTO, get_data)
      timer:start()
    end
    period = p
  else
    if (period > 0) then
      timer:unregister();
    end
    period = 0
  end
end

local function set_period(m)
  p = tonumber(m)
  if (p ~= nil) then
    register(p)
  end
end

-- Initialisation function
local function init_dht(d, p)
  dev = d
  publish = p
  -- Add the initialisation of the DHT22 shield
  register(10000)
end

local actions = {
  ["get_data"] = get_data,
  ["set_period"] = set_period
}

-- These 2 methods are needed by micro-service framework
DHT.init = init_dht
DHT.actions = actions
-- These methods are only needed for external use of the DHT module
DHT.get_data = get_data
DHT.set_period = set_period

return DHT
