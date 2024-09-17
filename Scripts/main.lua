--[[
    Author: Igromanru
    Date: 29.08.2024
    Mod Name: Jager Corpse Remover
]]

--- Settings ---
RemoveJagerCorpse = true
RemoveKitchenCorpse = true
RemoveHydroplantSecurityExorCorpse = true
RemoveHydroplantSecuritySoldierCorpse = true
RemoveHydroplantSecurityScientistCorpse = true
----------------

------------------------------
-- Don't change code below --
------------------------------

local AFUtils = require("AFUtils.AFUtils")

ModName = "JagerCorpseRemover"
ModVersion = "1.2.1"
DebugMode = true
IsModEnabled = true

LogInfo("Starting mod initialization")

---@param ShortActorClassName string
---@param Locations FVector[]
---@return boolean Removed # true if the actor was removed
local function FindAndRemoveActor(ShortActorClassName, Locations)
    if not ShortActorClassName or not Locations or #Locations < 1 then return false end

    local anActorWasRemoved = false
    local actorInstances  = FindAllOf(ShortActorClassName) ---@type AActor[]?
    if actorInstances and #actorInstances > 0 then
        for _, actor in ipairs(actorInstances) do
            local actorLocation = actor:K2_GetActorLocation()
            for _, location in ipairs(Locations) do
                if NearlyEqualVector(location, actorLocation) and (not actor:IsA(AFUtils.GetClassAbiotic_Character_ParentBP_C()) or actor.IsDead) then
                    if not actor.bActorIsBeingDestroyed and not actor.bHidden then
                        anActorWasRemoved = true
                        LogDebug("Removing actor")
                        ExecuteInGameThread(function()
                            actor:SetActorHiddenInGame(true)
                            actor:SetActorEnableCollision(false)
                            actor:K2_DestroyActor()
                        end)
                    else
                        -- LogDebug("FindAndRemoveActor: The actor is already hidden or pending for destruction")
                    end
                end
            end
        end
    end
    return anActorWasRemoved
end

local CharacterCorpseHumanLocations = {}
if RemoveHydroplantSecuritySoldierCorpse then
    table.insert(CharacterCorpseHumanLocations, FVector(-50725.972968, 8032.569451, 1336.949190))
end
if RemoveHydroplantSecurityScientistCorpse then
    table.insert(CharacterCorpseHumanLocations, FVector(-48337.985612, 8504.925779, 1230.139829))
end

if IsModEnabled then
    LoopAsync(1000, function()
        local playerController = AFUtils.GetMyPlayerController()
        if playerController then
            local activeLevelName = playerController.ActiveLevelName:ToString()
            if activeLevelName == "Facility_Office1" then
                if RemoveJagerCorpse then
                    FindAndRemoveActor("NarrativeNPC_Human_ParentBP_C", { FVector(-14416.694983, 12571.883403, 98.000005) })
                end
                if RemoveKitchenCorpse then
                    FindAndRemoveActor("SkeletalMeshActor", { FVector(-16577.186722, 11621.483725, 9.999998) })
                end
            elseif activeLevelName == "Facility_Dam" or activeLevelName == "Facility_Dam_Waterfall" then
                if RemoveHydroplantSecurityExorCorpse then
                    FindAndRemoveActor("CharacterCorpse_MonsterGeneric_C", { FVector(-50331.309412, 6731.079142, 1337.126070) })
                end
                FindAndRemoveActor("CharacterCorpse_Human_BP_C", CharacterCorpseHumanLocations)
            end
        end
        return false
    end)
else
    LogInfo("The mod is disabled")
end

LogInfo("Mod loaded successfully")
