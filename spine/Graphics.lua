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

-- inspired in Hanappe Graphics class
-- https://github.com/makotok/Hanappe/blob/master/projects/hanappe-framework/src/hp/display/Graphics.lua

local Graphics = class("Graphics")
Graphics.static.DEFAULT_STEPS = 32

function Graphics:initialize(width, height, layer)
  self.width = width
  self.height = height
  self.commands = {}

  local scriptDeck = MOAIScriptDeck.new()
  scriptDeck:setRect(0, 0, width, height)
  scriptDeck:setDrawCallback(function()
    if #self.commands == 0 then
      return
    end            
    
    MOAIGfxDevice.setPenColor(1, 1, 1, 1)
    MOAIGfxDevice.setPenWidth(1)
    MOAIGfxDevice.setPointSize(1)

    for _, command in ipairs(self.commands) do command(self) end
  end)

  self.prop = MOAIProp2D.new()  
  self.prop:setDeck(scriptDeck)
  layer:insertProp(self.prop)
end

function Graphics:setPenColor(r, g, b, a)
  a = a or 1
  local command = function(self)
    MOAIGfxDevice.setPenColor(r, g, b, a)
  end
  table.insert(self.commands, command)
  return self
end

function Graphics:drawLine(...)
  local args = {...}
  local command = function(self)
    MOAIDraw.drawLine(unpack(args))
  end
  table.insert(self.commands, command)
  return self
end

function Graphics:fillCircle()
  local command = function(self)
    local r = math.min(self.width, self.height) / 2
    MOAIDraw.fillCircle(r, r, r, Graphics.DEFAULT_STEPS)
  end
  table.insert(self.commands, command)
  return self
end

return Graphics
