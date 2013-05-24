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
package.path =  package.path .. ";../../?.lua"

local spine = require "spine.spine"

local width, height = 480, 320

MOAISim.openWindow("MOAI and Spine", width, height)

local viewport = MOAIViewport.new()
viewport:setSize(width, height)
viewport:setScale(width, -height)
viewport:setOffset(-1, 1)

local layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAISim.pushRenderPass(layer)


local loader = spine.AttachmentLoader:new()
function loader:createImage(attachment)

  local deck = MOAIGfxQuad2D.new()
  deck:setTexture("../../data/dragon/" .. attachment.name .. ".png")
  deck:setUVRect(0, 0, 1, 1)
  deck:setRect(0, 0, attachment.width, attachment.height)
  
  local prop = MOAIProp.new()
  prop:setDeck(deck)  
  prop:setPiv(attachment.width / 2, attachment.height / 2)
  layer:insertProp(prop)
  
  function prop:remove()
    layer:removeProp(self)
  end

  return prop
end


local json = spine.SkeletonJson:new(loader)
json.scale = 0.7

local skeletonData = json:readSkeletonDataFile("../../data/dragon/dragon.json")
local walkAnimation = skeletonData:findAnimation("fly")

local skeleton = spine.Skeleton:new(skeletonData)
skeleton.prop:setLoc(240, 300)
skeleton.flipX = false
skeleton.flipY = false
skeleton.debugBones = true
skeleton.debugLayer = layer
skeleton:setToBindPose()


local animationTime = 0
MOAIThread.new():run(function()
  while true do
    animationTime = animationTime + MOAISim.getStep()
  
    walkAnimation:apply(skeleton, animationTime, true)
    skeleton:updateWorldTransform()
    
    coroutine.yield()
  end
end)
