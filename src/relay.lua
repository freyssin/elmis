-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Relay module

local RELAY = {}

local dev, publish

-- Relay shield parameters

local gpio_pin = 4  -- GPIO 2 Blue led
local gpio_state = gpio.LOW
local delay = 1000

-- Declare module functions below

function toggle()
  if gpio_state == gpio.LOW then
    gpio_state = gpio.HIGH
  else
    gpio_state = gpio.LOW
  end
  gpio.write(gpio_pin, gpio_state)
end

function blink()
  toggle()
  tmr.create():alarm(delay, tmr.ALARM_SINGLE, toggle)
end

-- Initialisation function
local function init(d, p)
  dev = d
  publish = p
  -- Initializes the shield
  gpio.mode(gpio_pin, gpio.OUTPUT)
  gpio.write(gpio_pin, gpio_state)
end

-- Table of functions 
local actions = {
  ["init"] = init,
  ["toggle"] = toggle,
  ["blink"] = blink
}

-- These 2 methods are needed by micro-service framework
RELAY.init = init
RELAY.actions = actions
-- These methods are only needed for external use of the relay module
RELAY.toggle = toggle
RELAY.blink = blink

return RELAY
