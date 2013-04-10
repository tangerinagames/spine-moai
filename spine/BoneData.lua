local BoneData = class("BoneData")

function BoneData:initialize(name, parent)
  if not name then error("name cannot be nil", 2) end
  self.name = name
  self.parent = parent
end

return BoneData
