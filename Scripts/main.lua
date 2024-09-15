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
ModVersion = "1.2.0"
DebugMode = true
IsModEnabled = true

LogInfo("Starting mod initialization")

---@param ShortActorClassName string
---@param Locations FVector[]
---@return boolean Removed # true if the actor was removed
local function FindAndRemoveActor(ShortActorClassName, Locations)
    local anActorWasRemoved = false
    local actorInstances  = FindAllOf(ShortActorClassName) ---@type AActor[]?
    if actorInstances and #actorInstances > 0 then
        for _, actor in ipairs(actorInstances) do
            local actorLocation = actor:K2_GetActorLocation()
            for _, location in ipairs(Locations) do
                if NearlyEqualVector(location, actorLocation) then
                    if not actor.bActorIsBeingDestroyed and not actor.bHidden then
                        anActorWasRemoved = true
                        LogDebug("Removing actor")
                        ExecuteInGameThread(function()
                            actor:SetActorHiddenInGame(true)
                            actor:SetActorEnableCollision(false)
                            actor:K2_DestroyActor()
                        end)
                    else
                        LogDebug("FindAndRemoveActor: The actor is already hidden or pending for destruction")
                    end
                end
            end
        end
    end
    return anActorWasRemoved
end

if IsModEnabled then
    LoopAsync(1000, function()
        local playerController = AFUtils.GetMyPlayerController()
        if playerController then
            local activeLevelName = playerController.ActiveLevelName:ToString()
            if activeLevelName == "Facility_Office1" then
                FindAndRemoveActor("NarrativeNPC_Human_ParentBP_C", { FVector(-14416.694983, 12571.883403, 98.000005) })
                FindAndRemoveActor("SkeletalMeshActor", { FVector(-16577.186722, 11621.483725, 9.999998) })
            elseif activeLevelName == "Facility_Dam" or activeLevelName == "Facility_Dam_Waterfall" then
                FindAndRemoveActor("CharacterCorpse_MonsterGeneric_C", { FVector(-50331.309412, 6731.079142, 1337.126070) })
                FindAndRemoveActor("CharacterCorpse_Human_BP_C", { FVector(-50725.972968, 8032.569451, 1336.949190), FVector(-48337.985612, 8504.925779, 1230.139829) })
            end
        end
        return false
    end)
else
    LogInfo("The mod is disabled")
end

LogInfo("Mod loaded successfully")
