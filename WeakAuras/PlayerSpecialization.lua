if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local specializations = {
  {"WARRIOR_ARMS", "WARRIOR", "Arms", "ability_rogue_eviscerate", {12294, 21551, 21552, 21553}},
  {"WARRIOR_FURY", "WARRIOR", "Fury", "ability_warrior_innerrage", {23881, 23892, 23893, 23894}},
  {"WARRIOR_PROTECTION", "WARRIOR", "Protection", "ability_warrior_defensivestance", {23922, 23923, 23924, 23925}},
  {"PALADIN_HOLY", "PALADIN", "Holy", "spell_holy_holybolt", {1310911, 1311590, 1311595}},
  {"PALADIN_PROTECTION", "PALADIN", "Protection", "spell_holy_devotionaura", {20925, 20927, 20928}},
  {"PALADIN_RETRIBUTION", "PALADIN", "Retribution", "spell_holy_auraoflight", {1310735}},
  {"HUNTER_BEAST_MASTERY", "HUNTER", "Beast Mastery", "ability_hunter_beasttaming", {19574}},
  {"HUNTER_MARKSMANSHIP", "HUNTER", "Marksmanship", "ability_marksmanship", {1310687, 1310785, 1310786}},
  {"HUNTER_SURVIVAL", "HUNTER", "Survival", "ability_hunter_swiftstrike", {1310533}},
  {"ROGUE_ASSASSINATION", "ROGUE", "Assassination", "ability_rogue_eviscerate", {1310703}},
  {"ROGUE_COMBAT", "ROGUE", "Combat", "ability_backstab", {13750}},
  {"ROGUE_SUBTLETY", "ROGUE", "Subtlety", "ability_stealth", {1310721}},
  {"PRIEST_DISCIPLINE", "PRIEST", "Discipline", "spell_holy_wordfortitude", {10060}},
  {"PRIEST_HOLY", "PRIEST", "Holy", "spell_holy_holybolt", {401859, 1240826, 1240827}},
  {"PRIEST_SHADOW", "PRIEST", "Shadow", "spell_shadow_shadowwordpain", {15473}},
  {"SHAMAN_ELEMENTAL", "SHAMAN", "Elemental", "spell_nature_lightning", {408490, 1238299, 1238300}},
  {"SHAMAN_ENHANCEMENT", "SHAMAN", "Enhancement", "spell_nature_lightningshield", {425336}},
  {"SHAMAN_RESTORATION", "SHAMAN", "Restoration", "spell_nature_magicimmunity", {408521, 1239242, 1239243}},
  {"MAGE_ARCANE", "MAGE", "Arcane", "spell_holy_magicalsentry", {12042}},
  {"MAGE_FIRE", "MAGE", "Fire", "spell_fire_firebolt02", {11129}},
  {"MAGE_FROST", "MAGE", "Frost", "spell_frost_frostbolt02", {11426, 13031, 13032, 13033}},
  {"WARLOCK_AFFLICTION", "WARLOCK", "Affliction", "spell_shadow_deathcoil", {1316697}},
  {"WARLOCK_DEMONOLOGY", "WARLOCK", "Demonology", "spell_shadow_metamorphosis", {425464}},
  {"WARLOCK_DESTRUCTION", "WARLOCK", "Destruction", "spell_shadow_rainoffire", {412758, 1293812, 1293813}},
  {"DRUID_BALANCE", "DRUID", "Balance", "spell_nature_starfall", {24858}},
  {"DRUID_FERAL_COMBAT", "DRUID", "Feral Combat", "ability_racial_bearform", {417141}},
  {"DRUID_RESTORATION", "DRUID", "Restoration", "spell_nature_healingtouch", {408120, 1238214, 1238215}},
}

Private.forever_spec_types = {}
Private.forever_specs_sorted = {}
local byKey = {}
for _, entry in ipairs(specializations) do
  local key, class, name, icon = entry[1], entry[2], entry[3], entry[4]
  byKey[key] = entry
  local className = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class] or class
  Private.forever_spec_types[key] = "|TInterface\\Icons\\" .. icon .. ":0|t " .. className .. " - " .. name
  Private.forever_specs_sorted[#Private.forever_specs_sorted + 1] = key
end

local function KnownByPlayer(spellID)
  local api = C_SpellBook and C_SpellBook.IsSpellKnown or IsPlayerSpell or IsSpellKnown
  if not api then
    return false
  end
  local ok, known = pcall(api, spellID)
  if not ok or Private.IsSecret(known) then
    return false
  end
  return known == true
end

function Private.ExecEnv.IsForeverSpecialization(key)
  local entry = byKey[key]
  if not entry then
    return false
  end
  local _, class = UnitClass("player")
  if Private.IsSecret(class) or class ~= entry[2] then
    return false
  end
  for _, spellID in ipairs(entry[5]) do
    if KnownByPlayer(spellID) then
      return true
    end
  end
  return false
end
