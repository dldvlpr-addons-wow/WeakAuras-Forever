# WeakAuras Forever

Port of [WeakAuras](https://github.com/WeakAuras/WeakAuras2) 5.22.0 (Classic Era flavor) to WoW Forever 1.60.1,
a Classic client running on the modern 12.x engine (interface 16001).

Original work: The WeakAuras Team, GPL-2.0 (see `WeakAuras/LICENSE`).
Modifications: dldvlpr, GPL-2.0.
Portions taken from ForeverAuras (m33shoq, GPL-2.0), a WeakAuras fork for WoW Forever: the talent data reader and
the talent picker widget, see 2026-09-30.

This file lists every file changed from the upstream 5.22.0 release, as required by GPL-2.0 section 2a.

## 2026-10-02

### Added
- `WeakAuras/Prototypes.lua`: "Hide when target dies" option of the Spell Cast Succeeded trigger. When it is
  checked, the trigger also listens to `PLAYER_TARGET_DIED`. `WeakAuras/GenericTrigger.lua`: on that event, every
  state of the trigger is removed, so the timer hides before its duration ends. The event has no payload: it only
  tells the death of the current target. `WeakAuras/Locales/enUS.lua`: the two new strings. Not tested in game yet.

### Changed
- `TUTORIAL.md`, `WeakAuras/ForeverTutorial.lua`: section 5 (DoT or buff timer from your cast) uses the Spell Cast
  Succeeded trigger with "Hide when target dies" instead of custom code. The "hide the timer when your target
  dies" variant is merged into the recipe, and the ready-made Immolate aura is exported again with this trigger.
- `.github/workflows/release.yml`: a pushed tag is also uploaded to CurseForge (project 1713094) by a step of the
  workflow, with the game version read from `## Interface` and the first section of `WeakAuras/CHANGELOG.md` as
  changelog. The workflow stops before packaging when that section is not for the pushed tag.

## 2026-09-30

### Changed
- `WeakAuras/RegionTypes/ProgressTexture.lua`: a secret progress is drawn natively, like the Progress Bar. Left to
  Right, Right to Left, Bottom to Top and Top to Bottom textures follow an invisible `StatusBar` (`SetMinMaxValues`
  and `SetValue` for a secret value, `SetTimerDuration` for a duration object) through a mask on the foreground
  texture. Clockwise and Anticlockwise textures draw a native radial fill (`Texture:SetRadialProgressBarPercent`)
  from `state.secretPercent`, or from `EvaluateRemainingPercent` of the duration object on every frame. Not drawn
  natively: an inverted static value, extra textures, slant, crop, mirror and the start and end angles. Seen in
  game on WoW Forever 70124: a Left to Right texture on the health of a hostile target and a Clockwise texture on
  the power of the player move in combat. Colors, texture and desaturation follow the native radial texture, and a
  change of orientation or of the inverse setting redraws the native progress.
- `WeakAuras/Prototypes.lua`: the Health and Power triggers set `state.secretPercent` from `UnitHealthPercent` or
  `UnitPowerPercent` with the `CurveConstants.ZeroToOne` curve while the value is secret. `WeakAuras/WeakAuras.lua`
  does not scrub it, `WeakAuras/RegionTypes/RegionPrototype.lua` passes it with the main progress.
- `WeakAuras/RegionTypes/Text.lua`: a Text aura draws secret values natively like a Text sub element
  (`WeakAuras/SubRegionTypes/SubText.lua`, shared `Private.UpdateNativeText`): a text that is only `%p` follows the
  duration object, and a text made of `%p`, `%t`, `%value`, `%total`, `%health`, `%maxhealth`, `%power`, `%maxpower`,
  `%percenthealth`, `%percentpower` and plain text shows the secret value, total and percent (the Health and Power
  triggers store `secretPercentText` from the `CurveConstants.ScaleTo100` curve); a literal `%` is kept, a text
  with `{` (raid markers, `%{...}` placeholders) is not drawn natively. Format options and other
  placeholders keep the last readable values. The size of a Text aura is not recomputed while it is drawn natively.
  A Text aura updates its progress before its text, so a native text shows the current event, not the previous one.
  Once its FontString has shown a secret text, its width and height are secret: the size of the Text aura is
  then left as is (seen in game on WoW Forever 70124).
- `WeakAuras/Prototypes.lua`: while the cast of a unit is secret, the Cast trigger keeps a `durationObject` from
  `UnitCastingDuration` or `UnitChannelDuration`, so the bar, the swipe and a `%p` text run in combat. Its name,
  icon and spell ID are secret: the name is shown empty and the icon is drawn from `secretIcon`, instead of the
  name and icon of the last readable cast. A trigger filtered by spell name or ID, by "Remaining Time" or by
  "Interruptible" does not match a secret cast.
- `WeakAuras/Prototypes.lua`: while a totem slot is secret, the Totem trigger keeps a `durationObject` from
  `GetTotemDuration`; the totem name, icon and spell ID filters accept a secret totem
  (`WeakAuras/GenericTrigger.lua`), the "Remaining Time" filter does not.
- `WeakAuras/Init.lua`: `Private.UnitIsUnit(unitA, unitB)` (`Private.ExecEnv.UnitIsUnit` in trigger code) returns
  the last readable result of the same pair when `UnitIsUnit` is secret (compound tokens like `targettarget` on
  restricted maps), nil when there is none. Used by the Specific Unit, Unit is Unit, Ignore Self, Source Unit and
  Destination Unit checks of the unit triggers (`WeakAuras/Prototypes.lua`) and by the unit event dispatch
  (`WeakAuras/GenericTrigger.lua`).
- `WeakAuras/WeakAuras.lua`: internal version 91, the one ForeverAuras now uses too, so an aura exported from
  either addon imports into the other without a version warning. Auras saved or exported at 90 still load: no
  migration step is needed, `Modernize` only raises their number. `WeakAuras/ForeverAurasImport.lua`: since the
  number no longer tells the two addons apart, a ForeverAuras export is found by its content only: ForeverAuras
  trigger and sub element types, dispel indicator, Blizzard aura display, the ForeverAuras fields of the Swing
  Timer, Tracking, Ammo and Bag Space triggers, a TimelineParser trigger, a media path to `AddOns\ForeverAuras`
  (one or more separators) in any string, or a `ForeverAuras` API reference in custom code. Not detectable: a
  ForeverAuras aura whose only triggers are Role or Equipment Durability, imported as is. The Tracking conversion
  only runs on ForeverAuras fields, so an aura of this addon with a ForeverAuras media path keeps its Tracking
  settings. `WeakAuras/Transmission.lua`: comment.

### Fixed
- `WeakAuras/Compatibility.lua`: on WoW Forever, `C_SpecializationInfo.GetTalentInfo` refuses the Classic Era
  query (`specializationIndex`, `talentIndex`) with "query.tier must be specified", and the error stopped the
  import of any aura with a Talent load condition (`GetTalentInfo(): C_SpecializationInfo.GetTalent: query.tier
  must be specified`). The call is now under `pcall` and returns nothing on this client.
- Talents on WoW Forever, like ForeverAuras: `WeakAuras/Compatibility.lua` sets `Private.traitTalents` (retail, or a
  WoW Forever client with `C_Traits` and `C_SpecializationInfo.GetCombatConfigIDForSpecGroup`).
  `WeakAuras/Prototypes.lua`: `Private.GetTalentConfigID()` and `Private.GetTalentData(specId)` (copied from
  ForeverAuras `Types_Forever.lua`) read the Classic
  talent trees of the player's specialization from the trait config of the active spec group (`C_Traits`), one
  entry per trait entry ID, the same IDs ForeverAuras exports. The talent check frame, `WeakAuras.CheckTalentId`
  and `WeakAuras.GetTalentById` run on this client (`ACTIVE_TALENT_GROUP_CHANGED` refreshes them too), and the
  Talent and Or Talent load conditions and the Talent Known trigger use them, with the talent picker
  (`WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent.lua`, from ForeverAuras, listed in
  `WeakAurasOptions/WeakAurasOptions.toc`) once a single Class and Specialization is selected.
  `WeakAuras/GenericTrigger.lua`: the talents are read after `PLAYER_ENTERING_WORLD` on this client. The
  ForeverAuras Specialization load condition (`forever_spec`) is not converted on import.
- `WeakAuras/RegionTypes/RegionPrototype.lua`: on WoW Forever, a texture path that ends with `.tga` or `.blp` does
  not load (seen in game on 70124: `SetTexture` leaves the texture empty, the same path without the extension
  works). `Private.SetTextureOrAtlas` strips the extension, so the `.tga` entries of the texture picker (rings,
  circles, squares) and imported auras that use them are drawn.
- `WeakAuras/GenericTrigger.lua`: while cooldowns are secret, the Global Cooldown trigger reads whether the GCD runs
  from `isActive` of `C_Spell.GetSpellCooldown`, which is never secret. It relied on `IsZero` and `HasExpired` of the
  duration object, and `IsZero` is secret in combat on WoW Forever, so the trigger never showed in combat.
- `WeakAuras/BuffTrigger2.lua`: a `UNIT_AURA` whose unit or `isFullUpdate` flag is already secret is handled like
  any update received while aura data is secret, even when the `RestrictionChanged` callback has not fired yet. At
  the start of a fight, the payload could be secret one frame before that callback, which printed "Aura triggers
  paused until the end of combat" (`attempt to perform boolean test on field 'isFullUpdate'`). For the same reason,
  a full scan of a unit and the error filter of the aura updates also ask `Private.IsRestricted("auras")`, so that
  a scan started by another event during that frame (target change, encounter start, roster update) keeps the
  matched auras instead of cleaning them before failing on secret data.

## 2026-09-29

### Added
- `.luacheckrc`: luacheck checks syntax and global variables only. Every global the addons use is listed, so a new
  one (a typo, or an API not checked on WoW Forever) is reported. `.github/workflows/lint.yml` runs it on every push
  and pull request.

### Changed
- `WeakAuras/Init.lua`: `Private.IsRestricted(kind, ...)` asks `C_Secrets` whether auras, cooldowns, a spell
  cooldown, unit stats or unit identity are secret, and returns `nil` when the client cannot tell.
  `WeakAuras.IsRestricted()` is true while aura or cooldown data is secret (in combat without `C_Secrets`).
  The `RestrictionChanged` callback fires when that state changes. `Private.IsDurationObject(value)`.
- `WeakAuras/BuffTrigger2.lua`: aura triggers paused on secret data are rescanned when the restriction ends,
  instead of at the end of combat only.
- `WeakAuras/GenericTrigger.lua`: cooldowns are checked again when the restriction ends.
- `WeakAuras/RegionTypes/RegionPrototype.lua`: a timed trigger state can carry a `durationObject` (a duration object
  of the 12.x engine). Regions receive it with the trigger's main timer, unless the timer is paused or min or max
  progress is adjusted.
- `WeakAuras/RegionTypes/Icon.lua`: the cooldown swipe draws a `durationObject` with
  `SetCooldownFromDurationObject`, so it keeps running when the duration is secret.
- `WeakAuras/RegionTypes/AuraBar.lua`: an invisible native `StatusBar` runs a `durationObject` with
  `SetTimerDuration`, and the bar foreground mask follows its fill, so the bar keeps running when the duration is
  secret. In that mode the spark is shown unless it is set to always hidden.
- `WeakAuras/GenericTrigger.lua`: `WeakAuras.GetSpellCooldownDurationObject(id, showgcd, ignoreSpellKnown, track)`
  returns the duration object of `C_Spell.GetSpellCooldownDuration` (or `C_Spell.GetSpellChargeDuration` for charges)
  while the spell cooldown is secret. Spells with a secret cooldown send `SPELL_COOLDOWN_CHANGED` on every check.
  A `SPELL_UPDATE_COOLDOWN` with a secret payload checks every spell once on the next frame, instead of on every
  event. `WeakAuras/RegionTypes/Icon.lua`: the swipe of a duration object restarts only when its direction changes.
- `WeakAuras/Init.lua`: `Private.hasAuraInstanceAPI`, true when the aura instance API is available (Retail and the
  12.x engine). `WeakAuras/BuffTrigger2.lua` and `WeakAuras.GetAuraInstanceTooltipInfo` (`WeakAuras/WeakAuras.lua`)
  use it instead of `WeakAuras.IsRetail()`, so aura triggers handle `UNIT_AURA` incrementally by `auraInstanceID`.
- `WeakAuras/BuffTrigger2.lua`: while aura data is secret, `UNIT_AURA` no longer reads its payload. Once per frame,
  the auras already matched get a `durationObject` from `C_UnitAuras.GetAuraDuration`, and the ones that no longer
  exist are removed. Auras applied during the restriction, stacks and other fields are only read when it ends.
- `WeakAuras/Prototypes.lua`: the "Cooldown/Charges/Count" trigger sets `state.durationObject`, so its icon swipe and
  bar keep running in combat. Showing only on cooldown or when ready, and tracking a specific charge, still use the
  last readable cooldown.
- `WeakAuras/WeakAuras.lua`: when `value` or `total` of a trigger state is secret, both are also kept in
  `state.secretValue` and `state.secretTotal`, which are not scrubbed. `WeakAuras/RegionTypes/RegionPrototype.lua`
  passes them to regions with the main progress, unless min or max progress is adjusted.
  `WeakAuras/RegionTypes/AuraBar.lua` draws them with an invisible native `StatusBar` (`SetMinMaxValues`,
  `SetValue`), like duration objects, so health and power bars keep moving in combat. An inverted bar still shows the
  last readable value.
- `WeakAuras/Init.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Prototypes.lua`: generated trigger code no longer
  errors on secret health or power without a threshold: the state store compares secret values without reading
  them, percent and deficit are `nil` while value or total is secret, and a secret raid marker is ignored. A
  threshold on a secret value (for example health >= 1000) still errors.
- `WeakAuras/GenericTrigger.lua`: without combat log, a trigger that errors keeps its last state instead of being
  untriggered, as described on 2026-09-28. Before, a trigger with automatic hiding was hidden.
- `WeakAuras/GenericTrigger.lua`: without combat log, the options warn about combat log triggers and CLEU events,
  which never fire, and about thresholds of Health and Power triggers, which cannot be checked on secret values.
- `WeakAuras/BuffTrigger2.lua`: an aura update that fails on secret data no longer stops the profiler from counting
  that aura.
- `WeakAuras/Compatibility.lua`: `Private.hasSpecializations`, true on Classic Era when the client has
  `C_SpecializationInfo` (WoW Forever). `WeakAuras/Types.lua`, `WeakAuras/Prototypes.lua`, `WeakAuras/WeakAuras.lua`:
  in that case the "Class and Specialization" load option and the "Class and Specialization" trigger are available,
  and loads are checked again on `PLAYER_SPECIALIZATION_CHANGED`.
- `WeakAuras/Prototypes.lua`: "Ammo" trigger on Classic Era, with the count, name and icon of the ammo in the ammo
  slot. `.luacheckrc`: `INVSLOT_AMMO`.
- `WeakAuras/Init.lua`: `Private.IsRestricted("auraInstance", unit, auraInstanceID)`.
  `WeakAuras/BuffTrigger2.lua`: while aura data is secret, auras applied during the restriction are listed with
  `C_UnitAuras.GetUnitAuraInstanceIDs`, and the ones that `C_Secrets.ShouldUnitAuraInstanceBeSecret` reports as
  readable are handled right away. The matched auras also get their stack text from
  `C_UnitAuras.GetAuraApplicationDisplayCount`, kept in `state.secretStacks` (`WeakAuras/WeakAuras.lua` does not scrub
  it).
- `WeakAuras/SubRegionTypes/SubText.lua`: a text that is only `%p` is drawn by a `C_DurationUtil` duration text
  binding when the region has a `durationObject`, and a text that is only `%s` shows `state.secretStacks`, so both
  keep updating in combat. In that mode `%p` uses the client's seconds format instead of the text format options,
  and `%s` is empty below 2 stacks. `.luacheckrc`: `C_DurationUtil`, `C_StringUtil`, and for the entries below `C_SwingTimer`, `C_CurveUtil`,
  `NUM_BAG_SLOTS`.
- `WeakAuras/GenericTrigger.lua`: when the restriction ends, unit health and power events are scanned again, so
  health and power triggers do not keep their last readable values until the next change. `WeakAuras/Init.lua`:
  `RestrictionChanged` also fires when only the unit stats restriction changes.
- `WeakAuras/Compatibility.lua`: `Private.hasNativeSwingTimer`, true when `C_SwingTimer` exists.
  `WeakAuras/GenericTrigger.lua`: the swing timer starts on `PLAYER_SWING` with the swing duration of the client,
  for main hand, off hand and ranged (wand included), and a secret attack speed keeps the last readable one.
  With `PLAYER_SWING`, only a swing paused by a cast restarts when the cast ends. `WeakAuras.IsTargetInSwingRange(hand)`.
  `WeakAuras/Prototypes.lua`: the Swing Timer trigger has a Target In Range option, updated by
  `PLAYER_SWING_RANGE_UPDATE`.
- `WeakAuras/GenericTrigger.lua`: without the global `GetWeaponEnchantInfo`, the weapon enchant trigger reads
  `C_Item.GetWeaponEnchantInfo` for main hand, off hand and ranged.
- `WeakAuras/GenericTrigger.lua`: while cooldowns are secret, the global cooldown comes from the duration object of
  `C_Spell.GetSpellCooldownDuration` (spell 61304, 29515 on Classic), returned by `WeakAuras.GetGCDInfo` as a sixth
  value. `WeakAuras/Prototypes.lua`: the Global Cooldown trigger stores it as `durationObject`.
- `WeakAuras/SubRegionTypes/Border.lua`: Color by Dispel Type option. The border takes the dispel type color of the
  aura, from `C_UnitAuras.GetAuraDispelTypeColor` (secret colors included), else from the readable debuff class,
  else the border color, also used for auras without dispel type. A border color set by a condition wins.
  `WeakAurasOptions/SubRegionOptions/Border.lua`: its toggle.
- `WeakAuras/Prototypes.lua`: the Ammo trigger filters by ammo item and gives the total of projectiles in the bags.
- `WeakAuras/Prototypes.lua`: `Private.GetCooldownManagerSpells()` lists the spells of the Cooldown Manager catalog
  (`C_CooldownViewer`). `WeakAurasOptions/LoadOptions.lua`: the Cooldown trigger has a From the Cooldown Manager
  picker that sets the spell to an exact spell ID of that catalog.
- `WeakAuras/ForeverAurasImport.lua` (new, listed in `WeakAuras/WeakAuras.toc`): auras exported by ForeverAuras
  (found by their ForeverAuras trigger or sub element types, see 2026-09-30) are converted on
  import, before the version check (`WeakAuras/Transmission.lua`). Their
  Cooldown Manager triggers become Cooldown, Aura or Item Cooldown triggers, Blizzard Aura triggers become Aura
  triggers, dispel type borders become borders colored by dispel type, the Swing Timer weapon and the Ammo
  item list are mapped, media paths to ForeverAuras point to WeakAuras, and so do API references in custom code. What has no
  equivalent is listed in the chat.
- `WeakAuras/ForeverTutorial.lua`, `TUTORIAL.md`, `README.md`: what works in combat now, and a section on
  importing ForeverAuras auras. `.pkgmeta`: `TUTORIAL.md` is not packaged. `.github/workflows/release.yml`:
  CurseForge and Wago keys, used once the .toc files carry project IDs.
- `WeakAuras/GenericTrigger.lua`: an attack speed change rescales the off hand swing by the off hand speed, instead of
  the main hand one.
- `WeakAuras/Prototypes.lua`, `WeakAuras/Types.lua`: the Swing Timer Target In Range option is a choice between In Range
  and Out of Range (`Private.swing_range_types`), so an unknown range (no target) matches neither.
- `WeakAuras/BuffTrigger2.lua`: a secret unit name or GUID is replaced by an empty name or the previous GUID instead
  of being compared.
- `WeakAuras/Libs/LibRangeCheck-3.0`, `WeakAuras/Libs/LibCustomGlow-1.0`, `WeakAuras/Libs/Chomp`: WoW Forever reports
  the retail project ID with a Classic interface version. These libraries use their Classic Era spells, items,
  textures and chat throttle there, and LibRangeCheck keeps its secret GUID handling.
- `WeakAuras/SubRegionTypes/SubText.lua`: the client-drawn `%p` text follows the Old or Modern Blizzard time format
  and the Increase Precision Below threshold (one decimal at most).
- `WeakAuras/GenericTrigger.lua`: after an attack speed change, the off hand swing keeps an offset like the main hand,
  so its shown end matches its timer, and both hands count the offset of an earlier change. `WeakAuras/Modernize.lua`: a Swing Timer Target In Range set with the former
  yes/no option is converted to In Range or Out of Range.
- `WeakAuras/Types.lua`: without the combat log, the Aura trigger no longer offers the Multi-target unit.
  `WeakAuras/BuffTrigger2.lua`: its unit tracking skips secret GUIDs.
- `WeakAuras/WeakAuras.lua`: `/wa cdm` shows or hides the Blizzard Cooldown Manager through the
  `cooldownViewerEnabled` CVar, outside combat only. `.luacheckrc`: `C_CooldownViewer`.
- `WeakAuras/Prototypes.lua`: new Bag Space (free and used slots of the carried bags, specialty bags on request),
  Equipment Durability (lowest item, overall, broken items, all slots or one), Role (group role of the player) and
  Tracking (active minimap tracking, by spell ID, or inverse) triggers. `WeakAuras/Types.lua`:
  `Private.durability_progress_types`. `.luacheckrc`: `C_Minimap`, `GetInventoryItemDurability`,
  `INVSLOT_FIRST_EQUIPPED`, `INVSLOT_LAST_EQUIPPED`.
- `WeakAuras/Prototypes.lua`, `WeakAuras/Types.lua`, `WeakAuras/WeakAuras.lua`: the Instance Type load option (by
  difficulty ID) is available. The difficulty names come from `GetDifficultyInfo`, without the outdated version
  warning for unknown IDs.
- `WeakAuras/Prototypes.lua`, `WeakAuras/GenericTrigger.lua`: the Conditions trigger has a Secret Restrictions Active
  option, updated on the `RestrictionChanged` callback (`WA_RESTRICTION_CHANGED`).
- `WeakAuras/Prototypes.lua`: the Cooldown trigger has an On Global Cooldown condition, with Show Global Cooldown
  enabled, for example to hide the cooldown text during the global cooldown.
- `WeakAuras/SubRegionTypes/DispelIcon.lua`, `WeakAurasOptions/SubRegionOptions/DispelIcon.lua` (new, listed in the
  .toc files): Dispel Type Icon sub element. It shows the dispel type icon of the default UI when the dispel type is
  readable, and a circle colored by the client (`C_UnitAuras.GetAuraDispelTypeColor`) when it is secret.
  `WeakAuras/SubRegionTypes/Border.lua` shares its dispel colors and curve, and no longer reads a secret dispel type.
- `WeakAuras/BuffTrigger2.lua`, `WeakAurasOptions/BuffTrigger2.lua`: the Aura trigger has an Elapsed Time filter, and
  a From the Cooldown Manager picker that adds the aura spell IDs of a tracked buff (linked spells, tooltip spell and
  spell, like the default UI). `WeakAuras/Prototypes.lua`: `Private.GetCooldownManagerAuras()`,
  `Private.GetCooldownManagerAuraSpellIDs(cooldownID)`.
- `WeakAuras/ForeverAurasImport.lua`: ForeverAuras Role, Tracking, Equipment Durability and Bag Space triggers,
  dispel type icons, and the elapsed and total time filters of Cooldown Manager buffs are converted too.
- `WeakAuras/BuffTrigger2.lua`, `WeakAurasOptions/BuffTrigger2.lua`, `WeakAuras/Types.lua`: the Aura trigger has a
  Native Filter option, with the aura categories of the client (`Private.aura_native_filter_types`: cast by me,
  crowd control, important, big and external defensive, dispellable...), each one required or excluded, tested with
  `C_UnitAuras.IsAuraFilteredOutByInstanceID`. When it is the only filter, auras applied during the restriction also
  match: their data stays secret, so the name is empty, and the game draws their icon (`state.secretIcon`,
  `WeakAuras/RegionTypes/Icon.lua`, kept by `WeakAuras/WeakAuras.lua`), timer and stack text. They are read again
  when the restriction ends. `WeakAuras/ForeverAurasImport.lua`: the native filters of Blizzard Aura triggers are
  converted, and their own auras filter becomes the native one.
  TimelineParser Stage triggers are listed as not converted, like TimelineParser Timer ones.
- `TUTORIAL.md`: sections 2 and 3 rewritten from the in-game tests (tested, limited, not tested, not working),
  notes on the boss timeline, custom code and the ForeverAuras Native Filter.
- `WeakAuras/ForeverTutorial.lua`: the tutorial window becomes the full guide, generated from `TUTORIAL.md` (all
  sections, code examples, and import buttons for the DoT timer, the nameplate DoT timer and the pre-pull
  checklist). The window is larger, and hides when an import button is clicked so the import dialog is visible.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: a "Guide: learn WeakAuras" button in the title bar of the
  `/wa` window opens the guide, with a tooltip that describes it. `WeakAuras/WeakAuras.lua`: the `/wa` help line
  and the first login popup point to the guide.

### Fixed
- `WeakAuras/Prototypes.lua`: the Role trigger checks secret roles with `Private.ExecEnv.IsSecret`, available to
  the generated trigger code. The Npc ID of the unit triggers (Unit Characteristics, Health, Power, Threat Situation, Cast) is
  `nil` when the unit GUID is secret, instead of failing the trigger: an Npc ID filter then hides the aura.
  The Health trigger listens to `UNIT_HEALTH`, since the engine has no `UNIT_HEALTH_FREQUENT` (its health bar did
  not move in combat). The percent and deficit of the Health, Power, Faction Reputation and Experience triggers
  (`Private.ExecEnv.PercentOrSecret`, `Private.ExecEnv.DeficitOrSecret`) stay secret when their value is, so that
  `WeakAuras/WeakAuras.lua` keeps their last readable value, and a "Health < 50%" condition keeps its last state in
  combat instead of turning false. The Equipment Durability percentages are rounded down to whole numbers, so "below N" thresholds are unchanged.
- `WeakAuras/SubRegionTypes/SubText.lua`: while a progress value is secret, a text made only of `%p`, `%t` and
  plain text (for example `%p / %t`) is drawn from the secret value and total, unformatted, without raid marks or
  line breaks.

## 2026-09-28

### Added
- `WeakAuras/ForeverTutorial.lua`, listed in `WeakAuras/WeakAuras.toc`: in-game tutorial window (`/wa tutorial`)
  explaining how auras work on WoW Forever, with two example auras that can be imported from the window (a DoT
  timer from the player's own cast, and a pre-pull checklist).

### Changed
- `WeakAurasOptions/Changelog.lua`, `WeakAuras/CHANGELOG.md`: WeakAuras Forever changelog instead of the upstream
  one.
- `WeakAuras/WeakAuras.lua`: a popup listing the WoW Forever limitations is shown once, at the first login.
- `WeakAuras/GenericTrigger.lua`: the Loss of Control cooldown uses `C_Spell.GetSpellLossOfControlCooldown` when it
  exists, and `GetSpellLossOfControlCooldown` otherwise.
- `WeakAuras/Prototypes.lua`: `FindBaseSpellByID`, `FindSpellOverrideByID`, `IsSpellKnown` and `IsPlayerSpell`
  fall back on `C_SpellBook`. The "Queued Action" trigger uses `C_Spell.IsCurrentSpell`.
- `WeakAurasOptions/LoadOptions.lua`: `IsPlayerSpell` falls back on `C_SpellBook.IsSpellKnown`.
- `WeakAuras/WeakAuras.lua`: `/wa tutorial` and `/wa tuto` open the tutorial, `/wa help` lists it, and the first
  login popup has a "Tutorial" button.
- `WeakAuras/Init.lua`: `Private.IsSecret(...)`, true when any argument is a secret value.
- `WeakAuras/WeakAuras.lua`: secret values in a changed trigger state, and in fallback states, are replaced by the
  last readable value of that field (or `nil`). Nested tables such as overlays are not scrubbed. Lua errors raised
  on a secret value inside protected aura code (custom code, generated triggers, conditions) are not reported:
  the aura keeps its last state until the data is readable again. `GetNumTalentTabs` and `GetSpecialization` are
  optional in the talent caches.
- `WeakAuras/GenericTrigger.lua`: when spell, charge, item or item slot cooldowns are secret, the cooldown tracker
  keeps the last readable cooldown, so a cooldown still becomes ready at its known end time.
  `WeakAuras.GetSpellCooldownUnified` returns `false` alone in that case. The GCD ends at its known end time, and
  the Shoot cooldown is not stored when secret. Secret `SPELL_UPDATE_COOLDOWN` and `SPELL_UPDATE_USES` payloads
  are ignored, overlay values that are secret are dropped, and every cooldown is checked again on
  `PLAYER_REGEN_ENABLED`.
- `WeakAuras/BuffTrigger2.lua`: `UnitExistsFixed` returns `true` when the unit GUID is secret.
- `WeakAuras/GenericTrigger.lua`: the unit change tracker (target, focus, nameplates, group) no longer errors when
  unit GUIDs, raid markers, reactions or roles are secret, for example creature GUIDs inside instances: the unit
  is reported as changed, and GUID-based "unit is unit" tracking is skipped for it. The nameplate target tracker
  ignores secret target GUIDs.

## 2026-09-26

### Added
- `WeakAuras/WeakAuras.toc`, `WeakAurasArchive/WeakAurasArchive.toc`, `WeakAurasModelPaths/WeakAurasModelPaths.toc`,
  `WeakAurasOptions/WeakAurasOptions.toc`, `WeakAurasTemplates/WeakAurasTemplates.toc`: copies of the `_Vanilla.toc`
  files with `Interface: 16001`, title `WeakAuras Forever`, fork author, `X-License`, and the CurseForge, Wago,
  WoWInterface and website identifiers removed, `X-Website` set to the fork repository.

### Changed
- `WeakAuras/Init.lua`: `Private.hasCombatLog`, false on the 12.x engine.
- `WeakAuras/GenericTrigger.lua`: `COMBAT_LOG_EVENT_UNFILTERED` is not registered without combat log (generic
  triggers and swing timer). `UnitGroupRolesAssigned` is optional.
- `WeakAuras/BuffTrigger2.lua`: `UnitAura` fallback on `C_UnitAuras.GetAuraDataByIndex`. Without combat log, the
  multi-target aura frame skips the combat log, and aura reads that fail on secret data are caught: triggers keep
  their last state and every unit is rescanned on `PLAYER_REGEN_ENABLED`.
- `WeakAuras/Types.lua`, `WeakAuras/WeakAuras.lua`: legacy talent API (`GetNumTalentTabs`, `GetNumTalents`) is
  optional. `C_Engraving` is optional.
- `WeakAurasOptions/Cache.lua`: no full spell ID scan without combat log, because querying some spell IDs crashes
  the client (`Aura used in Client PlayerCondition is not known on the client`). `IsSpellKnown` falls back on
  `C_SpellBook.IsSpellKnown`.
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasSpinBox.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasPendingInstallButton.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasPendingUpdateButton.lua`,
  `WeakAurasOptions/OptionsFrames/FrameChooser.lua`: `MouseIsOver(frame)` replaced by `frame:IsMouseOver()`.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: fork credit added at the top of the "Thanks" tooltip, original
  credits unchanged. "Documentation" and "Found a Bug?" point to the fork repository, "Discord" says "Coming soon".
- `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua`: `GetSpellInfo` and `GetSpellDescription` fall back on
  `C_Spell`.

### Removed
Forever only: files that no other client flavor needs here.
- Every flavor toc (`*_Vanilla.toc`, `*_TBC.toc`, `*_Wrath.toc`, `*_Cata.toc`, `*_Mists.toc`) in the 5 addons.
- `WeakAuras/`: `Dragonriding.lua`, `Legendaries.lua`, `LibSpecializationWrapper.lua`, `PatreonList.lua`,
  `Types_Cata.lua`, `Types_Mists.lua`, `Types_Retail.lua`, `Types_TBC.lua`, `Types_Wrath.lua`.
- `WeakAurasModelPaths/`: `ModelPaths.lua`, `ModelPathsCata.lua`, `ModelPathsClassic.lua`, `ModelPathsMists.lua`,
  `ModelPathsTBC.lua`, `ModelPathsWrath.lua`.
- `WeakAurasOptions/`: `VersionCheck.lua`, `AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent_Cata.lua`,
  `_Mists.lua`, `_TWW.lua`, `_Wrath.lua`.
- `WeakAurasTemplates/`: `TriggerTemplatesData.lua`, `TriggerTemplatesDataCataclysm.lua`,
  `TriggerTemplatesDataMists.lua`, `TriggerTemplatesDataTBC.lua`, `TriggerTemplatesDataWrath.lua`.

## Known limitations

- Combat log triggers (`CLEU:...`, "Combat Log" event) never fire: the engine forbids the combat log to addons.
  Damage taken is available through `UNIT_COMBAT:player`.
- Aura triggers freeze during combat when aura data is secret, and update when combat ends. The `C_UnitAuras`
  calls of the restricted path (`GetAuraDuration`, `GetAuraApplicationDisplayCount`, `GetUnitAuraInstanceIDs`,
  `GetAuraDataByAuraInstanceID`) fail for addon code in combat ("Auras cannot be accessed when secret while
  tainted", confirmed in game for `GetAuraDuration` and `GetUnitAuraInstanceIDs`): stacks stay frozen, and a buff
  cast by someone else does not reset its timer. `WeakAuras/BuffTrigger2.lua`: during the restriction,
  `UNIT_SPELLCAST_SUCCEEDED` on `player` resets the timer of a buff on the player cast by the player with the same
  spell ID, to its last readable duration, whatever the target of the cast (the event does not give it). Only
  triggers on the Player unit. A buff first applied during combat is still only seen when combat ends.
- The swing timer does not reset on melee hits (it used the combat log).
- Spell and item cooldowns are frozen in combat when they are secret. A cooldown known before combat still becomes
  ready at its end time, but a cooldown started in combat is only seen when combat ends. An aura loaded during
  combat sees its spell as ready.
- Talent load options are empty, and the options do not suggest spells or icons by name: type the spell ID.
- The folder name `WeakAuras` and the global `WeakAuras` are kept on purpose, so auras from Wago and existing
  SavedVariables keep working. Do not install it next to the official WeakAuras.
