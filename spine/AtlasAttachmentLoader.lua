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

local AttachmentLoader = require "spine.AttachmentLoader"

local AtlasAttachmentLoader = class("AtlasAttachmentLoader", AttachmentLoader)

function AtlasAttachmentLoader:initialize(atlas, textureName, layer)
  AttachmentLoader.initialize(self)
  self.atlas = atlas
  self.layer = layer
  self.names = {}

  local texture = MOAITexture.new()
  texture:load(textureName)
  texture:setFilter(self.atlas.page.minFilter, self.atlas.page.maxFilter)
  
  local width, height = texture:getSize()

  self.deck = MOAIGfxQuadDeck2D.new()
  self.deck:setTexture(texture)
  self.deck:reserve(#self.atlas.regions)

  for index, region in ipairs(self.atlas.regions) do
    local uv = {}
    uv.u0 = region.x / width
    uv.v0 = region.y / height
    uv.u1 = (region.x + region.width) / width
    uv.v1 = (region.y + region.height) / height

    self.deck:setUVRect(index, uv.u0, uv.v0, uv.u1, uv.v1)

    self.names[region.name] = index
  end
end

function AtlasAttachmentLoader:createImage(attachment)
  local layer = self.layer
  local index = self.names[attachment.name]
  local region = self.atlas:findRegion(attachment.name)

  self.deck:setRect(index, 0, 0, attachment.width, attachment.height)
  
  local prop = MOAIProp.new()
  prop:setDeck(self.deck)
  prop:setIndex(index)
  prop:setPiv(attachment.width / 2, attachment.height / 2)
  
  layer:insertProp(prop)
  return prop
end

return AtlasAttachmentLoader
