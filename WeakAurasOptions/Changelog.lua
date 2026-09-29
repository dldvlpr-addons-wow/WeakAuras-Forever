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
  versionString = '1.2.0',
  dateString = '2026-09-29',
  fullChangeLogUrl = 'https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md',
  highlightText = [==[
- In combat, the game now draws what WeakAuras cannot read: cooldown swipes, timer bars, health and power bars, and texts made only of %p and %t keep moving
- Recasting a buff on yourself restarts its timer, even in combat
- New triggers: Bag Space, Equipment Durability, Role, Tracking and Ammo
- The full guide is inside WeakAuras: click Guide at the top of the /wa window]==],  commitText = [==[1.2.0 (2026-09-29):

New:

- Triggers: Bag Space, Equipment Durability, Role, Tracking, and Ammo (count of the equipped ammo in the bags)
- Swing Timer: uses the game's own swing for main hand, off hand and ranged (wand included), with a Target In Range option
- Aura trigger: Elapsed Time filter, Native Filter (aura categories of the game), and a "From the Cooldown Manager" list
- Cooldown trigger: "From the Cooldown Manager" list, and an "On Global Cooldown" condition
- Conditions trigger: "Secret Restrictions Active" option
- Dispel Type Icon sub element, and borders colored by dispel type
- Load options: Class and Specialization, and Instance Type
- Auras exported from ForeverAuras are converted on import. What cannot be converted is listed in the chat
- /wa cdm shows or hides the Blizzard Cooldown Manager, out of combat
- Guide: /wa tutorial or the Guide button opens the full guide, with three ready-made auras to import

Changes:

- Auras update as soon as the game stops hiding data, not only at the end of combat
- The options warn about combat log triggers, and about thresholds on health or power, which cannot be checked in combat
- The Weapon Enchant trigger works with the new game API

Fixes:

- Role trigger: no more Lua error
- Health trigger: the health bar of your target moves in combat
- A condition such as "Health < 50%" keeps its last state in combat instead of turning false
- Unit triggers keep working when the unit ID is hidden (instances). An Npc ID filter then hides the aura
- Equipment Durability percentages are whole numbers
- Off hand swing timer after an attack speed change

Known limitations:

- Buffs and debuffs are hidden in combat: a buff shown before the pull keeps counting down, stacks stay frozen, and a buff applied for the first time in combat only shows when combat ends
- The Native Filter of the Aura trigger shows nothing at the moment
- Combat log triggers never fire: the game forbids the combat log to addons
- The Blizzard Cooldown Manager is not enabled for every class on the WoW Forever beta
- Not tested in game yet: Equipment Durability, Tracking, Ammo, Instance Type, off hand and ranged swing timer, dispel type colors, dungeons and raids
- Nameplate anchoring only works with the default Blizzard nameplates

1.1.0 (2026-09-28):

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
