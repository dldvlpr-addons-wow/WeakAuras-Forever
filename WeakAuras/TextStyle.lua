if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local fontObjects = setmetatable({}, {__mode = "k"})
local fontObjectCounter = 0

function Private.ApplyTextFont(text, fontObject, fontPath, size, flags, shadowColor, shadowX, shadowY)
  if not fontObject then
    fontObject = fontObjects[text]
    if not fontObject then
      fontObjectCounter = fontObjectCounter + 1
      fontObject = CreateFont("WeakAuras-NativeText-Font" .. fontObjectCounter)
      fontObjects[text] = fontObject
    end
  end

  fontObject:SetFont(STANDARD_TEXT_FONT, size, flags)
  fontObject:SetShadowColor(unpack(shadowColor))
  if flags == "OUTLINE|SLUG" or flags == "THICKOUTLINE|SLUG" then
    fontObject:SetShadowOffset(0, 0)
  else
    fontObject:SetShadowOffset(shadowX, shadowY)
  end
  text:SetFontObject(fontObject)
  text:SetFont(fontPath, size, flags)

  if not text:GetFont() and fontPath then
    fontObject:SetFont(fontPath, size, flags)
    text:SetFontObject(fontObject)
  end
  if not text:GetFont() then
    text:SetFont(STANDARD_TEXT_FONT, size, flags)
  end
end
