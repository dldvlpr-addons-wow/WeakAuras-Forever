---
name: verified-spec-range-ammo
description: Spec/talent, range, ammo APIs verified on forever 1.60.1.70009 and live 12.1.0.69933 (both clones present 2026-09-29)
metadata:
  type: reference
---
Both clones present now (live 12.1.0.69933). Doc dir = Blizzard_APIDocumentationGenerated, near-identical in both.
Spec: C_SpecializationInfo (SpecializationInfoDocumentation.lua) all SecretArguments=AllowedWhenUntainted, only GetInspectSpecialization has SecretWhenUnitIdentityRestricted. Forever-only vs live: GetAllClassIDs, GetCombatConfigIDForSpecGroup, HasPlayerEarnedATalentPoint, IsSpecSelectionEnabled, SetActiveSpecGroup. Global GetSpecializationInfoForClassID (SpecializationSharedDocumentation.lua:10). Absent from docs both: GetSpecializationInfoByID, GetNumSpecializations, GetTalentTabInfo, GetNumTalentTabs, GetActiveTalentGroup, C_Talent, C_TalentTree. Forever camelot uses specs: Blizzard_CharacterCreate/Camelot/Blizzard_CharacterCreate.lua:3115-3121; no TalentUI addon dir; TalentFrameBase not loaded for camelot (FrameXML.toc:90-96). Deprecated_Specialization_* gated AllowLoadGameType classic, standard (not camelot) + loadDeprecationFallbacks.
Range: C_Spell.IsSpellInRange/SpellHasRange SecretArguments=AllowedWhenTainted, no SecretReturns; UnitInRange SecretReturns=true; IsActionInRange RequiresValidActionSlot. Global IsActionInRange only in Blizzard_DeprecatedActionBar. Identical live.
Ammo: INVSLOT_AMMO=0 (FrameXMLBase/Constants.lua:135); CharacterAmmoSlot in Camelot PaperDollFrame.xml:865; GetInventoryItemCount/ID undocumented globals but called (Camelot/PaperDollFrame.lua:2151). UnitRangedDamage SecretWhenUnitStatsRestricted.
