# WeakAuras Forever tutorial

How WeakAuras works on WoW Forever, and how to build auras that keep working in combat.

WoW Forever looks like Classic, but it runs on the modern 12.1 game engine. This engine hides most combat data
from addons. This guide explains what that changes and gives step-by-step recipes.

Section 3 says what was tested in game on Forever, and what was not. When you are not sure, test in game.

---

## 1. WeakAuras in 2 minutes

An aura is something WeakAuras shows on your screen: an icon, a bar, a text or a texture.
Every aura has 4 parts, one per tab in the options:

| Tab | What it decides |
| --- | --- |
| **Display** | What it looks like: icon, size, colors, text. |
| **Trigger** | When it shows: a buff, a cooldown, a cast, an item count, a game event. |
| **Conditions** | What changes while it is shown, for example red when less than 3 seconds remain. |
| **Load** | When WeakAuras even looks at it: class, in combat, in a group, zone. |

The **Actions** tab adds a sound, a chat message or a glow when the aura shows or hides.

Basic steps:

1. Type `/wa`.
2. Click **New**, then choose a display type: **Icon**, **Progress Bar**, **Text** or **Texture**.
3. Fill in the **Trigger** tab.
4. Set the **Load** tab, so the aura only loads when it is useful.
5. Close the options and test.

---

## 2. What changed on Forever

### Secret values

During combat, boss encounters and PvP matches, the game gives addons "secret" values: WeakAuras receives the
data but cannot read it, compare it or do math with it. Out of combat, almost everything works like before.

What that means for your auras, tested in game on Forever unless marked otherwise:

- **The game draws what WeakAuras cannot read.** Cooldown swipes and numbers, timer bars, and health or power
  bars keep moving in combat. A text made only of `%p` and `%t` (for example `%p` or `%p / %t`) is drawn by the
  game too, as a raw number.
- **Buffs and debuffs are refused to addons in combat.** An aura that was showing before the pull keeps counting
  down from its last known time. Its stacks stay frozen. Everything is read again when combat ends.
- **Your own recast restarts the timer.** When you cast again a buff that you put on yourself, the timer of an
  Aura trigger on the Player unit restarts from its last known duration, even if this cast went to someone else.
  A recast by someone else is not seen.
- **A buff or debuff applied for the first time in combat** is only seen when combat ends.
- **Logic on secret data keeps its last state.** A condition such as "Health < 50%" keeps the state it had when
  combat started, then updates when combat ends. Not tested again since the last fix.

### The combat log is closed

Triggers that use the combat log (`CLEU`, "Combat Log") never fire. For damage taken, use the event
`UNIT_COMBAT:player`.

### Other changes

- **Spells by ID.** Name search in the options may not find spells. Type the spell ID.
  Get the ID of your rank out of combat: `/dump C_Spell.GetSpellInfo("Corruption")`.
  Classic spells have one ID per rank.
- **Talent load options** are empty. Use the **Class and Specialization** load option instead.
- **Chat Message action** can be blocked during encounters and PvP matches.
- **Old functions in custom code** no longer exist (`GetSpellInfo`, `GetSpellCooldown`, `UnitBuff`...).
  Use `C_Spell`, `C_UnitAuras`, `C_Item`.
- **Blizzard Cooldown Manager.** `/wa cdm` shows or hides it, out of combat. On the Forever beta it is not
  enabled for every class: for some classes it has no spell and no buff, and the "From the Cooldown Manager" lists
  of the Cooldown and Aura triggers are empty.

---

## 3. What you can use

**Tested in game, works in combat:**

- Spell cooldowns: icon swipe and number. With **Show Global Cooldown**, the "On Global Cooldown" condition can
  hide the number during the global cooldown.
- Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.
- Health bar of your target and power bar of yourself, with a `%p / %t` text.
- Swing timer, main hand.
- Your own casts: `UNIT_SPELLCAST_SUCCEEDED:player` (see the recipes below).
- `PLAYER_TARGET_DIED`.

**Tested in game:**

- Temporary weapon enchants (poison, oil, sharpening stone), both hands.
- **Elapsed Time** filter of the Aura trigger.
- Bag Space trigger.
- Role trigger (role chosen in the group finder).
- `/wa cdm`, and the "From the Cooldown Manager" lists, for the classes that have it.

**Works, with limits:**

- Stacks stay frozen in combat.
- Conditions and filters on percentages, stacks or remaining time use the value from before combat.
- A filter checked in the trigger itself (for example "Health (%) < 50") freezes the trigger in combat instead of
  hiding the aura.

**Not tested in game yet:**

- Swing timer off hand, ranged and wand, "Target In Range" option.
- Ammo trigger, Equipment Durability, Tracking, instance difficulty load option.
- Border and icon colored by dispel type.
- Aura triggers in party or raid mode, glows, range conditions.
- Encounter start and end: `ENCOUNTER_START`, `ENCOUNTER_END`.

**Does not work:**

- Aura trigger filtered by **Native Filter** (crowd control, cast by me...): nothing shows at the moment.
- Other players' casts.
- Enemy names and IDs in instances.
- Low mana alert, mana or energy tick timer in combat.
- Combat log triggers.

---

## 4. New way of thinking: prepare or deduce

Stop reading the combat. **Prepare** before the pull, or **deduce** from what you do.

| Before | On Forever |
| --- | --- |
| Debuff on target, show its timer | You cast the DoT, start a fixed timer |
| Buff missing in combat, alert | Check buffs and consumables before the pull |
| Boss casts X, alert | Boss timeline from the pull (`ENCOUNTER_START`) |
| Cooldown ready, flash | Let the action bar show the cooldown |
| Low mana, alert | Show the mana bar, no logic on it |

For debuffs on enemies, the Blizzard nameplates and target frame can show them ("only my debuffs").
Use them for what only the game can see.

---

## 5. Recipe: DoT or buff timer from your cast

Not tested in game yet. No custom code. Example: Corruption on your target.

1. Out of combat, get the ID of your rank: `/dump C_Spell.GetSpellInfo("Corruption")`. Note the `spellID`.
2. `/wa`, **New**, **Icon** (or **Progress Bar**).
3. **Trigger** tab:
   - Type: **Other Events**, then **Spell Cast Succeeded**
   - Caster Unit: **Player**
   - **Exact Spell ID(s)**: your spell ID (for example 11672)
   - **Hide when target dies**: checked
   - **Hide After**, Duration: the spell duration from its tooltip (Corruption: 18)
4. Test on any mob.

The trigger gives the icon of the spell.

Limits: one aura per spell. Casting again restarts the timer. The aura does not know if the spell was resisted
or dispelled. It follows one target only.

**Hide when target dies** only sees the death of your current target. If you change target and the mob with your
DoT dies, the timer keeps running. If you change target and the new target dies, the timer is hidden. For a buff
on yourself, leave the box unchecked.

Ready-made example for Immolate rank 1 (spell ID 348, 15 seconds). Copy this text, then `/wa`, **Import**:

```
!WA:2!DjvVUrnqq4afePniKIfefHO40ricAIGJKiAJdXIt6q5KTbr3DR9o2EKS31A)5cHsxbT5r4QP6AONNGvriEa4ripbS7DxOGQ9BN1Z89Z47ef0eWcyFD75yUGNimYC4jBCn1OReYZB1OGRiZLqPdKEzle6)mjnF5dhhR0uPMKvGCuvrcDhAsNwILLGu9G9LRH)ou76ngMbCTu1c11dzpEWRp8n)rzYwwnXuuGFEXKtpjjDss6jXPDmJK6PP)RoYE)2hM4BR3PuLUxIjphagWcnocZARPxcYfgfmz9SN2TgOiXCAdOi)JOXsWruCY4ZgnQZ3IFetBFKhwHm4CEkvwc63cuD105miZPmVZLV7SrJJ(WORm81UI0UTpiMbPRU)Ebd((g3GCni506p6IaN8)Xvuo2S0jhBVx013ARj(irQaxEYu2Tc5co8tGQGeTe4L6Qn7838uB3lSHI8iBF7tTBz3Z(SnT77o28)R0hzT7oSPrut1qpn2aYEppsiDox(I4lqMUIUa5fc5kbrgyq2nfZUTf3gHsZCkQaljZ9kdx9hqwfGLvA6cgQ8X9q3B7E3GV1Lle1mXf8PH1cklkttRDH8oXnMAnscDRH8DShsIZRPkLhfQWVaEqGk7Odgm4Gxgm7xF6V)
```

### Variant: one timer per mob, on its nameplate

Tested in game on Forever. Each mob you cast the spell on gets its own icon and timer, above its nameplate.

**Only with the default Blizzard nameplates.** Addons that replace the nameplates (EllesmereUI, ElvUI, Plater,
Kui, etc.) hide the Blizzard health bar this aura attaches to: the icons then show nowhere, or at random places.
The game does not let addons measure or attach to protected nameplate regions, so this cannot be fixed on the
WeakAuras side. With a nameplate addon, use the single timer above.

Enemy nameplates must be shown (key **V**).

How it works:

- The aura is a **Dynamic Group** with **Group by Frame** set to **Nameplates**, and one icon inside.
- The icon uses a **Trigger State Updater** on `UNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED
  PLAYER_TARGET_DIED`.
- When you cast the spell, the code looks for the nameplate of your target: it tests `nameplate1` to
  `nameplate40` with `UnitIsUnit(token, "target")`, which stays readable in combat. It starts a timer for that
  nameplate and stores the nameplate in the state (`unit = token`), so the group puts the icon on it.
- When a nameplate disappears (the mob died or went out of range), its timer is removed.

Limits: a timer is lost when the nameplate disappears, for example when you move away from the mob. The aura does
not know if the spell was resisted or dispelled.

Ready-made example for Immolate rank 1 (spell ID 348, 15 seconds). Copy this text, then `/wa`, **Import**:

```
!WA:2!nwv3UXrTxCcuOTMac2kvAccWD)tRskllPH2Q2k1lYS7SjlkFSA2nvcHqB9mJNDT6S2JS9KpavUixvUnxWdqUMB(hP(c0NaR8O0Nao2ZUPzs3cDUWJ95C85ZFNJN5XvIM)5x5iwKG3vKlJOZeMrKuUod3E0irkrtXcoMtgrZShu4fAjK0DOYfpsshWe8E7Nr9S3xsI0Wz19cuAIuJctyCMAiYd(PrhOLSbdOs1NEt54T)LNgUByuUslgDCXV(wshdkqtZZIH1aWwCD4AusQEOxoOQqWr2NkdDmuz)02B2Ux)UD8xF9gR0f2TDJg((n9B(Wc5WBUYg(97S(k9877enWFJTESFtmq6N9d63BLGv971VzB)MhOYOPPTJvOaBaRqMpzVl8)tY5UaBbsAQZXu1WoBxdxVE9fry4lversXtKedX)aQUJnHTqHa2VeHeZWpcF7A47SeowCkJxRbT4Puois1tt4vbJGzLeLLG3gYd(7XuA1cURSiMWJDuBRSRfuRHRw4jvxeRhs5L0I9ts15sEHvlXKYJrNF)K)G5DHp(rGF(2s(vlBWIOZw9QHJik9QB3UznCr6UjeVqIeDMWJPu0iW52HKMtDHwjklm(Ifr1KOiHKQOL8CqttmXF8i8pEN7)FiF5AW0lIGo5c9yH(3v3P4LFXj9Vc683lLLvdf7AnKmNwReJOHe(aA8u5LjfdKuLY23zrkA2iAC1YYeNljoGia2UBzw09Yyfm7bxeeyvQ2UBHfXF3BimjxlwJftNQJyRMwgoK2PCEg68Gl4If4hi)uc78wAmRIH(Kxl1B2MovS1KQ27G6T4jaWznZ0RXfA0v7MeGUlD(cAjGMt63OlZrU(4cTdImf2Ll3OP1HEw6NVH8Saqeq8OyAyEsIfGixZF9oT2E9dZ5Jh6IY(C7C6DO9koVHiM(3V3RyCnvYjPpgMqdyJxCiHZg5Gj3ZCXwNmbq5gplHwrbpwzM1Jl40xsjkAxn8OXa9WlEG9K10MR7nIW4TmFJbBM1CDt1lA(FWVlDEkvzXzx70hBoDWh2cSLhejePXID5p54yMYorVny7R9(v(ZGDzX6Hp4eaJoui3kZ92dA5Cw8Rs2XQoxvfA6jEPcsCRqnjfGgxnyuEQMH8Gjdrx1uhfeLsuk7opf73O2nhPYddCpUPU1vnZEcCmKe90bsrop(EMzLabnDp9H2L(2LQ3i7e3Hebx3fuZCHdPSbd1p4iBQIv4ChZ4WBafPvuiWiHnavzuL4kXpFopq97ge0E116Lvb4PLI0uACJHS0yi3oV5gMfrY93kjrr1x2CHxgVpKRyrwVk7ecpcYcDOs70)dTqFhYp7ZYv0volVNy(iOIImxczUmYGM)MMpULPI5kMzdiqrEzZCM5nFbY8Li5Ef2AgZx9Idv00KocaLe6TvVEBTH5RT4IZxB)23PQT5doES7Av4Y92QtajLnGh2WFZE(bVQGzljGeSaPWUnc893uc9kwa7mMBD2c8QYSBhOYir0p0tjKAWq1Az(EBz08dU1LCR32TEFK5biZdrvuH3T(YlxFPk7CHN9pp
```

---

## 6. Recipe: pre-pull checklist

The idea: one group of icons that shows what is missing, only out of combat and in a group.

1. `/wa`, **New**, **Dynamic Group**. Name it "Pre-pull".
2. In the group, **Load** tab: **In Combat** unchecked twice (the box shows a cross = "not in combat"),
   **In Group** checked.
3. Add one icon per check, inside the group.

**Missing buff** (Power Word: Fortitude, Mark of the Wild, Arcane Intellect, Blessings, Thorns, flask, food):

- Trigger type: **Aura**
- Unit: **Player**, Type: **Buff**
- Aura name or spell ID: the buff. For buffs with ranks, add every rank you want to accept.
- Show On: **Aura(s) Missing**

**Weapon enchant** (poison, oil, stone): trigger **Weapon Enchant**, show when missing.

**Reagents and ammo** (Soul Shards, arrows, Symbol of Kings...):

- Trigger type: **Item**, **Item Count**
- Item: the item ID
- Count: lower than the number you want, for example `< 5`

Because the group only loads out of combat, secret data never matters here.

Ready-made example for a Warlock (tested in game on Forever). Copy this text, then `/wa`, **Import**:

| Icon | Shows when | Loads |
| --- | --- | --- |
| Fortitude | the buff is missing (every rank, Prayer of Fortitude included) | in a party or raid |
| Mark of the Wild | the buff is missing (every rank, Gift of the Wild included) | in a party or raid |
| Arcane Intellect | the buff is missing (every rank, Arcane Brilliance included) | in a party or raid |
| Demon Skin / Armor | neither Demon Skin nor Demon Armor is active | Warlock, solo included |
| Soul Shards | fewer than 3 Soul Shards (item 6265) in your bags | Warlock, solo included |

None of them loads in combat. Buffs are matched by spell ID, so the group works with any client language.
The IDs come from Classic 1.12 data: if an icon stays visible while you have the buff, report it.

```
!WA:2!nxzZUTTrxyy7206e2uxh628RtlB7xvtw0urkjkj30cy6iLyu)lLBcqakSgsouCQPijMzOCCa6gJIaJU0l)wQ1DLbYnGVcoWxc9sWxb9mucoUjObbDrqxOxnZHCgEMN3zoZKpu3)X7pJtCkjyWH5c6wSKE808Si(4gx2TFESKvYTOxxhoHf01tsIPjYldNtZ1pMieQwdvd3pTVhrg5iYO(QGoc2tPQgNWsKuEcj(HuUGLM88Hm)0KoP5CF6CtCajH1NiX42UcjHlBFCqoViWwYDZWHqX3oq4O64KKMqpIse0osonPNmAQ9u92eFgmRtFclPnmdCjqhMf(4PGpbM1lKLWerVC4Jj5YOu(AzQpKq7qwsykFuEO5LrWjxMn36C63KLhhB4hr93oMjKg3QDkNoGYVT7oSaz0gd50E4yujGJAz5H)cz90(cwqM(kmHaH58g4GKmzEa1kNfCs4aCIvZRkCztVikRxKCJHQ1jBu(Wj(fnSHpsdUIMdUgKA7j5SE9qImDj(4Mp7iccle5XXSaXV7yAvTIsQQKAow1BA6AwUzL6fAdxlZA2wfAvq3vnwRduAcPpvODc6JTEc(P7OMWLc6YXaRIpk6yenieeDIs3zTKJff)nE5nmG6LhgQqa)bTwE92)0Yo5y(6Lft2LYpipzCYQLDj1YAaDZr9xjnG(htS)mWKdG3jcExCZsj496cVFxyk1gh48f6fIaTIgFqHEXNdF4CtatJO5Lnv4YVsKR8krUQgCnn46WnG52aUj8PWNvywx7uZAfcFBJ0qdze14rS4a4ZFHJTsQCNYMWxUb8)0GVAS7aL0GVE6sWTEgC7)VJPPLTtnRkwo21Rv0QQtJMLR70SrJQkPgY)gvBQ0ALXmZcQObv7c1IaBOo0aAcZdFhCxn47)piDwG7tsOglHNPJJP(YZsNfWOVw68loMvR1ef7YkrT3e3kwO1DTQu2QXBcpcpOOEJQ6ZPSOKNk9IP8hTG7YRT4p(2dn34u0CpA)0eJoBZsm(wKt9t5Nfo3dJ8AHZtTSBu3YUPTv9Y2oMLBGGXSELkfA1cT2BeEGnEbwaxOZBpwmZYP7mVbwAp2OteHhiola6eXd(NbqiO7WK0(J82uSOrx3I)0RSNkUQm05V6UUyX3e5WLWiglQE8Fw8sBLIfFiYuU(Dhtc9(6b6b7Ffh82RDCDx6(pyZmDScRKNI7BdwmcpzJv5Fmya)aSeSj8Z4IIV7AHHcQ83UiCZJc2fRkY8lU9ZrGLQHzDfzeF6f(7z)1XSVDHhOmh0pChvnvLiiN)3YyKNiENS9yRu7mN5l8q(tgLRtEcjXhVkRnh)QQIWEDw0TvRv54TPQQStIEZbcAC46P4fXEl2A1nB5E4OXueceUKywVeqOmg0wpJNDF1I3ux4v7oww3PS(GZ9R)f
```

---

## 7. Recipe: boss timeline

Not tested in game yet.

1. Find the encounter ID. Out of combat, create a test aura on `ENCOUNTER_START` and print the ID,
   or search it on Wowhead.
2. For each boss ability, create a **Progress Bar**:
   - Trigger type: **Custom**, Event Type: **Event**
   - Event(s): `ENCOUNTER_START`
   - Custom Trigger:

     ```lua
     function(event, encounterID, encounterName, difficultyID, groupSize)
         return encounterID == 610 -- replace with the boss encounter ID
     end
     ```

   - Hide: **Timed**, Duration: the time of the first cast after the pull, in seconds.
3. **Load** tab: **Encounter ID(s)** = the same ID. The aura unloads when the encounter ends, so a wipe
   does not leave the bar on screen.
4. If a readable event marks a new phase (an emote, `ENCOUNTER_STATE_CHANGED`), use it to restart the timers.

Abilities based on boss health % or on random timings cannot be predicted.

---

## 8. Custom code

In custom code, check every value before you compare it or do math with it:

```lua
if issecretvalue and issecretvalue(value) then
    return false
end
```

Without this check, the code stops with a Lua error in combat. WeakAuras Forever does not show those errors:
the aura just keeps its last state.

In combat, the `C_UnitAuras` functions refuse addon code when auras are secret. They stop the code with
"Auras cannot be accessed when secret while tainted" (tested in game): call them under `pcall`, or only out of
combat.

For health events, use `UNIT_HEALTH`: `UNIT_HEALTH_FREQUENT` does not exist on Forever.

Other tools:

- `/dump <expression>` shows the content of a value in chat, secret values included.
- `/eventtrace` shows events and which of their values are secret.
- There are no training dummies on Forever. Test in real combat: pull any mob or duel a friend.

---

## 9. Importing auras from Wago

Most packs made for Classic Era, Season of Discovery or Retail need work:

- replace combat log triggers (section 5 for DoTs, `UNIT_COMBAT:player` for damage taken);
- replace spell names by the spell IDs of your ranks;
- rewrite custom code that calls old functions;
- move buff and consumable checks out of combat (section 6).

Found an aura that should work and does not? Report it:
https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/issues

---

## 10. Coming from ForeverAuras

Export your auras from ForeverAuras, then paste the strings in the WeakAuras import window. Groups work too.
WeakAuras Forever converts them on import, and lists in the chat what it could not convert.

| ForeverAuras | WeakAuras Forever |
| --- | --- |
| Cooldown Manager trigger, cooldown | Cooldown trigger (spell ID, or name if ForeverAuras used names) |
| Cooldown Manager trigger, buff | Aura trigger (your buffs, or your debuffs on the target) |
| Cooldown Manager trigger, item | Item cooldown trigger |
| Aura (Blizzard) trigger | Aura trigger with Native Filter (sorting removed). The Native Filter shows nothing at the moment. |
| Dispel type icon | Dispel Type Icon sub element |
| Dispel type border | Border colored by dispel type |
| Swing Timer, Ammo | Same triggers (Ammo: the item list now filters the equipped ammo) |
| Role, Tracking, Equipment Durability, Bag Space | Same triggers (Tracking: by spell ID only, no "always" mode) |

Not converted: TimelineParser triggers (they need the ExRT_Reminder addon and a boss timeline, which WoW Forever does not show). A Cooldown Manager cooldown trigger with several spells keeps the first one.
Do not run both addons at the same time.
