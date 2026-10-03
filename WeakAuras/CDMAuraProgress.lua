if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = {}
Private.CDMAuraProgress = Display

function Display.IsConfigured(data)
  if not data or type(data.triggers) ~= "table" then return false end
  local source = data.progressSource and data.progressSource[1] or -1
  if source == 0 then return false end
  if source < 0 then source = data.triggers.activeTriggerMode or -1 end
  if source < 0 and #data.triggers == 1 then source = 1 end
  local entry = data.triggers[source]
  return type(entry) == "table" and entry.trigger and entry.trigger.type == "cdm" and entry.trigger.event == "Blizzard CDM Buff" or false
end

local function SourceState(parent, explicit)
  local source = explicit or (parent.progressSource and parent.progressSource[1]) or -1
  if source > 0 then return parent.states and parent.states[source] end
  if source == -1 then return parent.state end
end

function Display.IsInactive(region)
  local state = SourceState(region)
  return state and state.cdmBuff and state.auraActive == false or false
end

local function NativeSource(state)
  if not CustomAuraContainerAuraProcessingPolicy or not state or not state.cdmBuff
      or not state.show or state.cdmTextPreview or state.cdmAuraTotem
      or state.auraActive == false or state.progressType ~= "static" then return end
  local unit = state.cdmAuraRenderUnit
  if unit ~= "target" or state.cdmAuraFilter ~= "HARMFUL|PLAYER" then return end
  local ids = state.cdmAuraRenderSpellIDs
  if type(ids) ~= "table" or not next(ids) then return end
  return unit, state.cdmAuraFilter or "HELPFUL", ids
end

local function CanStyleWidget(widget, initializing)
  if initializing then return true end
  if type(widget.CanBeAccessedInContext) ~= "function" then return false end
  local ok, allowed = pcall(widget.CanBeAccessedInContext, widget)
  return ok and not (issecretvalue and issecretvalue(allowed)) and allowed == true
end

local function CreateNative(owner, initialize)
  local native = {owner = owner}
  local container = CreateFrame("AuraContainer", nil, owner, "CustomAuraContainerTemplate")
  native.container = container
  container:SetEnabled(false)
  container:SetAllPoints(owner)
  container:SetFrameLevel(owner:GetFrameLevel())
  container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  container:AddAuraSlot("Timer", "HELPFUL", {
    candidateFilters = {includeSpellIDs = {}},
    initializeFrame = function(button)
      native.button = button
      button:SetAllPoints(container)
      button:SetFrameLevel(container:GetFrameLevel())
      button:EnableMouse(false)
      initialize(native, button)
    end,
  })
  owner:HookScript("OnHide", function() container:SetEnabled(false) end)
  owner:HookScript("OnShow", function() container:SetEnabled(native.wanted == true) end)
  return native
end

local function DisableNative(native)
  if native and native.wanted then
    native.wanted = false
    native.container:SetEnabled(false)
  end
end

local function BindNative(native, unit, filter, ids)
  local ordered, include = {}, {}
  for _, id in ipairs(ids) do
    if not (issecretvalue and issecretvalue(id)) and type(id) == "number" and id > 0 and not include[id] then
      include[id] = true
      ordered[#ordered + 1] = id
    end
  end
  table.sort(ordered)
  local key = unit .. ":" .. filter .. ":" .. table.concat(ordered, ",")
  if native.key ~= key then
    native.container:SetEnabled(false)
    native.container:SetUnit(unit)
    native.container:SetAuraSlotFilterString("Timer", filter)
    native.container:SetAuraSlotCandidateFilters("Timer", {includeSpellIDs = include})
    native.key = key
  end
  if native.key ~= native.enabledKey or not native.wanted then
    native.wanted = true
    native.enabledKey = native.key
    native.container:SetEnabled(native.owner:IsVisible())
  end
end

function Display.Modify(region, data)
  DisableNative(region.cdmAuraTimer)
  region.cdmProgressData = data
  region.cdmNativeProgress = nil
end

function Display.Update(region)
  region.cdmNativeProgress = nil
  local unit, filter, ids = NativeSource(SourceState(region))
  local data = region.cdmProgressData
  if region.regionType ~= "icon" or not data or not data.cooldown or not unit then
    DisableNative(region.cdmAuraTimer)
    return
  end
  if not region.cdmAuraTimer then
    region.cdmAuraTimer = CreateNative(region, function(native, button)
      native.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
      native.cooldown:SetAllPoints(region.icon)
      native.cooldown:SetDrawBling(false)
      native.cooldown:SetFrameLevel(button:GetFrameLevel())
      Display.Style(region, native)
      button:SetDurationCooldown(native.cooldown)
    end)
  end
  region.cdmNativeProgress = true
  region.cooldown:Hide()
  Display.Style(region)
  BindNative(region.cdmAuraTimer, unit, filter, ids)
end

function Display.SyncFrameLevels(region)
  local native = region.cdmAuraTimer
  if not native then return end
  local level = region.cooldown:GetFrameLevel()
  native.container:SetFrameLevel(level)
end

function Display.Style(region, initializing)
  local native = initializing or region.cdmAuraTimer
  if not native then return end
  Display.SyncFrameLevels(region)
  if not CanStyleWidget(native.cooldown, initializing) then return end
  local cooldown = native.cooldown
  cooldown:SetDrawSwipe(region.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(region.cooldownEdge == true)
  cooldown:SetReverse(region.inverseDirection == true)
  cooldown:SetHideCountdownNumbers(region.cdmConfiguredHideNumbers == true)
end

function Display.StyleText(sub, initializing)
  local native, config = initializing or sub.cdmAuraTimer, sub.cdmTextConfig
  if not native or not config then return end
  native.stylePending = true
  if not CanStyleWidget(native.text, initializing) then return end
  local font, size, flags = sub.text:GetFont()
  if not font then return end
  Private.ApplyTextFont(native.text, nil, font, size, flags,
    config.text_shadowColor, config.text_shadowXOffset, config.text_shadowYOffset)
  native.text:SetTextColor(sub.color_anim_r or sub.color_r or 1,
    sub.color_anim_g or sub.color_g or 1, sub.color_anim_b or sub.color_b or 1,
    sub.color_anim_a or sub.color_a or 1)
  native.text:SetJustifyH(config.text_justify or "CENTER")
  native.text:SetWidth(config.text_automaticWidth == "Fixed" and config.text_fixedWidth or 0)
  local wrap = config.text_automaticWidth ~= "Fixed" or config.text_wordWrap == "WordWrap"
  native.text:SetWordWrap(wrap)
  native.text:SetNonSpaceWrap(wrap)
  if sub.AnchorNativeText then sub:AnchorNativeText(native.text) end
  native.stylePending = nil
end

function Display.ModifyText(parent, sub, parentData, config)
  sub.cdmTextConfig = config
  Display.StyleText(sub)
end

function Display.HideText(sub)
  DisableNative(sub.cdmAuraTimer)
  sub.cdmNativeText = nil
end

function Display.UpdateText(parent, sub, config, kind, explicitTrigger)
  if not kind then Display.HideText(sub); return false end
  local state = SourceState(parent, explicitTrigger)
  if not state or not state.cdmBuff then Display.HideText(sub); return false end
  if not sub.text:GetFont() then return true end
  local unit, filter, ids = NativeSource(state)
  if unit and (kind == "p" or kind == "bp") then
    sub.cdmTextConfig = config
    if not sub.cdmAuraTimer then
      sub.cdmAuraTimer = CreateNative(sub, function(native, button)
        native.text = button:CreateFontString(nil, "OVERLAY")
        native.text:SetFont(sub.text:GetFont())
        Display.StyleText(sub, native)
        button:SetDurationText(native.text, {
          textFormatter = Private.GetDurationTextFormatter(99, 0, 0),
        })
      end)
    end
    local native = sub.cdmAuraTimer
    if native.stylePending then Display.StyleText(sub) end
    local level = sub:GetFrameLevel()
    native.container:SetFrameLevel(level)
    sub.cdmNativeText = true
    sub.text:SetText("")
    BindNative(native, unit, filter, ids)
    return true
  end
  Display.HideText(sub)
  Private.CopyCDMCountdownText(sub.text, state, kind)
  if sub.UpdateAnchorOnTextChange then sub:UpdateAnchorOnTextChange() end
  return true
end

function Display.ModifyIndicator(parent, sub, parentData, config)
  Display.ReleaseIndicator(sub)
end
function Display.ReleaseIndicator(sub, forget)
  if sub.preview then sub.preview:Hide() end
  if sub.dispelBorder then sub.dispelBorder:Hide() end
  if sub.dispelEdges then Private.DispelTypeDisplay.Hide(sub.dispelEdges) end
end
function Display.UpdateIndicator(parent, sub, config)
  local state = SourceState(parent)
  local dispel
  if sub.visible and state and state.show and state.cdmBuff then
    dispel = state.cdmTextPreview and "Magic" or state.cdmDispelName
  end
  if (issecretvalue and issecretvalue(dispel)) or type(dispel) ~= "string" or dispel == "" then
    Display.ReleaseIndicator(sub); return
  end
  Display.ReleaseIndicator(sub)
  if sub.dispelEdges then
    for _, edge in ipairs(sub.dispelEdges) do
      AuraUtil.SetAuraBorderColor(edge, dispel)
      edge:Show()
    end
  elseif sub.preview then
    AuraUtil.SetAuraDispelTypeIcon(sub.preview, dispel)
    sub.preview:SetVertexColor(1, 1, 1, 1)
    sub.preview:Show()
  end
end
