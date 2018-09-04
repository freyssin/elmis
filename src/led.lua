-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Play with blue led on board (Wemos or ESP8266)

local LED = {}

local dev, publish

-- Led shield parameters

local delay=1000
local pin_led = 4  -- GPIO 2 Blue led
local lighton = gpio.HIGH

-- Declare module functions below

local function toggle()
  if lighton == gpio.LOW then
    lighton = gpio.HIGH
  else
    lighton = gpio.LOW
  end
  gpio.write(pin_led, lighton)
end

local function blink()
  toggle()
  tmr.create():alarm(delay, tmr.ALARM_SINGLE, toggle)
end

-- Initialisation function
local function init(d, p)
  dev = d
  publish = p
  -- Initializes the shield
  gpio.mode(pin_led, gpio.OUTPUT)
  gpio.write(pin_led, lighton)
end

-- Table of functions 
local actions = {
  ["toggle"] = toggle,
  ["blink"] = blink
}

-- These 2 methods are needed by micro-service framework
LED.init = init
LED.actions = actions
-- These methods are only needed for external use of the LED module
LED.toggle = toggle
LED.blink = blink

return LED
