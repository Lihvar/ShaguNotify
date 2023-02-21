local frame = CreateFrame("Frame")
local combat = CreateFrame("Frame")

combat:RegisterEvent("PLAYER_ENTER_COMBAT")
combat:RegisterEvent("PLAYER_LEAVE_COMBAT")
combat:SetScript("OnEvent", function(_, event)
  frame.inCombat = event == "PLAYER_ENTER_COMBAT"
end)

frame:RegisterEvent("UNIT_HEALTH")
frame:SetScript("OnEvent", function(_, event, arg1)
  if event == "UNIT_HEALTH" and arg1 == "player" and frame.inCombat then
    local perc = UnitHealth("player") / UnitHealthMax("player") * 100
    if perc < 5 or UnitHealth("player") <= 5 then
      frame.waslow = true
    end
  end

  if UnitHealth("player") < 0 or UnitIsDead("player") then
    frame.waslow = nil
  end
end)

frame:SetScript("OnUpdate", function()
  if not frame.waslow then return end
  if combat.inCombat then return end

  frame.waslow = nil
  libnotify:ShowPopup("I will survive!", UnitLevel("player"), "Interface\\Icons\\INV_Misc_Bomb_04", true)
end)
