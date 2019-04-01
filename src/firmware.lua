-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 -2019 ScalAgent Distributed Technologies

-- Firmware module

local FW = {}

local dev, publish

-- Firmware module parameters

-- Declare module functions below

local function remove(msg)
  print("remove..")
  idx = msg:find("\n")
  if idx ~= nil then
    fname = msg:sub(0, idx-1)
    print("remove "..fname)
    file.remove(fname)
    print("remove ok")
  end
end

local function append(msg)
  print("append..")
  idx = msg:find("\n")
  fname = msg:sub(0, idx-1)
  print("append "..fname)

  fd = file.open(fname, "a+")
  if fd then
    fd:write(msg:sub(idx+1))
    fd:flush()
    fd:close()
    print("append ok")
  end
end

local function rename(msg)
  print("rename..")
  idx1 = msg:find(" ")
  fnameold = msg:sub(0, idx1-1)
  idx2 = msg:find("\n")
  if (idx1 ~= nil) and (idx2 ~= nil) then
    print(idx1..", "..idx2)
    fnamenew = msg:sub(idx1+1, idx2-1)
    print("update "..fnameold.." -> "..fnamenew)

    if (file.exists(fnamenew)) then
      print("remove existing file")
      file.remove(fnamenew)
    end
    file.rename(fnameold, fnamenew)
    print("rename ok")
  end
end

local function update(msg)
  print("update..")
  idx = msg:find("\n")
  fname = msg:sub(0, idx-1)
  print("update "..fname)

  fd = file.open(fname..".tmp", "w+")
  if fd then
    -- write 'foo bar' to the end of the file
    fd:write(msg:sub(idx+1))
    fd:flush()
    fd:close()
  end
  if (file.exists(fname..".lua")) then
    print("remove existing file")
    file.remove(fname..".lua")
  end
  file.rename(fname..".tmp", fname..".lua")
  print("updated")
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
  ["update"] = update,
  ["restart"] = restart,
  ["remove"] = remove,
  ["append"] = append,
  ["rename"] = rename
}

-- These 2 methods are needed by micro-service framework
FW.init = init_fw
FW.actions = actions
-- These methods are only needed for external use of the LED module
FW.update = update
FW.restart = restart
FW.remove = remove
FW.append = append
FW.rename = rename

return FW
