if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local SharedMedia = LibStub("LibSharedMedia-3.0");
local L = WeakAuras.L;

local default = function(parentType)
  local options = {
    border_visible = true,
    border_color = {1, 1, 1, 1},
    border_edge = "Square Full White",
    border_offset = 0,
    border_size = 2,
    border_dispelColor = false,
  }
  if parentType == "aurabar" then
    options["anchor_area"] = "bar"
  end
  return options
end

local properties = {
  border_visible = {
    display = L["Visibility"],
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true
  },
  border_color = {
    display = L["Color"],
    setter = "SetBorderColor",
    type = "color"
  },
}


-- Debuff border colors of the default UI, keyed by the debuffClass of BuffTrigger2.
-- An aura without dispel type ("none") keeps the border color. Shared with the Dispel Type Icon.
local dispelColors = {
  magic = {0.2, 0.6, 1},
  curse = {0.6, 0, 1},
  disease = {0.6, 0.4, 0},
  poison = {0, 0.6, 0},
  bleed = {1, 0, 0},
  enrage = {1, 0.5, 0},
}

-- ponytail: dispel type IDs assumed from the client enum, not found in the UI source
local dispelTypeIds = { magic = 1, curse = 2, disease = 3, poison = 4, enrage = 9, bleed = 11 }

-- Step curve from dispel type ID to color, point 0 (no dispel type) being noneColor
local function CreateDispelCurve(noneColor)
  if not (C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor and C_CurveUtil and C_CurveUtil.CreateColorCurve
          and Enum and Enum.LuaCurveType) then
    return nil
  end
  local ok, curve = pcall(C_CurveUtil.CreateColorCurve)
  if not ok or not curve then
    return nil
  end
  curve:SetType(Enum.LuaCurveType.Step)
  curve:AddPoint(0, CreateColor(noneColor[1], noneColor[2], noneColor[3], noneColor[4] or 1))
  for debuffClass, id in pairs(dispelTypeIds) do
    local color = dispelColors[debuffClass]
    curve:AddPoint(id, CreateColor(color[1], color[2], color[3], 1))
  end
  return curve
end

local function ReadDispelColor(unit, auraInstanceID, curve)
  local color = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, curve)
  return color.r, color.g, color.b, color.a
end

-- Readable dispel type of a state, or nil: debuffClass can be secret during the restriction
local function ReadableDebuffClass(state)
  local debuffClass = state and state.debuffClass
  if type(debuffClass) == "string" and not Private.IsSecret(debuffClass) then
    return debuffClass
  end
end

Private.dispelColors = dispelColors
Private.CreateDispelCurve = CreateDispelCurve
Private.ReadDispelColor = ReadDispelColor
Private.ReadableDebuffClass = ReadableDebuffClass

local function create()
  local region = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
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

  local edgeFile = SharedMedia:Fetch("border", data.border_edge)
  if edgeFile and edgeFile ~= "" then
    region:SetBackdrop({
      edgeFile = edgeFile,
      edgeSize = data.border_size,
      bgFile = nil,
    })
    region:SetBackdropBorderColor(data.border_color[1], data.border_color[2],
                                  data.border_color[3], data.border_color[4])
    region:SetBackdropColor(0, 0, 0, 0)
  end

  local defaultColor = data.border_color

  -- A color other than the default one comes from a condition, and wins over the dispel type color
  function region:SetBorderColor(r, g, b, a)
    self.colorOverridden = r ~= defaultColor[1] or g ~= defaultColor[2] or b ~= defaultColor[3]
    if self.Update and not self.colorOverridden then
      self:Update(parent.state)
    else
      self:SetBackdropBorderColor(r, g, b, a or 1)
    end
  end

  function region:SetVisible(visible)
    if visible then
      self:Show()
    else
      self:Hide()
    end
  end

  region:SetVisible(data.border_visible)

  if data.border_dispelColor then
    region.dispelCurve = CreateDispelCurve(defaultColor)
    -- Recolors on each state update; the alpha stays the configured one, so it is never secret
    function region:Update(state)
      if self.colorOverridden then
        return
      end
      local alpha = defaultColor[4]
      if state and state.unit and state.auraInstanceID and self.dispelCurve then
        local ok, r, g, b = pcall(ReadDispelColor, state.unit, state.auraInstanceID, self.dispelCurve)
        if ok then
          self:SetBackdropBorderColor(r, g, b, alpha)
          return
        end
      end
      local debuffClass = ReadableDebuffClass(state)
      local color = debuffClass and dispelColors[debuffClass] or defaultColor
      self:SetBackdropBorderColor(color[1], color[2], color[3], alpha)
    end
    parent.subRegionEvents:AddSubscriber("Update", region)
  else
    region.Update = nil
    region.dispelCurve = nil
    parent.subRegionEvents:RemoveSubscriber("Update", region)
  end

  region:SetBorderColor(defaultColor[1], defaultColor[2], defaultColor[3], defaultColor[4])

  region.Anchor = function()
    parent:AnchorSubRegion(region, "area", parentData.regionType == "aurabar" and data.anchor_area or nil,
                           nil, data.border_offset, data.border_offset)
  end
end

local function supports(regionType)
  return regionType == "texture"
         or regionType == "progresstexture"
         or regionType == "icon"
         or regionType == "aurabar"
         or regionType == "empty"
end

WeakAuras.RegisterSubRegionType("subborder", L["Border"], supports, create, modify, onAcquire, onRelease,
                                default, nil, properties)
