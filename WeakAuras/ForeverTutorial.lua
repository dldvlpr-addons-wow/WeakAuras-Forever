if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local blocks = {
  { text = "|cffffd100Everything you need to learn WeakAuras on WoW Forever:|r how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import.\n\nOpen this guide again with the |cffffd100Guide|r button at the top of the |cffffd100/wa|r window, or with |cffffd100/wa tutorial|r." },
  { text = "How WeakAuras works on WoW Forever, and how to build auras that keep working in combat.\n\nWoW Forever looks like Classic, but it runs on the modern 12.1 game engine. This engine hides most combat data from addons. This guide explains what that changes and gives step-by-step recipes.\n\nSection 3 says what was tested in game on Forever, and what was not. When you are not sure, test in game." },
  { title = "1. WeakAuras in 2 minutes" },
  { text = "An aura is something WeakAuras shows on your screen: an icon, a bar, a text or a texture. Every aura has 4 parts, one per tab in the options:\n\n- |cffffd100Display|r: What it looks like: icon, size, colors, text.\n- |cffffd100Trigger|r: When it shows: a buff, a cooldown, a cast, an item count, a game event.\n- |cffffd100Conditions|r: What changes while it is shown, for example red when less than 3 seconds remain.\n- |cffffd100Load|r: When WeakAuras even looks at it: class, in combat, in a group, zone.\n\nThe |cffffd100Actions|r tab adds a sound, a chat message or a glow when the aura shows or hides.\n\nBasic steps:\n\n1. Type |cff99ccff/wa|r.\n2. Click |cffffd100New|r, then choose a display type: |cffffd100Icon|r, |cffffd100Progress Bar|r, |cffffd100Text|r or |cffffd100Texture|r.\n3. Fill in the |cffffd100Trigger|r tab.\n4. Set the |cffffd100Load|r tab, so the aura only loads when it is useful.\n5. Close the options and test." },
  { title = "2. What changed on Forever" },
  { subtitle = "Secret values" },
  { text = "During combat, boss encounters and PvP matches, the game gives addons \"secret\" values: WeakAuras receives the data but cannot read it, compare it or do math with it. Out of combat, almost everything works like before.\n\nWhat that means for your auras, tested in game on Forever unless marked otherwise:\n\n- |cffffd100The game draws what WeakAuras cannot read.|r Cooldown swipes and numbers, timer bars, and health or power bars keep moving in combat. A text made only of |cff99ccff%p|r and |cff99ccff%t|r (for example |cff99ccff%p|r or |cff99ccff%p / %t|r) is drawn by the game too, as a raw number.\n- |cffffd100Buffs and debuffs are refused to addons in combat.|r An aura that was showing before the pull keeps counting down from its last known time. Its stacks stay frozen. Everything is read again when combat ends.\n- |cffffd100Your own recast restarts the timer.|r When you cast again a buff that you put on yourself, the timer of an Aura trigger on the Player unit restarts from its last known duration, even if this cast went to someone else. A recast by someone else is not seen.\n- |cffffd100A buff or debuff applied for the first time in combat|r is only seen when combat ends.\n- |cffffd100Logic on secret data keeps its last state.|r A condition such as \"Health < 50%\" keeps the state it had when combat started, then updates when combat ends. Not tested again since the last fix." },
  { subtitle = "The combat log is closed" },
  { text = "Triggers that use the combat log (|cff99ccffCLEU|r, \"Combat Log\") never fire. For damage taken, use the event |cff99ccffUNIT_COMBAT:player|r." },
  { subtitle = "Other changes" },
  { text = "- |cffffd100Spells by ID.|r Name search in the options may not find spells. Type the spell ID. Get the ID of your rank out of combat: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Classic spells have one ID per rank.\n- |cffffd100Talent load options|r are empty. Use the |cffffd100Class and Specialization|r load option instead.\n- |cffffd100Chat Message action|r can be blocked during encounters and PvP matches.\n- |cffffd100Old functions in custom code|r no longer exist (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Use |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Blizzard Cooldown Manager.|r |cff99ccff/wa cdm|r shows or hides it, out of combat. On the Forever beta it is not enabled for every class: for some classes it has no spell and no buff, and the \"From the Cooldown Manager\" lists of the Cooldown and Aura triggers are empty." },
  { title = "3. What you can use" },
  { text = "|cffffd100Tested in game, works in combat:|r\n\n- Spell cooldowns: icon swipe and number. With |cffffd100Show Global Cooldown|r, the \"On Global Cooldown\" condition can hide the number during the global cooldown.\n- Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.\n- Health bar of your target and power bar of yourself, with a |cff99ccff%p / %t|r text.\n- Swing timer, main hand.\n- Your own casts: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (see the recipes below).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Tested in game:|r\n\n- Temporary weapon enchants (poison, oil, sharpening stone), both hands.\n- |cffffd100Elapsed Time|r filter of the Aura trigger.\n- Bag Space trigger.\n- Role trigger (role chosen in the group finder).\n- |cff99ccff/wa cdm|r, and the \"From the Cooldown Manager\" lists, for the classes that have it.\n\n|cffffd100Works, with limits:|r\n\n- Stacks stay frozen in combat.\n- Conditions and filters on percentages, stacks or remaining time use the value from before combat.\n- A filter checked in the trigger itself (for example \"Health (%) < 50\") freezes the trigger in combat instead of hiding the aura.\n\n|cffffd100Not tested in game yet:|r\n\n- Swing timer off hand, ranged and wand, \"Target In Range\" option.\n- Ammo trigger, Equipment Durability, Tracking, instance difficulty load option.\n- Border and icon colored by dispel type.\n- Aura triggers in party or raid mode, glows, range conditions.\n- Encounter start and end: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Does not work:|r\n\n- Aura trigger filtered by |cffffd100Native Filter|r (crowd control, cast by me...): nothing shows at the moment.\n- Other players' casts.\n- Enemy names and IDs in instances.\n- Low mana alert, mana or energy tick timer in combat.\n- Combat log triggers." },
  { title = "4. New way of thinking: prepare or deduce" },
  { text = "Stop reading the combat. |cffffd100Prepare|r before the pull, or |cffffd100deduce|r from what you do.\n\n- Debuff on target, show its timer: You cast the DoT, start a fixed timer\n- Buff missing in combat, alert: Check buffs and consumables before the pull\n- Boss casts X, alert: Boss timeline from the pull (|cff99ccffENCOUNTER_START|r)\n- Cooldown ready, flash: Let the action bar show the cooldown\n- Low mana, alert: Show the mana bar, no logic on it\n\nFor debuffs on enemies, the Blizzard nameplates and target frame can show them (\"only my debuffs\"). Use them for what only the game can see." },
  { title = "5. Recipe: DoT or buff timer from your cast" },
  { text = "Not tested in game yet. No custom code. Example: Corruption on your target.\n\n1. Out of combat, get the ID of your rank: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Note the |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Icon|r (or |cffffd100Progress Bar|r).\n3. |cffffd100Trigger|r tab:\n    - Type: |cffffd100Other Events|r, then |cffffd100Spell Cast Succeeded|r\n    - Caster Unit: |cffffd100Player|r\n    - |cffffd100Exact Spell ID(s)|r: your spell ID (for example 11672)\n    - |cffffd100Hide when target dies|r: checked\n    - |cffffd100Hide After|r, Duration: the spell duration from its tooltip (Corruption: 18)\n4. Test on any mob.\n\nThe trigger gives the icon of the spell.\n\nLimits: one aura per spell. Casting again restarts the timer. The aura does not know if the spell was resisted or dispelled. It follows one target only.\n\n|cffffd100Hide when target dies|r only sees the death of your current target. If you change target and the mob with your DoT dies, the timer keeps running. If you change target and the new target dies, the timer is hidden. For a buff on yourself, leave the box unchecked.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below." },
  { import = "!WA:2!DjvVUrnqq4afePniKIfefHO40ricAIGJKiAJdXIt6q5KTbr3DR9o2EKS31A)5cHsxbT5r4QP6AONNGvriEa4ripbS7DxOGQ9BN1Z89Z47ef0eWcyFD75yUGNimYC4jBCn1OReYZB1OGRiZLqPdKEzle6)mjnF5dhhR0uPMKvGCuvrcDhAsNwILLGu9G9LRH)ou76ngMbCTu1c11dzpEWRp8n)rzYwwnXuuGFEXKtpjjDss6jXPDmJK6PP)RoYE)2hM4BR3PuLUxIjphagWcnocZARPxcYfgfmz9SN2TgOiXCAdOi)JOXsWruCY4ZgnQZ3IFetBFKhwHm4CEkvwc63cuD105miZPmVZLV7SrJJ(WORm81UI0UTpiMbPRU)Ebd((g3GCni506p6IaN8)Xvuo2S0jhBVx013ARj(irQaxEYu2Tc5co8tGQGeTe4L6Qn7838uB3lSHI8iBF7tTBz3Z(SnT77o28)R0hzT7oSPrut1qpn2aYEppsiDox(I4lqMUIUa5fc5kbrgyq2nfZUTf3gHsZCkQaljZ9kdx9hqwfGLvA6cgQ8X9q3B7E3GV1Lle1mXf8PH1cklkttRDH8oXnMAnscDRH8DShsIZRPkLhfQWVaEqGk7Odgm4Gxgm7xF6V)", label = "Import the DoT timer" },
  { subtitle = "Variant: one timer per mob, on its nameplate" },
  { text = "Tested in game on Forever. Each mob you cast the spell on gets its own icon and timer, above its nameplate.\n\n|cffffd100Only with the default Blizzard nameplates.|r Addons that replace the nameplates (EllesmereUI, ElvUI, Plater, Kui, etc.) hide the Blizzard health bar this aura attaches to: the icons then show nowhere, or at random places. The game does not let addons measure or attach to protected nameplate regions, so this cannot be fixed on the WeakAuras side. With a nameplate addon, use the single timer above.\n\nEnemy nameplates must be shown (key |cffffd100V|r).\n\nHow it works:\n\n- The aura is a |cffffd100Dynamic Group|r with |cffffd100Group by Frame|r set to |cffffd100Nameplates|r, and one icon inside.\n- The icon uses a |cffffd100Trigger State Updater|r on |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- When you cast the spell, the code looks for the nameplate of your target: it tests |cff99ccffnameplate1|r to |cff99ccffnameplate40|r with |cff99ccffUnitIsUnit(token, \"target\")|r, which stays readable in combat. It starts a timer for that nameplate and stores the nameplate in the state (|cff99ccffunit = token|r), so the group puts the icon on it.\n- When a nameplate disappears (the mob died or went out of range), its timer is removed.\n\nLimits: a timer is lost when the nameplate disappears, for example when you move away from the mob. The aura does not know if the spell was resisted or dispelled.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below." },
  { import = "!WA:2!nwv3UXrTxCcuOTMac2kvAccWD)tRskllPH2Q2k1lYS7SjlkFSA2nvcHqB9mJNDT6S2JS9KpavUixvUnxWdqUMB(hP(c0NaR8O0Nao2ZUPzs3cDUWJ95C85ZFNJN5XvIM)5x5iwKG3vKlJOZeMrKuUod3E0irkrtXcoMtgrZShu4fAjK0DOYfpsshWe8E7Nr9S3xsI0Wz19cuAIuJctyCMAiYd(PrhOLSbdOs1NEt54T)LNgUByuUslgDCXV(wshdkqtZZIH1aWwCD4AusQEOxoOQqWr2NkdDmuz)02B2Ux)UD8xF9gR0f2TDJg((n9B(Wc5WBUYg(97S(k9877enWFJTESFtmq6N9d63BLGv971VzB)MhOYOPPTJvOaBaRqMpzVl8)tY5UaBbsAQZXu1WoBxdxVE9fry4lversXtKedX)aQUJnHTqHa2VeHeZWpcF7A47SeowCkJxRbT4Puois1tt4vbJGzLeLLG3gYd(7XuA1cURSiMWJDuBRSRfuRHRw4jvxeRhs5L0I9ts15sEHvlXKYJrNF)K)G5DHp(rGF(2s(vlBWIOZw9QHJik9QB3UznCr6UjeVqIeDMWJPu0iW52HKMtDHwjklm(Ifr1KOiHKQOL8CqttmXF8i8pEN7)FiF5AW0lIGo5c9yH(3v3P4LFXj9Vc683lLLvdf7AnKmNwReJOHe(aA8u5LjfdKuLY23zrkA2iAC1YYeNljoGia2UBzw09Yyfm7bxeeyvQ2UBHfXF3BimjxlwJftNQJyRMwgoK2PCEg68Gl4If4hi)uc78wAmRIH(Kxl1B2MovS1KQ27G6T4jaWznZ0RXfA0v7MeGUlD(cAjGMt63OlZrU(4cTdImf2Ll3OP1HEw6NVH8Saqeq8OyAyEsIfGixZF9oT2E9dZ5Jh6IY(C7C6DO9koVHiM(3V3RyCnvYjPpgMqdyJxCiHZg5Gj3ZCXwNmbq5gplHwrbpwzM1Jl40xsjkAxn8OXa9WlEG9K10MR7nIW4TmFJbBM1CDt1lA(FWVlDEkvzXzx70hBoDWh2cSLhejePXID5p54yMYorVny7R9(v(ZGDzX6Hp4eaJoui3kZ92dA5Cw8Rs2XQoxvfA6jEPcsCRqnjfGgxnyuEQMH8Gjdrx1uhfeLsuk7opf73O2nhPYddCpUPU1vnZEcCmKe90bsrop(EMzLabnDp9H2L(2LQ3i7e3Hebx3fuZCHdPSbd1p4iBQIv4ChZ4WBafPvuiWiHnavzuL4kXpFopq97ge0E116Lvb4PLI0uACJHS0yi3oV5gMfrY93kjrr1x2CHxgVpKRyrwVk7ecpcYcDOs70)dTqFhYp7ZYv0volVNy(iOIImxczUmYGM)MMpULPI5kMzdiqrEzZCM5nFbY8Li5Ef2AgZx9Idv00KocaLe6TvVEBTH5RT4IZxB)23PQT5doES7Av4Y92QtajLnGh2WFZE(bVQGzljGeSaPWUnc893uc9kwa7mMBD2c8QYSBhOYir0p0tjKAWq1Az(EBz08dU1LCR32TEFK5biZdrvuH3T(YlxFPk7CHN9pp", label = "Import the nameplate DoT timer" },
  { title = "6. Recipe: pre-pull checklist" },
  { text = "The idea: one group of icons that shows what is missing, only out of combat and in a group.\n\n1. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Dynamic Group|r. Name it \"Pre-pull\".\n2. In the group, |cffffd100Load|r tab: |cffffd100In Combat|r unchecked twice (the box shows a cross = \"not in combat\"), |cffffd100In Group|r checked.\n3. Add one icon per check, inside the group.\n\n|cffffd100Missing buff|r (Power Word: Fortitude, Mark of the Wild, Arcane Intellect, Blessings, Thorns, flask, food):\n\n- Trigger type: |cffffd100Aura|r\n- Unit: |cffffd100Player|r, Type: |cffffd100Buff|r\n- Aura name or spell ID: the buff. For buffs with ranks, add every rank you want to accept.\n- Show On: |cffffd100Aura(s) Missing|r\n\n|cffffd100Weapon enchant|r (poison, oil, stone): trigger |cffffd100Weapon Enchant|r, show when missing.\n\n|cffffd100Reagents and ammo|r (Soul Shards, arrows, Symbol of Kings...):\n\n- Trigger type: |cffffd100Item|r, |cffffd100Item Count|r\n- Item: the item ID\n- Count: lower than the number you want, for example |cff99ccff< 5|r\n\nBecause the group only loads out of combat, secret data never matters here.\n\nReady-made example for a Warlock (tested in game on Forever). Click the import button below.\n\n- Fortitude: the buff is missing (every rank, Prayer of Fortitude included) (in a party or raid)\n- Mark of the Wild: the buff is missing (every rank, Gift of the Wild included) (in a party or raid)\n- Arcane Intellect: the buff is missing (every rank, Arcane Brilliance included) (in a party or raid)\n- Demon Skin / Armor: neither Demon Skin nor Demon Armor is active (Warlock, solo included)\n- Soul Shards: fewer than 3 Soul Shards (item 6265) in your bags (Warlock, solo included)\n\nNone of them loads in combat. Buffs are matched by spell ID, so the group works with any client language. The IDs come from Classic 1.12 data: if an icon stays visible while you have the buff, report it." },
  { import = "!WA:2!nxzZUTTrxyy7206e2uxh628RtlB7xvtw0urkjkj30cy6iLyu)lLBcqakSgsouCQPijMzOCCa6gJIaJU0l)wQ1DLbYnGVcoWxc9sWxb9mucoUjObbDrqxOxnZHCgEMN3zoZKpu3)X7pJtCkjyWH5c6wSKE808Si(4gx2TFESKvYTOxxhoHf01tsIPjYldNtZ1pMieQwdvd3pTVhrg5iYO(QGoc2tPQgNWsKuEcj(HuUGLM88Hm)0KoP5CF6CtCajH1NiX42UcjHlBFCqoViWwYDZWHqX3oq4O64KKMqpIse0osonPNmAQ9u92eFgmRtFclPnmdCjqhMf(4PGpbM1lKLWerVC4Jj5YOu(AzQpKq7qwsykFuEO5LrWjxMn36C63KLhhB4hr93oMjKg3QDkNoGYVT7oSaz0gd50E4yujGJAz5H)cz90(cwqM(kmHaH58g4GKmzEa1kNfCs4aCIvZRkCztVikRxKCJHQ1jBu(Wj(fnSHpsdUIMdUgKA7j5SE9qImDj(4Mp7iccle5XXSaXV7yAvTIsQQKAow1BA6AwUzL6fAdxlZA2wfAvq3vnwRduAcPpvODc6JTEc(P7OMWLc6YXaRIpk6yenieeDIs3zTKJff)nE5nmG6LhgQqa)bTwE92)0Yo5y(6Lft2LYpipzCYQLDj1YAaDZr9xjnG(htS)mWKdG3jcExCZsj496cVFxyk1gh48f6fIaTIgFqHEXNdF4CtatJO5Lnv4YVsKR8krUQgCnn46WnG52aUj8PWNvywx7uZAfcFBJ0qdze14rS4a4ZFHJTsQCNYMWxUb8)0GVAS7aL0GVE6sWTEgC7)VJPPLTtnRkwo21Rv0QQtJMLR70SrJQkPgY)gvBQ0ALXmZcQObv7c1IaBOo0aAcZdFhCxn47)piDwG7tsOglHNPJJP(YZsNfWOVw68loMvR1ef7YkrT3e3kwO1DTQu2QXBcpcpOOEJQ6ZPSOKNk9IP8hTG7YRT4p(2dn34u0CpA)0eJoBZsm(wKt9t5Nfo3dJ8AHZtTSBu3YUPTv9Y2oMLBGGXSELkfA1cT2BeEGnEbwaxOZBpwmZYP7mVbwAp2OteHhiola6eXd(NbqiO7WK0(J82uSOrx3I)0RSNkUQm05V6UUyX3e5WLWiglQE8Fw8sBLIfFiYuU(Dhtc9(6b6b7Ffh82RDCDx6(pyZmDScRKNI7BdwmcpzJv5Fmya)aSeSj8Z4IIV7AHHcQ83UiCZJc2fRkY8lU9ZrGLQHzDfzeF6f(7z)1XSVDHhOmh0pChvnvLiiN)3YyKNiENS9yRu7mN5l8q(tgLRtEcjXhVkRnh)QQIWEDw0TvRv54TPQQStIEZbcAC46P4fXEl2A1nB5E4OXueceUKywVeqOmg0wpJNDF1I3ux4v7oww3PS(GZ9R)f", label = "Import the pre-pull checklist" },
  { title = "7. Recipe: boss timeline" },
  { text = "Not tested in game yet.\n\n1. Find the encounter ID. Out of combat, create a test aura on |cff99ccffENCOUNTER_START|r and print the ID, or search it on Wowhead.\n2. For each boss ability, create a |cffffd100Progress Bar|r:\n    - Trigger type: |cffffd100Custom|r, Event Type: |cffffd100Event|r\n    - Event(s): |cff99ccffENCOUNTER_START|r\n    - Custom Trigger:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- replace with the boss encounter ID|r\n|cff99ccff    end|r\n\n    - Hide: |cffffd100Timed|r, Duration: the time of the first cast after the pull, in seconds.\n3. |cffffd100Load|r tab: |cffffd100Encounter ID(s)|r = the same ID. The aura unloads when the encounter ends, so a wipe does not leave the bar on screen.\n4. If a readable event marks a new phase (an emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), use it to restart the timers.\n\nAbilities based on boss health % or on random timings cannot be predicted." },
  { title = "8. Custom code" },
  { text = "In custom code, check every value before you compare it or do math with it:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nWithout this check, the code stops with a Lua error in combat. WeakAuras Forever does not show those errors: the aura just keeps its last state.\n\nIn combat, the |cff99ccffC_UnitAuras|r functions refuse addon code when auras are secret. They stop the code with \"Auras cannot be accessed when secret while tainted\" (tested in game): call them under |cff99ccffpcall|r, or only out of combat.\n\nFor health events, use |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r does not exist on Forever.\n\nOther tools:\n\n- |cff99ccff/dump <expression>|r shows the content of a value in chat, secret values included.\n- |cff99ccff/eventtrace|r shows events and which of their values are secret.\n- There are no training dummies on Forever. Test in real combat: pull any mob or duel a friend." },
  { title = "9. Importing auras from Wago" },
  { text = "Most packs made for Classic Era, Season of Discovery or Retail need work:\n\n- replace combat log triggers (section 5 for DoTs, |cff99ccffUNIT_COMBAT:player|r for damage taken);\n- replace spell names by the spell IDs of your ranks;\n- rewrite custom code that calls old functions;\n- move buff and consumable checks out of combat (section 6).\n\nFound an aura that should work and does not? Report it: https://github.com/dldvlpr-addons-wow/WeakAuras-Forever/issues" },
  { title = "10. Coming from ForeverAuras" },
  { text = "Export your auras from ForeverAuras, then paste the strings in the WeakAuras import window. Groups work too. WeakAuras Forever converts them on import, and lists in the chat what it could not convert.\n\n- Cooldown Manager trigger, cooldown: Cooldown trigger (spell ID, or name if ForeverAuras used names)\n- Cooldown Manager trigger, buff: Aura trigger (your buffs, or your debuffs on the target)\n- Cooldown Manager trigger, item: Item cooldown trigger\n- Aura (Blizzard) trigger: Aura trigger with Native Filter (sorting removed). The Native Filter shows nothing at the moment.\n- Dispel type icon: Dispel Type Icon sub element\n- Dispel type border: Border colored by dispel type\n- Swing Timer, Ammo: Same triggers (Ammo: the item list now filters the equipped ammo)\n- Role, Tracking, Equipment Durability, Bag Space: Same triggers (Tracking: by spell ID only, no \"always\" mode)\n\nNot converted: TimelineParser triggers (they need the ExRT_Reminder addon and a boss timeline, which WoW Forever does not show). A Cooldown Manager cooldown trigger with several spells keeps the first one. Do not run both addons at the same time." },
}

local frame

local function CreateTutorialFrame()
  frame = CreateFrame("Frame", "WeakAurasForeverTutorial", UIParent, "BackdropTemplate")
  frame:SetSize(700, 600)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:SetClampedToScreen(true)
  frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  tinsert(UISpecialFrames, "WeakAurasForeverTutorial")

  local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  header:SetPoint("TOP", 0, -20)
  header:SetText("|cff00ccffWeakAuras Forever|r - Guide")

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)

  local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 20, -50)
  scroll:SetPoint("BOTTOMRIGHT", -40, 20)

  local width = 630
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(width)
  scroll:SetScrollChild(content)

  local previous
  local height = 0
  local function place(region, spacing)
    if previous then
      region:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -spacing)
    else
      region:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    end
    previous = region
  end

  for _, block in ipairs(blocks) do
    if block.title or block.subtitle then
      local spacing = block.title and 20 or 12
      local title = content:CreateFontString(nil, "OVERLAY", block.title and "GameFontNormalLarge" or "GameFontNormal")
      title:SetWidth(width)
      title:SetJustifyH("LEFT")
      title:SetText(block.title or block.subtitle)
      place(title, spacing)
      height = height + spacing + title:GetStringHeight()
    elseif block.text then
      local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      text:SetWidth(width)
      text:SetJustifyH("LEFT")
      text:SetSpacing(2)
      text:SetText(block.text)
      place(text, 6)
      height = height + 6 + text:GetStringHeight()
    elseif block.import then
      local button = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
      button:SetSize(260, 24)
      button:SetText(block.label)
      button:SetScript("OnClick", function()
        frame:Hide()
        WeakAuras.Import(block.import)
      end)
      place(button, 10)
      height = height + 10 + 24
    end
  end
  content:SetHeight(height + 10)
end

function Private.ShowForeverTutorial()
  if not frame then
    CreateTutorialFrame()
  end
  frame:Show()
  frame:Raise()
end
