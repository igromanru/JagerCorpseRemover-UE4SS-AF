--[[
    Author: Igromanru
    Date: 29.08.2024
    Mod Name: Jager Corpse Remover
]]

------------------------------
-- Don't change code below --
------------------------------

local AFUtils = require("AFUtils.AFUtils")

ModName = "JagerCorpseRemover"
ModVersion = "1.1.3"
DebugMode = true
IsModEnabled = true

LogInfo("Starting mod initialization")

local function NearlyEqual(a, b, tolerance)
    tolerance = tolerance or 3 -- Default tolerance
    return math.abs(a - b) <= tolerance
end

local JagerName = NAME_None
local function GetJagerName()
    if JagerName == NAME_None then
        JagerName = FName("Jager", EFindName.FNAME_Find)
    end
    return JagerName
end

---@return boolean FoundAndRemoved
local function FindAndRemoveJagerCorpse()
    ---@type ANarrativeNPC_Human_ParentBP_C[]?
    local humanNPCs = FindAllOf("NarrativeNPC_Human_ParentBP_C")
    if humanNPCs then
        for _, humanNPC in ipairs(humanNPCs) do
            ---@cast humanNPC ANarrativeNPC_Human_ParentBP_C
            if humanNPC.IsDead and GetJagerName() ~= NAME_None and humanNPC.NarrativeNPC_ConversationRow.RowName == GetJagerName() then
                LogDebug("Found dead Jager, remove")
                ExecuteInGameThread(function()
                    humanNPC:SetActorHiddenInGame(true)
                    humanNPC:SetActorEnableCollision(false)
                    humanNPC:K2_DestroyActor()
                end)
                return true
            end
        end
    end
    return false
end

local KitchenCorpseLocation = { X = -16577.186722, Y = 11621.483725, Z = 9.999998 }
---@return boolean FoundAndRemoved
local function FindAndRemoveKitchenCorpse()
    ---@type ASkeletalMeshActor[]?
    local skeletalMeshActors = FindAllOf("SkeletalMeshActor")
    if skeletalMeshActors then
        for _, actor in ipairs(skeletalMeshActors) do
            local location = actor:K2_GetActorLocation()
            if NearlyEqual(location.X, KitchenCorpseLocation.X) and NearlyEqual(location.Y, KitchenCorpseLocation.Y) and NearlyEqual(location.Z, KitchenCorpseLocation.Z) then
                LogDebug("Found kitchen corpse, remove")
                ExecuteInGameThread(function()
                    actor:SetActorHiddenInGame(true)
                    actor:SetActorEnableCollision(false)
                    actor:K2_DestroyActor()
                end)
                return true
            end
        end
    end

    return false
end


local IsJagerCorpseLoopRunning = false
local function RunFindAndRemoveJagerCorpseLoop()
    if IsJagerCorpseLoopRunning then
        LogDebug("Jager Corpse Loop is already running")
    else
        LogDebug("Starting Jager Corpse Loop")
        IsJagerCorpseLoopRunning = true
        LoopAsync(800, function()
            if FindAndRemoveJagerCorpse() then
                IsJagerCorpseLoopRunning = false
                return true
            end
            return false
        end)
    end
end

local IsKitchenCorpseLoopRunning = false
local function RunFindAndRemoveKitchenCorpseLoop()
    if IsKitchenCorpseLoopRunning then
        LogDebug("Kitchen Corpse Loop is already running")
    else
        LogDebug("Starting Kitchen Corpse Loop")
        IsKitchenCorpseLoopRunning = true
        LoopAsync(800, function()
            if FindAndRemoveKitchenCorpse() then
                IsKitchenCorpseLoopRunning = false
                return true
            end
            return false
        end)
    end
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context, NewPawn)
    -- local playerController = Context:get()
    -- local pawn = NewPawn:get()

    LogDebug("----- [ClientRestart] called -----")
    local gameState = GetGameState()
    if gameState and gameState.MatchState == GetNameWaitingToStart() then
        LogDebug("Starting find and remove loops")
        RunFindAndRemoveJagerCorpseLoop()
        RunFindAndRemoveKitchenCorpseLoop()
    end
    LogDebug("------------------------------")
end)

LogInfo("Mod loaded successfully")
