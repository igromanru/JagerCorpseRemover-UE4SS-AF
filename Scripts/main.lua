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

local function CheckAndRemoveActorAtLocation(Class, Location)
    if not Class or not Class:IsValid() or not Location or not Location.X then return false end

    local startLocation = VectorToUserdata(Location)
    startLocation.Z = startLocation.Z + 30
    local endLocation = VectorToUserdata(Location)
    endLocation.Z = endLocation.Z - 100
    local hitActor = LineTraceByChannel(startLocation, endLocation, 3)
    -- LogInfo("hitActor: " .. type(hitActor))
    if hitActor then
        -- LogInfo("CheckAndRemoveActorAtLocation: startLocation: " .. VectorToString(startLocation))
        -- LogInfo("CheckAndRemoveActorAtLocation: endLocation: " .. VectorToString(endLocation))
        -- LogInfo("CheckAndRemoveActorAtLocation: target Class: " .. Class:GetFullName())
        -- LogInfo("CheckAndRemoveActorAtLocation: hitActor Class: " .. hitActor:GetClass():GetFullName())
        if hitActor:IsA(Class) then
            if DebugMode then
                LogInfo("CheckAndRemoveActorAtLocation: Found actor: " .. hitActor:GetFullName())
            end
            if not hitActor.bActorIsBeingDestroyed and not hitActor.bHidden then
                LogDebug("Removing actor")
                ExecuteInGameThread(function()
                    hitActor:SetActorHiddenInGame(true)
                    hitActor:SetActorEnableCollision(false)
                    hitActor:K2_DestroyActor()
                end)
                return true
            else
                LogDebug("CheckAndRemoveActorAtLocation: The actor is already hidden or pending for destruction")
            end
        end
    end
    return false
end

if IsModEnabled then
    LoopAsync(1000, function()
        local playerController = AFUtils.GetMyPlayerController()
        if playerController then
            if RemoveJagerCorpse then
                CheckAndRemoveActorAtLocation(AFUtils.GetClassNarrativeNPC_Human_ParentBP_C(), FVector(-14416.694983, 12571.883403, 98.0))
            end
            if RemoveKitchenCorpse then
                CheckAndRemoveActorAtLocation(AFUtils.GetClassSkeletalMeshActor(), FVector(-16577.186722, 11621.483725, 9.999998))
            end
            if RemoveHydroplantSecurityExorCorpse then
                CheckAndRemoveActorAtLocation(AFUtils.GetClassCharacterCorpse_ParentBP(), FVector(-50331.309412, 6731.079142, 1337.126070))
            end
            if RemoveHydroplantSecuritySoldierCorpse then
                CheckAndRemoveActorAtLocation(AFUtils.GetClassCharacterCorpse_Human_BP_C(), FVector(-50714.0, 8050.0, 1435.4))
            end
            if RemoveHydroplantSecurityScientistCorpse then
                CheckAndRemoveActorAtLocation(AFUtils.GetClassCharacterCorpse_Human_BP_C(), FVector(-48353.6, 8486.8, 1335.347729))
            end
            -- local activeLevelName = playerController.ActiveLevelName:ToString()
            -- if activeLevelName == "Facility_Office1" then
            --     -- FindAndRemoveJagerCorpse()
            --     -- FindAndRemoveKitchenCorpse()
            -- elseif activeLevelName == "Facility_Dam" then
            -- end
        end
        return false
    end)
else
    LogInfo("The mod is disabled")
end

LogInfo("Mod loaded successfully")
