local SlotData = class("SlotData")

function SlotData:initialize(name, boneData)
  if not name then error("name cannot be nil", 2) end
  if not boneData then error("boneData cannot be nil", 2) end
  
  self.name = name
  self.boneData = boneData

  self:setColor(255, 255, 255, 255)
end

function self:setColor(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
end

return SlotData
