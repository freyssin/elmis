-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- WS2812 module
-- NOTE: D4 (GPIO2) pin is used by the library, but shield uses D2 (GPIO4)

local WS2812 = {}

local dev, publish

-- WS2812 shield parameters

local delay=1000
local lighton = false

local colors = {
  ["red"]     = {0,90,0},
  ["green"]   = {90,0,0},
  ["blue"]    = {0,0,90},
  ["yellow"]  = {45,45,0},
  ["magenta"] = {0,45,45},
  ["cyan"]    = {45,0,45},
  ["white"]   = {30,30,30}
}

local off = {0,0,0}
local color = colors["green"]

-- Declare component functions below

local function set_color(msg)
  old = color
  color = colors[msg]
  if (color == nil) then
    color = old
  end
end

local function toggle_ws2812()
  if lighton == true then
    lighton = false
    ws2812.write(string.char(0,0,0))
  else
    lighton = true
    ws2812.write(string.char(color[1],color[2],color[3]))
  end
end

local function blink_ws2812()
  toggle_ws2812()
  tmr.create():alarm(delay, tmr.ALARM_SINGLE, toggle_ws2812)
end

local function on_ws2812(msg)
  set_color(msg)
  ws2812.write(string.char(color[1],color[2],color[3]))
end

local function off_ws2812()
  ws2812.write(string.char(0,0,0))
end

-- Initialisation function
local function init_ws2812(d, p)
  dev = d
  publish = p
  -- Initialisation of the WS2812 shield
  ws2812.init(ws2812.MODE_SINGLE)
  ws2812.write(string.char(0,0,0))
end

-- Table of functions 
local actions = {
  ["init"] = init_ws2812,
  ["on"] = on_ws2812,
  ["color"] = set_color,
  ["toggle"] = toggle_ws2812,
  ["blink"] = blink_ws2812,
  ["off"] = off_ws2812
}

-- These 2 methods are needed by micro-service framework
WS2812.init = init_ws2812
WS2812.actions = actions
-- These methods below are only needed for external use of the WS2812 module
WS2812.on = on_ws2812
WS2812.color = set_color
WS2812.toggle = toggle_ws2812
WS2812.blink = blink_ws2812
WS2812.off = off_ws2812

init_ws2812()
off_ws2812()

return WS2812
