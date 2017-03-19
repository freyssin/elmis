-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- X module

local X = {}

local dev, publish

-- X shield parameters

-- Declare module functions below

local function m1()
end

-- Initialisation function
local function init_x(d, p)
  dev = d
  publish = p
end

-- Table of functions 
local actions = {
  ["init"] = init_dht,
  ["m1"] = m1
}

-- These 2 methods are needed by micro-service framework
X.init = init_dht
X.actions = actions
-- These methods are only needed for external use of the LED module
X.m1 = m1

return X
