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

local showOnByCooldownShow = {
  always = "showAlways",
  cooldown = "showOnCooldown",
  ready = "showOnReady",
}

local showOnByBuffShow = {
  always = "showAlways",
  active = "showOnActive",
  missing = "showOnMissing",
}

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
    if type(subRegion) == "table" and type(subRegion.type) == "string" and subRegion.type:find("^subcdm") then
      return true
    end
  end
  return HasForeverAurasReferences(data)
end

local function IsForeverAurasData(data)
  return type(data) == "table" and HasForeverAurasContent(data)
end

local function RenameReferences(tbl)
  for key, value in pairs(tbl) do
    if type(value) == "string" then
      value = value:gsub("(" .. addonsPathPrefix .. ")ForeverAuras", "%1WeakAuras")
      if IsCodeField(tbl, key) then
        value = value:gsub(apiReferencePattern, "WeakAuras%1")
      end
      tbl[key] = value
    elseif type(value) == "table" then
      RenameReferences(value)
    end
  end
end

-- Spells of a ForeverAuras Cooldown Manager trigger. Like ForeverAuras, the ID and name lists replace the catalog
-- entries when one of them is enabled; the legacy single spell comes last. Buff entries give their aura spell IDs.
local function CooldownManagerSpells(trigger, warn, isBuff)
  local spells = {}
  if trigger.cdmUseExactIDs and type(trigger.cdmExactIDs) == "table" then
    for _, id in ipairs(trigger.cdmExactIDs) do
      tinsert(spells, tonumber(id) or id)
    end
  end
  if trigger.cdmUseNames and type(trigger.cdmNames) == "table" then
    for _, name in ipairs(trigger.cdmNames) do
      tinsert(spells, name)
    end
  end
  if not (trigger.cdmUseExactIDs or trigger.cdmUseNames)
     and type(trigger.cdmSpells) == "table" and type(trigger.cdmSpells.multi) == "table"
     and C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCooldownInfo then
    local cooldownIDs = {}
    for cooldownID, selected in pairs(trigger.cdmSpells.multi) do
      if selected and tonumber(cooldownID) then
        tinsert(cooldownIDs, tonumber(cooldownID))
      end
    end
    table.sort(cooldownIDs)
    for _, cooldownID in ipairs(cooldownIDs) do
      local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
      if info and (info.equipSlot or info.spellCategoryID) then
        warn("Cooldown Manager item entry skipped, use an Item Cooldown trigger")
      elseif info and isBuff and Private.GetCooldownManagerAuraSpellIDs then
        for _, spellID in ipairs(Private.GetCooldownManagerAuraSpellIDs(cooldownID)) do
          tinsert(spells, spellID)
        end
      elseif info and info.spellID then
        tinsert(spells, info.spellID)
      end
    end
  end
  local legacySpell = trigger.cdmSpell ~= nil and tostring(trigger.cdmSpell):match("^%s*(.-)%s*$")
  if not spells[1] and legacySpell and legacySpell ~= "" then
    tinsert(spells, trigger.cdmExact and tonumber(legacySpell) or legacySpell)
  end
  return spells
end

local function ConvertCooldownTrigger(trigger, warn)
  local spells = CooldownManagerSpells(trigger, warn)
  trigger.type = "spell"
  trigger.event = "Cooldown Progress (Spell)"
  trigger.spellName = spells[1]
  trigger.use_exact_spellName = type(spells[1]) == "number" or nil
  trigger.genericShowOn = showOnByCooldownShow[trigger.cdmShow] or "showAlways"
  trigger.track = trigger.cdmTrack or "auto"
  trigger.use_showgcd = trigger.use_cdmShowGCD
  if not spells[1] then
    warn("Cooldown Manager trigger without a readable spell")
  elseif spells[2] then
    warn("Cooldown Manager trigger with several spells, only the first one is kept")
  end
  if trigger.cdmShow == "usable" or trigger.cdmShow == "unusable" then
    warn("Cooldown Manager usable filter, shown always instead")
  end
end

local function ConvertBuffTrigger(trigger, warn)
  local spells = CooldownManagerSpells(trigger, warn, true)
  trigger.type = "aura2"
  trigger.event = nil
  if trigger.cdmRequireTarget then
    -- The Cooldown Manager tracks the player's own auras only
    trigger.unit, trigger.debuffType, trigger.ownOnly = "target", "HARMFUL", true
  else
    trigger.unit, trigger.debuffType = "player", "HELPFUL"
  end
  trigger.matchesShowOn = showOnByBuffShow[trigger.cdmBuffShow] or "showOnActive"
  local ids, names = {}, {}
  for _, spell in ipairs(spells) do
    tinsert(type(spell) == "number" and ids or names, tostring(spell))
  end
  if ids[1] then
    trigger.useExactSpellId, trigger.auraspellids = true, ids
  end
  if names[1] then
    trigger.useName, trigger.auranames = true, names
  end
  if trigger.cdmUseRemaining then
    trigger.useRem = true
    trigger.remOperator = trigger.cdmRemainingOperator or "<"
    trigger.rem = tostring(trigger.cdmRemainingTime or 10)
  end
  if trigger.cdmUseStacks then
    trigger.useStacks = true
    trigger.stacksOperator = trigger.cdmStackOperator or ">="
    trigger.stacks = tostring(trigger.cdmStackCount or 1)
  end
  if not spells[1] then
    warn("Cooldown Manager buff trigger without a readable spell")
  end
  if trigger.cdmUseTotal then
    trigger.useTotal = true
    trigger.totalOperator = trigger.cdmTotalOperator or ">="
    trigger.total = tostring(trigger.cdmTotalTime or 0)
  end
  if trigger.cdmUseElapsed then
    trigger.useElapsed = true
    trigger.elapsedOperator = trigger.cdmElapsedOperator or ">="
    trigger.elapsed = tostring(trigger.cdmElapsedTime or 0)
  end
end

local function ConvertItemTrigger(trigger, warn)
  local itemID = trigger.cdmUseItemIDs and type(trigger.cdmItemIDs) == "table" and trigger.cdmItemIDs[1]
  trigger.type = "item"
  trigger.event = "Cooldown Progress (Item)"
  trigger.itemName = tonumber(itemID) or itemID
  trigger.genericShowOn = showOnByCooldownShow[trigger.cdmShow] or "showAlways"
  if not itemID then
    warn("Cooldown Manager item trigger without an item ID")
  end
end

-- "Aura (Blizzard)" trigger: the aura filter is kept, the Blizzard aura container display is not
local function ConvertBlizzardAuraTrigger(trigger, warn)
  trigger.type = "aura2"
  trigger.unit = trigger.unit or "player"
  trigger.debuffType = trigger.debuffType or "HELPFUL"
  if trigger.secretUseSpellIDs and type(trigger.auraspellids) == "table" then
    trigger.useExactSpellId = true
  else
    trigger.auraspellids = nil
  end
  -- Native filters, the own auras one included, keep working in combat
  local nativeFilter, nativeFilterNot = {}, {}
  for token, value in pairs(type(trigger.nativeFilters) == "table" and trigger.nativeFilters or {}) do
    if Private.aura_native_filter_types and Private.aura_native_filter_types[token] then
      (value and nativeFilter or nativeFilterNot)[token] = true
    end
  end
  if trigger.isFromPlayerOrPlayerPet then
    nativeFilter.PLAYER = true
  end
  trigger.nativeFilters = nil
  if next(nativeFilter) or next(nativeFilterNot) then
    trigger.useNativeFilter, trigger.nativeFilter, trigger.nativeFilterNot = true, nativeFilter, nativeFilterNot
  end
  if trigger.sortMethod then
    warn("Blizzard Aura trigger sorting removed")
  end
end

local function ConvertTrigger(trigger, warn)
  if trigger.type == "cdm" or trigger.event == "Blizzard Cooldown Manager" or trigger.event == "Blizzard CDM Utility" then
    if trigger.event == "Blizzard CDM Buff" or trigger.cdmSource == "buff" then
      ConvertBuffTrigger(trigger, warn)
    elseif trigger.event == "Blizzard CDM Item" then
      ConvertItemTrigger(trigger, warn)
    else
      ConvertCooldownTrigger(trigger, warn)
    end
  elseif trigger.type == "secretAura" then
    ConvertBlizzardAuraTrigger(trigger, warn)
  elseif trigger.event == "Swing Timer" then
    -- swingType is the only weapon setting ForeverAuras reads
    local hand = handBySwingType[tonumber(trigger.swingType)]
    if hand then
      trigger.hand = hand
      trigger.use_hand = true
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
    end
  elseif trigger.event == "Role" then
    trigger.use_role = trigger.role ~= nil or nil
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
  elseif trigger.event == "Equipment Durability" then
    local slot = tonumber(trigger.durabilitySlot)
    trigger.use_durabilitySlot = slot and slot > 0 or nil
    trigger.durabilitySlot = slot and slot > 0 and slot or nil
  elseif trigger.event == "Bag Space" then
    if trigger.use_totalSlots or trigger.use_freePercent then
      warn("Bag Space total slots or free percent filter, removed")
    end
  elseif unsupportedEvents[trigger.event] then
    warn(("%s trigger has no equivalent, the aura will not show"):format(trigger.event))
  end
end

-- Dispel type icon sub element: same position, a border style becomes a border colored by dispel type
local function ConvertDispelIconSubRegion(subRegion)
  if subRegion.dispelStyle and subRegion.dispelStyle ~= "Icon" then
    return false
  end
  subRegion.type = "subdispelicon"
  subRegion.dispelIconVisible = subRegion.dispelVisible ~= false
  subRegion.dispelVisible, subRegion.dispelStyle = nil, nil
  return true
end

-- Dispel type border sub element becomes a border colored by dispel type, at the same index
local function ConvertDispelSubRegion(subRegion)
  local size, offset = subRegion.dispelBorderSize, subRegion.dispelBorderOffset
  wipe(subRegion)
  subRegion.type = "subborder"
  subRegion.border_visible = true
  subRegion.border_dispelColor = true
  subRegion.border_color = {1, 1, 1, 1}
  subRegion.border_edge = "Square Full White"
  subRegion.border_size = size or 2
  subRegion.border_offset = offset or 0
end

local function ConvertAura(data, warnings)
  local function warn(message)
    tinsert(warnings, ("%s: %s"):format(data.id or "?", message))
  end

  RenameReferences(data)
  -- Migration 89 of this addon, which ForeverAuras numbers differently
  data.information = data.information or {}
  data.information.showNilIsFalse = true

  if type(data.triggers) == "table" then
    for _, triggerData in ipairs(data.triggers) do
      if type(triggerData.trigger) == "table" then
        ConvertTrigger(triggerData.trigger, warn)
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

  if type(data.subRegions) == "table" then
    for _, subRegion in ipairs(data.subRegions) do
      if subRegion.type == "subcdmdispel" and ConvertDispelIconSubRegion(subRegion) then
        -- converted in place
      elseif subRegion.type == "subcdmdispel" or subRegion.type == "subcdmdispelborder" then
        ConvertDispelSubRegion(subRegion)
      end
    end
  end
  if data.cdmDispelIndicator then
    data.subRegions = data.subRegions or {}
    local subRegion = {}
    ConvertDispelSubRegion(subRegion)
    tinsert(data.subRegions, subRegion)
  end
  data.cdmDispelIndicator = nil
  data.blizzardAuraDisplay = nil

  -- Exports older than 90 still need migration 90, the same in both addons
  data.internalVersion = (tonumber(data.internalVersion) or 0) >= 90 and WeakAuras.InternalVersion() or 89
end

--- Converts in place an imported aura and its children when they come from ForeverAuras.
--- @return boolean converted
function Private.ConvertForeverAurasImport(data, children)
  local converted = false
  local warnings = {}
  if IsForeverAurasData(data) then
    ConvertAura(data, warnings)
    converted = true
  end
  if type(children) == "table" then
    for _, child in ipairs(children) do
      if IsForeverAurasData(child) then
        ConvertAura(child, warnings)
        converted = true
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
