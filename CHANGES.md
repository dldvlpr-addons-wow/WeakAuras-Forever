# WeakAuras Forever

Port of [WeakAuras](https://github.com/WeakAuras/WeakAuras2) 5.22.0 (Classic Era flavor) to WoW Forever 1.60.1,
a Classic client running on the modern 12.x engine (interface 16001).

Original work: The WeakAuras Team, GPL-2.0 (see `WeakAuras/LICENSE`).
Modifications: dldvlpr, GPL-2.0.

This file lists every file changed from the upstream 5.22.0 release, as required by GPL-2.0 section 2a.

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
- Talent load options are empty, and the options do not suggest spells or icons by name: type the spell ID.
- The folder name `WeakAuras` and the global `WeakAuras` are kept on purpose, so auras from Wago and existing
  SavedVariables keep working. Do not install it next to the official WeakAuras.
