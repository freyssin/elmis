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
