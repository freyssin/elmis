-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2019 ScalAgent Distributed Technologies

-- Get brightness from BH1750 shield

local BH1750 = {}

local dev, publish

-- Now a bh1750 module is available from nodemcu firmware

-- BH1750 shield and I2C parameters
local id  = 0
local sda = 2 -- pin D2
local scl = 1 -- pin D1
local dev_addr = 0x23 -- BH1750

local delay=180 -- 120/180 ms
local lux = -1

local function get_data2()
  local data, temp, humi, msg
  
  -- get data
  i2c.start(id)
  ack = i2c.address(id, dev_addr, i2c.RECEIVER)
  data = i2c.read(id, 2) -- read 2 bytes
  i2c.stop(id)

  -- calculate brightness (2 data bytes)
  lux = ((data:byte(1)*256 + data:byte(2))*1000)/12

  print("ambient light="..lux)

  -- send message
  msg=""..(lux/100).."."..(lux%100)
  publish(dev, "ambient", msg)
end

local function get_data()
  -- send command
  i2c.start(id)
  ack = i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x21)
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
  if (p ~= nil) then
    register(p)
  end
end

-- Initialisation function
local function init_bh1750(d, p)
  dev = d
  publish = p
  -- Add the initialisation of the BH1750 shield
  i2c.setup(id, sda, scl, i2c.SLOW)
  register(10000)
end

local actions = {
  ["get_data"] = get_data,
  ["set_period"] = set_period
}

BH1750.init = init_bh1750
BH1750.actions = actions
-- These methods are only needed for external use of the BH1750 module
BH1750.get_data = get_data
BH1750.set_period = set_period

return BH1750
