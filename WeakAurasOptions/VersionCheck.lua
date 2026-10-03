local L = WeakAuras.L

local optionsVersion = C_AddOns.GetAddOnMetadata("WeakAurasOptions", "Version")
local weakAurasVersion = C_AddOns.GetAddOnMetadata("WeakAuras", "Version")

if optionsVersion ~= weakAurasVersion then
  local message = string.format(L["The WeakAuras Options Addon version %s doesn't match the WeakAuras version %s. If you updated the addon while the game was running, try restarting World of Warcraft. Otherwise try reinstalling WeakAuras"],
                    tostring(optionsVersion), tostring(weakAurasVersion))
  WeakAuras.IsLibsOK = function() return false end
  WeakAuras.ToggleOptions = function()
    WeakAuras.prettyPrint(message)
  end
end
