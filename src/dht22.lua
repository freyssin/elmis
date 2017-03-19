-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Get temperature and humidity from DHT11/22 field

local DHT = {}

local dev, publish

-- DHT shield parameters
local pin_dht=4

-- Declare module functions below

local function get_data()
  -- get data
  status, temp, humi, temp_dec, humi_dec = dht.read(4)
  if status == dht.OK then
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

-- If observe is true device the device send data automatically, otherwise
-- datas shall be get explicitly
local observe=true
local period=10000
local timer = tmr.create()

-- Initialisation function
local function init_dht(d, p)
  dev = d
  publish = p
  if observe then
    timer:register(period, tmr.ALARM_AUTO, get_data)
    timer:start()
  end
end

local actions = {
  ["init"] = init_dht,
  ["get_data"] = get_data
}

-- These 2 methods are needed by micro-service framework
DHT.init = init_dht
DHT.actions = actions
-- These methods are only needed for external use of the LED module
DHT.get_data = get_data

return DHT
