local RegionAttachment = require "spine.RegionAttachment"

local AttachmentLoader = class("AttachmentLoader")
AttachmentLoader.static.FAILED = {}
AttachmentLoader.static.ATTACHMENT_REGION = "region"

function AttachmentLoader:newAttachment(type, name)
  if type == AttachmentLoader.ATTACHMENT_REGION then
    return RegionAttachment:new(name)
  end
  error("Unknown attachment type: " .. type .. " (" + name + ")")
end

function AttachmentLoader:createImage(attachment)
  return AttachmentLoader.FAILED
end

return AttachmentLoader
