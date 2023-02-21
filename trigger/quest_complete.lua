-- quest_complete
-- A notification trigger for quest objective completion

local quests = {}

local function IsCurrentQuest(questID)
  local isComplete = C_QuestLog.GetQuestInfo(questID)
  if isComplete then
    return true
  else
    return nil
  end
end

local function ScanCompletedQuests(silent)
  local numQuests = GetNumQuestLogEntries()
  for i=1, numQuests do
    local questID = GetQuestID(i)
    local title = C_QuestLog.GetQuestInfo(questID)
    if title and IsCurrentQuest(questID) and not quests[title] then
      if not silent then libnotify:ShowPopup(title, nil, nil, nil, nil, true) end
      quests[title] = true
    elseif title and quests[title] and not IsCurrentQuest(questID) then
      -- remove completed quest
      quests[title] = nil
    end
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...)
  if event == "QUEST_LOG_UPDATE" then
    ScanCompletedQuests()
  end

  -- cleanup cached quests (run max. 1 time per second)
  if ( self.tick or 1) > GetTime() then return else self.tick = GetTime() + 1 end
  for title in pairs(quests) do
    local questID = GetQuestID(i)
    if not questID or not IsCurrentQuest(questID) then
      quests[title] = nil
    end
  end
end)
