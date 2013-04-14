-------------------------------------------------------------------------------
-- Copyright (c) 2013, Esoteric Software, TangerinaGames
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------

local utils = require "spine.utils"

-- auxiliar functions

local FILTERS = {
  Nearest=MOAITexture.GL_NEAREST,
  Linear=MOAITexture.GL_LINEAR,
  MipMapNearestNearest=MOAITexture.GL_NEAREST_MIPMAP_NEAREST, 
  MipMapLinearNearest=MOAITexture.GL_LINEAR_MIPMAP_NEAREST,
  MipMapNearestLinear=MOAITexture.GL_NEAREST_MIPMAP_LINEAR, 
  MipMapLinearLinear=MOAITexture.GL_LINEAR_MIPMAP_LINEAR
}

local function parseLine(data, line)
  if not line:find(":") then
    data.name = utils.trim(line)
  else
    local key, value = unpack(utils.split(line, ":"))
    value = utils.trim(value)
    if value:find(",") then
      value = utils.split(value, ",")
    elseif value == "false" then
      value = false
    elseif value == "true" then
      value = true
    end
    data[utils.trim(key)] = value
  end
end

local function load(self, atlas)
  local pageData = {}
  local regionsData = {}
  local regionData = {}

  for line in atlas:gmatch("[^\r\n]+") do
    if utils.length(pageData) < 4 then
      parseLine(pageData, line)
    else
      if not line:find(":") and utils.length(regionData) ~= 0 then
        table.insert(regionsData, regionData)
        regionData = {}
      end
      parseLine(regionData, line)
    end
  end
  table.insert(regionsData, regionData)
  
  self.page = {
    name = pageData.name,
    minFilter = FILTERS[pageData.filter[1]],
    maxFilter = FILTERS[pageData.filter[2]]
  }
  
  self.regions = {}
  for _, regionData in ipairs(regionsData) do
    table.insert(self.regions, {
      name = regionData.name,
      x = tonumber(regionData.xy[1]),
      y = tonumber(regionData.xy[2]),
      width = tonumber(regionData.size[1]),
      height = tonumber(regionData.size[2])
    })
  end
end


-- class

local Atlas = class("Atlas")

function Atlas:initialize(filename)
  load(self, utils.readFile(filename))
end

function Atlas:findRegion(name)
  for _, region in ipairs(self.regions) do
    if region.name == name then return region end
  end
  return nil
end

return Atlas
