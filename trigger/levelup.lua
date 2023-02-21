local mod = math.mod or mod
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:SetScript("OnEvent", function(self, event, level)
  if event == "PLAYER_LEVEL_UP" then
    local elite = mod(level, 10) == 0 and true or nil
    libnotify:ShowPopup("Level: " .. level, level, "Interface\\Icons\\Spell_ChargePositive", elite)
  end
end)
