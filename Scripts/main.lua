--[[
    Author: Igromanru
    Date: 29.08.2024
    Mod Name: Jager Corpse Remover
]]

------------------------------
-- Don't change code below --
------------------------------

ModName = "JagerCorpseRemover"
ModVersion = "1.0.0"

function GetModInfoPrefix()
    return string.format("[%s v%s]", ModName, ModVersion)
end

print(GetModInfoPrefix() .. " Starting mod initialization")

local JagerName = NAME_None
local function GetJagerName()
    if JagerName == NAME_None then
        JagerName = FName("Jager", EFindName.FNAME_Find)
    end
    return JagerName
end

LoopAsync(200, function()
    local humanNPCs = FindAllOf("NarrativeNPC_Human_ParentBP_C")
    if humanNPCs then
        for i, humanNPC in ipairs(humanNPCs) do
            ---@cast humanNPC ANarrativeNPC_Human_ParentBP_C
            local JagerName = GetJagerName()
            if humanNPC.IsDead and JagerName ~= NAME_None and humanNPC.NarrativeNPC_ConversationRow.RowName == JagerName then
                ExecuteInGameThread(function()
                    humanNPC:K2_DestroyActor()
                end)
                return true
            end
        end
    end
    return false
end)

print(GetModInfoPrefix() .. " Mod loaded successfully")
