-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 - 2018 ScalAgent Distributed Technologies

-- Relay module

-- Normally the relay use the pin 4 (GPIO2) and is not compatible with I2C
-- devices. This component corresponds to a modified shield using pin 5.

local RELAY = {}

local dev, publish

-- Relay shield parameters

local gpio_pin = 5
local gpio_state = gpio.LOW
local delay = 1000

-- Declare module functions below

function on_relay()
  gpio_state = gpio.HIGH
  gpio.write(gpio_pin, gpio_state)
end

function off_relay()
  gpio_state = gpio.LOW
  gpio.write(gpio_pin, gpio_state)
end

local function set_relay(msg)
  if msg == "true" then
  	on_relay()
  else
  	off_relay()
  end
end

function toggle_relay()
  if gpio_state == gpio.LOW then
    gpio_state = gpio.HIGH
  else
    gpio_state = gpio.LOW
  end
  gpio.write(gpio_pin, gpio_state)
end

function blink_relay()
  toggle_relay()
  tmr.create():alarm(delay, tmr.ALARM_SINGLE, toggle_relay)
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
  ["toggle"] = toggle_relay,
  ["blink"] = blink_relay,
  ["on"] = on_relay,
  ["off"] = off_relay,
  ["set"] = set_relay
}

-- These 2 methods are needed by micro-service framework
RELAY.init = init
RELAY.actions = actions
-- These methods are only needed for external use of the relay module
RELAY.toggle = toggle_relay
RELAY.blink = blink_relay
RELAY.set = set_relay

return RELAY
