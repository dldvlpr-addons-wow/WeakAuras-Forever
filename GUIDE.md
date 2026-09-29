# WeakAuras Forever: the complete guide

Everything you need to build auras on WoW Forever, from your first icon to boss timers.

WoW Forever looks like Classic, but it runs on the modern game engine. During combat this engine hides most combat
data from addons ("secret" data). WeakAuras Forever is built around that: the game draws what addons cannot read,
so your icons, bars, timers and stack counts keep working in combat. This guide shows how to use it.

**Contents**

1. [Quick start](#1-quick-start)
2. [The options window](#2-the-options-window)
3. [How combat works on Forever](#3-how-combat-works-on-forever)
4. [Triggers](#4-triggers)
5. [Display elements](#5-display-elements)
6. [Conditions and actions](#6-conditions-and-actions)
7. [Load options](#7-load-options)
8. [Recipes](#8-recipes)
9. [Custom code](#9-custom-code)
10. [Importing auras](#10-importing-auras)
11. [Commands and troubleshooting](#11-commands-and-troubleshooting)
12. [Limits of the game](#12-limits-of-the-game)

---

## 1. Quick start

Your first aura in one minute: an icon that shows when your Power Word: Fortitude (or any buff) is active.

1. Type `/wa`.
2. Click **New**, then **Icon**.
3. **Trigger** tab:
   - Type: **Aura**
   - Unit: **Player**, Aura Type: **Buff**
   - Check **Exact Spell ID(s)** and type the spell ID of the buff.
   - Show On: **Aura(s) Found**
4. **Display** tab: add a **Text** element with `%p` to see the remaining time.
5. Close the window. Cast the buff: the icon shows, with its timer, in and out of combat.

Find a spell ID out of combat: `/dump C_Spell.GetSpellInfo("Power Word: Fortitude")`. Classic spells have one ID
per rank: add every rank you want to match.

New to WeakAuras? `/wa tutorial` opens a short tutorial with two ready-made auras.

---

## 2. The options window

Every aura has these tabs:

| Tab | What it decides |
| --- | --- |
| **Display** | What it looks like: size, colors, texts, borders, glows, and other elements. |
| **Trigger** | When it shows: a buff, a cooldown, a cast, a health value, an item count, an event. |
| **Conditions** | What changes while it is shown: red under 3 seconds, a glow when ready, hide the timer text. |
| **Actions** | What happens when it shows or hides: a sound, a chat message, a glow on an action button. |
| **Load** | When WeakAuras even looks at it: class, spec, in combat, in a group, zone, instance type. |

### Display types

| Type | Use it for |
| --- | --- |
| **Icon** | Buffs, debuffs, cooldowns, procs. The cooldown swipe shows the remaining time. |
| **Progress Bar** | Timers, health, mana, swing timer. |
| **Text** | Numbers and messages: "3 Soul Shards", "Bags full". |
| **Texture** | Big visual alerts in the middle of the screen. |
| **Progress Texture** | A texture that fills up (circle, ring). |
| **Dynamic Group** | Several auras that line up by themselves: only the visible ones take space. |
| **Group** | Several auras that you place by hand and move together. |

### Several triggers

An aura can have several triggers. In the Trigger tab, choose **All triggers** (every trigger must be active),
**Any trigger** (one is enough) or **Custom**. The first trigger gives the icon, name and timer by default.

---

## 3. How combat works on Forever

### Secret data

During combat, a boss encounter or a PvP match, the game gives addons "secret" values: WeakAuras holds them but
cannot read them, compare them or do math with them.

WeakAuras Forever handles this for you:

| What you want | In combat |
| --- | --- |
| Icon of a buff or debuff | Shown, drawn by the game. |
| Cooldown swipe, timer bar | Keep running, drawn by the game. |
| Text `%p` (remaining time) | Drawn by the game, with your time format. |
| Text `%s` (stacks) | Drawn by the game. |
| Health, mana, energy, rage bars | Keep moving, drawn by the game. |
| Border colored by dispel type | Colored by the game. |
| Dispel type icon | Colored by the game. |
| Buff or debuff applied during combat | Shown. With **Native Filter** only, even when the game hides it completely. |
| Conditions and thresholds on secret values | Keep their last state, and update when combat ends. |

When the restriction ends, every aura reads the data again and updates by itself. Out of combat, everything works
like in regular WeakAuras.

The **Conditions** trigger has a **Secret Restrictions Active** option, if you want to show or hide something
while data is secret.

### The one rule

**Put the display on secret data, and the logic on readable data.**

- Good: an icon with its timer and stacks, a health bar, a text with only `%p`.
- Works, with a delay: "turn red when health is below 30%". In combat the color keeps its last state.
- Always readable: your own casts, your cooldowns ready or not, combo points, your items, your bags, where you are.

### Spells by ID

Name search in the options may not find every spell. Type the spell ID, and add every rank.

---

## 4. Triggers

The most useful triggers, grouped by what they watch. Every trigger has a **Show On** or similar option, and a set
of values you can use in texts and conditions.

### Buffs and debuffs: the Aura trigger

Type **Aura**. Main options:

| Option | What it does |
| --- | --- |
| **Unit** | Player, Target, Focus, Pet, Party, Raid, Smart Group, Boss, Arena, Nameplate, Specific Unit. |
| **Aura Type** | Buff, Debuff, or both. |
| **Name(s)** | Match by name. |
| **Exact Spell ID(s)** | Match by spell ID. Recommended: one line per rank. |
| **From the Cooldown Manager** | Adds the spell IDs of a buff tracked by the Blizzard Cooldown Manager. |
| **Native Filter** | Match by the game's aura categories, see below. |
| **Debuff Type** | Magic, Curse, Disease, Poison, Bleed, Enrage. |
| **Own Only** | Only auras cast by you or your pet. |
| **Stack Count**, **Remaining Time**, **Elapsed Time**, **Total Time** | Filters on the aura's numbers. |
| **Show On** | Aura(s) Found, Aura(s) Missing, Always, Match Count. |
| **Auto-Clone (Show All Matches)** | One icon per matching aura (in a Dynamic Group). |

**Native Filter** uses the categories the game itself gives every aura. Check a category in **Is** to require it,
in **Is Not** to exclude it:

| Category | Meaning |
| --- | --- |
| Cast by Me or my Pet | You, your pet or your vehicle applied it. |
| Can Apply or Dispel | A buff you can cast, or a debuff you can dispel. |
| Dispellable by the Group | Someone in your group can dispel it. |
| Dispellable | It can be dispelled at all. |
| Shown on Raid Frames in Combat | The game shows it on raid frames in combat. |
| Cancelable | You can right-click it off. |
| Important | The game flags it as important. |
| Crowd Control | Stun, fear, polymorph, root... |
| Big Defensive | A strong personal defensive. |
| External Defensive | A defensive cast on you by someone else. |

**Native Filter alone shows everything, even hidden auras.** When Native Filter is the only filter of the trigger
(no name, no spell ID, no other filter), auras applied during combat show even when the game hides all their data.
Their icon, timer and stack text are drawn by the game; their name stays empty until combat ends.

### Cooldowns

| Trigger | Watches |
| --- | --- |
| **Cooldown/Charges/Count** (Cooldown Progress, Spell) | A spell cooldown and its charges. **From the Cooldown Manager** lists the spells the game tracks for your class. **Show Global Cooldown** includes the GCD. |
| **Cooldown Progress (Item)** | An item cooldown: potion, healthstone, trinket by item. |
| **Cooldown Progress (Slot)** | The item in an equipment slot: both trinket slots. |
| **Global Cooldown** | The global cooldown itself. |

Conditions on the spell cooldown: **On Cooldown**, **On Global Cooldown**, charges, usable, in range.

### Health, power and resources

| Trigger | Watches |
| --- | --- |
| **Health** | Health of any unit, with value, max and percent. |
| **Power** | Mana, energy, rage, focus, with value, max and percent. |
| **Combo Points** | Rogue and druid combo points (part of Power). |
| **Ammo** | Count (equipped ammo), Total Carried (all projectiles in your bags), Ammo Item filter. |
| **Item Count** | Any item in your bags: Soul Shards, reagents, potions. |

### Weapons and swings

| Trigger | Watches |
| --- | --- |
| **Swing Timer** | Main hand, off hand, ranged (bows, guns, wands). **Target In Range**: In Range or Out of Range. |
| **Weapon Enchant** | Temporary enchants on both weapons: poisons, oils, sharpening stones, with duration and charges. |

### Casts and spells

| Trigger | Watches |
| --- | --- |
| **Cast** | Casts and channels of a unit, with the cast bar. |
| **Spell Known** | Whether you know a spell. |
| **Stance/Form/Aura** | Druid forms, warrior stances, paladin auras, stealth. |
| **Range Check** | Distance to a unit. |
| **Threat Situation** | Your threat on the target. |

### Your character and the world

| Trigger | Watches |
| --- | --- |
| **Conditions** | In combat, alive, resting, mounted, moving, in a group, pet, instance, Secret Restrictions Active. |
| **Unit Characteristics** | Class, level, hostility, name, NPC ID of a unit. |
| **Role** | Your group role: Tank, Healer, Damager. |
| **Bag Space** | Free and used slots of your bags. Specialty bags (quiver, soul bag) on request. |
| **Equipment Durability** | Lowest item, overall durability, broken items, all slots or one. |
| **Tracking** | Your active minimap tracking (Find Herbs, Find Minerals, Track Beasts...). **Inverse** shows when it is off. |
| **Currency**, **Money**, **Experience**, **Reputation** | Progress values. |

### Events and custom code

| Trigger | Use |
| --- | --- |
| **Custom**, Event | Your code runs on game events, for example `UNIT_SPELLCAST_SUCCEEDED:player`. |
| **Custom**, Trigger State Updater | Your code manages one or many timers, see section 9. |
| **Encounter** events | `ENCOUNTER_START`, `ENCOUNTER_END` for boss timelines. |

---

## 5. Display elements

In the **Display** tab, **Add** adds elements on top of an aura:

| Element | Use |
| --- | --- |
| **Text** | Any text, with placeholders (below). |
| **Border** | A border. **Color by Dispel Type** colors it by the aura's dispel type. |
| **Dispel Type Icon** | The dispel type icon of the aura (magic, curse, disease, poison, bleed). |
| **Glow** | Pixel, autocast, proc or button glow. |
| **Texture** | An extra texture, for example a background. |
| **Tick** | A mark on a bar, for example at 30% or at a cast time. |
| **Model** | A 3D model. |
| **Background**, **Stop Motion**, **Circular / Linear Progress Texture** | Advanced visuals. |

### Text placeholders

| Placeholder | Shows |
| --- | --- |
| `%p` | Remaining time. Alone in the text, it keeps running in combat. |
| `%t` | Total duration. |
| `%s` | Stacks. Alone in the text, it keeps working in combat. |
| `%n` | Name of the aura or spell. |
| `%i` | Icon, inline. |
| `%unit`, `%unitName` | Unit token and name (group auras). |
| `%c` | Result of a custom function. |
| `%1.p`, `%2.s`... | Values of trigger 1, trigger 2... |

Click the gear next to a `%p` text for its time format: **Old** or **Modern** Blizzard format, and **Increase
Precision Below** to show tenths under a few seconds.

For texts that must keep working in combat, put `%p` or `%s` alone in their own Text element. Combine several
elements instead of writing "`%n: %p`" in one.

---

## 6. Conditions and actions

### Conditions

A condition changes a property while something is true. In the **Conditions** tab:

1. **Add Condition**, pick a value of a trigger (Remaining Time, Stacks, On Cooldown, Health (%), Dispel Type...).
2. Pick the property to change: color, alpha, glow, desaturate, text, sound, **Hide Timer Text**, zoom, size.

Examples:

- Remaining Time < 3: color red.
- On Cooldown = false: glow.
- Stacks >= 5: text color yellow, play a sound.
- On Global Cooldown = true: Hide Timer Text (no GCD numbers on your cooldown icons).

In combat, a condition on a secret value (health, stacks, remaining time of an aura) keeps its last state and
updates when combat ends. Conditions on readable values (cooldown ready, combo points, your casts) work all the time.

### Actions

In the **Actions** tab, **On Show** and **On Hide**:

- **Sound**: play a sound, with a volume and a channel.
- **Chat Message**: say, party, raid, whisper, or a local message.
- **Glow External Element**: glow an action button or a unit frame.
- **Custom**: your code.

---

## 7. Load options

An aura that is not loaded costs nothing. Always set the **Load** tab.

| Option | Use |
| --- | --- |
| **Class and Specialization** | Only for your class, or one spec. |
| **In Combat** | Checked: only in combat. Checked twice (cross): only out of combat. |
| **In Group**, **Group Size** | Solo, party, raid. |
| **Role** | Tank, Healer, Damager. |
| **Instance Size Type** | No instance, 5 man dungeon, 10/20/40 man raid, battleground. |
| **Instance Type** | The exact difficulty of the instance. |
| **Zone Name/ID**, **Encounter ID(s)** | A zone, a boss. |
| **Player Level**, **Race**, **Mounted**, **Alive** | Everything else. |

---

## 8. Recipes

Step-by-step auras for the most common needs. Adapt spell IDs, items and durations to your class and rank.

### 8.1 Your buff, with timer and stacks

1. **New**, **Icon**.
2. Trigger **Aura**: Unit **Player**, Aura Type **Buff**, **Exact Spell ID(s)** = every rank of the buff,
   Show On **Aura(s) Found**.
3. Display: add a **Text** with `%p` (bottom), and a second **Text** with `%s` (bottom right).
4. Conditions: Remaining Time < 5: color red.

Works in and out of combat. The timer and stacks keep running during combat.

### 8.2 Your DoT on the target

1. **New**, **Icon**.
2. Trigger **Aura**: Unit **Target**, Aura Type **Debuff**, **Exact Spell ID(s)** = every rank of the DoT,
   **Own Only** checked, Show On **Aura(s) Found**.
3. Display: **Text** with `%p`.

To see your DoT on every mob, use Unit **Nameplate** and **Auto-Clone** inside a Dynamic Group set to
**Group by Frame: Nameplates**: each mob gets its own icon above its nameplate (default Blizzard nameplates only).

### 8.3 Every crowd control on your target

1. **New**, **Dynamic Group**, then an **Icon** inside.
2. Trigger **Aura**: Unit **Target**, Aura Type **Debuff**, **Native Filter** checked, **Is** = Crowd Control.
   Nothing else. **Auto-Clone (Show All Matches)** checked.
3. Display: **Text** with `%p`, **Border** with **Color by Dispel Type**.

Every stun, fear or polymorph on your target shows with its icon and timer, even the ones applied during combat.
Add **Is** = Cast by Me or my Pet to see only yours.

### 8.4 Big defensives on your group

1. **New**, **Dynamic Group** (Grow: Right), then an **Icon** inside.
2. Trigger **Aura**: Unit **Smart Group**, Aura Type **Buff**, **Native Filter**, **Is** = Big Defensive and
   External Defensive in two auras (or one each). **Auto-Clone** checked.
3. Display: **Text** with `%p`, **Text** with `%unitName`.

### 8.5 Debuffs you must dispel

For healers and anyone who can dispel.

1. **New**, **Dynamic Group**, then an **Icon** inside.
2. Trigger **Aura**: Unit **Smart Group**, Aura Type **Debuff**, **Native Filter**, **Is** = Can Apply or Dispel.
   **Auto-Clone** checked.
3. Display: **Dispel Type Icon** (top right), **Border** with **Color by Dispel Type**, **Text** with `%unitName`.
4. Actions, On Show: a sound.

### 8.6 Cooldown tracker

1. **New**, **Icon**.
2. Trigger **Cooldown/Charges/Count**: pick your spell in **From the Cooldown Manager**, or type its spell ID.
   Show On: **Always**. Check **Show Global Cooldown** if you want to see the GCD on it.
3. Conditions:
   - On Cooldown = false: Glow.
   - On Cooldown = true: Desaturate.
   - On Global Cooldown = true: Hide Timer Text.

Put several of them in a Dynamic Group for a cooldown bar.

### 8.7 Proc alert

1. **New**, **Texture** (or **Icon**), big, in the middle of the screen.
2. Trigger **Aura**: Unit **Player**, Aura Type **Buff**, the proc's spell ID.
3. Actions, On Show: a sound. Display: add a **Glow**.

### 8.8 Health and mana bars

1. **New**, **Progress Bar**.
2. Trigger **Health** (or **Power**), Unit **Player** or **Target**.
3. Display: **Text** with `%health` / `%maxhealth`, or `%percenthealth` (`%power`, `%percentpower` for Power).
4. Conditions: Health (%) < 30: color red (updates when combat ends, the bar itself moves all the time).

### 8.9 Swing timer and wand

1. **New**, **Progress Bar**.
2. Trigger **Swing Timer**: Weapon **Main Hand** (a second bar for **Off Hand**, a third for **Ranged**: bow, gun,
   wand).
3. For a melee range warning: second trigger **Swing Timer** with **Target In Range** = Out of Range, and a
   condition "trigger 2 active": color red.

The bar restarts after a spell that resets your swing, and follows attack speed changes on both hands.

### 8.10 Ammo, bags and repairs

Three **Text** auras in a Dynamic Group, loaded out of combat:

- Trigger **Ammo**, Total Carried < 200: text "Low ammo: `%s`".
- Trigger **Bag Space**, Free Slots < 3: text "Bags almost full".
- Trigger **Equipment Durability**, Lowest Item Durability (%) < 25: text "Repair!". Add Broken Items >= 1 in
  red.

### 8.11 Tracking reminder

For herbalists and miners.

1. **New**, **Icon**.
2. Trigger **Tracking**: **Tracking Spell** = Find Herbs (its spell ID), **Inverse** checked.
3. Load: not in combat, not in an instance.

The icon shows when Find Herbs is off.

### 8.12 Pre-pull checklist

A Dynamic Group that shows what is missing before the pull, loaded **out of combat** and **in a group**:

- **Missing buff**: trigger **Aura**, Unit Player, Buff, every rank, Show On **Aura(s) Missing**.
- **Weapon enchant**: trigger **Weapon Enchant**, show when missing.
- **Reagents**: trigger **Item Count**, the item ID, count lower than what you want.

Ready-made example for a Warlock (Fortitude, Mark of the Wild, Arcane Intellect, Demon Skin/Armor, Soul Shards).
Copy this text, then `/wa`, **Import**:

```
!WA:2!nxzZUTTrxyy7206e2uxh628RtlB7xvtw0urkjkj30cy6iLyu)lLBcqakSgsouCQPijMzOCCa6gJIaJU0l)wQ1DLbYnGVcoWxc9sWxb9mucoUjObbDrqxOxnZHCgEMN3zoZKpu3)X7pJtCkjyWH5c6wSKE808Si(4gx2TFESKvYTOxxhoHf01tsIPjYldNtZ1pMieQwdvd3pTVhrg5iYO(QGoc2tPQgNWsKuEcj(HuUGLM88Hm)0KoP5CF6CtCajH1NiX42UcjHlBFCqoViWwYDZWHqX3oq4O64KKMqpIse0osonPNmAQ9u92eFgmRtFclPnmdCjqhMf(4PGpbM1lKLWerVC4Jj5YOu(AzQpKq7qwsykFuEO5LrWjxMn36C63KLhhB4hr93oMjKg3QDkNoGYVT7oSaz0gd50E4yujGJAz5H)cz90(cwqM(kmHaH58g4GKmzEa1kNfCs4aCIvZRkCztVikRxKCJHQ1jBu(Wj(fnSHpsdUIMdUgKA7j5SE9qImDj(4Mp7iccle5XXSaXV7yAvTIsQQKAow1BA6AwUzL6fAdxlZA2wfAvq3vnwRduAcPpvODc6JTEc(P7OMWLc6YXaRIpk6yenieeDIs3zTKJff)nE5nmG6LhgQqa)bTwE92)0Yo5y(6Lft2LYpipzCYQLDj1YAaDZr9xjnG(htS)mWKdG3jcExCZsj496cVFxyk1gh48f6fIaTIgFqHEXNdF4CtatJO5Lnv4YVsKR8krUQgCnn46WnG52aUj8PWNvywx7uZAfcFBJ0qdze14rS4a4ZFHJTsQCNYMWxUb8)0GVAS7aL0GVE6sWTEgC7)VJPPLTtnRkwo21Rv0QQtJMLR70SrJQkPgY)gvBQ0ALXmZcQObv7c1IaBOo0aAcZdFhCxn47)piDwG7tsOglHNPJJP(YZsNfWOVw68loMvR1ef7YkrT3e3kwO1DTQu2QXBcpcpOOEJQ6ZPSOKNk9IP8hTG7YRT4p(2dn34u0CpA)0eJoBZsm(wKt9t5Nfo3dJ8AHZtTSBu3YUPTv9Y2oMLBGGXSELkfA1cT2BeEGnEbwaxOZBpwmZYP7mVbwAp2OteHhiola6eXd(NbqiO7WK0(J82uSOrx3I)0RSNkUQm05V6UUyX3e5WLWiglQE8Fw8sBLIfFiYuU(Dhtc9(6b6b7Ffh82RDCDx6(pyZmDScRKNI7BdwmcpzJv5Fmya)aSeSj8Z4IIV7AHHcQ83UiCZJc2fRkY8lU9ZrGLQHzDfzeF6f(7z)1XSVDHhOmh0pChvnvLiiN)3YyKNiENS9yRu7mN5l8q(tgLRtEcjXhVkRnh)QQIWEDw0TvRv54TPQQStIEZbcAC46P4fXEl2A1nB5E4OXueceUKywVeqOmg0wpJNDF1I3ux4v7oww3PS(GZ9R)f
```

### 8.13 Refresh reminder

Refresh a buff or DoT at the right moment (for example, a DoT you can refresh in its last seconds).

1. **New**, **Icon**, trigger **Aura** on your buff or DoT.
2. **Remaining Time** < 4 (or **Elapsed Time** >= a value).
3. Actions, On Show: a sound. Display: a **Glow**.

### 8.14 Boss timeline

A bar per boss ability, started at the pull.

1. Find the encounter ID: Wowhead, or print it from a test aura on `ENCOUNTER_START`.
2. **New**, **Progress Bar** per ability:
   - Trigger **Custom**, Event Type **Event**, Event(s) `ENCOUNTER_START`.
   - Custom Trigger:

     ```lua
     function(event, encounterID)
         return encounterID == 610 -- the boss encounter ID
     end
     ```

   - Hide: **Timed**, Duration: time of the first cast after the pull.
3. Load: **Encounter ID(s)** = the same ID, so a wipe clears the bars.

### 8.15 Aura per instance

Load tab, **Instance Type**: pick the exact dungeon or raid difficulty. **Instance Size Type**: 5 man, 10, 20 or
40 man raid. Use it to keep raid auras out of dungeons, and the other way around.

---

## 9. Custom code

Custom code runs in combat too. Two rules on Forever:

**1. Check values before using them.** A secret value cannot be compared or used in math:

```lua
if issecretvalue(value) then
    return false
end
```

Without this check, the code stops in combat. WeakAuras Forever catches the error: the aura keeps its last state.

**2. Use the modern functions.** `GetSpellInfo`, `GetSpellCooldown`, `UnitBuff`, `UnitDebuff` no longer exist.
Use `C_Spell.GetSpellInfo`, `C_Spell.GetSpellCooldown`, `C_UnitAuras.GetAuraDataBySpellName`,
`C_UnitAuras.GetAuraDataByAuraInstanceID`, `C_Item.GetItemCount`.

### Timer from your own cast

Your own casts are always readable. This Trigger State Updater starts a timer when you cast a spell, and removes it
when your target dies:

- Trigger **Custom**, Event Type **Trigger State Updater (Advanced)**
- Event(s): `UNIT_SPELLCAST_SUCCEEDED:player PLAYER_TARGET_DIED`

```lua
function(allstates, event, unit, castGUID, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if issecretvalue(spellID) or spellID ~= 348 then return false end -- your spell ID
        allstates[""] = {
            show = true,
            changed = true,
            progressType = "timed",
            duration = 15, -- the spell duration
            expirationTime = GetTime() + 15,
            autoHide = true,
        }
        return true
    elseif event == "PLAYER_TARGET_DIED" then
        local state = allstates[""]
        if state and state.show then
            state.show = false
            state.changed = true
            return true
        end
    end
    return false
end
```

Ready-made example (Immolate rank 1). Copy, then `/wa`, **Import**:

```
!WA:2!fsvqVTTnu4LEybqDOa1hkYrcVSIeuJGUS0GHb4drXYjgWDnq2EOddfUuIpjraksbskNKnSDWNAVMFc(8ozGUFa76Uiu0Fb7Nq)fmsk7SQKmmDq8P3337XhFFpQn63kVfPf5npCbnwWhjkLXWgVhxQZeYxuOPcUYBHesngJVSa8TSK4yhWHHknwQ9IsOCQkZZ3SO9MRL00uqQEWJLRm)dFTj2O4sLwKVSEzQ11stc0qzbX8oeMbCD0PaMPZ8lnPkQGHVeKZvfaJnGO8ICuuf7p57hmE6OZcgo84JgzSMC8Xbb9c69D1rGoB4r)yq40XhfEsW4P9ge0lKJZbL3FRkRtYOYKe6flNwhVH44RHotcgOqx6R(IlU3FLuYDh4DWmMRGvDqoMDq2YSdkgR0NmzqVoO6sT3UEiZdnPMgQBxu7)RsUnsNbCh)vXqvkiwc6zywjGWCstp7SEpCbImUlLCucMPaeWjFAMwXe9BDrFZbF7)d)RpC)u72Vc1f9lxJyFuzIZno1YsOtdG4mmpfi3jwHuKkbLYo5yi0wtZbs7MCiLsST5AW)6N1ecUOGwdo2eOHWjG2ATZUONClYMrwXPucCRc5xV2A1r3c78bMwqdn62Jn3qDyIymd5AtM9PrhRrF3rWQCoR9CnVgjY1s)xSU16XDa3S92GWnpoUJ0kbD96NQ2EgNliqKzY3kiYtdgEw)jdVQKV6AQxXdT3SNbJR)(5cc87F2hPCni5y2pyUtB0I3DfMtZDYYHvFE)3VwaDxOLMbvbNOQUVpxWH)eWkyKwc8uD2MZTFz36QT9ZXuE)Q2vFz19R2U6R2S6XMLnVPN2usXwdYZfmBd1o(ir70xinsMC3WZPeDgEjLNiK1fK3(LuYhtMToeZupghzQOeAQ3cBLrR)LwugqtZ04LeQY(pJbgSTUxR3opwiyeX58x7Zeys)inMzMoEuyEjtt98n3OIFu1bEHXmSszT8v0FgSgTurpBV93FVN2A2hE5)8d
```

### Tools

- `/dump <expression>` prints a value, secret values included.
- `/eventtrace` shows events and their values.
- There are no training dummies on Forever: test on any mob, or duel a friend.

---

## 10. Importing auras

### From Wago or a friend

`/wa`, **Import**, paste the string. Before using a pack made for Classic Era, Season of Discovery or Retail:

- replace combat log triggers (`CLEU`, "Combat Log"): the combat log is closed on Forever;
- replace spell names by spell IDs of your ranks;
- rewrite custom code that uses old functions (section 9).

### From ForeverAuras

Export your auras from ForeverAuras, disable it, then import the strings in WeakAuras Forever. They are converted
on import, and the chat lists anything that could not be converted.

| ForeverAuras | WeakAuras Forever |
| --- | --- |
| Cooldown Manager trigger, cooldown | Cooldown trigger |
| Cooldown Manager trigger, buff | Aura trigger, with the buff's spell IDs, stacks, remaining, elapsed and total filters |
| Cooldown Manager trigger, item | Item cooldown trigger |
| Aura (Blizzard) trigger | Aura trigger with Native Filter |
| Dispel type icon / border | Dispel Type Icon / Border colored by dispel type |
| Swing Timer, Ammo, Role, Tracking, Equipment Durability, Bag Space | Same triggers |

Not converted: TimelineParser triggers. Never run both addons at the same time.

---

## 11. Commands and troubleshooting

| Command | Does |
| --- | --- |
| `/wa` | Opens the options. |
| `/wa tutorial` | Opens the in-game tutorial. |
| `/wa cdm` | Shows or hides the Blizzard Cooldown Manager (out of combat). |
| `/wa minimap` | Shows or hides the minimap button. |
| `/wa pstart`, `/wa pstop`, `/wa pprint` | Profiling: find which aura costs the most. `/wa pstart combat` profiles the next combat. |
| `/wa repair` | Repairs a broken saved variables file. |

**My aura does not show.**

1. Check the **Load** tab: class, spec, in combat, group.
2. In the options, the aura list shows unloaded auras greyed out.
3. Check spell IDs: one per rank.
4. Try Show On **Always** to see if the trigger finds anything.

**My aura shows but its condition does not change in combat.** The condition uses a secret value: it updates when
combat ends. Use the display (bar, timer, `%p`, `%s`) for live information.

**My custom code errors.** Add the `issecretvalue` check (section 9), and replace old functions.

**My icon has no name in combat.** It is an aura hidden by the game, found by Native Filter: the name comes back
when combat ends.

**Performance.** Load auras only where you need them, and use `/wa pstart combat` then `/wa pprint` to find the
expensive ones.

Report a bug: https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/issues

---

## 12. Limits of the game

These come from the game, not from WeakAuras:

- **The combat log is closed.** Combat log triggers never fire. For damage taken, use the event
  `UNIT_COMBAT:player`; for your spells, `UNIT_SPELLCAST_SUCCEEDED:player`.
- **Logic on secret data waits for the end of combat.** Thresholds, comparisons and custom code on secret values
  keep their last result during combat.
- **Other players' casts** and enemy names are hidden in instances.
- **Auras hidden by the game** are only found by Native Filter, and have no name until combat ends.
- **Chat messages** can be blocked during encounters and PvP matches.
- **Nameplate addons** (Plater, ElvUI, Kui...) replace the Blizzard nameplates that "Group by Frame: Nameplates"
  attaches to.
