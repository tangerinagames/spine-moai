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
module(..., package.seeall)

function onCreate()
  layer = flower.Layer()
  layer:setScene(scene)

  local cache = {}
  local loader = spine.AttachmentLoader:new()
  function loader:createImage(attachment)
    local image = cache[attachment.name]
    if not image then
      local texture = "../../data/dragon/" .. attachment.name .. ".png"
      
      image = flower.Image(texture, attachment.width, attachment.height)
      image:setLayer(layer)
      
      function image:remove() image:setVisible(false) end
      cache[attachment.name] = image
    end
    image:setVisible(true)
    return image
  end
  
  local json = spine.SkeletonJson:new(loader)
  json.scale = 0.5

  local skeletonData = json:readSkeletonDataFile("../../data/dragon/dragon.json")
  walkAnimation = skeletonData:findAnimation("fly")

  skeleton = spine.Skeleton:new(skeletonData)
  skeleton.prop:setLoc(240, 200)
  skeleton:setToBindPose()

  animationTime = 0
end

function onUpdate()
  animationTime = animationTime + MOAISim.getStep() * 0.5 -- animate in slow motion
  
  walkAnimation:apply(skeleton, animationTime, true)
  skeleton:updateWorldTransform()
end