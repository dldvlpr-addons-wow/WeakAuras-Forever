if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay

Display.singleUnits = {player = true, target = true, focus = true, pet = true, targettarget = true, focustarget = true}
function Display.IsSingleUnit(trigger)
  if type(trigger) ~= "table" then return false end
  if trigger.unit == "member" then return Display.SpecificUnit(trigger) ~= nil end
  return Display.singleUnits[trigger.unit] == true
end
Display.showOnValues = {showOnActive = "Aura(s) Found", showOnMissing = "Aura(s) Missing", showAlways = "Always"}
Display.remOperators = {["<"] = "<", ["<="] = "<=", [">"] = ">", [">="] = ">="}

local MISSING_GROUP = "FAMissing"
local SLOT_ICON = "FARemainIcon"
local REMAIN_EPS = 0.001
local TEXCOORD_UNITS = 1024

function Display.RawShowOn(trigger)
  local value = type(trigger) == "table" and trigger.secretShowOn
  return Display.showOnValues[value] and value or "showOnActive"
end

Display.ShowOn = Display.RawShowOn

local function UsesRemaining(trigger)
  return type(trigger) == "table" and trigger.secretUseRem == true and Display.ShowOn(trigger) == "showOnActive"
end

function Display.IsSingle(trigger, data)
  if Display.ShowOn(trigger) ~= "showOnActive" then return true end
  return UsesRemaining(trigger) and not (data and data.regionType ~= "icon")
end

function Display.RemainingWindow(trigger)
  if not UsesRemaining(trigger) then return end
  local op, x = trigger.secretRemOperator or "<", tonumber(trigger.secretRem)
  if not Display.remOperators[op] or not x or x ~= x or x < 0 or x == math.huge then return end
  return op, x
end

function Display.InRemainingWindow(value, op, x)
  if op == "<" then return value < x
  elseif op == "<=" then return value <= x
  elseif op == ">" then return value > x end
  return value >= x
end

function Display.RemainingWindowPoints(_, x)
  return {x, x + REMAIN_EPS}
end

local missingTypes = {icon = true, aurabar = true, progresstexture = true, text = true}
Display.missingTypes = missingTypes

local function NeedsMissing(trigger)
  local showOn = Display.ShowOn(trigger)
  return showOn == "showOnMissing" or showOn == "showAlways"
end

local function DrawsOne(data)
  return Display.IsSingle(Display.GetTrigger(data), data)
end
Display.DrawsOne = DrawsOne

function Display.Growth(data)
  local flowGrowth = Display.FlowGrowth(data)
  if flowGrowth then return Display.VisibleGrowth(flowGrowth) end
  if DrawsOne(data) then return "RIGHT" end
  return data.blizzardAuraDisplay and data.blizzardAuraDisplay.growth or "RIGHT"
end

function Display.MaxAuras(data)
  if Display.UsesGate(data) then return 10 end
  if DrawsOne(data) then return 1 end
  local limit = Display.FlowLimit(data)
  if limit then return limit end
  return data.blizzardAuraDisplay and data.blizzardAuraDisplay.maxIcons or 10
end

function Display.PreviewShowsMissing(data)
  local trigger = Display.GetTrigger(data)
  return Display.IsSingle(trigger) and Display.ShowOn(trigger) == "showOnMissing"
end

function Display.SingleIcon(data)
  if data.iconSource == 0 and data.displayIcon and data.displayIcon ~= "" then return data.displayIcon end
  local id = Display.GetSpellIDs(Display.GetTrigger(data) or {}, false)[1]
  local texture = id and C_Spell.GetSpellTexture(id)
  if texture and not issecretvalue(texture) then return texture end
  return 134400
end

function Display.SingleUnitExists(trigger)
  local unit = trigger and trigger.unit or "player"
  if unit == "player" then return true end
  if unit == "member" then
    unit = Display.SpecificUnit(trigger)
    if not unit then return false end
  end
  local ok, exists = pcall(UnitExists, unit)
  if not ok or issecretvalue(exists) then return true end
  return exists == true
end

local function HasRemainingPercentConditions(data)
  for _, condition in ipairs(data.conditions or {}) do
    local check = condition.check
    if check and Display.NativeConditionKind(data, check) and Display.IsNativeDurationCondition(check) and check.variable ~= "faAuraRemaining" then
      return true
    end
  end
  return false
end

function Display.FitsOneSlot(data, trigger)
  if not trigger or not Display.IsSingleUnit(trigger) then return false end
  return data.anchorFrameType ~= "UNITFRAME" and data.anchorFrameType ~= "NAMEPLATE"
end

function Display.InDynamicGroup(data)
  local parent = data and data.parent and WeakAuras.GetData(data.parent)
  while parent do
    if parent.regionType == "dynamicgroup" then return true end
    parent = parent.parent and WeakAuras.GetData(parent.parent)
  end
  return false
end

function Display.MigrateSingle(data, trigger)
  if trigger.secretTracking == nil then return end
  if trigger.secretTracking == "single" then
    if trigger.secretShowOn == nil and Display.showOnValues[trigger.matchesShowOn] and trigger.matchesShowOn ~= "showOnActive" then
      trigger.secretShowOn = trigger.matchesShowOn
    end
    if trigger.secretUseRem == nil and trigger.useRem then
      trigger.secretUseRem, trigger.secretRemOperator, trigger.secretRem = true, trigger.remOperator, trigger.rem
    end
    data.blizzardAuraDisplay = data.blizzardAuraDisplay or {}
    data.blizzardAuraDisplay.maxIcons = 1
  end
  trigger.secretTracking = nil
end

local friendlyUnits = {player = true, pet = true, group = true, party = true, raid = true}
local hostileUnits = {boss = true, arena = true}

local neverSecret = {}
local function NeverSecret(ids)
  if #ids == 0 or not (C_Secrets and C_Secrets.GetSpellAuraSecrecy and Enum.SecrecyLevel) then return false end
  for _, id in ipairs(ids) do
    if neverSecret[id] == nil then
      local ok, level = pcall(C_Secrets.GetSpellAuraSecrecy, id)
      neverSecret[id] = ok and not issecretvalue(level) and level == Enum.SecrecyLevel.NeverSecret
    end
    if not neverSecret[id] then return false end
  end
  return true
end

function Display.SpellIDFilterNote(trigger)
  if not (Display.UsesSpellIDs(trigger) or Display.UsesRankSpellIDs(trigger) or Display.UsesExcludedSpellIDs(trigger)) then return end
  if Display.UsesApproximate(trigger) then return end
  local ids = Display.GetSpellIDs(trigger, true)
  if Display.UsesExcludedSpellIDs(trigger) then
    for _, value in ipairs(trigger.excludedAuraSpellIDs or {}) do
      if tonumber(value) then ids[#ids + 1] = tonumber(value) end
    end
  end
  if NeverSecret(ids) then return end
  local debuff = trigger.debuffType == "HARMFUL"
  local kind = debuff and "Debuffs" or "Buffs"
  local category = Display.UnitCategory(trigger)
  local label = trigger.unit == "member" and Display.SpecificUnit(trigger) or Display.units[trigger.unit] or trigger.unit
  if (debuff and friendlyUnits[category]) or (not debuff and hostileUnits[category]) then
    if debuff and Display.approximateUnits[category] then
      return "error", ("Blizzard hides debuffs on %s from spell ID filters in combat. Try Approximate Match.")
        :format(label)
    end
    return "error", ("Blizzard hides %s on %s from spell ID filters in combat.")
      :format(kind:lower(), label)
  end
  if not friendlyUnits[category] and not hostileUnits[category] then
    return "note", ("%s selected by spell ID only match while the unit is %s.")
      :format(kind, debuff and "hostile" or "friendly")
  end
end

local GREEN, ORANGE, RED = "|cff33ff99", "|cffff9933", "|cffff2020"
function Display.TriggerStatus(data, trigger)
  local problem = Display.Validate(data)
  if problem then return RED .. "Won't work:|r " .. problem end
  local severity, reason = Display.SpellIDFilterNote(trigger)
  if severity == "error" then return RED .. "Won't work:|r " .. reason .. " " .. ORANGE .. "Sounds in Actions still play.|r" end
  local text = GREEN .. "Works in combat.|r"
  if Display.UsesApproximate(trigger) then
    local profile = Display.ApproximateProfile(trigger)
    if not profile then
      return RED .. "Won't work:|r This debuff's duration isn't known. Add a Total Duration filter."
    end
    local _, _, source, problem = Display.GateRange(data, trigger)
    text = text .. " " .. ORANGE .. ((source and not problem) and "Approximate match, may not be exact."
      or "Approximate match: shorter debuffs can match too.") .. "|r"
  end
  if severity == "note" then
    text = text .. " " .. ORANGE .. (trigger.debuffType == "HARMFUL" and "Hostile units only." or "Friendly units only.") .. "|r"
  end
  if Display.InDynamicGroup(data) then
    text = text .. " " .. ORANGE .. "In a Dynamic Group it keeps a fixed position; a Modern Aura Group is recommended.|r"
  end
  local lateX = Display.LateGlowSpec(data, trigger)
  if lateX then
    local total = Display.LateGlowTotal(trigger)
    if not (total and total > lateX) then text = text .. " " .. ORANGE .. "Glow starts once the aura's duration is known.|r" end
  end
  return text
end

function Display.ValidateSingle(data, trigger)
  local totalProblem = Display.TotalFilterProblem(data, trigger)
  if totalProblem then return totalProblem end
  local stackProblem = Display.StackFilterProblem(data, trigger)
  if stackProblem then return stackProblem end
  local remainingProblem = Display.RemainingGateProblem(data, trigger)
  if remainingProblem then return remainingProblem end
  local fallbackProblem = Display.FallbackProblem(data)
  if fallbackProblem then return fallbackProblem end
  if data.regionType ~= "icon" then
    for _, condition in ipairs(data.conditions or {}) do
      local check = condition.check
      if check and check.variable == "faAuraRemaining" and Display.NativeConditionKind(data, check) then
        for _, change in ipairs(condition.changes or {}) do
          if Display.IsGlowProperty(data, change.property) then return "A Remaining Time glow needs an Icon display." end
        end
      end
    end
  end
  if not Display.IsSingle(trigger, data) then return end
  if not Display.IsSingleUnit(trigger) then
    return "Aura(s) Missing, Always and Remaining Time watch one unit: choose Player, Target, Focus, Pet, Target of Target, Target of Focus or a Specific Unit."
  end
  local showOn = Display.ShowOn(trigger)
  local op = Display.RemainingWindow(trigger)
  if UsesRemaining(trigger) and not op then
    return "Remaining Time needs a comparison and a number of seconds of 0 or more."
  end
  if NeedsMissing(trigger) or op then
    local label = op and "Remaining Time" or ("Show On: " .. Display.showOnValues[showOn])
    if op and data.regionType ~= "icon" then
      return label .. " is available for Icon displays. Use Show On: Aura(s) Found for other display types."
    end
    if not op and not missingTypes[data.regionType] then
      return label .. " is available for Icon, Bar, Progress Texture and Text displays."
    end
    if Display.FrameAnchorType(data) == "UNITFRAME" or Display.FrameAnchorType(data) == "NAMEPLATE" then
      return label .. " cannot anchor to unit frames or nameplates. Anchor the aura to the screen or a frame."
    end
  end
  if NeedsMissing(trigger) and trigger.debuffType == "HARMFUL" and (trigger.unit == "player" or trigger.unit == "pet")
    and (Display.UsesSpellIDs(trigger) or Display.UsesRankSpellIDs(trigger)) and not Display.UsesApproximate(trigger) then
    return "Debuffs on you or your pet can't be found by spell ID in combat. Tick Approximate Match."
  end
  if op then
    if not Display.SupportsDurationColorCondition() then
      return "This client cannot limit auras by Remaining Time."
    end
    if HasRemainingPercentConditions(data) then
      return "With Remaining Time, countdown conditions must use Remaining Time in seconds."
    end
  end
end

local function MissingMargin(data, width, height)
  local margin = math.ceil(math.max(width, height)) * 2 + 64
  for _, element in ipairs(data.subRegions or {}) do
    local reach = math.max(math.abs(tonumber(element.anchorXOffset) or 0), math.abs(tonumber(element.anchorYOffset) or 0),
      math.abs(tonumber(element.text_anchorXOffset) or 0), math.abs(tonumber(element.text_anchorYOffset) or 0),
      math.abs(tonumber(element.glowXOffset) or 0), math.abs(tonumber(element.glowYOffset) or 0),
      math.abs(tonumber(element.xOffset) or 0), math.abs(tonumber(element.yOffset) or 0))
    if element.type == "subglow" then reach = reach + math.ceil(math.max(width, height) * (tonumber(element.glowScale) or 1)) end
    margin = math.max(margin, math.ceil(math.max(width, height)) + reach + 64)
  end
  return margin
end

local function MissingLayout(width, height, margin)
  return {elementWidth = width + 1 + 2 * margin, elementHeight = height}
end

function Display.KeepMissingDesaturated(native, data)
  Display.ApplyMissingConditions(native, data)
end

function Display.StyleMissingIcon(native, data)
  if native.icon then native.icon:SetDesaturated(data.desaturate == true) end
  for _, entry in ipairs(native.conditionPreview or {}) do entry.texture:SetShown(entry.kind == "faAuraMissing") end
  Display.ApplyMissingConditions(native, data)
  if native.cooldown then native.cooldown:Hide() end
  for index, element in ipairs(data.subRegions or {}) do
    local entry = native.sharedElements and native.sharedElements[index]
    if entry and (element.type == "subcdmdispel" or element.type == "subcdmdispelborder") then
      if entry.texture then entry.texture:Hide() end
      if entry.dispelEdges then Private.DispelTypeDisplay.Hide(entry.dispelEdges) end
    end
  end
end

local function StyleMissing(missing, region, data)
  local native = missing.native
  Display.StyleNative(native, data, region)
  native.button:ClearAllPoints()
  native.button:SetPoint("TOPLEFT", Display.ContentAnchor(region), "TOPLEFT")
  local trigger = Display.GetTrigger(data)
  local id = Display.GetSpellIDs(trigger, false)[1]
  local info = id and C_Spell.GetSpellInfo(id)
  Display.FillSampleBindings(native.button, Display.SingleIcon(data), info and info.name or "", data, false)
  Display.StyleMissingIcon(native, data)
end

local function Warn(data, message)
  Private.AuraWarnings.UpdateWarning(data.uid, "blizzard_aura_single", message and "warning" or nil, message)
end

local function Followable(data, index)
  local entry = data.triggers and data.triggers[index]
  return type(entry) == "table" and type(entry.trigger) == "table" and entry.trigger.type ~= "secretAura"
end

local function DrivingIndex(data, trigger)
  local saved = Display.GetSavedTrigger(data)
  for index, entry in ipairs(data.triggers or {}) do
    if type(entry) == "table" and entry.trigger == saved then return index end
  end
end

local function FallbackPossible(data, trigger)
  return Display.IsSingleUnit(trigger) and missingTypes[data.regionType]
    and not (Display.FlowGroup and Display.FlowGroup(data))
    and Display.FrameAnchorType(data) ~= "UNITFRAME" and Display.FrameAnchorType(data) ~= "NAMEPLATE"
    and not (Display.RawShowOn(trigger) == "showOnActive" and trigger.secretUseRem == true)
end

function Display.FallbackChoice(data)
  local value = data.triggers and data.triggers.secretFallback
  if value == "none" then return "none" end
  return tonumber(value) or "next"
end

function Display.Fallback(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  if type(trigger) ~= "table" or not FallbackPossible(data, trigger) then return end
  local m = DrivingIndex(data, trigger)
  if not m then return end
  local choice = Display.FallbackChoice(data)
  if choice == "none" then return end
  if choice ~= "next" then return choice ~= m and Followable(data, choice) and choice or nil end
  for index in ipairs(data.triggers) do
    if index ~= m and Followable(data, index) then return "next" end
  end
end

function Display.MigrateFallback(data)
  for _, entry in ipairs(type(data.triggers) == "table" and data.triggers or {}) do
    local trigger = type(entry) == "table" and entry.trigger
    if type(trigger) == "table" and trigger.secretMissingSource ~= nil then
      local index = tonumber(trigger.secretMissingSource)
      if index and data.triggers.secretFallback == nil then data.triggers.secretFallback = index end
      trigger.secretMissingSource = nil
    end
  end
end

function Display.FallbackProblem(data)
  local choice = Display.FallbackChoice(data)
  if type(choice) == "number" and not Followable(data, choice) then
    return "Trigger Combination: the trigger chosen for when Aura (Modern) filters are not met no longer exists or is an Aura (Modern) trigger."
  end
end

function Display.FoundFollow(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  if type(trigger) ~= "table" or Display.RawShowOn(trigger) ~= "showOnActive" then return end
  return Display.Fallback(data, trigger)
end

function Display.MissingSource(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  if type(trigger) ~= "table" then return end
  if Display.RawShowOn(trigger) ~= "showOnActive" and not NeedsMissing(trigger) then return end
  return Display.Fallback(data, trigger)
end

local function ResolveSource(region, data, source)
  if source ~= "next" then return source end
  local m = DrivingIndex(data)
  for index in ipairs(data.triggers or {}) do
    local state = region.states and region.states[index]
    if index ~= m and Followable(data, index) and type(state) == "table" and state.show then return index end
  end
end

local function CountdownElement(native, data, hide)
  local countdown
  for index, element in ipairs(data.subRegions or {}) do
    if element.type == "subtext" and Display.TextKind(element.text_text) == "duration" then
      local entry = native.sharedElements and native.sharedElements[index]
      if entry and entry.text then entry.text:SetShown(not hide and element.text_visible ~= false) end
      if element.text_visible ~= false and not countdown then countdown = element end
    end
  end
  return countdown
end

local function ApplyIconSource(region, missing, data, source)
  local native = missing.native
  local cooldown = native.cooldown
  local state = source and region.states and region.states[source]
  if not (type(state) == "table" and state.show) then
    if missing.following then
      missing.following = nil
      native.icon:SetTexture(Display.SingleIcon(data))
      cooldown:Clear(); cooldown:Hide()
      CountdownElement(native, data, false)
    end
    return
  end
  missing.following = true
  if state.icon == nil or not pcall(native.icon.SetTexture, native.icon, state.icon) then
    native.icon:SetTexture(Display.SingleIcon(data))
  end
  local ok = false
  if state.progressType == "durationObject" and state.durationObject and cooldown.SetCooldownFromDurationObject then
    ok = pcall(cooldown.SetCooldownFromDurationObject, cooldown, state.durationObject, true)
  elseif state.progressType == "timed" then
    local duration, expiration = state.duration, state.expirationTime
    if type(duration) == "number" and type(expiration) == "number" and not issecretvalue(duration)
      and not issecretvalue(expiration) and duration > 0 and expiration ~= math.huge then
      ok = pcall(cooldown.SetCooldown, cooldown, expiration - duration, duration)
    end
  end
  if not ok then
    cooldown:Clear(); cooldown:Hide()
    CountdownElement(native, data, false)
    return
  end
  cooldown:SetDrawSwipe(data.cooldown ~= false and data.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(data.cooldown ~= false and data.cooldownEdge == true)
  cooldown:SetReverse(data.inverse == true)
  local countdown = CountdownElement(native, data, true)
  if countdown then
    cooldown:SetHideCountdownNumbers(false)
    local numbers = cooldown:GetCountdownFontString()
    if numbers then Display.StyleText(numbers, native, Display.TextSettings(countdown), "text", 18, "CENTER", 0, 0) end
    local prefix = "text_text_format_p_time_"
    local format = countdown[prefix .. "format"]
    cooldown:SetCountdownFormatter(nil)
    if format ~= nil and format ~= -1 and Private.GetDurationTextFormatter then
      pcall(cooldown.SetCountdownFormatter, cooldown, Private.GetDurationTextFormatter(countdown[prefix .. "legacy_floor"] and 0 or 99,
        countdown[prefix .. "dynamic_threshold"] or 3, countdown[prefix .. "precision"] or 1, format == -2))
    end
  else
    cooldown:SetHideCountdownNumbers(data.cooldownTextDisabled ~= false)
  end
  cooldown:Show()
end

local function FollowDuration(missing, state)
  if state.progressType == "durationObject" and state.durationObject then return state.durationObject end
  if state.progressType ~= "timed" or not (C_DurationUtil and C_DurationUtil.CreateDuration) then return end
  local duration, expiration = state.duration, state.expirationTime
  if type(duration) ~= "number" or type(expiration) ~= "number" or issecretvalue(duration) or issecretvalue(expiration)
    or duration <= 0 or expiration == math.huge then return end
  missing.followDuration = missing.followDuration or C_DurationUtil.CreateDuration()
  if pcall(missing.followDuration.SetTimeFromStart, missing.followDuration, expiration - duration, duration) then
    return missing.followDuration
  end
end

local zeroDuration
local function ClearFollowBars(native)
  if not zeroDuration and C_DurationUtil and C_DurationUtil.CreateDuration then zeroDuration = C_DurationUtil.CreateDuration() end
  for _, entry in ipairs(native.button.bindings.DurationBar or {}) do
    local bar = entry.widget
    if zeroDuration and bar.SetTimerDuration then
      pcall(bar.SetTimerDuration, bar, zeroDuration, Enum.StatusBarInterpolation.Immediate, Enum.StatusBarTimerDirection.RemainingTime)
    end
    bar:SetMinMaxValues(0, 6)
    bar:SetValue(0)
  end
end

local FOLLOW_TEXT_INTERVAL = 0.1
local function ApplyTimerSource(region, missing, data, source)
  local native = missing.native
  local button = native.button
  local state = source and region.states and region.states[source]
  local duration = type(state) == "table" and state.show and FollowDuration(missing, state)
  if not duration then
    if missing.following then
      missing.following = nil
      button:SetScript("OnUpdate", nil)
      ClearFollowBars(native)
      for _, entry in ipairs(button.bindings.DurationText or {}) do entry.widget:SetText("") end
      native.icon:SetTexture(Display.SingleIcon(data))
    end
    return
  end
  missing.following = true
  if state.icon == nil or not pcall(native.icon.SetTexture, native.icon, state.icon) then
    native.icon:SetTexture(Display.SingleIcon(data))
  end
  local direction = data.inverse and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime
  for _, entry in ipairs(button.bindings.DurationBar or {}) do
    local bar = entry.widget
    if bar.SetTimerDuration then pcall(bar.SetTimerDuration, bar, duration, Enum.StatusBarInterpolation.Immediate, direction) end
  end
  local texts = button.bindings.DurationText or {}
  if #texts == 0 then button:SetScript("OnUpdate", nil); return end
  local modifier = Enum.DurationTimeModifier and Enum.DurationTimeModifier.RealTime
  local fallback = Private.GetDurationTextFormatter and Private.GetDurationTextFormatter(99, 0, 0)
  local elapsed = FOLLOW_TEXT_INTERVAL
  button:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < FOLLOW_TEXT_INTERVAL then return end
    elapsed = 0
    for _, entry in ipairs(texts) do
      local formatter = entry.options and entry.options.textFormatter or fallback
      local ok, text = pcall(duration.FormatRemainingDuration, duration, formatter, modifier)
      entry.widget:SetText(ok and text or "")
    end
  end)
end

local function ApplyMissingSource(region, missing, data, source)
  source = ResolveSource(region, data, source)
  if data.regionType == "icon" then ApplyIconSource(region, missing, data, source)
  else ApplyTimerSource(region, missing, data, source) end
  missing.native.button:SetAlpha((not missing.foundMode or missing.following) and 1 or 0)
end

function Display.UpdateMissingSource(region)
  local native = region.blizzardAuraDisplay
  if not native or not native.active then return end
  local data = native.data
  local source = Display.MissingSource(data)
  for _, instance in ipairs(native.instances or {}) do
    local missing = instance.single and instance.single.missing
    if missing and missing.active and (source or missing.following) then
      ApplyMissingSource(region, missing, data, source)
    end
  end
end
Display.ClearSingleWarning = function(data) Warn(data) end

local PRESENCE_GROUP = "FAPresence"
local function EnsurePresence(missing, region, data, filter, candidates)
  missing.presenceActive = false
  if not Display.FlowGroup(data) then
    if missing.presence then missing.presence:SetEnabled(false); missing.presence:Hide() end
    return
  end
  if missing.presenceFailed then return end
  local presence = missing.presence
  if not presence then
    presence = Display.CreateAuraContainer(region, data)
    presence:SetEnabled(false)
    presence:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    presence:SetPoint("TOPLEFT", region, "TOPLEFT")
    local layout = Display.FlowPresenceSize(data)
    local ok, err = pcall(presence.AddAuraGroup, presence, PRESENCE_GROUP, filter, {
      candidateFilters = candidates,
      maxFrameCount = 1,
      layout = layout,
      initializeFrame = function(button)
        button:SetSize(layout.elementWidth, layout.elementHeight)
        button:SetAlpha(0)
        button:EnableMouse(false)
      end,
    })
    if not ok then
      presence:Hide()
      missing.presenceFailed = true
      Warn(data, "Blizzard could not create the Modern Aura Group spacing: " .. tostring(err))
      return
    end
    missing.presence = presence
  else
    local layout = Display.FlowPresenceSize(data)
    presence:SetAuraGroupFilterString(PRESENCE_GROUP, filter)
    presence:SetAuraGroupCandidateFilters(PRESENCE_GROUP, candidates)
    presence:SetAuraGroupLayout(PRESENCE_GROUP, layout)
    presence:SetAuraGroupEnabled(PRESENCE_GROUP, true)
  end
  missing.presenceBoundUnit = nil
  if not Display.AnchorFlowPresence(region, data, presence) then
    presence:SetEnabled(false); presence:Hide()
    Warn(data, "Blizzard refused the Modern Aura Group spacing; this display keeps a fixed space.")
    return
  end
  missing.presenceActive = true
end

local function EnsureMissing(single, region, data, trigger)
  local width, height = Display.Dimensions(data)
  local margin = MissingMargin(data, width, height)
  local filter, candidates = Display.FilterString(trigger), Display.CandidateFilters(data)
  if single.missingFailed then
    Warn(data, single.missingFailed)
    return
  end
  local missing = single.missing
  if not missing then
    missing = {}
    local container = Display.CreateAuraContainer(region, data)
    container:SetEnabled(false)
    container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    container:SetPoint("TOPLEFT", region, "TOPLEFT")
    local ok, err = pcall(container.AddAuraGroup, container, MISSING_GROUP, filter, {
      candidateFilters = candidates,
      maxFrameCount = 1,
      layout = MissingLayout(width, height, margin),
      initializeFrame = function(button)
        button:SetSize(width + 1 + 2 * margin, height)
        button:EnableMouse(false)
      end,
    })
    if not ok then
      container:Hide()
      single.missingFailed = "Blizzard could not create the Aura(s) Missing display: " .. tostring(err)
      Warn(data, single.missingFailed)
      return
    end
    local clip = CreateFrame("Frame", nil, region, "DisableUntrustedLayoutScriptsTemplate")
    clip:SetClipsChildren(true)
    clip:EnableMouse(false)
    missing.container, missing.clip = container, clip
    missing.native = Display.CreateSampleNative(clip)
    single.missing = missing
  else
    missing.container:SetAuraGroupFilterString(MISSING_GROUP, filter)
    missing.container:SetAuraGroupCandidateFilters(MISSING_GROUP, candidates)
    missing.container:SetAuraGroupLayout(MISSING_GROUP, MissingLayout(width, height, margin))
    missing.container:SetAuraGroupEnabled(MISSING_GROUP, true)
  end
  local anchor = Display.ContentAnchor(region)
  missing.container:ClearAllPoints()
  if not Display.AnchorToContent(missing.container, "TOPLEFT", region, "TOPLEFT") then anchor = region end
  local clip = missing.clip
  clip:ClearAllPoints()
  clip:SetPoint("TOPLEFT", missing.container, "TOPRIGHT", -1 - margin, margin)
  clip:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", margin, -margin)
  EnsurePresence(missing, region, data, filter, candidates)
  clip:SetFrameLevel(region:GetFrameLevel() + 1)
  missing.container:SetFrameLevel(region:GetFrameLevel() + 1)
  StyleMissing(missing, region, data)
  missing.active = true
  missing.native.button:SetScript("OnUpdate", nil)
  if missing.following then ClearFollowBars(missing.native) end
  missing.following = nil
  missing.foundMode = single.foundMode == true
  missing.native.button:SetAlpha(1)
  local source = Display.MissingSource(data, trigger)
  if source or missing.foundMode then ApplyMissingSource(region, missing, data, source) end
end

local function DisableMissing(single)
  local missing = single.missing
  if not missing or not missing.active then return end
  missing.active = false
  for _, key in ipairs({"presence", "flowShadow"}) do
    if missing[key] then
      missing[key]:SetEnabled(false)
      missing[key]:Hide()
    end
  end
  missing.container:SetEnabled(false)
  missing.container:Hide()
  pcall(missing.container.SetAuraGroupEnabled, missing.container, MISSING_GROUP, false)
  missing.clip:Hide()
  missing.boundUnit = nil
end

local function RemainingCurve(op, x, r, g, b, a)
  local curve = C_CurveUtil.CreateColorCurve()
  curve:SetType(Enum.LuaCurveType.Step)
  local below = op == "<" or op == "<="
  local edge = (op == "<=" or op == ">") and x + REMAIN_EPS or x
  local on, off = CreateColor(r, g, b, a), CreateColor(r, g, b, 0)
  if edge > 0 then curve:AddPoint(0, below and on or off) end
  curve:AddPoint(edge, below and off or on)
  return curve
end

local function Units(value) return math.floor((tonumber(value) or 0) * TEXCOORD_UNITS + 0.5) end

local function TextureMarkup(texture, width, height, left, right, top, bottom)
  return ("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"):format(tostring(texture), height, width,
    TEXCOORD_UNITS, TEXCOORD_UNITS, Units(left), Units(right), Units(top), Units(bottom))
end

local function EnsureSlot(single, instance, region, key, trigger, data)
  local container = instance.container
  local filter, candidates = Display.FilterString(trigger), Display.CandidateFilters(data)
  single.slots = single.slots or {}
  local slot = single.slots[key]
  if not slot then
    slot = {}
    local ok, err = pcall(container.AddAuraSlot, container, key, filter, {
      candidateFilters = candidates,
      initializeFrame = function(button)
        slot.button = button
        button:EnableMouse(false)
        button:SetAllPoints(region)
      end,
    })
    if not ok or not slot.button then
      Warn(data, "Blizzard could not create the Remaining Time display: " .. tostring(err))
      return
    end
    single.slots[key] = slot
  end
  container:SetAuraSlotEnabled(key, false)
  local width, height = Display.Dimensions(data)
  slot.button:ClearAllPoints()
  slot.button:SetSize(width, height)
  slot.button:SetPoint("TOPLEFT", region, "TOPLEFT")
  container:SetAuraSlotFilterString(key, filter)
  container:SetAuraSlotCandidateFilters(key, candidates)
  container:SetAuraSlotSortMethod(key, Display.SortOrder(data, trigger))
  slot.used = true
  return slot
end

local function FirstElement(data, matches)
  for index, element in ipairs(data.subRegions or {}) do
    if not Display.IsDetachedElement(data, element) and matches(element) then return element, index end
  end
end

local function EnsureRemaining(single, instance, region, data, trigger, op, x)
  local icon = EnsureSlot(single, instance, region, SLOT_ICON, trigger, data)
  if not icon then return false end
  local width, height = Display.Dimensions(data)
  local color = data.color or {1, 1, 1, 1}
  local left, right, top, bottom = Display.IconTexCoords(data)
  icon.text = icon.text or icon.button:CreateFontString(nil, "ARTWORK")
  icon.text:SetWordWrap(false)
  icon.text:SetFont(STANDARD_TEXT_FONT, 12, "")
  icon.text:ClearAllPoints()
  icon.text:SetPoint("CENTER", icon.button, "CENTER")
  icon.button:ClearDurationText()
  local okIcon, iconErr = pcall(icon.button.SetDurationText, icon.button, icon.text, {
    textFormat = {formatString = TextureMarkup(Display.SingleIcon(data), width, height, left, right, top, bottom), components = {}},
    textColor = {curve = RemainingCurve(op, x, color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1),
      property = Enum.DurationTextBindingProperty.RemainingDuration},
  })
  if not okIcon then
    Warn(data, "Blizzard refused the Remaining Time icon: " .. tostring(iconErr))
    return false
  end
  icon.text:Show()
  instance.container:SetAuraSlotEnabled(SLOT_ICON, true)
  return true
end

local LATE_K, LATE_MAX_WIDTH = 2000, 200000
local WHITE = "Interface\\Buttons\\WHITE8X8"

function Display.LateGlowSpec(data, trigger)
  if data.regionType ~= "icon" then return end
  local op, x = Display.RemainingWindow(trigger)
  if op then
    local element, index = FirstElement(data, function(element) return element.type == "subglow" and element.glow end)
    if not element then return end
    local edge = (op == "<=" or op == ">") and x + REMAIN_EPS or x
    return edge, element, index, op == ">" or op == ">="
  end
  for _, condition in ipairs(data.conditions or {}) do
    local check = condition.check
    if not condition.linked and check and check.variable == "faAuraRemaining" and check.op == "<"
      and Display.NativeConditionKind(data, check) and tonumber(check.value) and tonumber(check.value) > 0 then
      for _, change in ipairs(condition.changes or {}) do
        if change.value == true and Display.IsGlowProperty(data, change.property) then
          local index = tonumber(change.property:match("^sub%.(%d+)%."))
          return tonumber(check.value), data.subRegions[index], index, false
        end
      end
    end
  end
end

local watchedIDs = {}
local waitingRegions = setmetatable({}, {__mode = "k"})
local function SeenDurations()
  if type(WeakAurasSaved) ~= "table" then return end
  WeakAurasSaved.auraDurations = WeakAurasSaved.auraDurations or {}
  return WeakAurasSaved.auraDurations
end

local describedDurations = {}
local pendingSpellData = {}
local loadAttempted = {}
local NUMBER = "(%d+[%.,]?%d*)"
local DURATION_GLOBALS = {
  {1, {"INT_SPELL_DURATION_SEC", "SPELL_DURATION_SEC", "SECONDS_ABBR", "SECOND_ONELETTER_ABBR", "D_SECONDS"}},
  {60, {"INT_SPELL_DURATION_MIN", "SPELL_DURATION_MIN", "MINUTES_ABBR", "MINUTE_ONELETTER_ABBR", "D_MINUTES"}},
  {3600, {"INT_SPELL_DURATION_HOURS", "SPELL_DURATION_HOURS", "HOURS_ABBR", "HOUR_ONELETTER_ABBR", "D_HOURS"}},
}
local ENGLISH_UNITS = {{1, "%d sec"}, {1, "%d secs"}, {1, "%d second"}, {1, "%d seconds"},
  {60, "%d min"}, {60, "%d mins"}, {60, "%d minute"}, {60, "%d minutes"},
  {3600, "%d hour"}, {3600, "%d hours"}, {3600, "%d hr"}, {3600, "%d hrs"}}
local function DurationPattern(format)
  local forms = {}
  local choice = format:match("|4([^;]*);")
  if choice then
    for form in (choice .. ":"):gmatch("([^:]*):") do forms[#forms + 1] = (format:gsub("|4[^;]*;", form, 1)) end
  else
    forms[1] = format
  end
  local patterns = {}
  for _, form in ipairs(forms) do
    form = form:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower()
    local before, after = form:match("^(.-)%%[%d%$]*[%.%d]*[dfsi](.*)$")
    if before then
      local function Escape(text)
        text = text:gsub("^%s+", ""):gsub("%s+$", "")
        return (text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"):gsub("%s+", "%%s*"):gsub("\194\160", "%%s*"))
      end
      before, after = Escape(before), Escape(after)
      if before ~= "" or after ~= "" then
        local boundary = after:match("[a-z]$") and "%f[%A]" or ""
        patterns[#patterns + 1] = before .. "%s*" .. NUMBER .. "%s*" .. after .. boundary
      end
    end
  end
  return patterns
end
local durationPatterns
local function DurationPatterns()
  if durationPatterns then return durationPatterns end
  durationPatterns = {}
  local seen = {}
  local function Add(seconds, format)
    if type(format) ~= "string" then return end
    for _, pattern in ipairs(DurationPattern(format)) do
      if not seen[pattern] then
        seen[pattern] = true
        durationPatterns[#durationPatterns + 1] = {pattern, seconds}
      end
    end
  end
  for _, group in ipairs(DURATION_GLOBALS) do
    for _, name in ipairs(group[2]) do Add(group[1], _G[name]) end
  end
  for _, entry in ipairs(ENGLISH_UNITS) do Add(entry[1], entry[2]) end
  return durationPatterns
end
local function SpellText(id)
  local parts = {}
  local ok, text = pcall(C_Spell.GetSpellDescription, id)
  local loaded = ok and type(text) == "string" and not issecretvalue(text) and text ~= ""
  if loaded then parts[#parts + 1] = text end
  if C_TooltipInfo and C_TooltipInfo.GetSpellByID then
    local okTip, info = pcall(C_TooltipInfo.GetSpellByID, id)
    for _, line in ipairs(okTip and type(info) == "table" and info.lines or {}) do
      for _, key in ipairs({"leftText", "rightText"}) do
        local side = line[key]
        if not issecretvalue(side) and type(side) == "string" then parts[#parts + 1] = side end
      end
    end
  end
  return table.concat(parts, "\n"):lower(), loaded
end
local function DescribedDuration(id)
  if describedDurations[id] ~= nil then return describedDurations[id] or nil end
  if pendingSpellData[id] then return end
  local text, loaded = SpellText(id)
  if not loaded and not loadAttempted[id] and C_Spell.RequestLoadSpellData then
    pendingSpellData[id], loadAttempted[id] = true, true
    local ok = pcall(C_Spell.RequestLoadSpellData, id)
    if not ok then pendingSpellData[id] = nil end
    loaded = not ok
  elseif not loaded then
    loaded = loadAttempted[id] == true
  end
  local best
  for _, entry in ipairs(DurationPatterns()) do
    for value in text:gmatch(entry[1]) do
      local seconds = tonumber((value:gsub(",", ".")))
      seconds = seconds and seconds * entry[2]
      if seconds and seconds > (best or 0) then best = seconds end
    end
  end
  if best or loaded then describedDurations[id] = best or false end
  return best
end

function Display.LateGlowTotal(trigger)
  local op, total = Display.TotalFilter(trigger)
  if op == "=" then return total, "manual" end
  local ids = Display.GetSpellIDs(trigger, true)
  local seen, best = SeenDurations(), nil
  for _, id in ipairs(ids) do
    local seconds = seen and tonumber(seen[id])
    if seconds and seconds > (best or 0) then best = seconds end
  end
  if best then return best, "seen" end
  for _, id in ipairs(ids) do
    local seconds = DescribedDuration(id)
    if seconds and seconds > (best or 0) then best = seconds end
  end
  if best then return best, "described" end
end

local function GlowMargin(width, height, element)
  local offset = math.max(math.abs(tonumber(element.glowXOffset) or 0), math.abs(tonumber(element.glowYOffset) or 0))
  return math.ceil(math.max(width, height) * 0.5 * (tonumber(element.glowScale) or 1)) + offset + 4
end

function Display.TimedGlowHolder(native, data, index, frame)
  if native.preview then return end
  local trigger = Display.GetTrigger(data)
  local x, element, glowIndex, above = Display.LateGlowSpec(data, trigger)
  if not x or glowIndex ~= index then return end
  local total = Display.LateGlowTotal(trigger)
  if not total or total <= x then return false end
  local late = native.lateGlow
  if not late then
    late = {}
    late.bar = CreateFrame("StatusBar", nil, native.button)
    late.bar:SetStatusBarTexture(WHITE)
    late.bar:SetStatusBarColor(0, 0, 0, 0)
    late.bar:SetAlpha(0)
    late.clip = CreateFrame("Frame", nil, native.gateClip or native.button, "DisableUntrustedLayoutScriptsTemplate")
    late.clip:SetClipsChildren(true)
    late.holder = CreateFrame("Frame", nil, late.clip)
    late.holder:SetAllPoints(native.button)
    native.lateGlow = late
  end
  local width, height = Display.Dimensions(data)
  local margin = GlowMargin(width, height, element)
  local k = math.min(LATE_K, LATE_MAX_WIDTH / total)
  late.bar:ClearAllPoints()
  late.bar:SetSize(total * k, height + 2 * margin)
  late.clip:ClearAllPoints()
  if above then
    late.bar:SetPoint("LEFT", native.button, "LEFT", -margin - x * k, 0)
    late.clip:SetPoint("TOPLEFT", late.bar, "TOPLEFT", x * k, 0)
    late.clip:SetPoint("BOTTOMRIGHT", late.bar:GetStatusBarTexture(), "BOTTOMRIGHT")
  else
    late.bar:SetPoint("LEFT", native.button, "RIGHT", margin - x * k, 0)
    late.clip:SetPoint("TOPLEFT", late.bar:GetStatusBarTexture(), "TOPRIGHT")
    late.clip:SetPoint("BOTTOMRIGHT", late.bar, "BOTTOMLEFT", x * k, 0)
  end
  native.button:SetDurationBar(late.bar, {direction = Enum.StatusBarTimerDirection.RemainingTime})
  late.clip:SetFrameLevel(frame:GetFrameLevel() + 1)
  late.clip:Show()
  return late.holder
end

function Display.StyleRemainingList(native, data)
  native.remainingHidesIcon = nil
  if native.preview then return end
  local limited = data.regionType == "icon" and Display.RemainingWindow(Display.GetTrigger(data)) ~= nil
  if native.conditionOverlay then native.conditionOverlay:SetShown(not limited) end
  if not limited then return end
  native.remainingHidesIcon = true
  native.button:ClearIcon(); native.icon:Hide()
  native.button:ClearDurationCooldown(); native.cooldown:Hide()
  native.button:ClearApplicationCount(); native.button:ClearSpellName()
  native.border:Hide()
  for index, element in ipairs(data.subRegions or {}) do
    local keep = element.type == "subglow" or element.type == "subbackground"
      or (element.type == "subtext" and Display.TextKind(element.text_text) == "duration")
    local frame = native.elementFrames and native.elementFrames["shared" .. index]
    if frame and not keep then frame:Hide() end
  end
end

local FINGERPRINT_FLAGS = {"canApplyAura", "isStealable", "isBossAura", "isFromPlayerOrPlayerPet", "nameplateShowAll", "nameplateShowPersonal"}
local watchedProfiles = {}
local learningRegions = setmetatable({}, {__mode = "k"})

local learnsFromGroup = false
local groupUnits = {group = true, party = true, raid = true}

local function RebuildLearningWatches()
  wipe(watchedProfiles); wipe(watchedIDs)
  learnsFromGroup = false
  for _, entry in pairs(learningRegions) do
    if entry.approximate and entry.group then learnsFromGroup = true end
    for _, id in ipairs(entry.ids) do
      if entry.approximate then watchedProfiles[id] = true end
      if entry.glow then watchedIDs[id] = true end
    end
  end
end

function Display.ReleaseAuraLearning(region)
  waitingRegions[region] = nil
  if learningRegions[region] then
    learningRegions[region] = nil
    RebuildLearningWatches()
  end
end

function Display.WatchAuraLearning(region, data, trigger, glow)
  local approximate = Display.UsesApproximate(trigger)
  if not approximate and not glow then Display.ReleaseAuraLearning(region); return end
  local ids = Display.GetSpellIDs(trigger, true)
  local key = table.concat(ids, ",") .. tostring(approximate) .. tostring(not not glow) .. tostring(trigger.unit)
  if not learningRegions[region] or learningRegions[region].key ~= key then
    learningRegions[region] = {ids = ids, key = key, approximate = approximate, glow = glow, group = groupUnits[Display.UnitCategory(trigger)]}
    RebuildLearningWatches()
  end
  waitingRegions[region] = data
end

local function Profiles()
  if type(WeakAurasSaved) ~= "table" then return end
  WeakAurasSaved.auraProfiles = WeakAurasSaved.auraProfiles or {}
  return WeakAurasSaved.auraProfiles
end

Display.approximateUnits = {player = true, pet = true, group = true, party = true, raid = true}

function Display.UsesApproximate(trigger)
  return type(trigger) == "table" and trigger.secretApproximate == true and Display.approximateUnits[Display.UnitCategory(trigger)]
    and trigger.debuffType == "HARMFUL" and (Display.UsesSpellIDs(trigger) or Display.UsesRankSpellIDs(trigger)) or false
end

function Display.ApproximateProfile(trigger)
  local all = Profiles()
  if not all then return end
  local merged
  for _, id in ipairs(Display.GetSpellIDs(trigger, true)) do
    local profile = all[id]
    if type(profile) == "table" then
      if not merged then
        merged = CopyTable(profile)
      else
        merged.duration = math.max(merged.duration or 0, profile.duration or 0)
        if merged.dispel ~= profile.dispel then merged.dispel = nil end
        for _, key in ipairs(FINGERPRINT_FLAGS) do if merged[key] ~= profile[key] then merged[key] = nil end end
      end
    end
  end
  local op, manual = Display.TotalFilter(trigger)
  if op then
    merged = merged or {}
    merged.duration = op == "=" and manual or nil
    return merged, "manual"
  end
  if merged then return merged, "seen" end
  local best
  for _, id in ipairs(Display.GetSpellIDs(trigger, true)) do
    local seconds = DescribedDuration(id)
    if seconds and seconds > (best or 0) then best = seconds end
  end
  if best then return {duration = best}, "duration" end
end

function Display.ApproximateFilters(trigger, filters)
  if not Display.UsesApproximate(trigger) then return filters end
  local profile = Display.ApproximateProfile(trigger)
  if not profile then filters.includeSpellIDs = {}; return filters end
  filters.includeSpellIDs, filters.excludeSpellIDs = nil, nil
  if (profile.duration or 0) > 0 then
    filters.maxDuration = math.min(filters.maxDuration or math.huge, profile.duration + 0.5)
  end
  if type(profile.dispel) == "string" then filters.includeDispelTypes = {[profile.dispel] = true} end
  for _, key in ipairs(FINGERPRINT_FLAGS) do
    if filters[key] == nil and type(profile[key]) == "boolean" then filters[key] = profile[key] end
  end
  return filters
end

local function Friendly(token)
  return token == "player" or token == "pet" or (type(token) == "string" and (token:match("^party%d$") or token:match("^raid%d+$"))) ~= nil
end

local BOTH_FILTERS, DEBUFF_FILTER = {"HELPFUL", "HARMFUL"}, {"HARMFUL"}
local FIXED_UNITS = {"player", "target", "focus", "pet"}
local learnEvents = CreateFrame("Frame")
learnEvents:RegisterEvent("UNIT_AURA")
learnEvents:RegisterEvent("PLAYER_TARGET_CHANGED")
learnEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
learnEvents:RegisterEvent("SPELL_DATA_LOAD_RESULT")
local reapplyAfterCombat = {}
local function ReapplyWaiting(changed)
  local refresh = {}
  for region, data in pairs(waitingRegions) do
    local entry = learningRegions[region]
    for _, id in ipairs(entry and entry.ids or {}) do
      if not changed or changed[id] then refresh[region] = data; break end
    end
  end
  for region, data in pairs(refresh) do
    if WeakAuras.GetData(data.id) == data then Display.Apply(region, data)
    else Display.ReleaseAuraLearning(region) end
  end
end
learnEvents:SetScript("OnEvent", function(_, event, unit, updateInfo)
  if event == "SPELL_DATA_LOAD_RESULT" then
    if pendingSpellData[unit] then
      pendingSpellData[unit], describedDurations[unit] = nil, nil
      loadAttempted[unit] = true
      if InCombatLockdown() then reapplyAfterCombat[unit] = true else ReapplyWaiting({[unit] = true}) end
    end
    return
  end
  if event == "PLAYER_REGEN_ENABLED" and next(reapplyAfterCombat) then
    local changed = reapplyAfterCombat
    reapplyAfterCombat = {}
    ReapplyWaiting(changed)
  end
  if (not next(watchedIDs) and not next(watchedProfiles)) or InCombatLockdown()
    or (C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret()) then return end
  local seen, profiles = SeenDurations(), Profiles()
  if not seen or not profiles then return end
  local changed = {}
  local function Learn(token, aura, harmful)
    local id, duration = aura.spellId, aura.duration
    if not issecretvalue(id) and not issecretvalue(duration) and watchedIDs[id] and type(duration) == "number" and duration > 0 then
      local tenths = math.floor(duration * 10 + 0.5) / 10
      if seen[id] ~= tenths then seen[id] = tenths; changed[id] = true end
    end
    if type(id) == "number" and not issecretvalue(id) and watchedProfiles[id] and harmful
      and type(duration) == "number" and not issecretvalue(duration) then
      local friendly = Friendly(token)
      local old = profiles[id]
      if friendly or not (type(old) == "table" and old.friendly) then
        local profile = {duration = math.floor(duration * 10 + 0.5) / 10, friendly = friendly or nil}
        local dispel = aura.dispelName
        if type(dispel) == "string" and not issecretvalue(dispel) then profile.dispel = dispel end
        if friendly then
          for _, key in ipairs(FINGERPRINT_FLAGS) do
            local value = aura[key]
            if type(value) == "boolean" and not issecretvalue(value) then profile[key] = value end
          end
        end
        local same = type(old) == "table"
        if same then
          for key, value in pairs(profile) do if old[key] ~= value then same = false end end
          for key in pairs(old) do if profile[key] == nil then same = false end end
        end
        if not same then profiles[id] = profile; changed[id] = true end
      end
    end
  end
  local filters = next(watchedIDs) and BOTH_FILTERS or DEBUFF_FILTER
  local function Scan(token)
    for _, filter in ipairs(filters) do
      for i = 1, 40 do
        local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, token, i, filter)
        if not ok or type(aura) ~= "table" then break end
        Learn(token, aura, filter == "HARMFUL")
      end
    end
  end
  if event == "UNIT_AURA" then
    if unit ~= "target" and unit ~= "focus" and not Friendly(unit) then return end
    if type(updateInfo) == "table" and not updateInfo.isFullUpdate then
      for _, aura in ipairs(updateInfo.addedAuras or {}) do
        local harmful = aura.isHarmful
        if not issecretvalue(harmful) then Learn(unit, aura, harmful == true) end
      end
      for _, instanceID in ipairs(updateInfo.updatedAuraInstanceIDs or {}) do
        local ok, aura = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, instanceID)
        if ok and type(aura) == "table" and not issecretvalue(aura.isHarmful) then Learn(unit, aura, aura.isHarmful == true) end
      end
    else
      Scan(unit)
    end
  elseif event == "PLAYER_TARGET_CHANGED" then
    Scan("target")
  else
    for _, token in ipairs(FIXED_UNITS) do Scan(token) end
    if learnsFromGroup then
      for i = 1, (IsInRaid() and GetNumGroupMembers() or 0) do Scan("raid" .. i) end
      for i = 1, (not IsInRaid() and GetNumSubgroupMembers() or 0) do Scan("party" .. i) end
    end
  end
  if next(changed) then ReapplyWaiting(changed) end
end)

local GATE_TOLERANCE = 0.5
Display.totalOperators = {["="] = "=", ["<="] = "<=", [">="] = ">="}

function Display.TotalFilter(trigger)
  if type(trigger) ~= "table" or not trigger.secretUseTotal then return end
  local op, x = trigger.secretTotalOperator or "=", tonumber(trigger.secretTotal)
  if not Display.totalOperators[op] or not x or x <= 0 or x ~= x or x == math.huge then return end
  return op, x
end

local function GateProblem(data, trigger)
  if Display.FrameAnchorType(data) == "UNITFRAME" or Display.FrameAnchorType(data) == "NAMEPLATE" then
    return "Total Duration = and >= can't anchor to unit frames or nameplates."
  end
  if Display.IsSingle(trigger) then
    return "Total Duration = and >= only work with Show On: Aura(s) Found, without Remaining Time."
  end
  if not (Enum.DurationTextBindingProperty and Enum.DurationTextBindingProperty.TotalDuration ~= nil
    and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and Display.SupportsDurationColorCondition()) then
    return "This client can't check Total Duration = or >=."
  end
end

function Display.GateRange(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  if not trigger then return end
  local op, x = Display.TotalFilter(trigger)
  local lower, upper, source
  if op == "=" then
    lower, upper, source = x - GATE_TOLERANCE, x + GATE_TOLERANCE, "filter"
  elseif op == ">=" then
    lower, source = x - GATE_TOLERANCE, "filter"
  elseif Display.UsesApproximate(trigger) then
    local profile = Display.ApproximateProfile(trigger)
    local duration = profile and tonumber(profile.duration)
    if duration and duration > 0 then lower, upper, source = duration - GATE_TOLERANCE, duration + GATE_TOLERANCE, "approximate" end
  end
  if not source then return end
  return math.max(0.001, lower), upper, source, GateProblem(data, trigger)
end

function Display.DurationGate(data, trigger)
  local lower, upper, _, problem = Display.GateRange(data, trigger)
  if lower and not problem then return lower, upper end
end

function Display.TotalFilterProblem(data, trigger)
  local _, _, source, problem = Display.GateRange(data, trigger)
  if source == "filter" and problem then return problem end
end

Display.stackOperators = {["="] = "=", [">="] = ">=", [">"] = ">", ["<="] = "<=", ["<"] = "<"}
Display.STACK_LIMIT = 100

function Display.StackFilter(trigger)
  if type(trigger) ~= "table" or not trigger.secretUseStacks then return end
  local op, x = trigger.secretStacksOperator or ">=", tonumber(trigger.secretStacks)
  if not Display.stackOperators[op] or not x or x ~= math.floor(x) or x < 0 or x > Display.STACK_LIMIT then return end
  if op == "=" then return "exactly", x end
  if op == ">" then op, x = ">=", x + 1 elseif op == "<" then op, x = "<=", x - 1 end
  if op == ">=" then
    if x <= 0 then return end
    return "atLeast", x
  end
  if x < 0 then return "never" end
  return "atMost", x
end

function Display.StackFilterProblem(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  if type(trigger) ~= "table" or not trigger.secretUseStacks then return end
  local x = tonumber(trigger.secretStacks)
  if not x or x ~= math.floor(x) or x < 0 or x > Display.STACK_LIMIT then
    return "Stack Count needs a whole number from 0 to " .. Display.STACK_LIMIT .. "."
  end
  local kind = Display.StackFilter(trigger)
  if kind == "never" then return "Stack Count < 0 never matches." end
  if not kind then return end
  if Display.FrameAnchorType(data) == "UNITFRAME" or Display.FrameAnchorType(data) == "NAMEPLATE" then
    return "Stack Count can't anchor to unit frames or nameplates."
  end
  if Display.IsSingle(trigger) then
    return "Stack Count only works with Show On: Aura(s) Found, without Remaining Time."
  end
  if Display.GateRange(data, trigger) then
    return "Stack Count can't be combined with Total Duration = or >=, or with Approximate Match."
  end
  if not (C_AuraContainerUtil and C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions) then
    return "This client can't check Stack Count."
  end
end

function Display.StackGate(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  local kind, n = Display.StackFilter(trigger)
  if (kind == "exactly" or kind == "atLeast" or kind == "atMost") and not Display.StackFilterProblem(data, trigger) then return kind, n end
end

function Display.RemainingGateProblem(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  if data.regionType == "icon" or not UsesRemaining(trigger) then return end
  if not Display.RemainingWindow(trigger) then
    return "Remaining Time needs a comparison and a number of seconds of 0 or more."
  end
  if Display.FrameAnchorType(data) == "UNITFRAME" or Display.FrameAnchorType(data) == "NAMEPLATE" then
    return "Remaining Time can't anchor to unit frames or nameplates."
  end
  if Display.GateRange(data, trigger) then
    return "On this display type, Remaining Time can't be combined with Total Duration = or >=, or with Approximate Match."
  end
  if not (Enum.DurationTextBindingProperty and Enum.DurationTextBindingProperty.RemainingDuration ~= nil
    and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and Display.SupportsDurationColorCondition()) then
    return "This client can't check Remaining Time on this display type."
  end
end

function Display.RemainingGateRange(data, trigger)
  trigger = trigger or Display.GetTrigger(data)
  if data.regionType == "icon" or not UsesRemaining(trigger) or Display.RemainingGateProblem(data, trigger) then return end
  local op, x = Display.RemainingWindow(trigger)
  if op == "<" then return 0, x - REMAIN_EPS
  elseif op == "<=" then return 0, x
  elseif op == ">" then return x + REMAIN_EPS end
  return x
end

function Display.UsesGate(data)
  return Display.DurationGate(data) ~= nil or Display.RemainingGateRange(data) ~= nil or Display.StackGate(data) ~= nil
end

local function GateMargin(width, height)
  return math.ceil(math.max(width, height) * 0.5) + 8
end

local invisibleCurve
local gateFormatters = {}
local function GateFormatter(lower, upper, fill)
  local key = table.concat({lower, tostring(upper), fill}, "|")
  if gateFormatters[key] then return gateFormatters[key] end
  local points
  if upper and upper < lower then
    points = {{threshold = 0, format = ""}}
  elseif lower <= 0 then
    points = {{threshold = 0, format = fill}}
  else
    points = {{threshold = 0, format = ""}, {threshold = lower, format = fill}}
  end
  if upper and upper >= lower then points[#points + 1] = {threshold = upper + REMAIN_EPS, format = ""} end
  local formatter = C_StringUtil.CreateNumericRuleFormatter()
  local ok, err = pcall(formatter.SetBreakpoints, formatter, points)
  if not ok then return nil, err end
  gateFormatters[key] = formatter
  return formatter
end

local function GateFill(width, height)
  local margin = GateMargin(width, height)
  local size = math.min(250, math.ceil(math.max(width, height) + 2 * margin))
  local fill = string.rep("W", math.ceil((width + 2 * margin) / (size / 2)) + 1)
  local lines = math.ceil((height + 2 * margin) / size)
  if lines > 1 then
    local rows = {}
    for row = 1, lines do rows[row] = fill end
    fill = table.concat(rows, "\n")
  end
  return size, fill, margin
end

local function PlaceGateText(text, button, margin)
  text:ClearAllPoints()
  text:SetJustifyH("LEFT")
  text:SetPoint("LEFT", button, "LEFT", -margin - 2, 0)
end

local function StyleExactStackGate(native, data, n)
  local button, clip = native.button, native.gateClip
  local width, height = Display.Dimensions(data)
  local size, fill, margin = GateFill(width, height)
  local formatter, err = GateFormatter(n, n, fill)
  local text = native.stackGateText
  if not text then
    text = button:CreateFontString(nil, "BACKGROUND")
    native.stackGateText = text
  end
  local ok = formatter ~= nil
  if ok then
    text:SetFont(STANDARD_TEXT_FONT, size, "")
    text:SetWordWrap(false)
    text:SetWidth(0)
    PlaceGateText(text, button, margin)
    text:SetTextColor(0, 0, 0, 0)
    text:SetAlpha(0)
    ok, err = pcall(button.SetApplicationCount, button, text, {formatter = formatter})
  end
  if not ok then
    Warn(data, "Blizzard refused the Stack Count check: " .. tostring(err))
    text:Hide()
    return false
  end
  text:Show()
  clip:SetClipsChildren(true)
  clip:ClearAllPoints()
  clip:SetPoint("TOPLEFT", text, "TOPLEFT")
  clip:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT")
  for index, element in ipairs(data.subRegions or {}) do
    if element.type == "subtext" and Display.TextKind(element.text_text) == "stack" then
      local entry = native.sharedElements and native.sharedElements[index]
      if entry and entry.text then entry.text:SetText(Display.StackTextFor(data, "sub." .. index .. ".text_color", n)) end
    end
  end
  if native.mainText and data.regionType == "text" and Display.TextKind(data.displayText) == "stack" then
    native.mainText:SetText(Display.StackTextFor(data, "color", n))
  end
  return true
end

local function StyleStackGate(native, data, trigger)
  local button, clip = native.button, native.gateClip
  local kind, n = Display.StackGate(data, trigger)
  local bar = native.stackGate
  if kind ~= "exactly" and native.stackGateText then native.stackGateText:Hide() end
  if (not kind or kind == "exactly") and bar then
    button:ClearApplicationBar()
    bar:Hide()
  end
  if not kind then return false end
  if kind == "exactly" then return StyleExactStackGate(native, data, n) end
  if not bar then
    bar = CreateFrame("StatusBar", nil, button)
    bar:SetStatusBarTexture(WHITE)
    bar:SetStatusBarColor(0, 0, 0, 0)
    bar:SetAlpha(0)
    native.stackGate = bar
  end
  local width, height = Display.Dimensions(data)
  local margin = GateMargin(width, height)
  local k = width + 2 * margin
  local max = kind == "atLeast" and n or n + 1
  bar:ClearAllPoints()
  bar:SetSize(max * k, height + 2 * margin)
  clip:SetClipsChildren(true)
  clip:ClearAllPoints()
  if kind == "atLeast" then
    bar:SetPoint("LEFT", button, "LEFT", -margin - (n - 1) * k, 0)
    clip:SetPoint("TOPLEFT", bar, "TOPLEFT", (n - 1) * k, 0)
    clip:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT")
  else
    bar:SetPoint("RIGHT", button, "RIGHT", margin, 0)
    clip:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT")
    clip:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
  end
  bar:Show()
  local ok, err = pcall(button.SetApplicationBar, button, bar, {maxApplications = max})
  if not ok then
    Warn(data, "Blizzard refused the Stack Count check: " .. tostring(err))
    bar:Hide()
    return false
  end
  return true
end

function Display.StyleDurationGate(native, data)
  if native.preview or not native.gateClip then return end
  local clip, gate, button = native.gateClip, native.gateText, native.button
  local trigger = Display.GetTrigger(data)
  local width, height = Display.Dimensions(data)
  local lower, upper = Display.DurationGate(data, trigger)
  local property, label = "TotalDuration", "Total Duration"
  if not lower then
    local remainingLower, remainingUpper = Display.RemainingGateRange(data, trigger)
    if remainingLower then lower, upper, property, label = remainingLower, remainingUpper, "RemainingDuration", "Remaining Time" end
  end
  if not lower then
    gate:Hide()
    native.cooldown:SetMinimumCountdownDuration(0)
    native.cooldown:SetCountdownFormatter(nil)
    if StyleStackGate(native, data, trigger) then return end
    clip:SetClipsChildren(false)
    clip:ClearAllPoints()
    clip:SetAllPoints(button)
    return
  end
  StyleStackGate(native, data, nil)
  local size, fill, margin = GateFill(width, height)
  local formatter, err = GateFormatter(lower, upper, fill)
  local ok = formatter ~= nil
  if ok then
    gate:SetFont(STANDARD_TEXT_FONT, size, "")
    gate:SetWordWrap(false)
    gate:SetWidth(0)
    PlaceGateText(gate, button, margin)
    if not invisibleCurve then
      invisibleCurve = C_CurveUtil.CreateColorCurve()
      invisibleCurve:SetType(Enum.LuaCurveType.Step)
      invisibleCurve:AddPoint(0, CreateColor(0, 0, 0, 0))
    end
    ok, err = pcall(button.SetDurationText, button, gate, {
      textFormat = {formatString = "{}", components = {{property = Enum.DurationTextBindingProperty[property], formatter = formatter}}},
      textColor = {curve = invisibleCurve, property = Enum.DurationTextBindingProperty[property]},
    })
  end
  if not ok then
    Warn(data, "Blizzard refused the " .. label .. " check: " .. tostring(err))
    return
  end
  gate:Show()
  clip:SetClipsChildren(true)
  clip:ClearAllPoints()
  clip:SetPoint("TOPLEFT", gate, "TOPLEFT")
  clip:SetPoint("BOTTOMRIGHT", gate, "BOTTOMRIGHT")
  if native.mainText and data.regionType == "text" and Display.TextKind(data.displayText) == "duration" then
    native.mainText:Hide()
  end
  local countdown
  for index, element in ipairs(data.subRegions or {}) do
    if element.type == "subtext" and Display.TextKind(element.text_text) == "duration" then
      local entry = native.sharedElements and native.sharedElements[index]
      if entry and entry.text then entry.text:Hide() end
      if element.text_visible ~= false and not countdown then countdown = element end
    end
  end
  if countdown and data.regionType == "icon" and property == "TotalDuration" then
    local cooldown = native.cooldown
    cooldown:Show()
    if data.cooldown == false then
      cooldown:SetDrawSwipe(false)
      cooldown:SetDrawEdge(false)
    end
    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetUseAuraDisplayTime(true)
    cooldown:SetMinimumCountdownDuration(lower * 1000)
    local numbers = cooldown:GetCountdownFontString()
    if numbers then Display.StyleText(numbers, native, Display.TextSettings(countdown), "text", 18, "CENTER", 0, 0) end
    local prefix = "text_text_format_p_time_"
    local format = countdown[prefix .. "format"]
    cooldown:SetCountdownFormatter(nil)
    if format ~= nil and format ~= -1 and Private.GetDurationTextFormatter then
      pcall(cooldown.SetCountdownFormatter, cooldown, Private.GetDurationTextFormatter(countdown[prefix .. "legacy_floor"] and 0 or 99,
        countdown[prefix .. "dynamic_threshold"] or 3, countdown[prefix .. "precision"] or 1, format == -2))
    end
    button:SetDurationCooldown(cooldown)
  end
end

function Display.MigrateTotal(trigger)
  if trigger.secretUseTotal == nil then
    if trigger.secretExactDuration and tonumber(trigger.secretDuration) then
      trigger.secretUseTotal, trigger.secretTotalOperator, trigger.secretTotal = true, "=", tostring(trigger.secretDuration)
      trigger.secretDuration = nil
    elseif type(trigger.maxDuration) == "number" then
      trigger.secretUseTotal, trigger.secretTotalOperator, trigger.secretTotal = true, "<=", tostring(trigger.maxDuration)
    end
  end
  trigger.maxDuration = nil
  trigger.secretExactDuration = nil
  trigger.secretDuration = nil
end

function Display.ConfigureSingle(instance, region, data, index)
  local trigger = Display.GetTrigger(data)
  local valid = index == 1 and Display.ValidateSingle(data, trigger) == nil
  local isSingle = valid and Display.IsSingle(trigger, data)
  if valid then
    local lateX = Display.LateGlowSpec(data, trigger)
    Display.WatchAuraLearning(region, data, trigger, lateX)
  elseif index == 1 then
    Display.ReleaseAuraLearning(region)
  end
  local foundFollow = valid and not isSingle and Display.FoundFollow(data, trigger) ~= nil
  if not isSingle and not foundFollow and not instance.single then return end
  local single = instance.single or {}
  instance.single = single
  for _, slot in pairs(single.slots or {}) do slot.used = false end
  single.foundMode = foundFollow
  if (isSingle and NeedsMissing(trigger)) or foundFollow then EnsureMissing(single, region, data, trigger) else DisableMissing(single) end
  local op, x = Display.RemainingWindow(trigger)
  if isSingle and op then EnsureRemaining(single, instance, region, data, trigger, op, x) end
  for key, slot in pairs(single.slots or {}) do
    if not slot.used then pcall(instance.container.SetAuraSlotEnabled, instance.container, key, false) end
  end
  local listDraws = not isSingle or Display.ShowOn(trigger) ~= "showOnMissing"
  single.listDisabled = not listDraws
  instance.container:SetAuraGroupEnabled("Auras", listDraws)
  for _, button in ipairs(instance.buttons or {}) do button.button:SetAlpha(listDraws and 1 or 0) end
end

function Display.RefreshSingle(instance, unit, shown)
  local single = instance.single
  if shown and single and single.listDisabled then
    pcall(instance.container.SetAuraGroupEnabled, instance.container, "Auras", false)
  end
  local missing = instance.single and instance.single.missing
  if not missing or not missing.active then return end
  local container = missing.container
  if unit and missing.boundUnit ~= unit then
    container:SetEnabled(false)
    container:SetUnit(unit)
    missing.boundUnit = unit
  end
  shown = shown and unit ~= nil
  container:SetShown(shown)
  container:SetEnabled(shown)
  for _, key in ipairs({"presence", "flowShadow"}) do
    local follower = missing[key]
    if follower and missing[key .. "Active"] then
      if unit and missing[key .. "BoundUnit"] ~= unit then
        follower:SetEnabled(false)
        follower:SetUnit(unit)
        missing[key .. "BoundUnit"] = unit
      end
      follower:SetShown(shown)
      follower:SetEnabled(shown)
      if shown then follower:UpdateAllAuras() end
    end
  end
  missing.clip:SetShown(shown)
  local trigger = instance.data and Display.GetTrigger(instance.data)
  local keepWithoutUnit = trigger and trigger.unitExists
  missing.clip:SetAlpha((keepWithoutUnit or Display.SingleUnitExists({unit = unit})) and 1 or 0)
  if shown then container:UpdateAllAuras() end
end
