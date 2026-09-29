---
name: verified-secrets-duration-apis
description: APIs verified in Forever 1.60.1.70009 (live clone absent): C_Secrets, restriction event, duration objects, StatusBar timer
metadata:
  type: reference
---
Clone forever 1.60.1.70009 only; ~/wow-ui-source/live was absent (2026-09-29).
Doc dir: Interface/AddOns/Blizzard_APIDocumentationGenerated. Verified: C_Secrets.Should* (SecretPredicateAPIDocumentation.lua; ShouldUnitStatsBeSecret has no args, Should*Aura/Cooldowns no args, SpellCooldown(spellIdentifier), UnitIdentity(unit)); ADDON_RESTRICTION_STATE_CHANGED(type,state) RestrictedActionsDocumentation.lua:99; Cooldown:SetCooldownFromDurationObject(duration, clearIfZero=true) FrameAPICooldownDocumentation.lua:308; StatusBar:SetTimerDuration(duration, interpolation=Immediate, direction=ElapsedTime) SimpleStatusBarAPIDocumentation.lua:334; LuaDurationObject is Userdata (LuaDurationObjectAPIDocumentation.lua:4); GetSpellCooldownDuration(spell, ignoreGCD=false) SpellDocumentation.lua:310; GetAuraDuration(unit, auraInstanceID) UnitAuraDocumentation.lua:286.
Trap: docs do not say if issecretvalue(durationObject) is false; no RegisterEvent-unknown-event behavior in Lua source.
