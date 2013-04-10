local RegionAttachment = class("RegionAttachment")

function RegionAttachment:initialize(name)
  if not name then error("name cannot be nil", 2) end
  self.name = name
end

return RegionAttachment
