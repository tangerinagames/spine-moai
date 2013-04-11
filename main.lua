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
  deck:setTexture("data/spineboy/" .. attachment.name .. ".png")
  deck:setUVRect(0, 0, 1, 1)
  deck:setRect(0, 0, attachment.width, attachment.height)
  
  local prop = MOAIProp2D.new()
  prop:setDeck(deck)  
  prop:setPiv(attachment.width / 2, attachment.height / 2)
  layer:insertProp(prop)

  return prop
end


local json = spine.SkeletonJson:new(loader)
json.scale = 0.7

local skeletonData = json:readSkeletonDataFile("data/spineboy/spineboy.json")
local walkAnimation = skeletonData:findAnimation("walk")

local skeleton = spine.Skeleton:new(skeletonData)
skeleton.prop:setLoc(240, 300)
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
