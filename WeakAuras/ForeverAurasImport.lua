if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

-- Converts auras exported by ForeverAuras (a WeakAuras fork for WoW Forever) to this addon's format.
-- Only the saved data format is read: types without equivalent are kept disabled, and listed in the chat.

-- ForeverAuras numbers its internal versions like this addon, so its exports are found by their content only
local addonsPathPrefix = "[Aa][Dd][Dd][Oo][Nn][Ss][\\/]+"
local apiReferencePattern = "ForeverAuras([%.:%[])"

local handBySwingType = { [0] = "main", [1] = "off", [2] = "ranged" }

-- TimelineParser triggers need the ExRT_Reminder addon, and the boss timeline of the client behind it
local unsupportedEvents = {
  ["TimelineParser Timer"] = true,
  ["TimelineParser Stage"] = true,
}

-- Code fields: custom*, message_custom, and the code of a Custom Check condition
local function IsCodeField(tbl, key)
  return type(key) == "string" and (key:find("custom", 1, true) or (key == "value" and tbl.variable == "customcheck"))
end

-- Media paths of ForeverAuras in any string, its API in custom code only
local function HasForeverAurasReferences(tbl)
  for key, value in pairs(tbl) do
    if type(value) == "string" then
      if value:find(addonsPathPrefix .. "ForeverAuras") or (IsCodeField(tbl, key) and value:find(apiReferencePattern)) then
        return true
      end
    elseif type(value) == "table" and HasForeverAurasReferences(value) then
      return true
    end
  end
  return false
end

local function IsForeverAurasDispelSubRegion(subRegion)
  return subRegion.type == "subcdmdispelborder"
    or (subRegion.type == "subcdmdispel" and subRegion.dispelStyle ~= nil and subRegion.dispelStyle ~= "Icon")
end

local function HasForeverAurasContent(data)
  if data.cdmDispelIndicator or data.blizzardAuraDisplay then
    return true
  end
  for _, triggerData in ipairs(type(data.triggers) == "table" and data.triggers or {}) do
    local trigger = type(triggerData) == "table" and triggerData.trigger
    if type(trigger) == "table" and (trigger.type == "cdm" or trigger.type == "secretAura"
       or trigger.swingType ~= nil or trigger.trackingType ~= nil or trigger.trackingShow ~= nil
       or trigger.ammoItemIDs ~= nil or trigger.use_totalSlots ~= nil or trigger.use_freePercent ~= nil
       or unsupportedEvents[trigger.event]) then
      return true
    end
  end
  for _, subRegion in ipairs(type(data.subRegions) == "table" and data.subRegions or {}) do
    if type(subRegion) == "table" and IsForeverAurasDispelSubRegion(subRegion) then
      return true
    end
  end
  return HasForeverAurasReferences(data)
end

local function IsForeverAurasData(data)
  return type(data) == "table" and HasForeverAurasContent(data)
end

local function RenameReferences(tbl)
  local renamed = false
  for key, value in pairs(tbl) do
    if type(value) == "string" then
      local count, codeCount
      value, count = value:gsub("(" .. addonsPathPrefix .. ")ForeverAuras", "%1WeakAuras")
      if IsCodeField(tbl, key) then
        value, codeCount = value:gsub(apiReferencePattern, "WeakAuras%1")
        count = count + codeCount
      end
      if count > 0 then
        tbl[key] = value
        renamed = true
      end
    elseif type(value) == "table" then
      renamed = RenameReferences(value) or renamed
    end
  end
  return renamed
end

local function ConvertTrigger(trigger, warn)
  if trigger.event == "Swing Timer" then
    -- swingType is the only weapon setting ForeverAuras reads
    local hand = handBySwingType[tonumber(trigger.swingType)]
    if hand and (trigger.hand ~= hand or not trigger.use_hand) then
      trigger.hand = hand
      trigger.use_hand = true
      return true
    end
  elseif trigger.event == "Ammo" then
    if type(trigger.ammoItemIDs) == "string" and trigger.ammoItemIDs ~= "" then
      local items = {}
      for id in trigger.ammoItemIDs:gmatch("%d+") do
        tinsert(items, tonumber(id))
      end
      trigger.use_ammoItem = items[1] and true or nil
      trigger.ammoItem = items[1] and items or nil
      warn("Ammo item list now filters the equipped ammo, instead of counting these items in the bags")
      return true
    end
  elseif trigger.event == "Role" then
    if trigger.use_role == nil and trigger.role ~= nil then
      trigger.use_role = true
      return true
    end
  elseif trigger.event == "Tracking" and (trigger.trackingType ~= nil or trigger.trackingShow ~= nil) then
    local spellID = tonumber(trigger.trackingType)
    trigger.use_trackingSpell = spellID and true or nil
    trigger.trackingSpell = spellID and { spellID } or nil
    trigger.use_inverse = trigger.trackingShow == "inactive" or nil
    if not spellID and trigger.trackingType and trigger.trackingType ~= "" then
      warn("Tracking without a spell ID, now shows on any active tracking")
    end
    if trigger.trackingShow == "always" then
      warn("Tracking shown always, now shown when active")
    end
    return true
  elseif trigger.event == "Equipment Durability" then
    local slot = tonumber(trigger.durabilitySlot)
    if trigger.use_durabilitySlot == nil and slot and slot > 0 then
      trigger.use_durabilitySlot = true
      trigger.durabilitySlot = slot
      return true
    end
  elseif trigger.event == "Bag Space" then
    if trigger.use_totalSlots or trigger.use_freePercent then
      warn("Bag Space total slots or free percent filter, removed")
    end
  elseif unsupportedEvents[trigger.event] then
    warn(("%s trigger has no equivalent, the aura will not show"):format(trigger.event))
  end
  return false
end

local function ConvertAura(data, warnings)
  local warningCount = #warnings
  local function warn(message)
    tinsert(warnings, ("%s: %s"):format(data.id or "?", message))
  end

  local changed = RenameReferences(data)
  -- Migration 89 of this addon, which ForeverAuras numbers differently
  data.information = data.information or {}
  if data.information.showNilIsFalse ~= true then
    data.information.showNilIsFalse = true
    changed = true
  end

  if type(data.triggers) == "table" then
    for _, triggerData in ipairs(data.triggers) do
      if type(triggerData.trigger) == "table" then
        changed = ConvertTrigger(triggerData.trigger, warn) or changed
      end
    end
  end

  -- Bag Space variables without equivalent, in conditions (checks can nest in and / or checks)
  local function WarnConditionVariables(check)
    if type(check) ~= "table" then
      return
    end
    if check.variable == "totalSlots" or check.variable == "freePercent" then
      warn(("Condition on Bag Space %s, it never matches"):format(check.variable))
    end
    for _, subCheck in ipairs(type(check.checks) == "table" and check.checks or {}) do
      WarnConditionVariables(subCheck)
    end
  end
  for _, condition in ipairs(type(data.conditions) == "table" and data.conditions or {}) do
    WarnConditionVariables(type(condition) == "table" and condition.check)
  end

  -- Exports older than 90 still need migration 90, the same in both addons
  data.internalVersion = (tonumber(data.internalVersion) or 0) >= 90 and WeakAuras.InternalVersion() or 89
  return changed or #warnings > warningCount
end

--- Converts in place an imported aura and its children when they come from ForeverAuras.
--- @return boolean converted
function Private.ConvertForeverAurasImport(data, children)
  local converted = false
  local warnings = {}
  if IsForeverAurasData(data) then
    converted = ConvertAura(data, warnings) or converted
  end
  if type(children) == "table" then
    for _, child in ipairs(children) do
      if IsForeverAurasData(child) then
        converted = ConvertAura(child, warnings) or converted
      end
    end
  end
  if converted then
    WeakAuras.prettyPrint("Converted from ForeverAuras.")
    for _, message in ipairs(warnings) do
      WeakAuras.prettyPrint(message)
    end
  end
  return converted
end
