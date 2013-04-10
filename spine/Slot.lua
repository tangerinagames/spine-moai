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
