-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- Firmware module

local FW = {}

local dev, publish

-- Firmware module parameters

-- Declare module functions below

local function update(msg)
  idx = msg:find("\n")
  fname = msg:sub(0, idx-1)

  fd = file.open(fname..".tmp", "w+")
  if fd then
    -- write 'foo bar' to the end of the file
    fd:write(msg:sub(idx+1))
    fd:close()
  end
  if (file.exists(fname..".lua")) then
    print("remove existing file")
    file.remove(fname..".lua")
  end
  file.rename(fname..".tmp", fname..".lua")
end

local function restart()
  node.restart()
end

-- Initialisation function
local function init_fw(d, p)
  dev = d
  publish = p
end

-- Table of functions 
local actions = {
  ["init"] = init_fw,
  ["update"] = update,
  ["restart"] = restart
}

-- These 2 methods are needed by micro-service framework
FW.init = init_fw
FW.actions = actions
-- These methods are only needed for external use of the LED module
FW.update = update
FW.restart = restart

return FW
