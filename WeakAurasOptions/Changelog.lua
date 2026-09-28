if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)
OptionsPrivate.changelog = {
  versionString = '1.1.0',
  dateString = '2026-09-28',
  fullChangeLogUrl = 'https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md',
  highlightText = [==[
- Combat stability: no more Lua errors when the game hides data in combat (secret values)
- Cooldowns known before combat still become ready at their end time
- Target, focus and nameplate tracking no longer errors on hidden unit IDs (instances)
- New in-game tutorial: /wa tutorial, with two example auras to import]==],  commitText = [==[1.1.0 (2026-09-28):

- Secret values in trigger states are replaced by the last readable value
- Lua errors caused by secret values inside aura code are no longer reported
- Spell, charge, item and item slot cooldowns keep their last readable value in combat
- The GCD ends at its known end time, and every cooldown is checked again when combat ends
- The unit change tracker and the nameplate target tracker ignore secret unit GUIDs
- Talent caches no longer require GetNumTalentTabs or GetSpecialization
- /wa tutorial (or /wa tuto) opens a tutorial window, also reachable from the first login popup
- TUTORIAL.md: how to create auras on WoW Forever, with ready-to-import examples

Known limitations:

- Not tested in dungeons and raids yet
- Combat log triggers never fire: the game forbids the combat log to addons
- Aura and cooldown data can freeze during combat and update when combat ends
- Nameplate anchoring only works with the default Blizzard nameplates

1.0.2-beta:

- Loss of Control and Queued Action triggers use the new spell API
- First login popup lists what works on WoW Forever

1.0:

- First release of WeakAuras 5.22.0 for WoW Forever 1.60.1 (interface 16001)

]==]
}
