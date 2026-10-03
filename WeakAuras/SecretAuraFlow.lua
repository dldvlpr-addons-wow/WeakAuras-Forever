if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay

Display.flowGrowths = {RIGHT = "Right", LEFT = "Left", DOWN = "Down", UP = "Up",
  CENTER_HORIZONTAL = "Centered Horizontal", CENTER_VERTICAL = "Centered Vertical"}

local GROWTH = {
  RIGHT = {start = "TOPLEFT", listEnd = "TOPRIGHT", pixel = {-1, 0}, far = "TOPRIGHT", sign = {1, 0}},
  LEFT = {start = "TOPRIGHT", listEnd = "TOPLEFT", pixel = {1, 0}, far = "TOPLEFT", sign = {-1, 0}},
  DOWN = {start = "TOPLEFT", listEnd = "BOTTOMLEFT", pixel = {0, 1}, far = "BOTTOMLEFT", sign = {0, -1}},
  UP = {start = "BOTTOMLEFT", listEnd = "TOPLEFT", pixel = {0, -1}, far = "TOPLEFT", sign = {0, 1}},
}
local function Centered(visible, shadow, centerPoint)
  local result = CopyTable(GROWTH[visible])
  result.visible, result.shadow, result.centerPoint = visible, GROWTH[shadow], centerPoint
  return result
end
GROWTH.CENTER_HORIZONTAL = Centered("RIGHT", "LEFT", "TOP")
GROWTH.CENTER_VERTICAL = Centered("DOWN", "UP", "LEFT")

function Display.VisibleGrowth(growth)
  return GROWTH[growth] and GROWTH[growth].visible or growth
end

function Display.FlowGroup(data)
  local parent = data and data.parent and WeakAuras.GetData(data.parent)
  if parent and parent.regionType == "group" and parent.blizzardFlow then return parent end
end

local function GrowthKey(group)
  local growth = GROWTH[group.blizzardFlowGrowth] and group.blizzardFlowGrowth or "RIGHT"
  local mode = group.blizzardFlowFrames
  if mode ~= "UNITFRAME" and mode ~= "NAMEPLATE" then return growth end
  local selfPoint = group.selfPoint or "CENTER"
  if growth == "CENTER_HORIZONTAL" then
    if selfPoint:find("LEFT") then return "RIGHT" end
    if selfPoint:find("RIGHT") then return "LEFT" end
  elseif growth == "CENTER_VERTICAL" then
    if selfPoint:find("TOP") then return "DOWN" end
    if selfPoint:find("BOTTOM") then return "UP" end
  end
  return growth
end
Display.FlowGrowthKey = GrowthKey

function Display.FlowGrowth(data)
  local group = Display.FlowGroup(data)
  if not group then return end
  return GrowthKey(group), tonumber(group.blizzardFlowSpacing) or 2
end

Display.flowFrameModes = {SCREEN = "Screen", UNITFRAME = "Unit Frames", NAMEPLATE = "Nameplates"}

function Display.FlowFrameMode(data)
  local group = Display.FlowGroup(data)
  local mode = group and group.blizzardFlowFrames
  if mode == "UNITFRAME" or mode == "NAMEPLATE" then return mode end
end

function Display.SortOrder(data, trigger)
  local group = Display.FlowGroup(data)
  local method, reverse
  if group then
    method, reverse = group.blizzardFlowSort, group.blizzardFlowReverse
  else
    method, reverse = trigger.sortMethod, trigger.sortReverse
  end
  if not Display.sortMethods[method or "Default"] or method == "UnitFrameDebuff" then method = "Default" end
  return AuraContainerSortMethod[method or "Default"],
    reverse and AuraContainerSortDirection.Reverse or AuraContainerSortDirection.Normal
end

function Display.FrameAnchorType(data)
  if Display.FlowGroup(data) then return Display.FlowFrameMode(data) or "SCREEN" end
  return data.anchorFrameType
end

function Display.FlowLimit(data)
  local group = Display.FlowGroup(data)
  if not group then return end
  if not group.blizzardFlowUseLimit then return 20 end
  return math.max(1, math.floor(tonumber(group.blizzardFlowLimit) or 5))
end

function Display.FlowProblem(data, trigger)
  if not Display.FlowGroup(data) then return end
  if data.regionType ~= "icon" then return "In a Modern Aura Group, use an Icon display." end
  if Display.RemainingWindow(trigger) then return "In a Modern Aura Group, Remaining Time is not available yet." end
  local mode = Display.FlowFrameMode(data)
  if mode then
    if Display.IsSingle(trigger) then return "Grouped by unit frame or nameplate, use Show On: Aura(s) Found." end
    if mode == "NAMEPLATE" and trigger.unit ~= "nameplate" then return "Grouped by nameplate, choose the Nameplate unit." end
    if mode == "UNITFRAME" and trigger.unit == "nameplate" then return "Grouped by unit frame, choose a unit other than Nameplate." end
  end
end

function Display.CreateAuraContainer(parent, data)
  if Display.FlowGroup(data) then
    local ok, container = pcall(CreateFrame, "AuraContainer", nil, parent,
      "CustomAuraContainerTemplate, DisableUntrustedLayoutScriptsTemplate")
    if ok and container then return container, true end
  end
  return CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate"), false
end

function Display.AnchorToContent(container, point, region, relativePoint, x, y)
  local anchor = Display.ContentAnchor(region)
  if anchor ~= region and pcall(container.SetPoint, container, point, anchor, relativePoint, x or 0, y or 0) then return true end
  container:ClearAllPoints()
  container:SetPoint(point, region, relativePoint, x or 0, y or 0)
  return anchor == region
end

function Display.ContentAnchor(region)
  local native = region.blizzardAuraDisplay
  return native and native.flow and native.flow.start or region
end

function Display.EnsureFlowStart(region, data)
  local native = region.blizzardAuraDisplay
  if not Display.FlowGroup(data) then
    if native.flow then native.flow.start:Hide(); native.flow = nil end
    return
  end
  local flow = native.flow or {}
  native.flow = flow
  if not flow.start then
    flow.start = CreateFrame("Frame", nil, region, "DisableUntrustedLayoutScriptsTemplate")
    flow.start:EnableMouse(false)
  end
  local width, height = Display.Dimensions(data)
  flow.start:SetSize(width, height)
  flow.start:Show()
  local growth = Display.FlowGrowth(data)
  flow.growth = GROWTH[growth]
  flow.start:ClearAllPoints()
  flow.start:SetPoint(flow.growth.start, region, flow.growth.start)
end

function Display.SetFlowEnd(region, data, presence)
  local native = region.blizzardAuraDisplay
  local flow = native and native.flow
  if not flow then return end
  local g = flow.growth
  local trigger = Display.GetTrigger(data)
  local _, spacing = Display.FlowGrowth(data)
  local width, height = Display.Dimensions(data)
  local showOn = Display.ShowOn(trigger)
  if showOn == "showOnMissing" and presence then
    flow.endFrame, flow.endPoint, flow.x, flow.y = presence, g.start, 0, 0
  elseif showOn == "showOnActive" and not Display.UsesGate(data) and native.instances[1] then
    flow.endFrame, flow.endPoint = native.instances[#native.instances].container, g.listEnd
    flow.x, flow.y = g.pixel[1], g.pixel[2]
  else
    flow.endFrame, flow.endPoint = flow.start, g.start
    flow.x, flow.y = g.sign[1] * (width + spacing), g.sign[2] * (height + spacing)
  end
end

function Display.FlowPresenceSize(data)
  local growth, spacing = Display.FlowGrowth(data)
  local width, height = Display.Dimensions(data)
  local along = GROWTH[growth].sign[1] ~= 0
  local size = (along and width or height) + spacing + 1
  return along and {elementWidth = size, elementHeight = height} or {elementWidth = width, elementHeight = size}
end

local OPPOSITE = {TOPLEFT = "TOPRIGHT", TOPRIGHT = "TOPLEFT", BOTTOMLEFT = "TOPLEFT"}
local function AnchorBackwards(container, g, startFrame, size, region)
  local along = g.sign[1] ~= 0
  local point = along and OPPOSITE[g.start] or (g.start == "TOPLEFT" and "BOTTOMLEFT" or "TOPLEFT")
  container:ClearAllPoints()
  local ok = pcall(container.SetPoint, container, point, startFrame, g.start, g.sign[1] * size, g.sign[2] * size)
  if not ok then
    container:ClearAllPoints()
    container:SetPoint("TOPLEFT", region, "TOPLEFT")
  end
  return ok
end

function Display.AnchorFlowPresence(region, data, container)
  local flow = region.blizzardAuraDisplay and region.blizzardAuraDisplay.flow
  if not flow then return false end
  local layout = Display.FlowPresenceSize(data)
  local along = flow.growth.sign[1] ~= 0
  return AnchorBackwards(container, flow.growth, flow.start, along and layout.elementWidth or layout.elementHeight, region)
end

local SHADOW_GROUP = "FAShadow"
local function MeasureContainer(existing, region, data, g, layout, maxCount, filter, candidates)
  local container = existing
  if not container then
    container = Display.CreateAuraContainer(region, data)
    container:SetEnabled(false)
    container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    container:SetPoint("TOPLEFT", region, "TOPLEFT")
    local ok = pcall(container.AddAuraGroup, container, SHADOW_GROUP, filter, {
      candidateFilters = candidates, maxFrameCount = maxCount, layout = layout,
      initializeFrame = function(button)
        button:SetSize(layout.elementWidth, layout.elementHeight)
        button:SetAlpha(0)
        button:EnableMouse(false)
      end,
    })
    if not ok then container:Hide(); return nil end
  else
    container:SetAuraGroupFilterString(SHADOW_GROUP, filter)
    container:SetAuraGroupCandidateFilters(SHADOW_GROUP, candidates)
    container:SetAuraGroupLayout(SHADOW_GROUP, layout)
    container:SetAuraGroupMaxFrameCount(SHADOW_GROUP, maxCount)
    container:SetAuraGroupEnabled(SHADOW_GROUP, true)
  end
  local vertical = g.sign[2] ~= 0
  container:SetFlowLayoutAxis(vertical and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
  container:SetFlowLayoutAnchorPoint(g.start)
  container:SetFlowLayoutGrowthDirection(g.sign[1] < 0 and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right,
    g.sign[2] > 0 and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down)
  return container
end

local function HideShadow(holder, key)
  local container = holder and holder[key]
  if container then
    holder[key .. "Active"] = false
    container:SetEnabled(false)
    container:Hide()
  end
end

function Display.EnsureFlowShadows(region, data)
  local native = region.blizzardAuraDisplay
  local flow = native and native.flow
  local sh = flow and flow.growth.shadow
  local missing = native and native.instances[1] and native.instances[1].single and native.instances[1].single.missing
  for _, instance in ipairs(native and native.instances or {}) do
    if not sh then HideShadow(instance, "flowShadow") end
  end
  if not sh then
    HideShadow(missing, "flowShadow")
    if flow and flow.shadowStart then flow.shadowStart:Hide() end
    return
  end
  if not flow.shadowStart then
    flow.shadowStart = CreateFrame("Frame", nil, region, "DisableUntrustedLayoutScriptsTemplate")
    flow.shadowStart:EnableMouse(false)
    flow.shadowStart:SetSize(1, 1)
  end
  flow.shadowStart:Show()
  local trigger = Display.GetTrigger(data)
  local _, spacing = Display.FlowGrowth(data)
  local width, height = Display.Dimensions(data)
  local along = sh.sign[1] ~= 0
  flow.half = ((along and width or height) + spacing) / 2
  local size = flow.half + 1
  local layout = along and {elementWidth = size, elementHeight = height, elementSpacing = -1}
    or {elementWidth = width, elementHeight = size, elementSpacing = -1}
  local filter, candidates = Display.FilterString(trigger), Display.CandidateFilters(data)
  local showOn = Display.ShowOn(trigger)
  flow.shadowKind, flow.shadowList = "fixed", nil
  if showOn == "showOnActive" and not Display.UsesGate(data) then
    flow.shadowList = {}
    for _, instance in ipairs(native.instances) do
      instance.flowShadow = MeasureContainer(instance.flowShadow, region, data, sh, layout, Display.MaxAuras(data), filter, candidates)
      instance.flowShadowActive = instance.flowShadow ~= nil
      if instance.flowShadow then flow.shadowList[#flow.shadowList + 1] = instance.flowShadow end
    end
    if #flow.shadowList > 0 then flow.shadowKind = "list" end
  else
    for _, instance in ipairs(native.instances) do HideShadow(instance, "flowShadow") end
  end
  if showOn == "showOnMissing" and missing and missing.active then
    local single = {elementWidth = along and size or width, elementHeight = along and height or size}
    missing.flowShadow = MeasureContainer(missing.flowShadow, region, data, sh, single, 1, filter, candidates)
    missing.flowShadowActive = missing.flowShadow ~= nil
      and AnchorBackwards(missing.flowShadow, sh, flow.shadowStart, size, region)
    missing.flowShadowBoundUnit = nil
    if missing.flowShadowActive then flow.shadowKind = "missing" end
  else
    HideShadow(missing, "flowShadow")
  end
end

function Display.RefreshFlowShadow(instance, unit, shown)
  local container = instance.flowShadowActive and instance.flowShadow
  if not container then return end
  if unit and instance.flowShadowUnit ~= unit then
    container:SetEnabled(false)
    container:SetUnit(unit)
    instance.flowShadowUnit = unit
  end
  container:SetShown(shown)
  container:SetEnabled(shown)
  if shown then container:UpdateAllAuras() end
end

local function ChainShadows(flow)
  local sh = flow.growth.shadow
  if flow.shadowKind == "list" then
    for index, container in ipairs(flow.shadowList) do
      container:ClearAllPoints()
      if index == 1 then
        pcall(container.SetPoint, container, sh.start, flow.shadowStart, sh.start)
      else
        pcall(container.SetPoint, container, sh.start, flow.shadowList[index - 1], sh.listEnd, sh.pixel[1], sh.pixel[2])
      end
    end
    return {flow.shadowList[#flow.shadowList], sh.listEnd, sh.pixel[1], sh.pixel[2]}
  elseif flow.shadowKind == "missing" then
    local single = flow.region.blizzardAuraDisplay.instances[1].single.missing
    return {single.flowShadow, sh.start, 0, 0}
  end
  return {flow.shadowStart, sh.start, sh.sign[1] * flow.half, sh.sign[2] * flow.half}
end

local function NameplatePreview(group)
  if not (Private.ensurePRDFrame and WeakAuras.IsOptionsOpen()) then return end
  Private.ensurePRDFrame()
  local frame = Private.personalRessourceDisplayFrame
  if frame and frame.anchorFrame then frame:anchorFrame(group.id, "NAMEPLATE") end
  return frame
end

local function MovePreviewRegion(region, button)
  if not (region.SetAnchor and region.SetOffset) then return end
  if region.relativeTo ~= button and not (type(region.relativeTo) == "table" and region.relativeTo.bindings) then
    region.flowPreviewSaved = {region.anchorPoint, region.relativeTo, region.relativePoint,
      region.GetXOffset and region:GetXOffset() or 0, region.GetYOffset and region:GetYOffset() or 0}
  end
  region:SetAnchor("TOPLEFT", button, "TOPLEFT")
  region:SetOffset(0, 0)
end

function Display.RestorePreviewRegion(region)
  local saved = region and region.flowPreviewSaved
  if not saved then return end
  region.flowPreviewSaved = nil
  if saved[1] and saved[2] then region:SetAnchor(saved[1], saved[2], saved[3]) end
  region:SetOffset(saved[4], saved[5])
end

local function SetGroupPreviewBounds(group, g, length, cross, ox, oy)
  local entry = Private.regions[group.id]
  local region = entry and entry.region
  if not region then return end
  local blx, bly, trx, try
  if g.sign[1] > 0 then blx, trx, try, bly = 0, length, 0, -cross
  elseif g.sign[1] < 0 then blx, trx, try, bly = -length, 0, 0, -cross
  elseif g.sign[2] < 0 then blx, trx, try, bly = 0, cross, 0, -length
  else blx, trx, bly, try = 0, cross, 0, length end
  blx, trx, bly, try = blx + ox, trx + ox, bly + oy, try + oy
  if region.GetBoundingRect ~= region.flowPreviewBoundsFn then
    region.flowPreviewBoundsSaved = region.GetBoundingRect
  end
  region.flowPreviewBoundsFn = function(self)
    self.blx, self.bly, self.trx, self.try = blx, bly, trx, try
    return blx, bly, trx, try
  end
  region.GetBoundingRect = region.flowPreviewBoundsFn
  region:GetBoundingRect()
end

function Display.RestoreGroupPreview(group)
  local entry = group and Private.regions[group.id]
  local region = entry and entry.region
  if not region then return end
  if region.flowPreviewBoundsSaved then
    if region.GetBoundingRect == region.flowPreviewBoundsFn then region.GetBoundingRect = region.flowPreviewBoundsSaved end
    region.flowPreviewBoundsSaved, region.flowPreviewBoundsFn = nil, nil
    region.boundingRect = false
    region:GetBoundingRect()
  end
end

function Display.ReleaseNameplatePreview(group)
  local frame = Private.personalRessourceDisplayFrame
  if group and frame and frame.anchorFrame then frame:anchorFrame(group.id, nil) end
end

local function FramePosition(group)
  return group.anchorPoint or "CENTER", tonumber(group.xOffset) or 0, tonumber(group.yOffset) or 0
end

local function CrossOffset(group, g, cross)
  local selfPoint = group.selfPoint or "CENTER"
  if g.sign[1] ~= 0 then
    if selfPoint:find("TOP") then return 0, 0 end
    if selfPoint:find("BOTTOM") then return 0, cross end
    return 0, cross / 2
  end
  if selfPoint:find("LEFT") then return 0, 0 end
  if selfPoint:find("RIGHT") then return -cross, 0 end
  return -cross / 2, 0
end

local function AlignedPoints(group, g)
  local selfPoint = group.selfPoint or "CENTER"
  local horizontal = g.sign[1] ~= 0
  local cross
  if horizontal then
    cross = selfPoint:find("TOP") and "TOP" or selfPoint:find("BOTTOM") and "BOTTOM" or ""
  else
    cross = selfPoint:find("LEFT") and "LEFT" or selfPoint:find("RIGHT") and "RIGHT" or ""
  end
  local function Align(point)
    if horizontal then return cross .. (point:find("LEFT") and "LEFT" or "RIGHT") end
    return (point:find("TOP") and "TOP" or "BOTTOM") .. cross
  end
  return Align(g.start), Align(g.listEnd), Align(g.far)
end

local function UnitAnchor(mode, unit)
  local frame = mode == "UNITFRAME" and WeakAuras.GetUnitFrame(unit) or (mode == "NAMEPLATE" and C_NamePlate.GetNamePlateForUnit(unit))
  if frame and not frame:IsForbidden() then return frame end
end

local batch
function Display.BeginFlowBatch() batch = batch or {} end
function Display.EndFlowBatch()
  local groups = batch
  batch = nil
  for group in pairs(groups or {}) do Display.RelinkFlowUnits(group) end
end

function Display.RelinkFlowUnits(group)
  local mode = group and group.blizzardFlowFrames
  if mode ~= "UNITFRAME" and mode ~= "NAMEPLATE" then return end
  if batch then batch[group] = true; return end
  local g = GROWTH[GrowthKey(group)]
  local point, frameX, frameY = FramePosition(group)
  local start, listEnd = AlignedPoints(group, g)
  local spacing = tonumber(group.blizzardFlowSpacing) or 2
  local lastShadow = {}
  local sh = g.shadow
  local shStart, shEnd
  if sh then shStart, shEnd = AlignedPoints(group, sh) end
  if sh then
    for _, childID in ipairs(group.controlledChildren or {}) do
      local entry = Private.regions[childID]
      local native = entry and entry.region and entry.region.blizzardAuraDisplay
      if native and native.active then
        for _, instance in ipairs(native.instances) do
          local unit = instance.visible and instance.boundUnit
          local shadow = unit and instance.flowShadowActive and instance.flowShadow
          if shadow then
            shadow:ClearAllPoints()
            local linked = lastShadow[unit] and pcall(shadow.SetPoint, shadow, shStart, lastShadow[unit], shEnd, sh.pixel[1], sh.pixel[2])
            local frame = not linked and UnitAnchor(mode, unit)
            if frame then shadow:SetPoint(shStart, frame, point, frameX, frameY) end
            lastShadow[unit] = shadow
          end
        end
      end
    end
  end
  local last = {}
  for _, childID in ipairs(group.controlledChildren or {}) do
    local entry = Private.regions[childID]
    local native = entry and entry.region and entry.region.blizzardAuraDisplay
    if native and native.active then
      for _, instance in ipairs(native.instances) do
        local unit = instance.visible and instance.boundUnit
        if unit then
          local container = instance.container
          container:ClearAllPoints()
          local linked = last[unit] and pcall(container.SetPoint, container, start, last[unit], listEnd, g.pixel[1], g.pixel[2])
          if not linked and lastShadow[unit] then
            linked = pcall(container.SetPoint, container, start, lastShadow[unit], shEnd,
              sh.pixel[1] + g.sign[1] * spacing / 2, sh.pixel[2] + g.sign[2] * spacing / 2)
          end
          if not linked then
            local frame = UnitAnchor(mode, unit)
            if frame then
              container:ClearAllPoints()
              container:SetPoint(start, frame, point, frameX, frameY)
            end
          end
          last[unit] = container
        end
      end
    end
  end
end

local MAX_PREVIEW_UNITS = 5
function Display.FlowPreviewUnits(data)
  if Display.FlowFrameMode(data) ~= "UNITFRAME" then return {false} end
  local units = {}
  for _, unit in ipairs(Display.UnitTokens(Display.GetTrigger(data) or {})) do
    if UnitExists(unit) and WeakAuras.GetUnitFrame(unit) then
      units[#units + 1] = unit
      if #units >= MAX_PREVIEW_UNITS then break end
    end
  end
  if #units == 0 then units[1] = "player" end
  return units
end

local function PreviewFrame(group, unit)
  local frame
  if group.blizzardFlowFrames == "NAMEPLATE" then
    frame = NameplatePreview(group)
  elseif unit then
    frame = WeakAuras.GetUnitFrame(unit)
  end
  if frame and not frame:IsForbidden() then return frame end
end

function Display.FlowPreviewFrame(group)
  local mode = group and group.blizzardFlow and group.blizzardFlowFrames
  if (mode ~= "UNITFRAME" and mode ~= "NAMEPLATE") or not WeakAuras.IsOptionsOpen() then return end
  local unit
  for _, childID in ipairs(group.controlledChildren or {}) do
    local child = WeakAuras.GetData(childID)
    if child and Display.Enabled(child) then
      unit = Display.FlowPreviewUnits(child)[1]
      break
    end
  end
  return PreviewFrame(group, unit or "player")
end

function Display.ArrangeFlowPreview(group)
  if not group then return end
  local mode = group.blizzardFlowFrames
  local framed = mode == "UNITFRAME" or mode == "NAMEPLATE"
  if mode ~= "NAMEPLATE" then Display.ReleaseNameplatePreview(group) end
  local g = GROWTH[GrowthKey(group)]
  local spacing = tonumber(group.blizzardFlowSpacing) or 2
  local along = g.sign[1] ~= 0
  local point, frameX, frameY = FramePosition(group)
  local function Key(sample) return framed and mode == "UNITFRAME" and sample.previewUnit or "" end
  local length, cross, firstKey = {}, {}, nil
  for _, childID in ipairs(group.controlledChildren or {}) do
    local entry = Private.regions[childID]
    local region = entry and entry.region
    if region and region.secretAuraSamplesActive then
      for _, sample in ipairs(region.secretAuraSamples or {}) do
        local button = sample.button
        if button:IsShown() then
          local key = Key(sample)
          firstKey = firstKey or key
          local width, height = button:GetWidth() or 0, button:GetHeight() or 0
          length[key] = (length[key] or 0) + (along and width or height) + spacing
          cross[key] = math.max(cross[key] or 0, along and height or width)
        end
      end
    end
  end
  local function Offset(key)
    if not g.shadow then return 0, 0 end
    local half = math.max(0, (length[key] or 0) - spacing) / 2
    return -g.sign[1] * half, -g.sign[2] * half
  end
  local previous = {}
  local onFrame = false
  for _, childID in ipairs(group.controlledChildren or {}) do
    local entry = Private.regions[childID]
    local region = entry and entry.region
    if region and region.secretAuraSamplesActive then
      local moved = false
      for _, sample in ipairs(region.secretAuraSamples or {}) do
        local button = sample.button
        if button:IsShown() then
          local key = Key(sample)
          local frame = framed and PreviewFrame(group, sample.previewUnit or nil)
          local ox, oy = Offset(key)
          local start, far = g.start, g.far
          if framed then
            local alignedStart, _, alignedFar = AlignedPoints(group, g)
            start, far = alignedStart, alignedFar
          end
          button:ClearAllPoints()
          if previous[key] then
            button:SetPoint(start, previous[key], far, g.sign[1] * spacing, g.sign[2] * spacing)
          elseif frame then
            button:SetPoint(start, frame, point, frameX + ox, frameY + oy)
          elseif g.shadow then
            button:SetPoint(g.start, region, g.centerPoint, ox, oy)
          else
            button:SetPoint(g.start, region, g.start)
          end
          if frame and not moved then
            MovePreviewRegion(region, button)
            moved = true
          end
          onFrame = onFrame or frame ~= nil and frame ~= false
          previous[key] = button
        end
      end
      if not moved then Display.RestorePreviewRegion(region) end
    end
  end
  if onFrame and firstKey then
    local ox, oy = Offset(firstKey)
    local cx, cy = CrossOffset(group, g, cross[firstKey] or 0)
    ox, oy = ox + cx, oy + cy
    SetGroupPreviewBounds(group, g, math.max(0, (length[firstKey] or 0) - spacing), cross[firstKey] or 0, ox, oy)
  else
    Display.RestoreGroupPreview(group)
  end
end

local staleRebuilds = {}
local function StaleGrowth(group, childID)
  local entry = Private.regions[childID]
  local native = entry and entry.region and entry.region.blizzardAuraDisplay
  return native and native.active and native.flow and native.flow.growth
    and native.flow.growth ~= GROWTH[GrowthKey(group)] or false
end

function Display.RechainFlow(group)
  if not group then return end
  if group.blizzardFlowFrames == "UNITFRAME" or group.blizzardFlowFrames == "NAMEPLATE" then
    if not InCombatLockdown() then
      for _, childID in ipairs(group.controlledChildren or {}) do
        if StaleGrowth(group, childID) and not staleRebuilds[childID] then
          staleRebuilds[childID] = true
          C_Timer.After(0, function()
            staleRebuilds[childID] = nil
            local child = WeakAuras.GetData(childID)
            if child and not InCombatLockdown() and StaleGrowth(group, childID) then WeakAuras.Add(child) end
          end)
        end
      end
    end
    Display.RelinkFlowUnits(group)
    return
  end
  if InCombatLockdown() then return end
  local flows = {}
  local g = GROWTH[group.blizzardFlowGrowth] or GROWTH.RIGHT
  for _, childID in ipairs(group.controlledChildren or {}) do
    local entry = Private.regions[childID]
    local region = entry and entry.region
    local native = region and region.blizzardAuraDisplay
    local flow = native and native.active and native.flow
    if flow and flow.endFrame and flow.growth == g then
      flow.region = region
      flows[#flows + 1] = flow
    end
  end
  local previous, shadowEnd
  if g.shadow and flows[1] then
    local spacing = tonumber(group.blizzardFlowSpacing) or 2
    for _, flow in ipairs(flows) do
      if flow.shadowStart and flow.shadowKind then
        flow.shadowStart:ClearAllPoints()
        if not (shadowEnd and pcall(flow.shadowStart.SetPoint, flow.shadowStart, g.shadow.start, shadowEnd[1], shadowEnd[2], shadowEnd[3], shadowEnd[4])) then
          flow.shadowStart:ClearAllPoints()
          flow.shadowStart:SetPoint(g.shadow.start, flows[1].region, g.centerPoint)
        end
        shadowEnd = ChainShadows(flow)
      end
    end
    if shadowEnd then
      previous = {endFrame = shadowEnd[1], endPoint = shadowEnd[2],
        x = shadowEnd[3] + g.sign[1] * spacing / 2, y = shadowEnd[4] + g.sign[2] * spacing / 2}
    end
  end
  for _, flow in ipairs(flows) do
    local region = flow.region
    do
      flow.start:ClearAllPoints()
      local chained = previous and pcall(flow.start.SetPoint, flow.start, flow.growth.start,
        previous.endFrame, previous.endPoint, previous.x, previous.y)
      if not chained then
        flow.start:ClearAllPoints()
        flow.start:SetPoint(flow.growth.start, region, flow.growth.start)
      end
      previous = flow
    end
  end
end
