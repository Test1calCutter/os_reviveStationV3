-- May take some knowledge of LUA to modify directly.


ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


function _U(text)
    local locale = Config.Locale
    return Locales[locale] and Locales[locale][text] or text
end

--Config--
local minDistance = Config.minDistance
local reviveHealth = Config.reviveHealth
local healHealth = Config.healHealth
local maxHealth = Config.maxHealth
local check = Config.check

--Marker--
local drawMarker = Config.drawMarker
local circleCenter = Config.circleCenter
local circleRadius = Config.circleRadius
local markerType = Config.markerType

--NPC--
local spawnNPC = Config.Npc
local npcCenter = Config.npcCenter
local model = Config.model

--Job--
local job = Config.Job
local useJob = Config.HideOnJob
local minCount = Config.count

--Blip--
local BlipName = Config.BlipName
local BlipSprite = Config.BlipSprite
local BlipDisplay = Config.BlipDisplay
local BlipScale = Config.BlipScale
local BlipColour = Config.BlipColour

--Billing--
local useBilling = Config.billing
local society = Config.society
local revivePrice = Config.revivePrice
local healPrice = Config.healPrice
local okokBilling = Config.okokBilling

-- Variables
local spawned = false
local npc = nil
local medics = false
local blip = nil
local showing = true
local blipCreated = false

-- Make the blip not meow but rather do blip things
function bliping()
    if showing and not blipCreated then
        AddTextEntry('label', BlipName)
        blip = AddBlipForCoord(circleCenter)
        SetBlipSprite(blip, BlipSprite)
        SetBlipDisplay(blip, BlipDisplay)
        SetBlipScale(blip, BlipScale)
        SetBlipColour(blip, BlipColour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("label")
        EndTextCommandSetBlipName(blip)
        blipCreated = true
    end
end

-- Receive count of how many people have the job (if enabled)
RegisterNetEvent('os_revivestation:client:receiveCount')
AddEventHandler('os_revivestation:client:receiveCount', function(count)
    if useJob then
        if count > minCount then
            medics = true
            showing = false
            if blipCreated then
                RemoveBlip(blip)
                blipCreated = false
            end
        else
            medics = false
            showing = true
            bliping()
        end
    end
end)

-- Automatically check every x seconds if someone now has the job (if enabled)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(check)
        if useJob then
            TriggerServerEvent('os_revivestation:client:count')
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        -- Some more variables
        local playerPed = PlayerPedId()
        local playerServerId = GetPlayerServerId(PlayerId())
        local playerCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(playerCoords, circleCenter, true)
        

        -- If the job thingy is enabled
        if useJob then
            if distance <= minDistance and medics == false then
                local playerHealth = GetEntityHealth(playerPed)

                if spawnNPC then
                    if spawned == false then
                        SpawnNPC()
                        spawned = true
                    end
                end
                
                -- If playerhealth is lower than or equal to
                if playerHealth <= reviveHealth then
                    
                    
                    

                    if drawMarker then
                        DrawMarker(markerType, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 255, 0, 0, 200, false, true, 2, nil, nil, false)
                    end
                    if distance <= circleRadius and IsControlJustReleased(0, 38) then
                        DisplayHelpText(_U('revive'))
                        if useBilling then
                            if okokBilling then
                                TriggerServerEvent("okokBilling:CreateCustomInvoice", playerServerId, revivePrice, _U('billing_reason'), _U('invoiceSource'), society, _U('jobName'))
                                TriggerEvent('esx_ambulancejob:revive')
                            else
                                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(PlayerId()), 'society_'..job, _U('billing_reason'), revivePrice)
                                TriggerEvent('esx_ambulancejob:revive')
                            end
                        else
                            TriggerEvent('esx_ambulancejob:revive')
                        end
                    end
                    

                -- If playerhealth is lower than or equal to
                elseif playerHealth <= healHealth then
                    
                    
                    if drawMarker then
                        DrawMarker(markerType, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 0, 255, 0, 200, false, true, 2, nil, nil, false)
                    end

                    if distance <= circleRadius and IsControlJustReleased(0, 38) then
                        DisplayHelpText(_U('heal'))
                        if useBilling then
                            if okokBilling then
                                TriggerServerEvent("okokBilling:CreateCustomInvoice", playerServerId, revivePrice, _U('billing_reason'), _U('invoiceSource'), society, _U('jobName'))
                                TriggerEvent('esx_ambulancejob:revive')
                            else
                                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(PlayerId()), 'society_'..job, _U('billing_reason'), revivePrice)
                                TriggerEvent('esx_ambulancejob:revive')
                            end
                        else
                            TriggerEvent('esx_ambulancejob:revive')
                        end
                    end

                -- If playerhealth is higher than or equal to
                elseif playerHealth >= maxHealth then
                    
                    if drawMarker then
                        DrawMarker(markerType, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 0, 0, 255, 200, false, true, 2, nil, nil, false)
                    end
                    if distance <= circleRadius then
                        DisplayHelpText(_U('no_injuries'))
                    end
                    if distance <= circleRadius and IsControlJustReleased(0, 38) then -- Remove this if you want, it's just telling the user to cry about it if they have no injuries
                        ESX.ShowNotification(_U('joke'))
                    end
                end
            else
                -- Delete spawned NPC (if enabled)
                if spawnNPC then
                    DeleteNPC()
                    spawned = false
                end
                RemoveHelpText()
            end
        -- If the job thingy isn't enabled
        elseif not useJob then
            if distance <= minDistance then
                local playerHealth = GetEntityHealth(playerPed)

                if spawnNPC then
                    if spawned == false then
                        SpawnNPC()
                        spawned = true
                    end
                end

                -- If playerhealth is lower than or equal to
                if playerHealth <= reviveHealth then
                    
                    
                    if drawMarker then
                        DrawMarker(markerType, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 255, 0, 0, 200, false, true, 2, nil, nil, false)
                    end

                    if distance <= circleRadius and IsControlJustReleased(0, 38) then
                        DisplayHelpText(_U('revive'))
                        if useBilling then
                            if okokBilling then
                                TriggerServerEvent("okokBilling:CreateCustomInvoice", playerServerId, revivePrice, _U('billing_reason'), _U('invoiceSource'), society, _U('jobName'))
                                TriggerEvent('esx_ambulancejob:revive')
                            else
                                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(PlayerId()), 'society_'..job, _U('billing_reason'), revivePrice)
                                TriggerEvent('esx_ambulancejob:revive')
                            end
                        else
                            TriggerEvent('esx_ambulancejob:revive')
                        end
                    end
                -- If playerhealth is lower than or equal to
                elseif playerHealth <= healHealth then
                    
                    
                    if drawMarker then
                        DrawMarker(markerType, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 0, 255, 0, 200, false, true, 2, nil, nil, false)
                    end
                    if distance <= circleRadius and IsControlJustReleased(0, 38) then
                        DisplayHelpText(_U('heal'))
                        if useBilling then
                            if okokBilling then
                                TriggerServerEvent("okokBilling:CreateCustomInvoice", playerServerId, revivePrice, _U('billing_reason'), _U('invoiceSource'), society, _U('jobName'))
                                TriggerEvent('esx_ambulancejob:revive')
                            else
                                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(PlayerId()), 'society_'..job, _U('billing_reason'), revivePrice)
                                TriggerEvent('esx_ambulancejob:revive')
                            end
                        else
                            TriggerEvent('esx_ambulancejob:revive')
                        end
                    end
                -- If playerhealth is higher than or equal to
                elseif playerHealth >= maxHealth then
                    if drawMarker then
                        DrawMarker(markerType, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 0, 0, 255, 200, false, true, 2, nil, nil, false)
                    end
                    if distance <= circleRadius then
                        DisplayHelpText(_U('no_injuries'))
                    end
                    if distance <= circleRadius and IsControlJustReleased(0, 38) then
                        ESX.ShowNotification(_U('joke'))
                    end
                end
            else
                -- Delete spawned NPC (if enabled)
                if spawnNPC and spawned then
                    DeleteNPC()
                    spawned = false
                end
                RemoveHelpText()
            end
        end
    end
end)

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function RemoveHelpText()
    BeginTextCommandDisplayHelp("STRING")
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function SpawnNPC()
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(500)
    end

    local pos = vector4(npcCenter.x, npcCenter.y, npcCenter.z, npcCenter.w - 1.0)

    npc = CreatePed(4, model, pos.x, pos.y, pos.z, pos.w, 0.0, true, false)

    SetEntityCoordsNoOffset(npc, pos.x, pos.y, pos.z, pos.w, true, true, true)
    SetEntityInvincible(npc, true)
    SetEntityHasGravity(npc, false)
    FreezeEntityPosition(npc, true)
    SetAmbientVoiceName(npc, "ALERT_Player")
    SetModelAsNoLongerNeeded(model)
end

function DeleteNPC()
    if spawned and DoesEntityExist(npc) then
        DeleteEntity(npc)
        spawned = false
    end
end



