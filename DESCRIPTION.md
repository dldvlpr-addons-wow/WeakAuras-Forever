<p style="text-align:center">![WeakAuras Forever](https://raw.githubusercontent.com/dldvlpr-addons-wow/WeakAuras-Forever/main/.github/logo.png)</p>

# <span style="color:#0cf">WeakAuras</span> <span style="color:#ffd100">Forever</span>

**The WeakAuras you know, rebuilt for WoW Forever.**  
Icons, bars, texts and timers that keep working on the modern engine, even in combat.

***

## <span style="color:#0cf">⚡ What is it?</span>

WoW Forever looks like Classic, but it runs on the **modern game engine**. That engine hides most combat data from addons, and the regular WeakAuras breaks. **WeakAuras Forever** is WeakAuras 5.22.0 ported to WoW Forever (client 1.60.1):

*   <span style="color:#ffd100"><strong>Same addon, same habits.</strong></span> `/wa` opens the options, your saved auras and Wago strings load as they are.
*   <span style="color:#ffd100"><strong>No Lua error storm in combat.</strong></span> When the game hides a value, the aura keeps its last state and updates when the data is readable again.
*   <span style="color:#ffd100"><strong>The game draws what addons cannot read.</strong></span> Cooldown swipes, timer bars, health and power bars, progress textures and texts keep moving in combat.
*   <span style="color:#ffd100"><strong>ForeverAuras auras import as they are.</strong></span> Same data version, same talent IDs.

***

## <span style="color:#0cf">📖 Learn everything, in game</span>

Click the <span style="color:#ffd100"><strong>Guide</strong></span> button at the top of the `/wa` window, or type `/wa tutorial`. The guide covers:

*   how an aura works, tab by tab;
*   what changed on WoW Forever, and what works in combat;
*   step-by-step recipes: DoT timer from your own cast, one timer per mob on its nameplate, pre-pull checklist, boss timeline, custom code;
*   <span style="color:#ffd100"><strong>three ready-made auras to import in one click</strong></span>.

***

## <span style="color:#0cf">✨ New in 1.3.0</span>

*   **Progress Textures** move in combat: linear and circular fills follow the hidden value, like the Progress Bar.
*   **Text auras** show health, power and percent in combat: `%health`, `%maxhealth`, `%percenthealth`, `%power`, `%maxpower`, `%percentpower`.
*   **Cast bar on your target:** the Cast trigger follows the cast in combat, with the icon of the spell.
*   **Totem timers** keep running in combat.
*   **Talents:** the Talent load conditions and the Talent Known trigger work on WoW Forever, with a talent picker, like ForeverAuras.
*   **ForeverAuras auras** import as they are, talent conditions included. Internal data version 91, the same as ForeverAuras.
*   **Fixed:** `.tga` textures of the texture picker (rings, circles, squares), Global Cooldown trigger in combat, import of an aura with a Talent load condition.

***

## <span style="color:#0cf">✨ New in 1.2.0</span>

*   **In combat:** cooldown swipes, timer bars, health and power bars, and texts made only of `%p` and `%t` keep moving.
*   **Your own recast** of a buff on yourself restarts its timer, even in combat.
*   **New triggers:** Bag Space, Equipment Durability, Role, Tracking, Ammo.
*   **Swing Timer** based on the game's own swing: main hand, off hand, ranged and wand, with a Target In Range option.
*   **Aura trigger:** Elapsed Time filter, Native Filter, and a "From the Cooldown Manager" list.
*   **Cooldown trigger:** "From the Cooldown Manager" list, and an "On Global Cooldown" condition.
*   **Dispel type:** Dispel Type Icon sub element, and borders colored by dispel type.
*   **Load options:** Class and Specialization, Instance Type.
*   **`/wa cdm`** shows or hides the Blizzard Cooldown Manager, out of combat.

***

## <span style="color:#0cf">🎯 What you can use</span>

<span style="color:#4caf50"><strong>✔ Tested in game, works in combat</strong></span>

*   Spell cooldowns: swipe and number, with an "On Global Cooldown" condition.
*   Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.
*   Health bar of your target and power bar of yourself, as bars, progress textures or a `%p / %t` text.
*   Cast bar of your target.
*   Swing timer, main hand.
*   Your own casts (`UNIT_SPELLCAST_SUCCEEDED:player`) and `PLAYER_TARGET_DIED`.

<span style="color:#4caf50"><strong>✔ Tested in game</strong></span>

*   Temporary weapon enchants, Elapsed Time filter, Bag Space, Role, `/wa cdm`.

<span style="color:#ff9800"><strong>⚠ Works, with limits</strong></span>

*   Stacks stay frozen in combat.
*   Conditions on percentages, stacks or remaining time use the value from before combat.
*   A buff applied for the first time in combat only shows when combat ends.
*   The ForeverAuras "Specialization" load condition is ignored on import: the aura loads for every specialization of its class.

<span style="color:#f44336"><strong>✖ Does not work</strong></span>

*   Combat log triggers: the game forbids the combat log to addons.
*   Other players' casts, enemy names and IDs in instances.
*   The Native Filter of the Aura trigger shows nothing at the moment.

<span style="color:#9e9e9e"><em>Not tested in game yet: talents, Totem trigger in combat, Equipment Durability, Tracking, Ammo, Instance Type, off hand and ranged swing timer, dispel type colors, dungeons and raids.</em></span>

***

## <span style="color:#0cf">⚠ Before you import auras from Wago</span>

Most auras made for Classic Era, Season of Discovery or Retail need some work:

*   replace combat log triggers (the guide shows how);
*   type spell IDs instead of spell names: every rank has its own ID;
*   update custom code that calls old functions (`GetSpellInfo`, `UnitBuff`…) to `C_Spell`, `C_UnitAuras`, `C_Item`.

Auras exported from ForeverAuras are converted on import. What has no equivalent is listed in the chat.

***

## <span style="color:#0cf">📦 Installation</span>

Install with the CurseForge app, or copy the five folders `WeakAuras`, `WeakAurasArchive`, `WeakAurasModelPaths`, `WeakAurasOptions` and `WeakAurasTemplates` into `World of Warcraft/_classic_beta_/Interface/AddOns/`.

<span style="color:#f44336"><strong>Do not install it next to another WeakAuras build.</strong></span> The folder name and the saved settings are the same, on purpose, so your existing auras keep working.

***

## <span style="color:#0cf">🐞 Support</span>

Found a bug, or an aura that should work and does not? [Open an issue on GitHub](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/issues).

Discord: coming soon.

***

## <span style="color:#0cf">⚖ License and credits</span>

*   **WeakAuras Forever** is a modified version of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2), © The WeakAuras Team, released under the [GNU General Public License v2](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/LICENSE). Changes © 2026 dldvlpr, same license. This project is not affiliated with, nor endorsed by, the WeakAuras Team.
*   **Portions taken from ForeverAuras** by m33shoq, another WeakAuras fork for WoW Forever, released under the GNU GPL v2: the talent data reader (`Private.GetTalentData`) and the talent picker widget. The ForeverAuras import converter is original code that only reads their saved data format.
*   **Bundled libraries** keep their own licenses, included in their folders under `WeakAuras/Libs/`: Ace3 (AceComm, AceSerializer, AceTimer, CallbackHandler, LibStub), Archivist, Chomp, LibCompress, LibCustomGlow, LibDBIcon, LibDataBroker, LibDeflate, LibDispel, LibGetFrame, LibRangeCheck, LibSerialize, LibSharedMedia, LibSpecialization, LibSpellRange, TaintLess.
*   **Source code and change list:** every modified file, with the date and the nature of the change, is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md), as required by the GPL v2 section 2a. Full source: [github.com/dldvlpr-addons-wow/WeakAuras-Forever](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever).
*   **No warranty.** This addon is provided as is, without warranty of any kind, as stated in the GPL v2.
*   World of Warcraft and WoW Forever are trademarks of Blizzard Entertainment, Inc. This addon is a fan project, not affiliated with Blizzard.
