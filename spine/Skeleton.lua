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
local Bone = require "spine.Bone"
local Slot = require "spine.Slot"
local AttachmentLoader = require "spine.AttachmentLoader"

-- auxiliar functions

local function getAttachmentTransform(self, slot, attachment)
  local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
  local y = -(slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11)
  local rotation = slot.bone.worldRotation + attachment.rotation
  local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
  local yScale = slot.bone.worldScaleY + attachment.scaleY - 1
  local propX, propY = self.prop:getLoc()
  if self.flipX then
    xScale = -xScale
    rotation = -rotation
  end
  if self.flipY then
    yScale = -yScale
    rotation = -rotation
  end
  return x + propX, y + propY, -rotation, xScale, yScale
end


--class

local Skeleton = class("Skeleton")

function Skeleton:initialize(skeletonData)
  if not skeletonData then error("skeletonData cannot be nil", 2) end

  self.data = skeletonData
  self.bones = {}
  self.slots = {}
  self.drawOrder = {}
  self.images = {}
  self.prop = MOAIProp2D.new()

  for i, boneData in ipairs(skeletonData.bones) do
    local parent
    if boneData.parent then parent = self.bones[utils.indexOf(skeletonData.bones, boneData.parent)] end
    table.insert(self.bones, Bone:new(boneData, parent))
  end

  for i, slotData in ipairs(skeletonData.slots) do
    local bone = self.bones[utils.indexOf(skeletonData.bones, slotData.boneData)]
    local slot = Slot:new(slotData, self, bone)
    table.insert(self.slots, slot)
    table.insert(self.drawOrder, slot)
  end
end

function Skeleton:updateWorldTransform()
  for i, bone in ipairs(self.bones) do
    bone:updateWorldTransform(self.flipX, self.flipY)
  end

  for i, slot in ipairs(self.drawOrder) do
    local attachment = slot.attachment
    if attachment then
      local image = self.images[attachment]
      if not image then
        image = self.data.attachmentLoader:createImage(attachment)
        if image then
          image:setPriority(i)          
        else
          print("Error creating image: " .. attachment.name)
          image = AttachmentLoader.failed
        end
        self.images[attachment] = image
      end
      if image ~= AttachmentLoader.failed then
        local x, y, rotation, xScale, yScale = getAttachmentTransform(self, slot, attachment)
        image:setLoc(x, y)
        image:setRot(rotation)
        image:setScl(xScale, yScale)
      end
    end
  end

  if self.debug then
    -- TODO: implement debug lines
  end
end

function Skeleton:setToBindPose()
  self:setBonesToBindPose()
  self:setSlotsToBindPose()
end

function Skeleton:setBonesToBindPose()
  for i,bone in ipairs(self.bones) do
    bone:setToBindPose()
  end
end

function Skeleton:setSlotsToBindPose()
  for i,slot in ipairs(self.slots) do
    slot:setToBindPose()
  end
end

function Skeleton:getRootBone()
  return self.bones[1]
end

function Skeleton:findSlot(slotName)
  if not slotName then error("slotName cannot be nil.", 2) end
  for i, slot in ipairs(self.slots) do
    if slot.data.name == slotName then return slot end
  end
  return nil
end

function Skeleton:setSkin(skinName)
  local newSkin
  if skinName then
    newSkin = self.data:findSkin(skinName)
    if not newSkin then error("Skin not found: " .. skinName, 2) end
    if self.skin then
      -- Attach all attachments from the new skin if the corresponding attachment from the old skin is currently attached.
      for k, v in self.skin.attachments do
        local attachment = v[3]
        local slotIndex = v[1]
        local slot = self.slots[slotIndex]
        if slot.attachment == attachment then
          local name = v[2]
          local newAttachment = newSkin:getAttachment(slotIndex, name)
          if newAttachment then slot:setAttachment(newAttachment) end
        end
      end
    end
  end
  self.skin = newSkin
end

function Skeleton:getAttachment(slotName, attachmentName)
  if not slotName then error("slotName cannot be nil.", 2) end
  if not attachmentName then error("attachmentName cannot be nil.", 2) end
  local slotIndex = self.data:findSlotIndex(slotName)
  if slotIndex == -1 then error("Slot not found: " .. slotName, 2) end
  if self.skin then return self.skin:getAttachment(slotIndex, attachmentName) end
  if self.data.defaultSkin then
    local attachment = self.data.defaultSkin:getAttachment(slotIndex, attachmentName)
    if attachment then return attachment end
  end
  return nil
end

function Skeleton:setAttachment(slotName, attachmentName)
  if not slotName then error("slotName cannot be nil.", 2) end
  if not attachmentName then error("attachmentName cannot be nil.", 2) end
  for i, slot in ipairs(self.slots) do
    if slot.data.name == slotName then
      slot:setAttachment(self:getAttachment(slotName, attachmentName))
      return
    end
  end
  error("Slot not found: " + slotName, 2)
end

function Skeleton:update(delta)
  self.time = self.time + delta
end 

return Skeleton
