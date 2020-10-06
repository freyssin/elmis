-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2019 ScalAgent Distributed Technologies

-- Get temperature and pressure from HP303B shield

local HP303B = {}

-- BH1750 shield and I2C parameters
local id  = 0
local sda = 2 -- pin D2
local scl = 1 -- pin D1
local dev_addr = 0x77 -- BH1750

local delay=50 -- 120/180 ms
local lux = -1

-- user defined function: read 1 byte of data from device
function read_reg(reg_addr)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, reg_addr)
    i2c.stop(id)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    c = i2c.read(id, 1)
    i2c.stop(id)
    return c:byte(1)
end

-- user defined function: write some data to device
-- with address dev_addr starting from reg_addr
function write_reg(reg_addr, data)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, reg_addr)
    c = i2c.write(id, data)
    i2c.stop(id)
    return c
end

-- {524288, 1572864, 3670016, 7864320, 253952, 516096, 1040384, 2088960}

function read_temperature()
   t = ((read_reg(5) + (read_reg(4)*256) + (read_reg(3)*65536)) * 100) / 253952
   print("Temperature="..read_reg(5)..", "..read_reg(4)..", "..read_reg(3).." -> "..t)
end

function read_pressure()
   p = ((read_reg(2) + (read_reg(1)*256) + (read_reg(0)*65536)) * 100) / 253952
   print("Pressure="..read_reg(2)..", "..read_reg(1)..", "..read_reg(0).." -> "..p)
end

local function get_data2()
  local data, temp, humi, msg
  
  -- get data
  i2c.start(id)
  ack = i2c.address(id, dev_addr, i2c.RECEIVER)
  data = i2c.read(id, 2) -- read 2 bytes
  i2c.stop(id)

  -- calculate brightness (2 data bytes) + 1 checksum byte)
  l = ((data:byte(1)*256 + data:byte(2))*1000)/12
  if (lux == -1) or ((lux - l) > 100) or ((l - lux) > 100) then
    lux = l
    -- send message
    print(data:byte(1)..", "..data:byte(2)..", "..(lux/100).."."..(lux%100))
  end
end

local function get_data()
  -- send command
  i2c.start(id)
  ack = i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x21)
  i2c.stop(id)

  tmr.create():alarm(delay, tmr.ALARM_SINGLE, get_data2)
end

-- Initialisation function
local function init()
  -- Add the initialisation of the BH1750 shield
  i2c.setup(id, sda, scl, i2c.SLOW)
  -- Set configuration
  write_reg(0x06, 0x04) -- Pressure configuration
  write_reg(0x07, 0x04) -- Temperature configuration
  write_reg(0x09, 0x00)
end

init()

-- mytimer = tmr.create()
-- mytimer:register(1000, tmr.ALARM_AUTO, get_data)
-- mytimer:start()

function get_temp()
  write_reg(0x08, 0x02)
  tmr.create():alarm(delay, tmr.ALARM_SINGLE, read_temperature)
end

function get_pressure()
  write_reg(0x08, 0x01)
  tmr.create():alarm(delay, tmr.ALARM_SINGLE, read_pressure)
end

get_temp()
tmr.create():alarm(2000, tmr.ALARM_SINGLE, get_pressure)
