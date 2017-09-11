-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Get temperature and humidity from SHT30 field

local DHT12 = {}

local dev, publish

-- SHT shield and I2C parameters
local id  = 0
local sda = 2 -- pin D2
local scl = 1 -- pin D1
local dev_addr = 0x5C -- DHT12

local delay=14 -- 13500us

local function get_data2()
  local data, temp, humi, msg
  
  -- get data
  i2c.start(id)
  ack = i2c.address(id, dev_addr, i2c.RECEIVER)
  data = i2c.read(id, 5) -- read 5 bytes
  i2c.stop(id)

  -- calculate temperature (2 data bytes) and humidity (2 data bytes) + 1 checksum byte)
  crc = data:byte(1) + data:byte(2) + data:byte(3) + data:byte(4)
  if (crc ~= data:byte(5)) then
    print("get_data CRC nok")
  end

  -- send message
  msg=""..(data:byte(3)).."."..(data:byte(4))
  publish(dev, "temperature", msg)
  msg=""..(data:byte(1)).."."..(data:byte(2))
  publish(dev, "humidity", msg)
end

local function get_data()
  print("get_data")
  -- send command
  i2c.start(id)
  ack = i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0)
  i2c.stop(id)

  tmr.create():alarm(delay, tmr.ALARM_SINGLE, get_data2)
end

-- If period set to 0 datas shall be get explicitly, otherwise the device
-- send data automatically. Set by default to 10s in init_sht.
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
  register(p)
end

-- Initialisation function
local function init_dht(d, p)
  dev = d
  publish = p
  -- Add the initialisation of the SHT shield
  i2c.setup(id, sda, scl, i2c.SLOW)
  register(10000)
end

local actions = {
  ["init"] = init_dht,
  ["get_data"] = get_data,
  ["set_period"] = set_period
}

DHT12.init = init_dht
DHT12.actions = actions
-- These methods are only needed for external use of the SHT module
DHT12.get_data = get_data
DHT12.set_period = set_period

return DHT12
