if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L;

local function createOptions(parentData, data, index, subIndex)
  local pointAnchors = {}
  local areaAnchors = {}
  for child in OptionsPrivate.Private.TraverseLeafsOrAura(parentData) do
    Mixin(pointAnchors, OptionsPrivate.Private.GetAnchorsForData(child, "point"))
    Mixin(areaAnchors, OptionsPrivate.Private.GetAnchorsForData(child, "area"))
  end

  local options = {
    __title = L["Dispel Type Icon %s"]:format(subIndex),
    __order = 1,
    dispelIconVisible = {
      type = "toggle",
      width = WeakAuras.doubleWidth,
      name = L["Show Dispel Type Icon"],
      desc = L["Shows the dispel type of the aura shown. During combat restrictions, a circle in the dispel type color replaces the icon."],
      order = 1,
    },
  }

  OptionsPrivate.commonOptions.PositionOptionsForSubElement(data, options, 2, areaAnchors, pointAnchors)
  OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, "subdispelicon")

  return options
end

WeakAuras.RegisterSubRegionOptions("subdispelicon", createOptions, L["Shows the dispel type of the aura"]);
