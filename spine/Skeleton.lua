local utils = require "spine.utils"
local Bone = require "spine.Bone"
local Slot = require "spine.Slot"
local AttachmentLoader = require "spine.AttachmentLoader"

local Skeleton = class("Skeleton")

function Skeleton:initialize(skeletonData)
  if not skeletonData then error("skeletonData cannot be nil", 2) end

  self.data = skeletonData
  self.bones = {}
  self.slots = {}
  self.drawOrder = {}

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
      -- TODO: implement image loading
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
