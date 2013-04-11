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

local Slot = class("Slot")

function Slot:initialize(slotData, skeleton, bone)
  if not slotData then error("slotData cannot be nil", 2) end
  if not skeleton then error("skeleton cannot be nil", 2) end
  if not bone then error("bone cannot be nil", 2) end

  self.data = slotData
  self.skeleton = skeleton
  self.bone = bone

  self:setToBindPose()
end

function Slot:setColor(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
end

function Slot:setAttachment(attachment)
  if self.attachment and self.attachment ~= attachment and self.skeleton.images[self.attachment] then
    -- TODO: remove old attachment
    self.skeleton.images[self.attachment] = nil
  end
  self.attachment = attachment
  self.attachmentTime = self.skeleton.time
end

function Slot:setAttachmentTime(time)
  self.attachmentTime = self.skeleton.time - time
end

function Slot:getAttachmentTime()
  return self.skeleton.time - self.attachmentTime
end

function Slot:setToBindPose()
  local data = self.data

  self:setColor(data.r, data.g, data.b, data.a)

  local attachment
  if data.attachmentName then attachment = self.skeleton:getAttachment(data.name, data.attachmentName) end
  self:setAttachment(attachment)
end

return Slot
