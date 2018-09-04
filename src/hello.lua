-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Hello module

local Hello = {}

local dev, publish

-- Hello shield parameters

-- If period set to 0 datas shall be get explicitly, otherwise the device
-- send data automatically. Set by default to 10s in init_hello.
local period=0
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

local function register(p)
  if (p > 0) then
    if (p < 1000) then
      p = 1000
    end
    if (period > 0) then
      timer:interval(p)
    else
      timer:register(p, tmr.ALARM_AUTO, send_msg)
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
local function init_hello(d, p)
  dev = d
  publish = p
  -- Add the initialisation of the Hello shield
  register(10000)
end

-- Table of functions 
local actions = {
  ["set_hello"] = set_msg,
  ["set_period"] = set_period,
  ["say_hello"] = send_msg
}

-- These 2 methods are needed by micro-service framework
Hello.init = init_hello
Hello.actions = actions
-- These methods below are only needed for external use of the X module
Hello.set_msg = set_msg
Hello.set_period = set_period
Hello.send_msg = send_msg

return Hello
