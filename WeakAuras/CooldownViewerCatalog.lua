if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local identities = {}
local requestedItems = {}

function Private.CDMRequestItemData(itemID)
  if itemID and C_Item and C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID
      and not requestedItems[itemID] and not C_Item.IsItemDataCachedByID(itemID) then
    requestedItems[itemID] = true
    C_Item.RequestLoadItemDataByID(itemID)
  end
end

function Private.CDMResetIdentities()
  if Private.cdmScanBatch then
    if Private.cdmScanBatch.identitiesReset then return end
    Private.cdmScanBatch.identitiesReset = true
  end
  identities = {}
end

local labels = {
  Essential = "Essential", Utility = "Utility", TrackedBuff = "Tracked Buffs", TrackedBar = "Tracked Bars",
  GroupBuff = "Group Buffs", SpecAgnosticEssential = "Shared Cooldowns", SpecAgnosticTracked = "Shared Buffs",
  EquipSlotEssential = "Item Cooldowns", EquipSlotTracked = "Item Buffs",
}
local viewerNames = {"EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer"}

local function Number(value)
  if not (issecretvalue and issecretvalue(value)) and type(value) == "number" then return value end
end

local function Readable(value)
  return not (issecretvalue and issecretvalue(value))
end

function Private.CDMCategoryName(category)
  for name, value in pairs(Enum.CooldownViewerCategory) do
    if value == category then return labels[name] or name end
  end
  return "Other"
end

function Private.CDMIsBuff(category)
  local c = Enum.CooldownViewerCategory
  return category == c.TrackedBuff or category == c.TrackedBar or category == c.GroupBuff or category == c.SpecAgnosticTracked or category == c.EquipSlotTracked
end

local observed = setmetatable({}, {__mode = "k"})
local observedViewers = setmetatable({}, {__mode = "k"})
local nativeRefreshQueued = false
local function NativeRefresh()
  if nativeRefreshQueued then return end
  nativeRefreshQueued = true
  C_Timer.After(0, function()
    nativeRefreshQueued = false
    if Private.ScanEvents then Private.ScanEvents("WA_CDM_REFRESH") end
  end)
end
Private.QueueCDMRefresh = NativeRefresh
local function Boolean(value)
  if Readable(value) and type(value) == "boolean" then return value end
end

local function TimerExpired(record)
  if record.paused then return end
  local duration = record.duration or record.converted
  if duration and duration.GetRemainingDuration then
    local remaining = Number(duration:GetRemainingDuration())
    if remaining then return remaining <= 0 end
    return
  end
  local raw = record.raw
  if not raw then return end
  local start, total = Number(raw.start), Number(raw.duration)
  local rate = Number(raw.modRate)
  if Readable(raw.modRate) and raw.modRate == nil then rate = 1 end
  if start and total and rate and rate > 0 then
    return GetTime() >= start + total / rate
  end
end

local function Observe(frame)
  if observed[frame] or not hooksecurefunc then return end
  local record = {}
  observed[frame] = record
  local function CaptureIdentity()
    record.cooldownID = Number(frame.cooldownID)
    record.spellID = frame.GetSpellID and Number(frame:GetSpellID())
    record.onCooldown = Boolean(frame.isOnActualCooldown)
    record.recharging = Boolean(frame.wasSetFromCharges)
    record.paused = Boolean(frame.cooldownPaused) == true
    if record.completedRevision and record.completedRevision == record.revision then
      record.onCooldown, record.recharging = false, false
    end
    record.charges = Number(frame.cooldownChargesCount)
    record.onGCD = Boolean(frame.isOnGCD)
    if record.onCooldown == true or record.recharging == true
        or Boolean(frame.cooldownUseAuraDisplayTime) == true then
      record.onGCD = false
    end
  end
  local function Clear()
    record.revision = (record.revision or 0) + 1
    record.duration, record.raw, record.converted = nil, nil, nil
    CaptureIdentity()
    NativeRefresh()
  end
  local function ClearAura()
    if not frame.RefreshSpellCooldownInfo then Clear() else NativeRefresh() end
  end
  local function RefreshNativeState()
    CaptureIdentity()
    NativeRefresh()
  end
  local function CooldownDone()
    CaptureIdentity()
    if Readable(frame.cooldownUseAuraDisplayTime) and not frame.cooldownUseAuraDisplayTime
        and record.onGCD == false and TimerExpired(record) == true then
      record.completedRevision = record.revision
      record.onCooldown, record.recharging = false, false
    end
    NativeRefresh()
  end
  for _, method in ipairs({"ClearAuraInstanceInfo", "OnAuraInstanceInfoCleared", "OnAuraInstanceInfoSet"}) do
    if type(frame[method]) == "function" then hooksecurefunc(frame, method, ClearAura) end
  end
  for _, method in ipairs({"OnCooldownIDSet", "OnCooldownIDCleared", "ResetCooldownData"}) do
    if type(frame[method]) == "function" then hooksecurefunc(frame, method, Clear) end
  end
  for _, method in ipairs({"SetAuraInstanceInfo", "OnUnitAuraRemovedEvent", "OnUnitAuraUpdatedEvent", "OnNewTarget", "OnActiveStateChanged", "RefreshIconColor"}) do
    if type(frame[method]) == "function" then hooksecurefunc(frame, method, NativeRefresh) end
  end
  for _, method in ipairs({"RefreshData", "RefreshCooldownOnly"}) do
    if type(frame[method]) == "function" then hooksecurefunc(frame, method, RefreshNativeState) end
  end
  if frame.HookScript then frame:HookScript("OnShow", NativeRefresh); frame:HookScript("OnHide", NativeRefresh) end
  local cooldown = frame.Cooldown or frame.cooldown
  if cooldown then
    if cooldown.HookScript then cooldown:HookScript("OnCooldownDone", CooldownDone) end
    if cooldown.SetCooldownFromDurationObject then
      hooksecurefunc(cooldown, "SetCooldownFromDurationObject", function(_, duration)
        record.revision = (record.revision or 0) + 1
        record.duration, record.raw, record.converted = duration, nil, nil
        CaptureIdentity()
        NativeRefresh()
      end)
    end
    if cooldown.SetCooldown then
      hooksecurefunc(cooldown, "SetCooldown", function(_, start, duration, modRate)
        record.revision = (record.revision or 0) + 1
        record.duration, record.raw, record.converted = nil, {start = start, duration = duration, modRate = modRate}, nil
        CaptureIdentity()
        NativeRefresh()
      end)
    end
    if cooldown.Clear then hooksecurefunc(cooldown, "Clear", Clear) end
    if cooldown.Pause then hooksecurefunc(cooldown, "Pause", function() record.paused = true; NativeRefresh() end) end
    if cooldown.Resume then hooksecurefunc(cooldown, "Resume", function() record.paused = false; NativeRefresh() end) end
    if cooldown.GetCooldownTimes then
      local ok, start, duration = pcall(cooldown.GetCooldownTimes, cooldown)
      start, duration = Number(start), Number(duration)
      if ok and start and duration then
        record.raw = {start = start / 1000, duration = duration / 1000, modRate = frame.cooldownModRate}
      elseif frame.RefreshSpellCooldownInfo then
        record.raw = {start = frame.cooldownStartTime, duration = frame.cooldownDuration, modRate = frame.cooldownModRate}
      end
    end
    CaptureIdentity()
  end
end

function Private.CDMGetNativeCooldown(frame, spellID)
  if not frame then return end
  local record = observed[frame]
  if not record or record.cooldownID ~= Number(frame.cooldownID)
      or record.spellID ~= spellID then return end
  local nativeID = frame.GetSpellID and Number(frame:GetSpellID())
  if nativeID ~= spellID then return end
  local duration = record.duration or record.converted
  local raw = record.raw
  if not duration and raw and C_DurationUtil and C_DurationUtil.CreateDuration then
    local candidate = C_DurationUtil.CreateDuration()
    if candidate.SetTimeFromStart then
      local ok = pcall(candidate.SetTimeFromStart, candidate, raw.start, raw.duration, raw.modRate)
      if ok then duration = candidate; record.converted = candidate end
    end
  end
  local outOfRange = Boolean(frame.spellOutOfRange)
  local inRange
  if outOfRange ~= nil then inRange = not outOfRange end
  return {duration = duration, revision = record.revision, onGCD = record.onGCD, onCooldown = record.onCooldown,
    recharging = record.recharging, charges = record.charges, inRange = inRange,
    paused = record.paused}
end

function Private.CDMFrames()
  local batch = Private.cdmScanBatch
  if batch and batch.frames then return batch.frames end
  local frames = {}
  for _, name in ipairs(viewerNames) do
    local viewer = _G[name]

    if viewer and hooksecurefunc and not observedViewers[viewer] then
      observedViewers[viewer] = true
      if name == "BuffIconCooldownViewer" or name == "BuffBarCooldownViewer" then
        if type(viewer.OnAcquireItemFrame) == "function" then
          hooksecurefunc(viewer, "OnAcquireItemFrame", function(_, frame) Observe(frame) end)
        end
        if type(viewer.RefreshData) == "function" then hooksecurefunc(viewer, "RefreshData", NativeRefresh) end
      end
      for _, method in ipairs({"OnUnitAura", "OnPlayerTargetChanged", "RefreshActiveFramesForTargetChange"}) do
        if type(viewer[method]) == "function" then hooksecurefunc(viewer, method, NativeRefresh) end
      end
    end
    local pool = viewer and viewer.itemFramePool
    if pool and pool.EnumerateActive then
      for frame in pool:EnumerateActive() do
        local id = Number(frame.cooldownID)
        if id then Observe(frame); frames[id] = frame end
      end
    end
  end
  if batch then batch.frames = frames end
  return frames
end

function Private.CDMCatalog()
  local catalog = {}
  local settings = _G.CooldownViewerSettings
  local provider = settings and settings.GetDataProvider and settings:GetDataProvider()
  provider = provider or _G.CooldownViewerDataProvider
  local layout

  if provider and provider.GetDisplayData and (not provider.IsDirty or not provider:IsDirty()) then
    local data = provider:GetDisplayData()
    layout = data and data.cooldownInfoByID
  end
  local categories = {}
  local frames = Private.CDMFrames()
  for _, category in pairs(Enum.CooldownViewerCategory) do
    if type(category) == "number" and category >= 0 then categories[category] = true end
  end
  for category in pairs(categories) do
    for _, id in ipairs(C_CooldownViewer.GetCooldownViewerCategorySet(category, true) or {}) do
      if Number(id) then
        local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
        if info then
          local arranged = layout and layout[id]
          local placement = arranged and Number(arranged.category)
          local displayed
          if placement ~= nil then
            local c = Enum.CooldownViewerCategory
            displayed = placement == c.Essential or placement == c.Utility or placement == c.TrackedBuff or placement == c.TrackedBar
          elseif frames[id] then

            displayed = true
            local viewer = frames[id].viewerFrame
            placement = viewer and Number(viewer.cooldownViewerCategory)
          end
          catalog[id] = {
            category = placement and placement >= 0 and placement or category,
            sourceCategory = category,
            displayed = displayed,
            known = Readable(info.isKnown) and info.isKnown ~= false,
          }
        end
      end
    end
  end
  return catalog
end

function Private.CDMIdentity(id, entry, info, frame)
  local spellID = frame and frame.GetSpellID and Number(frame:GetSpellID())
  spellID = spellID or Number(info.linkedSpellID) or Number(info.overrideTooltipSpellID) or Number(info.overrideSpellID)
  if not spellID and Private.CDMIsBuff(entry.category) then
    for _, linked in ipairs(info.linkedSpellIDs or {}) do
      local candidate = Number(linked)
      if candidate and candidate > 0 then spellID = candidate; break end
    end
  end
  spellID = spellID or Number(info.spellID)
  local slot = Number(info.equipSlot)
  local itemID = slot and Number(GetInventoryItemID("player", slot))
  if not itemID and frame and frame.cooldownInfo then itemID = Number(frame.cooldownInfo.lastItemIDForCategory) end
  local categoryID = Number(info.spellCategoryID)
  if not spellID and categoryID and C_Spell.GetLastCategoryCooldownSource then
    local sourceSpell, sourceItem = C_Spell.GetLastCategoryCooldownSource(categoryID)
    spellID, itemID = Number(sourceSpell), itemID or Number(sourceItem)
  end
  local spell = spellID and spellID > 0 and C_Spell.GetSpellInfo(spellID)
  local name, icon = spell and spell.name, spell and spell.iconID
  if itemID and C_Item then
    Private.CDMRequestItemData(itemID)
    name = C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID) or ("Item " .. itemID)
    icon = C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID) or icon
  end
  local previous = identities[id] or {}
  if slot or (itemID and itemID ~= previous.itemID) then previous = {} end
  local identity = {spellID = spellID or previous.spellID, itemID = itemID or previous.itemID, slot = slot, name = name or previous.name or (slot and ("Equipment slot " .. slot)) or ("CDM entry " .. id), icon = icon or previous.icon or 134400}
  identities[id] = identity
  return identity
end

local function SetTimes(state, startTime, duration, modRate)
  startTime, duration, modRate = Number(startTime), Number(duration), Number(modRate)
  if not startTime or not duration then return false end
  state.progressType = "timed"
  state.duration = duration
  state.expirationTime = startTime + duration
  state.modRate = modRate or 1
  state.value, state.total = nil, nil
  return true
end

function Private.CDMApplyItem(state, identity)
  local startTime, duration, enabled
  if identity.slot then
    startTime, duration, enabled = GetInventoryItemCooldown("player", identity.slot)
  elseif identity.itemID and C_Item and C_Item.GetItemCooldown then
    startTime, duration, enabled = C_Item.GetItemCooldown(identity.itemID)
  end
  if SetTimes(state, startTime, duration) then
    state.onCooldown = state.duration > 0 and state.expirationTime > GetTime()
    state.isReady = not state.onCooldown
    if Number(enabled) == 0 then state.isReady = false end
  end
end

local function ApplyAuraSource(state, unit, aura)
  state.cdmAuraFilter = "HELPFUL"
  if Readable(unit) and (unit == "player" or unit == "target") then state.cdmAuraUnit = unit end
  local harmful = aura and aura.isHarmful
  if Readable(harmful) and type(harmful) == "boolean" then
    state.cdmAuraFilter = harmful and "HARMFUL" or "HELPFUL"
  elseif state.cdmAuraUnit == "target" then
    local friend = UnitIsFriend and UnitIsFriend("player", "target")
    state.cdmAuraFilter = Readable(friend) and friend == true and "HELPFUL" or "HARMFUL"
  end
  if state.cdmAuraUnit == "target" then
    state.cdmAuraFilter = state.cdmAuraFilter == "HELPFUL" and "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY" or "HARMFUL|PLAYER"
  end
end

local function ApplyCachedAura(state, identity, info, frame, exactID, buffSpellIDs)
  local aura, unit
  state.cdmAuraUnit, state.cdmAuraFilter, state.cdmAuraTotem = "player", "HELPFUL", false
  if frame then aura, unit = frame.auraDataCached, frame.auraDataUnit end
  ApplyAuraSource(state, unit, aura)
  local nativeMatches = frame and not exactID
  if frame and exactID then
    local spellID = Number(frame.auraSpellID) or (aura and Number(aura.spellId))
    nativeMatches = spellID == exactID
  end
  if nativeMatches then
    local instance = frame.auraInstanceID
    if Readable(instance) then
      if instance ~= nil then state.auraActive = true
      elseif not aura then state.auraActive = false end
    end
  end
  if exactID and aura and not nativeMatches then aura, unit = nil, nil end

  local nativeAbsent = frame and Readable(frame.auraInstanceID) and frame.auraInstanceID == nil
    and not frame.auraDataCached
  state.cdmAuraRenderUnit, state.cdmAuraRenderSpellIDs = nil, nil
  if nativeMatches and not nativeAbsent and Readable(unit) and (unit == "player" or unit == "target") then
    local spellID = Number(frame.auraSpellID) or (aura and Number(aura.spellId))
    state.cdmAuraRenderUnit = unit
    state.cdmAuraRenderSpellIDs = spellID and {spellID} or buffSpellIDs
    if not exactID and Private.GetAuraSpellRanks and type(state.cdmAuraRenderSpellIDs) == "table" then
      local ranks, seen = {}, {}
      for _, id in ipairs(state.cdmAuraRenderSpellIDs) do
        for _, rankID in ipairs(Private.GetAuraSpellRanks(id) or {id}) do
          if not seen[rankID] then seen[rankID] = true; ranks[#ranks + 1] = rankID end
        end
      end
      state.cdmAuraRenderSpellIDs = ranks
    end
  end
  if nativeAbsent then state.auraActive = false end
  if aura then
    state.auraActive = true
    if Readable(aura.dispelName) and type(aura.dispelName) == "string" then
      state.cdmDispelName = aura.dispelName
      state.debuffClass = aura.dispelName == "" and "enrage" or aura.dispelName:lower()
    end
  end
  local totem = not aura and frame and frame.totemData
  if totem then
    state.cdmAuraTotem = true
    state.auraActive = nil
    local duration, expiration = Number(totem.duration), Number(totem.expirationTime)
    if duration and expiration then
      SetTimes(state, expiration - duration, duration, totem.modRate)
      state.auraActive = expiration > GetTime()
    end
    return
  end
  if nativeMatches and not nativeAbsent then
    local cooldown = frame.Cooldown or frame.cooldown
    if cooldown and cooldown.GetCountdownFontString then state.cdmCountdownSource = cooldown:GetCountdownFontString() end
    if not state.cdmCountdownSource and frame.Bar then state.cdmCountdownSource = frame.Bar.Duration end
    local applications = frame.Applications
    local stacks = applications and (applications.Applications or applications)
    if not stacks or not stacks.GetText then stacks = frame.Icon and frame.Icon.Applications end
    if stacks and stacks.GetText then state.cdmStackSource = stacks end
    state.cdmTextRecord = observed[frame]
    local instance = frame.auraInstanceID
    local hasInstance = not Readable(instance) or type(instance) == "number"
    if hasInstance and Readable(unit) and (unit == "player" or unit == "target")
        and C_UnitAuras and C_UnitAuras.GetAuraDuration then
      local ok, duration = pcall(C_UnitAuras.GetAuraDuration, unit, instance)
      if ok and Private.IsDurationObject(duration) then
        state.progressType, state.durationObject = "durationObject", duration
        state.value, state.total = nil, nil
      end
    end
  end
  if nativeMatches and not nativeAbsent and observed[frame] then
    local record = observed[frame]
    if not state.durationObject and record.duration then
      state.progressType, state.durationObject = "durationObject", record.duration
      state.value, state.total = nil, nil
    elseif not state.durationObject and record.raw then
      local duration = record.converted
      if not duration and C_DurationUtil and C_DurationUtil.CreateDuration then
        local candidate = C_DurationUtil.CreateDuration()
        if candidate.SetTimeFromStart and pcall(candidate.SetTimeFromStart, candidate,
            record.raw.start, record.raw.duration, record.raw.modRate) then
          duration = candidate
          record.converted = candidate
        end
      end
      if duration then
        state.progressType, state.durationObject = "durationObject", duration
        state.value, state.total = nil, nil
      else
        SetTimes(state, record.raw.start, record.raw.duration, record.raw.modRate)
      end
    end
    state.cdmNativePaused = record.paused == true
  end
  if not aura then return end
  state.stacks = Number(aura.applications)
  if not state.durationObject and C_DurationUtil and C_DurationUtil.CreateDuration then
    local duration = C_DurationUtil.CreateDuration()
    if duration.SetTimeFromEnd and pcall(duration.SetTimeFromEnd, duration,
        aura.expirationTime, aura.duration, aura.timeMod) then
      state.progressType, state.durationObject = "durationObject", duration
      state.value, state.total = nil, nil
    end
  end
  local duration, expiration = Number(aura.duration), Number(aura.expirationTime)
  if duration and expiration then
    if not state.durationObject then
      SetTimes(state, expiration - duration, duration, aura.timeMod)
    end
    state.auraActive = duration == 0 or expiration > GetTime()
  end
end

function Private.CDMApplyAura(state, identity, info, frame, exactID, buffSpellIDs)
  ApplyCachedAura(state, identity, info, frame, exactID, buffSpellIDs)

  if frame and state.auraActive ~= false then
    local active = frame.isActive
    if not Readable(active) then
      state.auraActive = nil

    elseif type(active) == "boolean" then

      state.auraActive = active
      if active and exactID then
        local spellID = Number(frame.auraSpellID)
          or (frame.auraDataCached and Number(frame.auraDataCached.spellId))

        if spellID then state.auraActive = spellID == exactID
        else state.auraActive = nil end
      end
    end
  end
  if state.auraActive == false then
    state.progressType, state.value, state.total = "static", 1, 1
    state.durationObject, state.duration, state.expirationTime, state.modRate = nil, nil, nil, nil
    state.cdmCountdownSource, state.cdmStackSource, state.cdmTextRecord = nil, nil, nil
    state.stacks, state.cdmDispelName, state.debuffClass = nil, nil, nil
  end
end

function Private.ParseCDMText(value)
  if type(value) ~= "string" then return end
  local token = value:match("^%%{(.-)}$") or value:match("^%%(.+)$")
  if not token then return end
  if token == "bp" or token == "bs" or token == "p" or token == "s" or token == "caster" or token == "dispel" then return token end
  local trigger, kind = token:match("^(%d+)%.(b?[ps])$")
  if not trigger then
    local index, field = token:match("^(%d+)%.(%a+)$")
    if field == "caster" or field == "dispel" then return field, tonumber(index) end
  end
  if trigger then return kind, tonumber(trigger) end
end

function Private.IsCDMBuffText(value, data)
  local kind, index = Private.ParseCDMText(value)
  if not kind then return false end
  if kind == "bp" or kind == "bs" then return true end
  local triggers = data and data.triggers
  if not triggers then return false end
  if not index and data.progressSource and data.progressSource[1] then
    local source = data.progressSource[1]
    if source == 0 then return false elseif source > 0 then index = source end
  end
  index = index or (triggers.activeTriggerMode and triggers.activeTriggerMode > 0 and triggers.activeTriggerMode) or (#triggers == 1 and 1)
  local entry = index and triggers[index]
  local trigger = type(entry) == "table" and entry.trigger
  return trigger and trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff" or false
end

function Private.CopyCDMCountdownText(destination, state, kind)
  if kind == "caster" then destination:SetText(""); return end
  if kind == "dispel" then destination:SetText(state and state.show and state.cdmDispelName or ""); return end
  if kind == "s" then kind = "bs" end
  if kind ~= "bs" and state and state.cdmBuff and state.show and not state.cdmTextPreview
      and Private.IsDurationObject(state.durationObject) then
    destination:SetText(Private.FormatDurationText(state.durationObject, false, 99, 0, 0))
    return
  end
  local source = state and state.show and (kind == "bs" and state.cdmStackSource or kind ~= "bs" and state.cdmCountdownSource)
  if source and source.IsForbidden and source:IsForbidden() then source = nil end
  if source and (kind == "bs" or (state and state.cdmBuff)) and source.IsShown then
    local shown = source:IsShown()
    if Readable(shown) and not shown then destination:SetText(""); return end
  end
  if source then
    local value = source:GetText()
    if kind ~= "bs" and state and state.cdmBuff and Readable(value) and tonumber(value) == 0 then value = "" end
    destination:SetText(value)
  elseif state and state.show and state.cdmTextPreview then
    local remaining = state.expirationTime and math.max(0, state.expirationTime - GetTime()) or 6
    destination:SetText(kind == "bs" and "3" or tostring(math.ceil(remaining)))
  else destination:SetText("") end
end
