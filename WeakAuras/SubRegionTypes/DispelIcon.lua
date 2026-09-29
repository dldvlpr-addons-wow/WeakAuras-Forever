if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local L = WeakAuras.L

-- Dispel type icon of the aura shown. A readable dispel type shows the icon of the default UI. During the
-- restriction the dispel type is secret: a white circle tinted with the dispel type color by the game shows instead.

local dispelAtlases = {
  magic = "RaidFrame-Icon-DebuffMagic",
  curse = "RaidFrame-Icon-DebuffCurse",
  disease = "RaidFrame-Icon-DebuffDisease",
  poison = "RaidFrame-Icon-DebuffPoison",
  bleed = "RaidFrame-Icon-DebuffBleed",
}

local genericTexture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_White"

local default = function(parentType)
  return {
    dispelIconVisible = true,
    anchor_mode = "point",
    anchor_area = parentType == "aurabar" and "bar" or "ALL",
    self_point = "TOPRIGHT",
    anchor_point = "TOPRIGHT",
    width = 16,
    height = 16,
    xOffset = 0,
    yOffset = 0,
  }
end

local properties = {
  dispelIconVisible = {
    display = L["Visibility"],
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true
  },
}

local funcs = {
  SetVisible = function(self, visible)
    if visible then
      self:Show()
    else
      self:Hide()
    end
  end,
  Update = function(self, state)
    local texture = self.texture
    local debuffClass = Private.ReadableDebuffClass(state)
    if debuffClass then
      local color = Private.dispelColors[debuffClass]
      local atlas = dispelAtlases[debuffClass]
      if atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
        texture:SetAtlas(atlas)
        texture:SetVertexColor(1, 1, 1, 1)
        texture:Show()
      elseif color then
        -- SetAtlas keeps its texture coordinates, the circle needs the full texture
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetTexture(genericTexture)
        texture:SetVertexColor(color[1], color[2], color[3], 1)
        texture:Show()
      else
        texture:Hide()
      end
      return
    end
    if state and state.unit and state.auraInstanceID and self.dispelCurve then
      -- No dispel type gives an alpha of 0, so the values stay secret from start to end
      local ok, r, g, b, a = pcall(Private.ReadDispelColor, state.unit, state.auraInstanceID, self.dispelCurve)
      if ok then
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetTexture(genericTexture)
        texture:SetVertexColor(r, g, b, a)
        texture:Show()
        return
      end
    end
    texture:Hide()
  end,
}

local function create()
  local region = CreateFrame("Frame", nil, UIParent)
  for k, v in pairs(funcs) do
    region[k] = v
  end
  region.texture = region:CreateTexture(nil, "OVERLAY")
  region.texture:SetAllPoints(region)
  return region
end

local function onAcquire(subRegion)
  subRegion:Show()
end

local function onRelease(subRegion)
  subRegion:Hide()
end

local function modify(parent, region, parentData, data, first)
  region:SetParent(parent)
  region.dispelCurve = region.dispelCurve or Private.CreateDispelCurve({1, 1, 1, 0})

  local arg1 = data.anchor_mode == "point" and data.anchor_point or data.anchor_area
  local arg2 = data.anchor_mode == "point" and data.self_point or nil
  if data.anchor_mode == "point" then
    region:SetSize(data.width or 16, data.height or 16)
  end

  region.Anchor = function()
    region:ClearAllPoints()
    parent:AnchorSubRegion(region, data.anchor_mode, arg1, arg2, data.xOffset, data.yOffset)
  end

  region:SetVisible(data.dispelIconVisible)
  parent.subRegionEvents:AddSubscriber("Update", region)
  region:Update(parent.state)
end

local function supports(regionType)
  return regionType == "texture"
         or regionType == "progresstexture"
         or regionType == "icon"
         or regionType == "aurabar"
         or regionType == "text"
         or regionType == "empty"
end

WeakAuras.RegisterSubRegionType("subdispelicon", L["Dispel Type Icon"], supports, create, modify, onAcquire,
                                onRelease, default, nil, properties)
