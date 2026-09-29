<p align="center">
  <img src="https://raw.githubusercontent.com/dldvlpr-addons-wow/WeakAuras-Forever/main/.github/logo.png" alt="WeakAuras Forever" width="160">
</p>

<h1 align="center"><span style="color:#00ccff">WeakAuras</span> <span style="color:#ffd100">Forever</span></h1>

<p align="center"><b>The WeakAuras you know, rebuilt for WoW Forever.</b><br>
Icons, bars, texts and timers that keep working on the modern engine, even in combat.</p>

---

## <span style="color:#00ccff">⚡ What is it?</span>

WoW Forever looks like Classic, but it runs on the **modern game engine**. That engine hides most combat data from
addons, and the regular WeakAuras breaks. **WeakAuras Forever** is WeakAuras 5.22.0 ported to WoW Forever
(client 1.60.1):

- <span style="color:#ffd100">**Same addon, same habits.**</span> `/wa` opens the options, your saved auras and Wago
  strings load as they are.
- <span style="color:#ffd100">**No Lua error storm in combat.**</span> When the game hides a value, the aura keeps its
  last state and updates when the data is readable again.
- <span style="color:#ffd100">**The game draws what addons cannot read.**</span> Cooldown swipes, timer bars, health
  and power bars keep moving in combat.

---

## <span style="color:#00ccff">📖 Learn everything, in game</span>

Click the <span style="color:#ffd100">**Guide**</span> button at the top of the `/wa` window, or type
`/wa tutorial`. The guide covers:

- how an aura works, tab by tab;
- what changed on WoW Forever, and what works in combat;
- step-by-step recipes: DoT timer from your own cast, one timer per mob on its nameplate, pre-pull checklist,
  boss timeline, custom code;
- <span style="color:#ffd100">**three ready-made auras to import in one click**</span>.

---

## <span style="color:#00ccff">✨ New in 1.2.0</span>

- **In combat:** cooldown swipes, timer bars, health and power bars, and texts made only of `%p` and `%t` keep moving.
- **Your own recast** of a buff on yourself restarts its timer, even in combat.
- **New triggers:** Bag Space, Equipment Durability, Role, Tracking, Ammo.
- **Swing Timer** based on the game's own swing: main hand, off hand, ranged and wand, with a Target In Range option.
- **Aura trigger:** Elapsed Time filter, Native Filter, and a "From the Cooldown Manager" list.
- **Cooldown trigger:** "From the Cooldown Manager" list, and an "On Global Cooldown" condition.
- **Dispel type:** Dispel Type Icon sub element, and borders colored by dispel type.
- **Load options:** Class and Specialization, Instance Type.
- **`/wa cdm`** shows or hides the Blizzard Cooldown Manager, out of combat.

---

## <span style="color:#00ccff">🎯 What you can use</span>

<span style="color:#4caf50">**✔ Tested in game, works in combat**</span>

- Spell cooldowns: swipe and number, with an "On Global Cooldown" condition.
- Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.
- Health bar of your target and power bar of yourself, with a `%p / %t` text.
- Swing timer, main hand.
- Your own casts (`UNIT_SPELLCAST_SUCCEEDED:player`) and `PLAYER_TARGET_DIED`.

<span style="color:#4caf50">**✔ Tested in game**</span>

- Temporary weapon enchants, Elapsed Time filter, Bag Space, Role, `/wa cdm`.

<span style="color:#ff9800">**⚠ Works, with limits**</span>

- Stacks stay frozen in combat.
- Conditions on percentages, stacks or remaining time use the value from before combat.
- A buff applied for the first time in combat only shows when combat ends.

<span style="color:#f44336">**✖ Does not work**</span>

- Combat log triggers: the game forbids the combat log to addons.
- Other players' casts, enemy names and IDs in instances.
- The Native Filter of the Aura trigger shows nothing at the moment.

<span style="color:#9e9e9e">*Not tested in game yet: Equipment Durability, Tracking, Ammo, Instance Type, off hand and
ranged swing timer, dispel type colors, dungeons and raids.*</span>

---

## <span style="color:#00ccff">🔁 Coming from ForeverAuras?</span>

Export your auras from ForeverAuras and paste the strings in the WeakAuras import window. Groups work too.
They are **converted on import**, and the chat lists what could not be converted.
<span style="color:#f44336">Do not run both addons at the same time.</span>

---

## <span style="color:#00ccff">⚠ Before you import auras from Wago</span>

Most auras made for Classic Era, Season of Discovery or Retail need some work:

- replace combat log triggers (the guide shows how);
- type spell IDs instead of spell names: every rank has its own ID;
- update custom code that calls old functions (`GetSpellInfo`, `UnitBuff`...) to `C_Spell`, `C_UnitAuras`, `C_Item`.

---

## <span style="color:#00ccff">📦 Installation</span>

Install with the CurseForge app, or copy the five folders `WeakAuras`, `WeakAurasArchive`, `WeakAurasModelPaths`,
`WeakAurasOptions` and `WeakAurasTemplates` into `World of Warcraft/_classic_beta_/Interface/AddOns/`.

<span style="color:#f44336">**Do not install it next to another WeakAuras build.**</span> The folder name and the
saved settings are the same, on purpose, so your existing auras keep working.

---

## <span style="color:#00ccff">🐞 Support</span>

Found a bug, or an aura that should work and does not?
[Open an issue on GitHub](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/issues).

Discord: coming soon.

---

<sub>WeakAuras Forever is a modified version of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2) by The WeakAuras
Team, released under the GNU GPL v2. Changes © 2026 dldvlpr, same license. Every modified file is listed in
[CHANGES.md](https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/blob/main/CHANGES.md).</sub>
