if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local DOT_TIMER_IMPORT = "!WA:2!fsvqVTTnu4LEybqDOa1hkYrcVSIeuJGUS0GHb4drXYjgWDnq2EOddfUuIpjraksbskNKnSDWNAVMFc(8ozGUFa76Uiu0Fb7Nq)fmsk7SQKmmDq8P3337XhFFpQn63kVfPf5npCbnwWhjkLXWgVhxQZeYxuOPcUYBHesngJVSa8TSK4yhWHHknwQ9IsOCQkZZ3SO9MRL00uqQEWJLRm)dFTj2O4sLwKVSEzQ11stc0qzbX8oeMbCD0PaMPZ8lnPkQGHVeKZvfaJnGO8ICuuf7p57hmE6OZcgo84JgzSMC8Xbb9c69D1rGoB4r)yq40XhfEsW4P9ge0lKJZbL3FRkRtYOYKe6flNwhVH44RHotcgOqx6R(IlU3FLuYDh4DWmMRGvDqoMDq2YSdkgR0NmzqVoO6sT3UEiZdnPMgQBxu7)RsUnsNbCh)vXqvkiwc6zywjGWCstp7SEpCbImUlLCucMPaeWjFAMwXe9BDrFZbF7)d)RpC)u72Vc1f9lxJyFuzIZno1YsOtdG4mmpfi3jwHuKkbLYo5yi0wtZbs7MCiLsST5AW)6N1ecUOGwdo2eOHWjG2ATZUONClYMrwXPucCRc5xV2A1r3c78bMwqdn62Jn3qDyIymd5AtM9PrhRrF3rWQCoR9CnVgjY1s)xSU16XDa3S92GWnpoUJ0kbD96NQ2EgNliqKzY3kiYtdgEw)jdVQKV6AQxXdT3SNbJR)(5cc87F2hPCni5y2pyUtB0I3DfMtZDYYHvFE)3VwaDxOLMbvbNOQUVpxWH)eWkyKwc8uD2MZTFz36QT9ZXuE)Q2vFz19R2U6R2S6XMLnVPN2usXwdYZfmBd1o(ir70xinsMC3WZPeDgEjLNiK1fK3(LuYhtMToeZupghzQOeAQ3cBLrR)LwugqtZ04LeQY(pJbgSTUxR3opwiyeX58x7Zeys)inMzMoEuyEjtt98n3OIFu1bEHXmSszT8v0FgSgTurpBV93FVN2A2hE5)8d"
local PREPULL_IMPORT = "!WA:2!nxzZUTTrxyy7206e2uxh628RtlB7xvtw0urkjkj30cy6iLyu)lLBcqakSgsouCQPijMzOCCa6gJIaJU0l)wQ1DLbYnGVcoWxc9sWxb9mucoUjObbDrqxOxnZHCgEMN3zoZKpu3)X7pJtCkjyWH5c6wSKE808Si(4gx2TFESKvYTOxxhoHf01tsIPjYldNtZ1pMieQwdvd3pTVhrg5iYO(QGoc2tPQgNWsKuEcj(HuUGLM88Hm)0KoP5CF6CtCajH1NiX42UcjHlBFCqoViWwYDZWHqX3oq4O64KKMqpIse0osonPNmAQ9u92eFgmRtFclPnmdCjqhMf(4PGpbM1lKLWerVC4Jj5YOu(AzQpKq7qwsykFuEO5LrWjxMn36C63KLhhB4hr93oMjKg3QDkNoGYVT7oSaz0gd50E4yujGJAz5H)cz90(cwqM(kmHaH58g4GKmzEa1kNfCs4aCIvZRkCztVikRxKCJHQ1jBu(Wj(fnSHpsdUIMdUgKA7j5SE9qImDj(4Mp7iccle5XXSaXV7yAvTIsQQKAow1BA6AwUzL6fAdxlZA2wfAvq3vnwRduAcPpvODc6JTEc(P7OMWLc6YXaRIpk6yenieeDIs3zTKJff)nE5nmG6LhgQqa)bTwE92)0Yo5y(6Lft2LYpipzCYQLDj1YAaDZr9xjnG(htS)mWKdG3jcExCZsj496cVFxyk1gh48f6fIaTIgFqHEXNdF4CtatJO5Lnv4YVsKR8krUQgCnn46WnG52aUj8PWNvywx7uZAfcFBJ0qdze14rS4a4ZFHJTsQCNYMWxUb8)0GVAS7aL0GVE6sWTEgC7)VJPPLTtnRkwo21Rv0QQtJMLR70SrJQkPgY)gvBQ0ALXmZcQObv7c1IaBOo0aAcZdFhCxn47)piDwG7tsOglHNPJJP(YZsNfWOVw68loMvR1ef7YkrT3e3kwO1DTQu2QXBcpcpOOEJQ6ZPSOKNk9IP8hTG7YRT4p(2dn34u0CpA)0eJoBZsm(wKt9t5Nfo3dJ8AHZtTSBu3YUPTv9Y2oMLBGGXSELkfA1cT2BeEGnEbwaxOZBpwmZYP7mVbwAp2OteHhiola6eXd(NbqiO7WK0(J82uSOrx3I)0RSNkUQm05V6UUyX3e5WLWiglQE8Fw8sBLIfFiYuU(Dhtc9(6b6b7Ffh82RDCDx6(pyZmDScRKNI7BdwmcpzJv5Fmya)aSeSj8Z4IIV7AHHcQ83UiCZJc2fRkY8lU9ZrGLQHzDfzeF6f(7z)1XSVDHhOmh0pChvnvLiiN)3YyKNiENS9yRu7mN5l8q(tgLRtEcjXhVkRnh)QQIWEDw0TvRv54TPQQStIEZbcAC46P4fXEl2A1nB5E4OXueceUKywVeqOmg0wpJNDF1I3ux4v7oww3PS(GZ9R)f"

local blocks = {
  { title = "How an aura works" },
  { text = "An aura is something WeakAuras shows on your screen: an icon, a bar, a text or a texture. "
    .. "In the options (|cffffd100/wa|r), every aura has these tabs:\n\n"
    .. "|cffffd100Display|r: what it looks like (icon, size, colors, texts).\n"
    .. "|cffffd100Trigger|r: when it shows (a buff, a cooldown, a cast, an item count, a game event).\n"
    .. "|cffffd100Conditions|r: what changes while it is shown, for example red under 3 seconds.\n"
    .. "|cffffd100Actions|r: a sound, a glow or a chat message when it shows or hides.\n"
    .. "|cffffd100Load|r: when WeakAuras looks at it at all (class, in combat, in a group, zone)." },
  { title = "Create your first aura" },
  { text = "1. Type |cffffd100/wa|r and click |cffffd100New|r.\n"
    .. "2. Pick a display type: Icon, Progress Bar, Text or Texture.\n"
    .. "3. Fill in the Trigger tab.\n"
    .. "4. Set the Load tab, so the aura only loads when it is useful.\n"
    .. "5. Close the options and test on any mob: there are no training dummies on WoW Forever." },
  { title = "What is different on WoW Forever" },
  { text = "WoW Forever runs on the modern game engine. During combat, boss encounters and PvP matches, "
    .. "the game hides most combat data from addons: buffs, debuffs, cooldowns and other players' casts.\n\n"
    .. "- The game still draws timers, bars, and texts set to only %p or %s. Conditions and thresholds on hidden data "
    .. "keep their last state, and update when combat ends.\n"
    .. "- Your own casts stay readable in combat. Build auras on them.\n"
    .. "- The combat log is closed: combat log triggers never fire.\n"
    .. "- Type spell IDs, not spell names. Every rank has its own ID. Out of combat: "
    .. "|cffffd100/dump C_Spell.GetSpellInfo(\"Immolate\")|r\n\n"
    .. "So: prepare before the pull, or deduce from what you do. The two examples below do exactly that." },
  { title = "Example 1: DoT timer from your own cast" },
  { text = "|cffffd100What it does:|r shows an Immolate icon with a 15 second timer when you cast "
    .. "Immolate rank 1 (spell ID 348). Casting again restarts the timer. The timer hides when your target dies.\n\n"
    .. "|cffffd100How it works:|r the debuff on your target is hidden in combat, but your own cast is not. "
    .. "The trigger is Custom, Trigger State Updater. It listens to |cffffd100UNIT_SPELLCAST_SUCCEEDED:player|r "
    .. "and |cffffd100PLAYER_TARGET_DIED|r. When the cast ID is 348, it starts a 15 second timer. "
    .. "When your target dies, it hides the icon. The code first checks |cffffd100issecretvalue(spellID)|r, "
    .. "so it never errors on hidden data.\n\n"
    .. "|cffffd100Adapt it:|r open the aura, Trigger tab, Custom Trigger. Replace 348 with your spell ID and "
    .. "15 with the spell duration (twice). Set the icon in the Display tab.\n\n"
    .. "|cffffd100Limits:|r one aura per spell, one target. It does not know if the spell was resisted or "
    .. "dispelled. If you change target and the other mob dies, the timer keeps running." },
  { import = DOT_TIMER_IMPORT, label = "Import the DoT timer" },
  { title = "Example 2: pre-pull checklist" },
  { text = "|cffffd100What it does:|r a row of icons above your character that shows only what is missing, "
    .. "before the pull:\n"
    .. "- Fortitude, Mark of the Wild, Arcane Intellect: when the buff is missing, in a party or raid.\n"
    .. "- Demon Skin / Demon Armor: when neither is active (Warlock only).\n"
    .. "- Soul Shards: when you have fewer than 3 (Warlock only).\n\n"
    .. "|cffffd100How it works:|r it is a Dynamic Group, so visible icons line up by themselves. "
    .. "Buff icons use an Aura trigger on the player, Show On: Aura(s) Missing, with the spell IDs of every rank. "
    .. "The Soul Shard icon uses an Item Count trigger, item 6265, count lower than 3. "
    .. "In the Load tab, In Combat is set to \"not in combat\": the checklist never needs hidden combat data.\n\n"
    .. "|cffffd100Adapt it:|r select an icon, then change its spell IDs, its item, or the class in the Load tab. "
    .. "Copy an icon (right click, Duplicate) to add a check: Blessings, flask, food, poisons, ammo." },
  { import = PREPULL_IMPORT, label = "Import the checklist" },
  { title = "More" },
  { text = "Full guide with more recipes (boss timers, custom code): TUTORIAL.md on "
    .. "github.com/dldvlpr-addons-wow/WeakAuras-Forever\n\n"
    .. "Open this window again with |cffffd100/wa tutorial|r." },
}

local frame

local function CreateTutorialFrame()
  frame = CreateFrame("Frame", "WeakAurasForeverTutorial", UIParent, "BackdropTemplate")
  frame:SetSize(560, 520)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
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
  header:SetText("|cff00ccffWeakAuras Forever|r - Tutorial")

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)

  local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 20, -50)
  scroll:SetPoint("BOTTOMRIGHT", -40, 20)

  local width = 490
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
    if block.title then
      local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
      title:SetWidth(width)
      title:SetJustifyH("LEFT")
      title:SetText(block.title)
      place(title, 16)
      height = height + 16 + title:GetStringHeight()
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
      button:SetSize(200, 24)
      button:SetText(block.label)
      button:SetScript("OnClick", function()
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
end
