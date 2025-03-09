ESX = exports['es_extended']:getSharedObject()

local createdPeds = {}
local cooldowns = {}

CreateThread(function()
    while true do
        Wait(500) 
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for i, location in ipairs(Config.Locations) do
            local dist = #(playerCoords - location.position)
            
            if dist < 50.0 then
                if not HasModelLoaded(location.pedModel) then
                    RequestModel(location.pedModel)
                    while not HasModelLoaded(location.pedModel) do
                        Wait(100)
                    end
                end
                
                if not createdPeds[i] then
                    local ped = CreatePed(4, location.pedModel, location.position.x, location.position.y, location.position.z, 0.0, false, true)
                    SetEntityAsMissionEntity(ped, true, true)
                    
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    SetEntityInvincible(ped, true)
                    SetEntityVisible(ped, true, false)
                    SetPedCanRagdoll(ped, false)
                    SetPedCanBeKnockedOffVehicle(ped, false)
                    ClearPedTasksImmediately(ped)
                    TaskStandStill(ped, -1)
                    FreezeEntityPosition(ped, true)
                    SetEntityCoordsNoOffset(ped, location.position.x, location.position.y, location.position.z, false, false, false)
                    
                    createdPeds[i] = ped
                end
            else
                if createdPeds[i] then
                    DeleteEntity(createdPeds[i])
                    createdPeds[i] = nil
                end
                SetModelAsNoLongerNeeded(location.pedModel)
            end
        end
    end
end)
function DeletePeds()
    for i, ped in pairs(createdPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
        createdPeds[i] = nil
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DeletePeds()
    end
end)


function IsCooldownActive(playerId)
    local currentTime = GetGameTimer()
    if cooldowns[playerId] then
        if currentTime - cooldowns[playerId] < 30000 then 
            return true
        else
            cooldowns[playerId] = nil 
            return false
        end
    end
    return false
end

function SetCooldown(playerId)
    cooldowns[playerId] = GetGameTimer()
end

function GiveVehicle(vehicleModel, spawnPoint)
    local playerPed = PlayerPedId()

    if IsPositionOccupied(spawnPoint.x, spawnPoint.y, spawnPoint.z, 5.0, false, true, true, false, false, 0, false) then
        ESX.ShowNotification("L'espace de sortie de véhicule est occupé, veuillez réesseyez une fois qu'il sera libéré.")
        return
    end

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(100)
    end

    local vehicle = CreateVehicle(vehicleModel, spawnPoint.x, spawnPoint.y, spawnPoint.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, "LOCATION")
    ESX.ShowNotification("Tu as loué un véhicule.")
end

function OpenLocationMenu(locationName, vehicles, spawnPoint)
    local menu = RageUI.CreateMenu(locationName, "Location")
    RageUI.Visible(menu, true)

    CreateThread(function()
        while RageUI.Visible(menu) do
            RageUI.IsVisible(menu, function()
                RageUI.Separator("~b~Louer un véhicule")
                for _, vehicle in ipairs(vehicles) do
                    RageUI.Button(vehicle.label, "Loue une " .. vehicle.label, {}, true, {
                        onSelected = function()
                            local playerId = GetPlayerServerId(PlayerId())
                            if IsCooldownActive(playerId) then
                                ESX.ShowNotification("Tu dois attendre 30 secondes avant de louer un autre véhicule.")
                            else
                                GiveVehicle(vehicle.model, spawnPoint)
                                SetCooldown(playerId)
                                RageUI.CloseAll()
                            end
                        end
                    })
                end
            end)
            Wait(1)
        end
    end)
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local minDist = math.huge
        for _, location in pairs(Config.Locations) do
            local dist = #(playerCoords - location.position)
            if dist < minDist then
                minDist = dist
            end
        end

        if minDist > 50.0 then
            Wait(1000) 
        else
            Wait(1) 
            for _, location in pairs(Config.Locations) do
                local dist = #(playerCoords - location.position)
                if dist < 2.0 then
                    ESX.ShowHelpNotification("Appurer sur ~INPUT_CONTEXT~ pour louer un véhicule")
                    if IsControlJustPressed(0, 38) then 
                        OpenLocationMenu(location.name, location.vehicles, location.spawnPoint)
                    end
                end
            end
        end
    end
end)


function ProcessPayment(amount)
    local playerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('location:payRental', playerId, amount) 
end


function GiveVehicle(vehicleModel, spawnPoint, price)
    local playerPed = PlayerPedId()

    if IsPositionOccupied(spawnPoint.x, spawnPoint.y, spawnPoint.z, 5.0, false, true, true, false, false, 0, false) then
        ESX.ShowNotification("L'espace de sortie de véhicule est occupé, veuillez réessayer une fois qu'il sera libéré.")
        return false
    end

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(100)
    end


    local vehicle = CreateVehicle(vehicleModel, spawnPoint.x, spawnPoint.y, spawnPoint.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, "LOCATION")
    ESX.ShowNotification("Tu as loué un véhicule pour $" .. price .. ".")
    return true
end


function OpenLocationMenu(locationName, vehicles, spawnPoint)
    local menu = RageUI.CreateMenu(locationName, "Location")
    RageUI.Visible(menu, true)

    CreateThread(function()
        while RageUI.Visible(menu) do
            RageUI.IsVisible(menu, function()
                RageUI.Separator("~b~Louer un véhicule")
                for _, vehicle in ipairs(vehicles) do
                    RageUI.Button(vehicle.label, "Loue une " .. vehicle.label .. " pour $" .. vehicle.price, {RightLabel = "~g~"..vehicle.price.."$"}, true, {
                        onSelected = function()
                            local playerId = GetPlayerServerId(PlayerId())
                            if IsCooldownActive(playerId) then
                                ESX.ShowNotification("Tu dois attendre 30 secondes avant de louer un autre véhicule.")
                            else
                                ESX.TriggerServerCallback('location:canAfford', function(canAfford)
                                    if canAfford then
                                        if GiveVehicle(vehicle.model, spawnPoint, vehicle.price) then
                                            SetCooldown(playerId)
                                            RageUI.CloseAll()
                                        end
                                    else
                                        ESX.ShowNotification("Tu n'as pas assez d'argent pour louer ce véhicule.")
                                    end
                                end, vehicle.price)
                            end
                        end
                    })
                end
            end)
            Wait(1)
        end
    end)
end