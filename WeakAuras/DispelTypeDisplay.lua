if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = {}
Private.DispelTypeDisplay = Display

function Display.CreateEdges(owner)
  local edges = {}
  for i = 1, 4 do
    local edge = owner:CreateTexture(nil, "OVERLAY", nil, 0)
    edge:SetTexture("Interface\\Buttons\\WHITE8X8")
    edge:Hide()
    edges[i] = edge
  end
  return edges
end

function Display.Layout(edges, target, data)
  local size = math.max(1, math.min(32, tonumber(data.dispelBorderSize) or 2))
  local offset = tonumber(data.dispelBorderOffset) or 0
  for _, edge in ipairs(edges) do edge:ClearAllPoints() end
  edges[1]:SetPoint("TOPLEFT", target, "TOPLEFT", -offset, offset)
  edges[1]:SetPoint("TOPRIGHT", target, "TOPRIGHT", offset, offset)
  edges[1]:SetHeight(size)
  edges[2]:SetPoint("BOTTOMLEFT", target, "BOTTOMLEFT", -offset, -offset)
  edges[2]:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", offset, -offset)
  edges[2]:SetHeight(size)
  edges[3]:SetPoint("TOPLEFT", target, "TOPLEFT", -offset, offset)
  edges[3]:SetPoint("BOTTOMLEFT", target, "BOTTOMLEFT", -offset, -offset)
  edges[3]:SetWidth(size)
  edges[4]:SetPoint("TOPRIGHT", target, "TOPRIGHT", offset, offset)
  edges[4]:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", offset, -offset)
  edges[4]:SetWidth(size)
end

function Display.Hide(edges)
  for _, edge in ipairs(edges or {}) do edge:Hide() end
end

function Display.Bind(button, edges)
  local style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset
  if style == nil then return end
  for _, edge in ipairs(edges) do
    button:AddDispelTypeTexture(edge, {showWhenHelpful = true, showWhenHarmful = true, style = style})
  end
end

function Display.Migrate(data)
  local elements = data.subRegions or {}
  local count = #elements
  for index = 1, count do
    local element = elements[index]
    local style = element.type == "subcdmdispel" and element.dispelStyle
    if style == "Border" or style == "BorderWithIcon" then
      local border = style == "Border" and element or CopyTable(element)
      border.type, border.dispelStyle = "subcdmdispelborder", nil
      border.dispelBorderSize = border.dispelBorderSize or 2
      border.dispelBorderOffset = border.dispelBorderOffset or 0
      if border.anchor_mode ~= "area" then border.xOffset, border.yOffset = 0, 0 end
      border.anchor_mode = "area"
      border.anchor_area = border.anchor_area or (data.regionType == "aurabar" and "bar" or "ALL")
      if style == "BorderWithIcon" then
        element.dispelStyle = "Icon"
        elements[#elements + 1] = border
        local oldProperty = "sub." .. index .. ".dispelVisible"
        local newProperty = "sub." .. #elements .. ".dispelVisible"
        for _, condition in ipairs(data.conditions or {}) do
          local changes = condition.changes or {}
          for i = 1, #changes do
            if changes[i].property == oldProperty then
              local copy = CopyTable(changes[i]); copy.property = newProperty
              changes[#changes + 1] = copy
            end
          end
        end
      end
    end
  end
end
