# WeakAuras Forever

Port of [WeakAuras](https://github.com/WeakAuras/WeakAuras2) 5.22.0 (Classic Era flavor) to WoW Forever 1.60.1,
a Classic client running on the modern 12.x engine (interface 16001).

Original work: The WeakAuras Team, GPL-2.0 (see `WeakAuras/LICENSE`).
Modifications: dldvlpr, GPL-2.0.

This file lists every file changed from the upstream 5.22.0 release, as required by GPL-2.0 section 2a.

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
- Aura triggers freeze during combat when aura data is secret, and update when combat ends.
- The swing timer does not reset on melee hits (it used the combat log).
- Spell and item cooldowns are frozen in combat when they are secret. A cooldown known before combat still becomes
  ready at its end time, but a cooldown started in combat is only seen when combat ends. An aura loaded during
  combat sees its spell as ready.
- Talent load options are empty, and the options do not suggest spells or icons by name: type the spell ID.
- The folder name `WeakAuras` and the global `WeakAuras` are kept on purpose, so auras from Wago and existing
  SavedVariables keep working. Do not install it next to the official WeakAuras.
