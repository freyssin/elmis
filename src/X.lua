-- LGPL v3 License (Free Software Foundation)
-- Copyright (C) 2017 ScalAgent Distributed Technologies

-- X module

local X = {}

local dev, publish

-- X shield parameters

-- Declare component functions below

-- Initialisation function
local function init_x(d, p)
  dev = d
  publish = p
  -- Add the initialisation of the X shield if needed below
end

-- Table of functions 
local actions = {
}

-- These 2 methods are needed by micro-service framework
X.init = init_x
X.actions = actions
-- These methods below are only needed for external use of the X module

return X
