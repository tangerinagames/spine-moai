
-- auxiliar functions

local function findItem(list, name)
  for index, item in ipairs(list) do
    if item.name == name then return item end
  end
  return nil
end

local function findIndex(list, name)
  for index, item in ipairs(list) do
    if item.name == name then return index end
  end
  return -1
end


-- class

local SkeletonData = class("SkeletonData")

function SkeletonData:initializer(attachmentLoader)
  if not attachmentLoader then error("attachmentLoader cannot be nil", 2) end

  self.attachmentLoader = attachmentLoader
  self.bones = {}
  self.slots = {}
  self.skins = {}
  self.animations = {}
end

function SkeletonData:findBone(boneName)
  if not boneName then error("boneName cannot be nil.", 2) end
  return findItem(self.bones, boneName)
end

function SkeletonData:findBoneIndex(boneName)
  if not boneName then error("boneName cannot be nil.", 2) end
  return findIndex(self.bones, boneName)
end

function SkeletonData:findSlot(slotName)
  if not slotName then error("slotName cannot be nil.", 2) end
  return findItem(self.slots, slotName)
end

function SkeletonData:findSlotIndex(slotName)
  if not slotName then error("slotName cannot be nil.", 2) end
  return findIndex(self.slots, slotName)
end

function SkeletonData:findSkin(skinName)
  if not skinName then error("skinName cannot be nil.", 2) end
  return findItem(self.skins, skinName)
end

function SkeletonData:findAnimation(animationName)
  if not animationName then error("animationName cannot be nil.", 2) end
  return findItem(self.animations, animationName)
end

return SkeletonData
