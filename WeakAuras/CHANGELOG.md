# WeakAuras Forever 1.4.0 (2026-10-03)

Based on WeakAuras 5.22.0. Every changed file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md).
Features taken from ForeverAuras (m33shoq, GPL-2.0).

## Highlights

- The addon loads again: the 1.3.2 download from CurseForge stopped at start-up and `/wa` did nothing.
- New trigger type: Aura (Modern). Buffs and debuffs are drawn by the game's own aura widgets, so duration and
  stacks keep moving in combat.
- New trigger type: Blizzard Cooldown Manager. Cooldowns, buffs, debuffs and items shown by the game's Cooldown
  Manager, drawn natively, so they keep working in combat.

## New

- Aura (Modern) trigger: Show On, Remaining Time, Total Duration and Stack Count rules, native conditions (Aura
  Present, In Pandemic Window, Dispel Type, Aura Highlight), glow on the unit frame. ForeverAuras auras that use it
  are imported as they are.
- Modern Aura Group: from the New button or the multi-selection menu, with growth, spacing, sort, limit and
  grouping by unit frame or nameplate.
- Dispel Type Border sub element.

- Blizzard Cooldown Manager trigger: Cooldown, Buff/Debuff and Item, with remaining time, total, stacks and
  "require target" filters. ForeverAuras auras that use it are imported as they are.
- "Hide Blizzard's CDM" in the options and `/wa cdm`: hide the Blizzard Cooldown Manager while its triggers keep
  working.
- CDM Dispel Type Icon sub element.
- Load conditions: Specialization (deduced from the talents you learned), Secret Restrictions Active, Enabled
  BossMod ID (BigWigs).
- Spell in Range trigger.
- Color picker palette: class colors, favorites, recent colors and a hex field.
- Warnings in the trigger options for values the game hides in combat, and combat status of the Cast trigger.

## Changes

- Spell cooldowns in combat: ready and on cooldown states follow the spell, ignore the global cooldown and the
  shared Shoot cooldown, and Cooldown Ready fires once.
- Totems keep their name and icon in combat once each totem was placed out of combat.
- Progress Texture, Progress Bar and Text regions: more cases drawn natively in combat (inverse direction,
  smoothing, additional bars, ring angles, rotation and mirror).
- Dynamic groups wait for the end of combat to move protected anchors.
- The swing timer no longer listens to the combat log.

## Fixes

- The 1.3.2 zip built for CurseForge did not load: `Init.lua` stopped on `unexpected symbol near ']'`.
- Aura trigger, Name Pattern Match: the filter matched every aura, so an aura made for Demon Skin also showed
  Devotion Aura. It now matches the name, with equality when no operator is chosen.
- Action Usable trigger: a paused cooldown was read from the wrong value.
- Range Check: no Lua error when the game hides the range.
- Custom code: `WeakAuras.GetCritChance`, `GetHitChance`, `GetEffectiveAttackPower` and `GetEffectiveSpellPower`
  return nil instead of 0 while the game hides your stats.

## Known limitations

- Tested in game: Aura (Modern) on a buff of the player, out of combat and in combat, the Secret Restrictions Active
  load condition, and the Range Check trigger in combat. Everything else listed under New and Changes is not tested
  in game yet.
- Aura (Modern) needs the spell ID of the aura itself, which can differ from the spell you cast on WoW Forever.
- `/wa` is also used by ForeverAuras: disable ForeverAuras, or type `/weakauras`.
- With the classic Aura trigger, buffs and debuffs are hidden in combat: a buff shown before the pull keeps
  counting down, stacks stay frozen, and a buff applied for the first time in combat only shows when combat ends.
  Use Aura (Modern) for combat.
- The Native Filter of the Aura trigger shows nothing at the moment.
- Combat log triggers never fire: the game forbids the combat log to addons.
- The Blizzard Cooldown Manager is not enabled for every class on the WoW Forever beta.
- Nameplate anchoring only works with the default Blizzard nameplates.

# WeakAuras Forever 1.3.2 (2026-10-03)

Based on WeakAuras 5.22.0. Every changed file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md).

## Highlights

- Aura names typed by hand work again: "Demon Skin" in an Aura trigger now matches the buff.

## Fixes

- Aura trigger and Load tab: an aura name typed by hand was replaced by an empty name, so the trigger matched
  nothing and an extra "or" row appeared. The name is now kept as typed. Spell IDs were not affected.

## Known limitations

- Talents: not tested in game yet. The ForeverAuras "Specialization" load condition is ignored on import: the aura
  then loads for every specialization of its class.
- Buffs and debuffs are hidden in combat: a buff shown before the pull keeps counting down, stacks stay frozen, and
  a buff applied for the first time in combat only shows when combat ends.
- The Native Filter of the Aura trigger shows nothing at the moment.
- Combat log triggers never fire: the game forbids the combat log to addons.
- The Blizzard Cooldown Manager is not enabled for every class on the WoW Forever beta.
- Not tested in game yet: Hide when target dies, Totem trigger in combat, Equipment Durability, Tracking, Ammo,
  Instance Type, off hand and ranged swing timer, dispel type colors, dungeons and raids.
- Nameplate anchoring only works with the default Blizzard nameplates.

# WeakAuras Forever 1.3.1 (2026-10-02)

Based on WeakAuras 5.22.0. Every changed file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md).

## Highlights

- DoT timers without custom code: the Spell Cast Succeeded trigger has a new **Hide when target dies** option.

## New

- Spell Cast Succeeded trigger: **Hide when target dies**. The timer started by your cast hides when your current
  target dies, before its duration ends. Only the death of your current target is seen: if you change target and
  the mob with your DoT dies, the timer keeps running, and if the new target dies, the timer is hidden.

## Changes

- Guide (`/wa tutorial`), section 5: the DoT timer recipe uses the Spell Cast Succeeded trigger, with no custom
  code. The ready-made Immolate aura uses this trigger too: importing it again updates the old one.

## Known limitations

- Talents: not tested in game yet. The ForeverAuras "Specialization" load condition is ignored on import: the aura
  then loads for every specialization of its class.
- Buffs and debuffs are hidden in combat: a buff shown before the pull keeps counting down, stacks stay frozen, and
  a buff applied for the first time in combat only shows when combat ends.
- The Native Filter of the Aura trigger shows nothing at the moment.
- Combat log triggers never fire: the game forbids the combat log to addons.
- The Blizzard Cooldown Manager is not enabled for every class on the WoW Forever beta.
- Not tested in game yet: Hide when target dies, Totem trigger in combat, Equipment Durability, Tracking, Ammo,
  Instance Type, off hand and ranged swing timer, dispel type colors, dungeons and raids.
- Nameplate anchoring only works with the default Blizzard nameplates.

# WeakAuras Forever 1.3.0 (2026-09-30)

Based on WeakAuras 5.22.0. Every changed file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md).

## Highlights

- Progress Textures move in combat: linear and circular fills follow the hidden value, like the Progress Bar.
- Text auras show the health, power and percent of the unit in combat, with `%health`, `%maxhealth`,
  `%percenthealth`, `%power`, `%maxpower` and `%percentpower`.
- Cast bar on your target: the Cast trigger follows the cast in combat, with the icon of the spell.
- Totem timers keep running in combat.
- Talents: the Talent load conditions and the Talent Known trigger work on WoW Forever, with a talent picker, the
  same way as in ForeverAuras.
- Auras published for ForeverAuras import as they are, talent conditions included.

## New

- Progress Texture: Left to Right, Right to Left, Bottom to Top, Top to Bottom, Clockwise and Anticlockwise
  textures are drawn by the game while the value is hidden. Not drawn that way: an inverted static value, extra
  textures, slant, crop, mirror and the start and end angles.
- Text aura and Text sub element: `%health`, `%maxhealth`, `%percenthealth`, `%power`, `%maxpower`,
  `%percentpower`, `%value`, `%total`, `%p` and `%t` are drawn by the game in combat, with the plain text around
  them. Format options are ignored while the value is hidden, and a text with `{` (raid markers, `%{...}`) keeps
  its last readable values.
- Cast trigger: while the cast of the unit is hidden, the bar, the swipe and a `%p` text follow the cast. The name
  is shown empty, the icon is the icon of the spell. A trigger filtered by spell name or ID, Remaining Time or
  Interruptible does not match a hidden cast.
- Totem trigger: the timer of a totem keeps running in combat. The totem name, icon and spell ID filters accept
  every hidden totem; the Remaining Time filter does not.
- Talent and Or Talent load conditions, and the Talent Known trigger: once a single Class and Specialization is
  selected, a talent picker shows the talent tree of that specialization. The talents are read from the game's
  talent trees, with the same IDs as ForeverAuras. The talent data reader and the picker come from ForeverAuras
  (m33shoq, GPL-2.0).

## Changes

- Unit is Unit, Specific Unit, Ignore Self, Source Unit and Destination Unit checks keep their last readable
  result when the game hides the comparison (compound unit IDs such as `targettarget` on restricted maps).
- Internal data version 91, the same as ForeverAuras: an aura exported from either addon imports into the other
  without a version warning. Auras saved or exported with 1.2.0 still load. An export made with 1.3.0 cannot be
  imported into 1.2.0, and going back to 1.2.0 shows the repair window.
- ForeverAuras exports are recognized by their content (ForeverAuras trigger and sub element types, media paths,
  custom code), no longer by their version number. An aura whose only triggers are Role or Equipment Durability
  imports as it is.

## Fixes

- Texture paths ending with `.tga` or `.blp` (rings, circles and squares of the texture picker) now load on WoW
  Forever.
- Global Cooldown trigger: shows in combat.
- Aura triggers: no more "Aura triggers paused until the end of combat" at the start of a fight, and a scan started
  by a target change or a roster update in that frame keeps the matched auras.
- Text aura: no Lua error after a hidden text was shown (its size is then left as is).
- Importing an aura with a Talent load condition no longer stops with "C_SpecializationInfo.GetTalent: query.tier
  must be specified".
- ForeverAuras media paths written with doubled backslashes in custom code are renamed on import too.

## Known limitations

- Talents: not tested in game yet. The ForeverAuras "Specialization" load condition is ignored on import: the aura
  then loads for every specialization of its class.
- Buffs and debuffs are hidden in combat: a buff shown before the pull keeps counting down, stacks stay frozen, and
  a buff applied for the first time in combat only shows when combat ends.
- The Native Filter of the Aura trigger shows nothing at the moment.
- Combat log triggers never fire: the game forbids the combat log to addons.
- The Blizzard Cooldown Manager is not enabled for every class on the WoW Forever beta.
- Not tested in game yet: Totem trigger in combat, Equipment Durability, Tracking, Ammo, Instance Type, off hand
  and ranged swing timer, dispel type colors, dungeons and raids.
- Nameplate anchoring only works with the default Blizzard nameplates.

# WeakAuras Forever 1.2.0 (2026-09-29)

Based on WeakAuras 5.22.0. Every changed file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md).

## Highlights

- In combat, the game now draws what WeakAuras cannot read: cooldown swipes, timer bars, health and power bars, and
  texts made only of `%p` and `%t` keep moving.
- Recasting a buff on yourself restarts its timer, even in combat.
- New triggers: Bag Space, Equipment Durability, Role, Tracking and Ammo.
- The full guide is inside WeakAuras: click **Guide** at the top of the `/wa` window.

## New

- Triggers: Bag Space, Equipment Durability, Role, Tracking, and Ammo (count of the equipped ammo in the bags).
- Swing Timer: uses the game's own swing for main hand, off hand and ranged (wand included), with a Target In Range
  option.
- Aura trigger: Elapsed Time filter, Native Filter (aura categories of the game), and a "From the Cooldown Manager"
  list.
- Cooldown trigger: "From the Cooldown Manager" list, and an "On Global Cooldown" condition.
- Conditions trigger: "Secret Restrictions Active" option.
- Dispel Type Icon sub element, and borders colored by dispel type.
- Load options: Class and Specialization, and Instance Type.
- Auras exported from ForeverAuras are converted on import. What cannot be converted is listed in the chat.
- `/wa cdm` shows or hides the Blizzard Cooldown Manager, out of combat.
- Guide: `/wa tutorial` or the **Guide** button opens the full guide, with three ready-made auras to import
  (DoT timer, DoT timer on nameplates, pre-pull checklist).

## Changes

- Auras update as soon as the game stops hiding data, not only at the end of combat.
- The options warn about combat log triggers, and about thresholds on health or power, which cannot be checked in
  combat.
- The Weapon Enchant trigger works with the new game API.

## Fixes

- Role trigger: no more Lua error.
- Health trigger: the health bar of your target moves in combat.
- A condition such as "Health < 50%" keeps its last state in combat instead of turning false.
- Unit triggers keep working when the unit ID is hidden (instances). An Npc ID filter then hides the aura.
- Equipment Durability percentages are whole numbers.
- Off hand swing timer after an attack speed change.

## Known limitations

- Buffs and debuffs are hidden in combat: a buff shown before the pull keeps counting down, stacks stay frozen, and
  a buff applied for the first time in combat only shows when combat ends.
- The Native Filter of the Aura trigger shows nothing at the moment.
- Combat log triggers never fire: the game forbids the combat log to addons.
- The Blizzard Cooldown Manager is not enabled for every class on the WoW Forever beta.
- Not tested in game yet: Equipment Durability, Tracking, Ammo, Instance Type, off hand and ranged swing timer,
  dispel type colors, dungeons and raids.
- Nameplate anchoring only works with the default Blizzard nameplates.

# WeakAuras Forever 1.1.0 (2026-09-28)

Based on WeakAuras 5.22.0. Every changed file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md).

## Highlights

- Combat stability: no more Lua errors when the game hides data in combat (secret values).
- Cooldowns known before combat still become ready at their end time.
- Target, focus and nameplate tracking no longer errors on hidden unit IDs (instances).
- New in-game tutorial: `/wa tutorial`, with two example auras to import.

## Changes

- Secret values in trigger states are replaced by the last readable value.
- Lua errors caused by secret values inside aura code are no longer reported.
- Spell, charge, item and item slot cooldowns keep their last readable value in combat.
- The GCD ends at its known end time, and every cooldown is checked again when combat ends.
- The unit change tracker and the nameplate target tracker ignore secret unit GUIDs.
- Talent caches no longer require `GetNumTalentTabs` or `GetSpecialization`.
- `/wa tutorial` (or `/wa tuto`) opens a tutorial window, also reachable from the first login popup.
- `TUTORIAL.md`: how to create auras on WoW Forever, with ready-to-import examples.

## Known limitations

- Not tested in dungeons and raids yet.
- Combat log triggers never fire: the game forbids the combat log to addons.
- Aura and cooldown data can freeze during combat and update when combat ends.
- Nameplate anchoring only works with the default Blizzard nameplates.

# WeakAuras Forever 1.0.2-beta

- Loss of Control and Queued Action triggers use the new spell API.
- First login popup lists what works on WoW Forever.

# WeakAuras Forever 1.0

- First release of WeakAuras 5.22.0 for WoW Forever 1.60.1 (interface 16001).
