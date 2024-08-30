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
ModVersion = "1.1.2"
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

local JagerCorpseWasRemoved = false
local function FindAndRemoveJagerCorpse()
    if JagerCorpseWasRemoved then return true end
    LogDebug("FindAndRemoveJagerCorpse: Search Tick")

    ---@type ANarrativeNPC_Human_ParentBP_C[]?
    local humanNPCs = FindAllOf("NarrativeNPC_Human_ParentBP_C")
    if humanNPCs then
        for i, humanNPC in ipairs(humanNPCs) do
            ---@cast humanNPC ANarrativeNPC_Human_ParentBP_C
            if humanNPC.IsDead and GetJagerName() ~= NAME_None and humanNPC.NarrativeNPC_ConversationRow.RowName == GetJagerName() then
                LogDebug("Found dead Jager, remove")
                ExecuteInGameThread(function()
                    humanNPC:SetActorHiddenInGame(true)
                    humanNPC:SetActorEnableCollision(false)
                    humanNPC:K2_DestroyActor()
                end)
                JagerCorpseWasRemoved = true
                break
            end
        end
    end
    return JagerCorpseWasRemoved
end

local KitchenCorpseLocation = { X = -16577.186722, Y = 11621.483725, Z = 9.999998 }
local KitchenCorpseWasRemoved = false
local function FindAndRemoveKitchenCorpse()
    if KitchenCorpseWasRemoved then return true end
    LogDebug("FindAndRemoveKitchenCorpse: Search Tick")

    ---@type ASkeletalMeshActor[]?
    local skeletalMeshActors = FindAllOf("SkeletalMeshActor")
    if skeletalMeshActors then
        for i, actor in ipairs(skeletalMeshActors) do
            local location = actor:K2_GetActorLocation()
            if NearlyEqual(location.X, KitchenCorpseLocation.X) and NearlyEqual(location.Y, KitchenCorpseLocation.Y) and NearlyEqual(location.Z, KitchenCorpseLocation.Z) then
                LogDebug("Found kitchen corpse, remove")
                ExecuteInGameThread(function()
                    actor:SetActorHiddenInGame(true)
                    actor:SetActorEnableCollision(false)
                    actor:K2_DestroyActor()
                end)
                KitchenCorpseWasRemoved = true
                break
            end
        end
    end

    return KitchenCorpseWasRemoved
end

local function Reset()
    JagerCorpseWasRemoved = false
    KitchenCorpseWasRemoved = false
    LogDebug("Reset: Search")
end

local Local_BeginPlayWasHooked = false
local function HookLocal_BeginPlay()
    if not Local_BeginPlayWasHooked then
        Local_BeginPlayWasHooked = TryRegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:Local_BeginPlay", function(Context)
            Reset()
        end)
    end
end

LoopAsync(1000, function()
    HookLocal_BeginPlay()
    FindAndRemoveJagerCorpse()
    FindAndRemoveKitchenCorpse()

    return false
end)

LogInfo("Mod loaded successfully")
