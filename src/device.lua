-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Device module

local DEV = {}

local dev, publish

-- Device module parameters

-- Declare module functions below

local function get_info(msg)
  local major, minor, v, chipid, flashid = node.info()
  local msg = major.."."..minor..","..v..","..chipid..","..flashid
  publish(dev, "info", msg)
end

local function get_fsinfo(msg)
  publish(dev, "fsinfo", file.fsinfo())
end

-- Initialisation function
local function init_dev(d, p)
  dev = d
  publish = p
end

-- Table of functions 
local actions = {
  ["init"] = init_dev,
  ["get_info"] = get_info,
  ["get_fsinfo"] = get_fsinfo
}

-- These 2 methods are needed by micro-service framework
DEV.init = init_dev
DEV.actions = actions
-- These methods are only needed for external use of the LED module
DEV.get_info = get_info
DEV.get_fsinfo = get_fsinfo

return DEV
