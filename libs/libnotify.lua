libnotify = {}
libnotify.window = {}

libnotify.max_window = 5

-- detect current addon path
local addonpath
local tocs = { "", "-master", "-tbc", "-wotlk" }
for _, name in pairs(tocs) do
  local current = string.format("ShaguNotify%s", name)
  local _, title = GetAddOnInfo(current)
  if title then
    addonpath = "Interface\\AddOns\\" .. current
    break
  end
end

function libnotify:CreateFrame()
  local frame = CreateFrame("Button", "Achievement", UIParent)

  frame:SetWidth(300)
  frame:SetHeight(88)
  frame:SetFrameStrata("DIALOG")
  frame:Hide()

  do -- animations
    frame:SetScript("OnShow", function()
      frame.modifyA = 1
      frame.modifyB = 0
      frame.stateA = 0
      frame.stateB = 0
      frame.animate = true

      frame.showTime = GetTime()
    end)

    frame:SetScript("OnUpdate", function()
      if ( frame.tick or 1) > GetTime() then return else frame.tick = GetTime() + .01 end

      if frame.animate == true then
        if frame.stateA > .50 and frame.modifyA == 1 then
          frame.modifyB = 1
        end

        if frame.stateA > .75 then
          frame.modifyA = -1
        end

        if frame.stateB > .50 then
          frame.modifyB = -1
        end

        frame.stateA = frame.stateA + frame.modifyA/50
        frame.stateB = frame.stateB + frame.modifyB/50

        frame.glow:SetGradientAlpha("HORIZONTAL",
          frame.stateA, frame.stateA, frame.stateA, frame.stateA,
          frame.stateB, frame.stateB, frame.stateB, frame.stateB)

        frame.shine:SetGradientAlpha("VERTICAL",
          frame.stateA, frame.stateA, frame.stateA, frame.stateA,
          frame.stateB, frame.stateB, frame.stateB, frame.stateB)

        if frame.stateA < 0 and frame.stateB < 0 then
          frame.animate = false
        end
      end

      if frame.showTime + 5 < GetTime() then
        frame:SetAlpha(frame:GetAlpha() - .05)
        if frame:GetAlpha() <= 0 then
          frame:Hide()
          frame:SetAlpha(1)
        end
      end
    end)
  end

  frame.background = frame:CreateTexture("background", "BACKGROUND")
  frame.background:SetTexture(addonpath .. "\\textures\\UI-Achievement-Alert-Background")
  frame.background:SetPoint("TOPLEFT", 0, 0)
  frame.background:SetPoint("BOTTOMRIGHT", 0, 0)
  frame.background:SetTexCoord(0, .605, 0, .703)

  frame.unlocked = frame:CreateFontString("Unlocked", "DIALOG", "GameFontBlack")
  frame.unlocked:SetWidth(200)
  frame.unlocked:SetHeight(12)
  frame.unlocked:SetPoint("TOP", 7, -23)
  frame.unlocked:SetText(COMPLETE)

  frame.name = frame:CreateFontString("Name", "DIALOG", "GameFontHighlight")
  frame.name:SetWidth(240)
  frame.name:SetHeight(16)
  frame.name:SetPoint("BOTTOMLEFT", 72, 36)
  frame.name:SetPoint("BOTTOMRIGHT", -60, 36)

  frame.glow = frame:CreateTexture("glow", "OVERLAY")
  frame.glow:SetTexture(addonpath .. "\\textures\\UI-Achievement-Alert-Glow")
  frame.glow:SetBlendMode("ADD")
  frame.glow:SetWidth(400)
  frame.glow:SetHeight(171)
  frame.glow:SetPoint("CENTER", 0, 0)
  frame.glow:SetTexCoord(0, 0.78125, 0, 0.66796875)
  frame.glow:SetAlpha(0)

  frame.shine = frame:CreateTexture("shine", "OVERLAY")
  frame.shine:SetBlendMode("ADD")
  frame.shine:SetTexture(addonpath .. "\\textures\\UI-Achievement-Alert-Glow")
  frame.shine:SetWidth(67)
  frame.shine:SetHeight(72)
  frame.shine:SetPoint("BOTTOMLEFT", 0, 8)
  frame.shine:SetTexCoord(0.78125, 0.912109375, 0, 0.28125)
  frame.shine:SetAlpha(0)

  frame.icon = CreateFrame("Frame", "icon", frame)
  frame.icon:SetWidth(124)
  frame.icon:SetHeight(124)
  frame.icon:SetPoint("TOPLEFT", -26, 16)

  --[[
  frame.icon.backfill = frame.icon:CreateTexture("backfill", "BACKGROUND")
  frame.icon.backfill:SetBlendMode("ADD")
  frame.icon.backfill:SetTexture(addonpath .. "\\textures\\UI-Achievement-IconFrame-Backfill")
  frame.icon.backfill:SetPoint("CENTER", 0, 0)
  frame.icon.backfill:SetWidth(64)
  frame.icon.backfill:SetHeight(64)
  ]]--

  frame.icon.bling = frame.icon:CreateTexture("bling", "BORDER")
  frame.icon.bling:SetTexture(addonpath .. "\\textures\\UI-Achievement-Bling")
  frame.icon.bling:SetPoint("CENTER", -1, 1)
  frame.icon.bling:SetWidth(116)
  frame.icon.bling:SetHeight(116)

  frame.icon.texture = frame.icon:CreateTexture("texture", "ARTWORK")
  frame.icon.texture:SetPoint("CENTER", 0, 3)
  frame.icon.texture:SetWidth(50)
  frame.icon.texture:SetHeight(50)

  frame.icon.overlay = frame.icon:CreateTexture("overlay", "OVERLAY")
  frame.icon.overlay:SetTexture(addonpath .. "\\textures\\UI-Achievement-IconFrame")
  frame.icon.overlay:SetPoint("CENTER", -1, 2)
  frame.icon.overlay:SetHeight(72)
  frame.icon.overlay:SetWidth(72)
  frame.icon.overlay:SetTexCoord(0, 0.5625, 0, 0.5625)

  frame.shield = CreateFrame("Frame", "shield", frame)
  frame.shield:SetWidth(64)
  frame.shield:SetHeight(64)
  frame.shield:SetPoint("TOPRIGHT", -10, -13)

  frame.shield.icon = frame.shield:CreateTexture("icon", "BACKGROUND")
  frame.shield.icon:SetTexture(addonpath .. "\\textures\\UI-Achievement-Shields")
  frame.shield.icon:SetWidth(52)
  frame.shield.icon:SetHeight(48)
  frame.shield.icon:SetPoint("TOPRIGHT", 1, -8)

  frame.shield.points = frame.shield:CreateFontString("Name", "DIALOG", "GameFontWhite")
  frame.shield.points:SetPoint("CENTER", 7, 2)
  frame.shield.points:SetWidth(64)
  frame.shield.points:SetHeight(64)

  return frame
end

function libnotify:ShowPopup(text, points, icon, elite, header)
  for i=1, libnotify.max_window do
    if not libnotify.window[i]:IsVisible() then
      libnotify.window[i].unlocked:SetText(header or COMPLETE)
      libnotify.window[i].name:SetText(text or "DUMMY")
      libnotify.window[i].icon.texture:SetTexture(icon or "Interface\\QuestFrame\\UI-QuestLog-BookIcon")

      if elite then
        libnotify.window[i].shield.icon:SetTexCoord(0, .5 , .5 , 1)
      else
        libnotify.window[i].shield.icon:SetTexCoord(0, .5 , 0 , .5)
      end

      libnotify.window[i].shield.points:SetText(points or "10")
      libnotify.window[i]:Show()

      return
    end
  end
end

for i=1, libnotify.max_window do
  libnotify.window[i] = libnotify:CreateFrame()
  libnotify.window[i]:SetPoint("BOTTOM", 0, 28 + (100*i))
end
