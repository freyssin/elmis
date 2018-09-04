-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Device module

local DEV = {}

local dev, publish

-- Device module parameters

-- Declare module functions below

local function get_info()
  local major, minor, v, chipid, flashid = node.info()
  local msg = major.."."..minor..","..v..","..chipid..","..flashid
  publish(dev, "info", msg)
end

local function get_fsinfo()
  publish(dev, "fsinfo", file.fsinfo())
end

local function get_heap()
  publish(dev, "heap", node.heap())
end

local function get_flashsize()
  publish(dev, "flashsize", node.flashsize())
end

local function restart()
  node.restart()
end

-- Initialisation function
local function init_dev(d, p)
  dev = d
  publish = p
end

-- Table of functions 
local actions = {
  ["get_info"] = get_info,
  ["get_fsinfo"] = get_fsinfo,
  ["get_heap"] = get_heap,
  ["get_flashsize"] = get_flashsize,
  ["restart"] = restart
}

-- These 2 methods are needed by micro-service framework
DEV.init = init_dev
DEV.actions = actions
-- These methods are only needed for external use of the device module
DEV.get_info = get_info
DEV.get_fsinfo = get_fsinfo
DEV.get_heap = get_heap
DEV.get_flashsize = get_flashsize
DEV.restart = restart

return DEV
