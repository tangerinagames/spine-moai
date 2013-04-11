local utils = require "spine.utils"

-- auxiliar functions

local function binarySearch(values, target, step)
  local low = 0
  local high = math.floor((#values + 1) / step - 2)
  if high == 0 then return step end
  local current = math.floor(high / 2)
  while true do
    if values[(current + 1) * step] <= target then
      low = current + 1
    else
      high = current
    end
    if low == high then return (low + 1) * step end
    current = math.floor((low + high) / 2)
  end
end

local function linearSearch (values, target, step)
  for i = 0, #values, step do
    if (values[i] > target) then return i end
  end
  return -1
end


-- classes

local Animation = class("Animation")

function Animation:initialize(name, timelines, duration)
  if not timelines then error("timelines cannot be nil", 2) end

  self.name = name
  self.timelines = timelines
  self.duration = duration
end

function Animation:apply(skeleton, time, loop)
  self:mix(skeleton, time, loop, 1)
end

function Animation:mix(skeleton, time, loop, alpha)
  if not skeleton then error("skeleton cannot be nil.", 2) end

  if loop and self.duration then time = time % self.duration end

  for i, timeline in ipairs(self.timelines) do
    timeline:apply(skeleton, time, alpha)
  end
end


Animation.CurveTimeline = class("Animation.CurveTimeline")
Animation.CurveTimeline.static.LINEAR = 0
Animation.CurveTimeline.static.STEPPED = -1
Animation.CurveTimeline.static.BEZIER_SEGMENTS = 10

function Animation.CurveTimeline:initialize()
  self.curves = {}
end

function Animation.CurveTimeline:setLinear(keyframeIndex)
  self.curves[keyframeIndex * 6] = Animation.CurveTimeline.LINEAR
end

function Animation.CurveTimeline:setStepped(keyframeIndex)
  self.curves[keyframeIndex * 6] = Animation.CurveTimeline.STEPPED
end

function Animation.CurveTimeline:setCurve(keyframeIndex, cx1, cy1, cx2, cy2)
  local subdiv_step = 1 / Animation.CurveTimeline.BEZIER_SEGMENTS
  local subdiv_step2 = subdiv_step * subdiv_step
  local subdiv_step3 = subdiv_step2 * subdiv_step
  local pre1 = 3 * subdiv_step
  local pre2 = 3 * subdiv_step2
  local pre4 = 6 * subdiv_step2
  local pre5 = 6 * subdiv_step3
  local tmp1x = -cx1 * 2 + cx2
  local tmp1y = -cy1 * 2 + cy2
  local tmp2x = (cx1 - cx2) * 3 + 1
  local tmp2y = (cy1 - cy2) * 3 + 1
  local i = keyframeIndex * 6
  local curves = self.curves
  curves[i] = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3
  curves[i + 1] = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3
  curves[i + 2] = tmp1x * pre4 + tmp2x * pre5
  curves[i + 3] = tmp1y * pre4 + tmp2y * pre5
  curves[i + 4] = tmp2x * pre5
  curves[i + 5] = tmp2y * pre5
end

function Animation.CurveTimeline:getCurvePercent(keyframeIndex, percent)
  local curveIndex = keyframeIndex * 6
  local curves = self.curves
  local dfx = curves[curveIndex]
  if not dfx then return percent end -- linear
  if dfx == Animation.CurveTimeline.STEPPED then return 0 end
  local dfy = curves[curveIndex + 1]
  local ddfx = curves[curveIndex + 2]
  local ddfy = curves[curveIndex + 3]
  local dddfx = curves[curveIndex + 4]
  local dddfy = curves[curveIndex + 5]
  local x = dfx
  local y = dfy
  local i = Animation.CurveTimeline.BEZIER_SEGMENTS - 2
  while true do
    if x >= percent then
      local lastX = x - dfx
      local lastY = y - dfy
      return lastY + (y - lastY) * (percent - lastX) / (x - lastX)
    end
    if i == 0 then break end
    i = i - 1
    dfx = dfx + ddfx
    dfy = dfy + ddfy
    ddfx = ddfx + dddfx
    ddfy = ddfy + dddfy
    x = x + dfx
    y = y + dfy
  end
  return y + (1 - y) * (percent - x) / (1 - x) -- Last point is 1,1.
end


Animation.RotateTimeline = class("Animation.RotateTimeline", Animation.CurveTimeline)
Animation.RotateTimeline.static.LAST_FRAME_TIME = -2
Animation.RotateTimeline.static.FRAME_VALUE = 1

function Animation.RotateTimeline:initialize()
  Animation.CurveTimeline.initialize(self)
  self.frames = {}
  self.boneIndex = -1
end

function Animation.RotateTimeline:getDuration()
  return self.frames[#self.frames - 1]
end

function Animation.RotateTimeline:getKeyframeCount()
  return (#self.frames + 1) / 2
end

function Animation.RotateTimeline:setKeyframe(keyframeIndex, time, value)
  keyframeIndex = keyframeIndex * 2
  self.frames[keyframeIndex] = time
  self.frames[keyframeIndex + 1] = value
end

function Animation.RotateTimeline:apply(skeleton, time, alpha)
  local frames = self.frames
  if time < frames[0] then return end -- Time is before first frame.

  local bone = skeleton.bones[self.boneIndex]

  if time >= frames[#frames - 1] then -- Time is after last frame.
    local amount = bone.data.rotation + frames[#frames] - bone.rotation
    while amount > 180 do
      amount = amount - 360
    end
    while amount < -180 do
      amount = amount + 360
    end
    bone.rotation = bone.rotation + amount * alpha
    return
  end

  -- Interpolate between the last frame and the current frame.
  local frameIndex = binarySearch(frames, time, 2)
  local lastFrameValue = frames[frameIndex - 1]
  local frameTime = frames[frameIndex]
  local percent = 1 - (time - frameTime) / (frames[frameIndex + Animation.RotateTimeline.LAST_FRAME_TIME] - frameTime)
  if percent < 0 then percent = 0 elseif percent > 1 then percent = 1 end
  percent = self:getCurvePercent(frameIndex / 2 - 1, percent)

  local amount = frames[frameIndex + Animation.RotateTimeline.FRAME_VALUE] - lastFrameValue
  while amount > 180 do
    amount = amount - 360
  end
  while amount < -180 do
    amount = amount + 360
  end
  amount = bone.data.rotation + (lastFrameValue + amount * percent) - bone.rotation
  while amount > 180 do
    amount = amount - 360
  end
  while amount < -180 do
    amount = amount + 360
  end
  bone.rotation = bone.rotation + amount * alpha
end


Animation.TranslateTimeline = class("Animation.TranslateTimeline", Animation.CurveTimeline)
Animation.TranslateTimeline.static.LAST_FRAME_TIME = -3
Animation.TranslateTimeline.static.FRAME_X = 1
Animation.TranslateTimeline.static.FRAME_Y = 2

function Animation.TranslateTimeline:initialize()
  Animation.CurveTimeline.initialize(self)
  self.frames = {}
  self.boneIndex = -1
end

function Animation.TranslateTimeline:getDuration()
  return self.frames[#self.frames - 2]
end

function Animation.TranslateTimeline:getKeyframeCount()
  return (#self.frames + 1) / 3
end

function Animation.TranslateTimeline:setKeyframe(keyframeIndex, time, x, y)
  keyframeIndex = keyframeIndex * 3
  self.frames[keyframeIndex] = time
  self.frames[keyframeIndex + 1] = x
  self.frames[keyframeIndex + 2] = y
end

function Animation.TranslateTimeline:apply(skeleton, time, alpha)
  local frames = self.frames
  if time < frames[0] then return end -- Time is before first frame.

  local bone = skeleton.bones[self.boneIndex]
  
  if time >= frames[#frames - 2] then -- Time is after last frame.
    bone.x = bone.x + (bone.data.x + frames[#frames - 1] - bone.x) * alpha
    bone.y = bone.y + (bone.data.y + frames[#frames] - bone.y) * alpha
    return
  end

  -- Interpolate between the last frame and the current frame.
  local frameIndex = binarySearch(frames, time, 3)
  local lastFrameX = frames[frameIndex - 2]
  local lastFrameY = frames[frameIndex - 1]
  local frameTime = frames[frameIndex]
  local percent = 1 - (time - frameTime) / (frames[frameIndex + Animation.TranslateTimeline.LAST_FRAME_TIME] - frameTime)
  if percent < 0 then percent = 0 elseif percent > 1 then percent = 1 end
  percent = self:getCurvePercent(frameIndex / 3 - 1, percent)

  bone.x = bone.x + (bone.data.x + lastFrameX + (frames[frameIndex + Animation.TranslateTimeline.FRAME_X] - lastFrameX) * percent - bone.x) * alpha
  bone.y = bone.y + (bone.data.y + lastFrameY + (frames[frameIndex + Animation.TranslateTimeline.FRAME_Y] - lastFrameY) * percent - bone.y) * alpha
end


Animation.ScaleTimeline = class("Animation.ScaleTimeline", Animation.TranslateTimeline)
Animation.ScaleTimeline.static.LAST_FRAME_TIME = -3
Animation.ScaleTimeline.static.FRAME_X = 1
Animation.ScaleTimeline.static.FRAME_Y = 2

function Animation.ScaleTimeline:initialize()
  Animation.TranslateTimeline.initialize(self)
end

function Animation.ScaleTimeline:apply(skeleton, time, alpha)
  local frames = self.frames
  if time < frames[0] then return end -- Time is before first frame.

  local bone = skeleton.bones[self.boneIndex]

  if time >= frames[#frames - 2] then -- Time is after last frame.
    bone.scaleX = bone.scaleX + (bone.data.scaleX - 1 + frames[#frames - 1] - bone.scaleX) * alpha
    bone.scaleY = bone.scaleY + (bone.data.scaleY - 1 + frames[#frames] - bone.scaleY) * alpha
    return
  end

  -- Interpolate between the last frame and the current frame.
  local frameIndex = binarySearch(frames, time, 3)
  local lastFrameX = frames[frameIndex - 2]
  local lastFrameY = frames[frameIndex - 1]
  local frameTime = frames[frameIndex]
  local percent = 1 - (time - frameTime) / (frames[frameIndex + Animation.ScaleTimeline.LAST_FRAME_TIME] - frameTime)
  if percent < 0 then percent = 0 elseif percent > 1 then percent = 1 end
  percent = self:getCurvePercent(frameIndex / 3 - 1, percent)

  bone.scaleX = bone.scaleX + (bone.data.scaleX - 1 + lastFrameX + (frames[frameIndex + Animation.ScaleTimeline.FRAME_X] - lastFrameX) * percent - bone.scaleX) * alpha
  bone.scaleY = bone.scaleY + (bone.data.scaleY - 1 + lastFrameY + (frames[frameIndex + Animation.ScaleTimeline.FRAME_Y] - lastFrameY) * percent - bone.scaleY) * alpha
end


Animation.ColorTimeline = class("Animation.ColorTimeline", Animation.CurveTimeline)
Animation.ColorTimeline.static.LAST_FRAME_TIME = -5
Animation.ColorTimeline.static.FRAME_R = 1
Animation.ColorTimeline.static.FRAME_G = 2
Animation.ColorTimeline.static.FRAME_B = 3
Animation.ColorTimeline.static.FRAME_A = 4

function Animation.ColorTimeline:initialize()
  Animation.CurveTimeline.initialize(self)
  self.frames = {}
  self.slotIndex = -1
end

function Animation.ColorTimeline:getDuration()
  return self.frames[#self.frames - 4]
end

function Animation.ColorTimeline:getKeyframeCount()
  return (#self.frames + 1) / 5
end

function Animation.ColorTimeline:setKeyframe(keyframeIndex, time, r, g, b, a)
  keyframeIndex = keyframeIndex * 5
  self.frames[keyframeIndex] = time
  self.frames[keyframeIndex + 1] = r
  self.frames[keyframeIndex + 2] = g
  self.frames[keyframeIndex + 3] = b
  self.frames[keyframeIndex + 4] = a
end

function Animation.ColorTimeline:apply(skeleton, time, alpha)
  local frames = self.frames
  if time < frames[0] then return end -- Time is before first frame.

  local slot = skeleton.slots[self.slotIndex]

  if time >= frames[#frames - 4] then -- Time is after last frame.
    local r = frames[#frames - 3]
    local g = frames[#frames - 2]
    local b = frames[#frames - 1]
    local a = frames[#frames]
    slot:setColor(r, g, b, a)
    return
  end

  -- Interpolate between the last frame and the current frame.
  local frameIndex = binarySearch(frames, time, 5)
  local lastFrameR = frames[frameIndex - 4]
  local lastFrameG = frames[frameIndex - 3]
  local lastFrameB = frames[frameIndex - 2]
  local lastFrameA = frames[frameIndex - 1]
  local frameTime = frames[frameIndex]
  local percent = 1 - (time - frameTime) / (frames[frameIndex + Animation.ColorTimeline.LAST_FRAME_TIME] - frameTime)
  if percent < 0 then percent = 0 elseif percent > 255 then percent = 255 end
  percent = self:getCurvePercent(frameIndex / 5 - 1, percent)

  local r = lastFrameR + (frames[frameIndex + Animation.ColorTimeline.FRAME_R] - lastFrameR) * percent
  local g = lastFrameG + (frames[frameIndex + Animation.ColorTimeline.FRAME_G] - lastFrameG) * percent
  local b = lastFrameB + (frames[frameIndex + Animation.ColorTimeline.FRAME_B] - lastFrameB) * percent
  local a = lastFrameA + (frames[frameIndex + Animation.ColorTimeline.FRAME_A] - lastFrameA) * percent
  if alpha < 1 then
    slot:setColor(slot.r + (r - color.r) * alpha, slot.g + (g - color.g) * alpha, slot.b + (b - color.b) * alpha, slot.a + (a - color.a) * alpha)
  else
    slot:setColor(r, g, b, a)
  end
end


Animation.AttachmentTimeline = class("Animation.ColorTimeline", Animation.CurveTimeline)
function Animation.AttachmentTimeline:initialize()
  Animation.CurveTimeline.initialize(self)
  self.frames = {}
  self.attachmentNames = {}
  self.slotName = nil
end

function Animation.AttachmentTimeline:getDuration()
  return self.frames[#self.frames]
end

function Animation.AttachmentTimeline:getKeyframeCount()
  return #self.frames + 1
end

function Animation.AttachmentTimeline:setKeyframe(keyframeIndex, time, attachmentName)
  self.frames[keyframeIndex] = time
  self.attachmentNames[keyframeIndex] = attachmentName
end

function Animation.AttachmentTimeline:apply(skeleton, time, alpha)
  local frames = self.frames
  if time < frames[0] then return end -- Time is before first frame.

  local frameIndex
  if time >= frames[#frames] then -- Time is after last frame.
    frameIndex = #frames
  else
    frameIndex = binarySearch(frames, time, 1) - 1
  end

  local attachmentName = self.attachmentNames[frameIndex]
  local attachment
  if attachmentName then attachment = skeleton:getAttachment(self.slotName, attachmentName) end
  skeleton:findSlot(self.slotName):setAttachment(attachment)
end

return Animation
