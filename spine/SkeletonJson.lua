local utils = require "spine.utils"
local SkeletonData = require "spine.SkeletonData"
local BoneData = require "spine.BoneData"
local SlotData = require "spine.SlotData"
local Skin = require "spine.Skin"
local AttachmentLoader = require "spine.AttachmentLoader"
local Animation = require "spine.Animation"

-- auxiliar functions

local TIMELINE_SCALE = "scale"
local TIMELINE_ROTATE = "rotate"
local TIMELINE_TRANSLATE = "translate"
local TIMELINE_ATTACHMENT = "attachment"
local TIMELINE_COLOR = "color"

local function readCurve(timeline, keyframeIndex, valueMap)
  local curve = valueMap["curve"]
  if not curve then return end
  if curve == "stepped" then
    timeline:setStepped(keyframeIndex)
  else
    timeline:setCurve(keyframeIndex, curve[1], curve[2], curve[3], curve[4])
  end
end

local function readAttachment(name, map, scale, attachmentLoader)
  name = map["name"] or name
  local attachment
  local type = map["type"] or AttachmentLoader.ATTACHMENT_REGION
  attachment = attachmentLoader:newAttachment(type, name)
  if not attachment then return nil end

  attachment.x = (map["x"] or 0) * scale
  attachment.y = (map["y"] or 0) * scale
  attachment.scaleX = (map["scaleX"] or 1)
  attachment.scaleY = (map["scaleY"] or 1)
  attachment.rotation = (map["rotation"] or 0)
  attachment.width = map["width"] * scale
  attachment.height = map["height"] * scale
  return attachment
end

local function readAnimation(name, map, skeletonData, scale)
  local timelines = {}
  local duration = 0

  local bonesMap = map["bones"]
  for boneName, timelineMap in pairs(bonesMap) do
    local boneIndex = skeletonData:findBoneIndex(boneName)
    if boneIndex == -1 then error("Bone not found: " .. boneName) end

    for timelineName, values in pairs(timelineMap) do
      if timelineName == TIMELINE_ROTATE then
        local timeline = Animation.RotateTimeline:new()
        timeline.boneIndex = boneIndex

        local keyframeIndex = 0
        for i, valueMap in ipairs(values) do
          local time = valueMap["time"]
          timeline:setKeyframe(keyframeIndex, time, valueMap["angle"])
          readCurve(timeline, keyframeIndex, valueMap)
          keyframeIndex = keyframeIndex + 1
        end
        table.insert(timelines, timeline)
        duration = math.max(duration, timeline:getDuration())

      elseif timelineName == TIMELINE_TRANSLATE or timelineName == TIMELINE_SCALE then
        local timeline
        local timelineScale = 1
        if timelineName == TIMELINE_SCALE then
          timeline = Animation.ScaleTimeline:new()
        else
          timeline = Animation.TranslateTimeline:new()
          timelineScale = scale
        end
        timeline.boneIndex = boneIndex

        local keyframeIndex = 0
        for i, valueMap in ipairs(values) do
          local time = valueMap["time"]
          local x = (valueMap["x"] or 0) * timelineScale
          local y = (valueMap["y"] or 0) * timelineScale
          timeline:setKeyframe(keyframeIndex, time, x, y)
          readCurve(timeline, keyframeIndex, valueMap)
          keyframeIndex = keyframeIndex + 1
        end
        table.insert(timelines, timeline)
        duration = math.max(duration, timeline:getDuration())

      else
        error("Invalid timeline type for a bone: " .. timelineName .. " (" .. boneName .. ")")
      end
    end
  end

  local slotsMap = map["slots"]
  if slotsMap then
    for slotName, timelineMap in pairs(slotsMap) do
      local slotIndex = skeletonData:findSlotIndex(slotName)

      for timelineName, values in pairs(timelineMap) do
        if timelineName == TIMELINE_COLOR then
          local timeline = Animation.ColorTimeline:new()
          timeline.slotIndex = slotIndex

          local keyframeIndex = 0
          for i, valueMap in ipairs(values) do
            local time = valueMap["time"]
            local color = valueMap["color"]
            timeline:setKeyframe(
              keyframeIndex, time, 
              tonumber(color:sub(1, 2), 16),
              tonumber(color:sub(3, 4), 16),
              tonumber(color:sub(5, 6), 16),
              tonumber(color:sub(7, 8), 16)
            )
            readCurve(timeline, keyframeIndex, valueMap)
            keyframeIndex = keyframeIndex + 1
          end
          table.insert(timelines, timeline)
          duration = math.max(duration, timeline:getDuration())

        elseif timelineName == TIMELINE_ATTACHMENT then
          local timeline = Animation.AttachmentTimeline:new()
          timeline.slotName = slotName

          local keyframeIndex = 0
          for i, valueMap in ipairs(values) do
            local time = valueMap["time"]
            local attachmentName = valueMap["name"]
            timeline:setKeyframe(keyframeIndex, time, attachmentName)
            keyframeIndex = keyframeIndex + 1
          end
          table.insert(timelines, timeline)
          duration = math.max(duration, timeline:getDuration())

        else
          error("Invalid frame type for a slot: " .. timelineName .. " (" .. slotName .. ")")
        end
      end
    end
  end

  table.insert(skeletonData.animations, Animation:new(name, timelines, duration))
end


-- class

local SkeletonJson = class("SkeletonJson")

function SkeletonJson:initialize(attachmentLoader)
  if not attachmentLoader then attachmentLoader = AttachmentLoader:new() end

  self.attachmentLoader = attachmentLoader
  self.scale = 1  
end

function SkeletonJson:readSkeletonDataFile(fileName, base)
  return self:readSkeletonData(utils.readFile(fileName, base))
end


function SkeletonJson:readSkeletonData(jsonText)
  local skeletonData = SkeletonData:new(self.attachmentLoader)
  
  local root = MOAIJsonParser.decode(jsonText)
  if not root then error("Invalid JSON: " .. jsonText, 2) end

  -- Bones.
  for i, boneMap in ipairs(root["bones"]) do
    local boneName = boneMap["name"]
    local parent = nil
    local parentName = boneMap["parent"]
    if parentName then
      parent = skeletonData:findBone(parentName)
      if not parent then error("Parent bone not found: " .. parentName) end
    end
    local boneData = BoneData:new(boneName, parent)
    boneData.length = (boneMap["length"] or 0) * self.scale
    boneData.x = (boneMap["x"] or 0) * self.scale
    boneData.y = (boneMap["y"] or 0) * self.scale
    boneData.rotation = (boneMap["rotation"] or 0)
    boneData.scaleX = (boneMap["scaleX"] or 1)
    boneData.scaleY = (boneMap["scaleY"] or 1)
    table.insert(skeletonData.bones, boneData)
  end

  -- Slots.
  if root["slots"] then
    for i, slotMap in ipairs(root["slots"]) do
      local slotName = slotMap["name"]
      local boneName = slotMap["bone"]
      local boneData = skeletonData:findBone(boneName)
      if not boneData then error("Slot bone not found: " .. boneName) end
      local slotData = SlotData:new(slotName, boneData)

      local color = slotMap["color"]
      if color then
        slotData:setColor(
          tonumber(color:sub(1, 2), 16),
          tonumber(color:sub(3, 4), 16),
          tonumber(color:sub(5, 6), 16),
          tonumber(color:sub(7, 8), 16)
        )
      end
      slotData.attachmentName = slotMap["attachment"]
      table.insert(skeletonData.slots, slotData)
    end
  end

  -- Skins.
  map = root["skins"]
  if map then
    for skinName, skinMap in pairs(map) do
      local skin = Skin:new(skinName)
      for slotName, slotMap in pairs(skinMap) do
        local slotIndex = skeletonData:findSlotIndex(slotName)
        for attachmentName, attachmentMap in pairs(slotMap) do
          local attachment = readAttachment(attachmentName, attachmentMap, self.scale, self.attachmentLoader)
          if attachment then
            skin:addAttachment(slotIndex, attachmentName, attachment)
          end
        end
      end
      if skin.name == "default" then
        skeletonData.defaultSkin = skin
      else
        table.insert(skeletonData.skins, skin)
      end
    end
  end

  map = root["animations"]
  if map then
    for animationName, animationMap in pairs(map) do
      readAnimation(animationName, animationMap, skeletonData, self.scale)
    end
  end

  return skeletonData
end 

return SkeletonJson
