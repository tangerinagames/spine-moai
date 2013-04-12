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

local AnimationState = class("AnimationState")

function AnimationState:initialize(animationStateData)
  if not animationStateData then error("animationStateData cannot be nil", 2) end

  self.animationStateData = animationStateData
  self.current = nil
  self.previous = nil
  self.currentTime = 0
  self.previousTime = 0
  self.currentLoop = false
  self.previousLoop = false
  self.mixTime = 0
  self.mixDuration = 0
end

function AnimationState:update(delta)
  self.currentTime = self.currentTime + delta
  self.previousTime = self.previousTime + delta
  self.mixTime = self.mixTime + delta
end

function AnimationState:apply(skeleton)
  if self.current then
    if self.previous then
      self.previous:apply(skeleton, self.previousTime, self.previousLoop)
      local alpha = self.mixTime / self.mixDuration
      if alpha >= 1 then
        alpha = 1
        self.previous = nil
      end
      self.current:mix(skeleton, self.currentTime, self.currentLoop, alpha)
    else
      self.current:apply(skeleton, self.currentTime, self.currentLoop)
    end
  end
end

function AnimationState:setAnimation(animationName, loop)
  local animation = self.animationStateData.skeletonData:findAnimation(animationName)
  if not animation then error("Animation not found: " + animationName, 2) end
  
  self.previous = nil
  if animation and self.current then
    self.mixDuration = self.animationStateData:getMix(self.current.name, animationName)
    if self.mixDuration > 0 then
      self.mixTime = 0
      self.previous = self.current
      self.previousTime = self.currentTime
      self.previousLoop = self.currentLoop
    end
  end
  self.current = animation
  self.currentLoop = loop
  self.currentTime = 0
end

return AnimationState
