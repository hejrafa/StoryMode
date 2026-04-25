local addonName, SM = ...

local defaults = {
    version = "1.4.0",
    selectedQuestline = 1,
    viewedLoreChapters = {},
    playedChapters = {},
}

local function ChapterFlagKey(storylineTitle, chapterName)
    return (storylineTitle or "") .. "|" .. (chapterName or "")
end

function SM.ApplySavedVariableDefaults()
    StoryModeDB = StoryModeDB or {}
    for key, value in pairs(defaults) do
        if StoryModeDB[key] == nil then
            StoryModeDB[key] = type(value) == "table" and CopyTable(value) or value
        end
    end
end

function SM.IsLoreChapterViewed(storylineTitle, chapterName)
    if not StoryModeDB or not StoryModeDB.viewedLoreChapters then return false end
    return StoryModeDB.viewedLoreChapters[ChapterFlagKey(storylineTitle, chapterName)] == true
end

function SM.SetLoreChapterViewed(storylineTitle, chapterName)
    if not StoryModeDB then return end
    if not StoryModeDB.viewedLoreChapters then StoryModeDB.viewedLoreChapters = {} end
    StoryModeDB.viewedLoreChapters[ChapterFlagKey(storylineTitle, chapterName)] = true
end

function SM.IsChapterPlayed(storylineTitle, chapterName)
    if not StoryModeDB or not StoryModeDB.playedChapters then return false end
    return StoryModeDB.playedChapters[ChapterFlagKey(storylineTitle, chapterName)] == true
end

function SM.SetChapterPlayed(storylineTitle, chapterName)
    if not StoryModeDB then return end
    if not StoryModeDB.playedChapters then StoryModeDB.playedChapters = {} end
    StoryModeDB.playedChapters[ChapterFlagKey(storylineTitle, chapterName)] = true
end
