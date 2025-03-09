-- Configuration
NoClipSpeed = 0.5
local noclipActive = false
local currentSpeedIndex = 1
local followCamMode = true

-- Controls
local controls = {
    openKey = 170, -- F3
    goUp = 22, -- A
    goDown = 20, -- Z
    turnLeft = 52, -- Q
    turnRight = 35, -- D
    goForward = 32, -- W
    goBackward = 33, -- S
    changeSpeed = 335, -- Mouse Wheel Up
    changeSpeedDown = 336, -- Mouse Wheel Down
    camMode = 74, -- H
}

-- Speeds
local speeds = {
    { label = 'Very Slow', speed = 0.5 },
    { label = 'Slow', speed = 1 },
    { label = 'Normal', speed = 2 },
    { label = 'Fast', speed = 5 },
    { label = 'Very Fast', speed = 10 },
    { label = 'Max', speed = 15 },
}

-- Offsets
local offsets = {
    y = 0.5, -- Forward and backward movement speed multiplier
    z = 0.2, -- Upward and downward movement speed multiplier
    h = 3, -- Rotation movement speed multiplier
}

-- Toggle NoClip
function toggleNoClip()
    noclipActive = not noclipActive
    local playerPed = PlayerPedId()

    if noclipActive then
        SetEntityInvincible(playerPed, true)
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, false)
        SetEveryoneIgnorePlayer(playerPed, true)
        SetPoliceIgnorePlayer(playerPed, true)
    else
        SetEntityInvincible(playerPed, false)
        FreezeEntityPosition(playerPed, false)
        SetEntityCollision(playerPed, true, true)
        SetEveryoneIgnorePlayer(playerPed, false)
        SetPoliceIgnorePlayer(playerPed, false)
    end

    Citizen.CreateThread(function()
        while noclipActive do
            Citizen.Wait(0)
            HideHudComponentThisFrame(19)
            HideHudComponentThisFrame(20)
            HideHudComponentThisFrame(21)
            HideHudComponentThisFrame(22)
            local pCoords = GetEntityCoords(playerPed, false)
            local camCoords = getCamDirection()
            SetEntityVelocity(playerPed, 0.01, 0.01, 0.01)
            SetEntityCollision(playerPed, false, false)
            FreezeEntityPosition(playerPed, true)

            local yoff = 0.0
            local zoff = 0.0

            if IsDisabledControlPressed(0, controls.goForward) then
                yoff = offsets.y
            end

            if IsDisabledControlPressed(0, controls.goBackward) then
                yoff = -offsets.y
            end

            if not followCamMode and IsDisabledControlPressed(0, controls.turnLeft) then
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) + offsets.h)
            end

            if not followCamMode and IsDisabledControlPressed(0, controls.turnRight) then
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) - offsets.h)
            end

            if IsDisabledControlPressed(0, controls.goUp) then
                zoff = offsets.z
            end

            if IsDisabledControlPressed(0, controls.goDown) then
                zoff = -offsets.z
            end

            local newPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, yoff * (speeds[currentSpeedIndex].speed + 0.3), zoff * (speeds[currentSpeedIndex].speed + 0.3))
            local heading = GetEntityHeading(playerPed)
            SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)
            SetEntityRotation(playerPed, 0.0, 0.0, 0.0, 0, false)

            if followCamMode then
                SetEntityHeading(playerPed, GetGameplayCamRelativeHeading())
            else
                SetEntityHeading(playerPed, heading)
            end

            SetEntityCoordsNoOffset(playerPed, newPos.x, newPos.y, newPos.z, true, true, true)
            SetEntityVisible(playerPed, false, false)

            if IsDisabledControlJustPressed(0, controls.camMode) then
                followCamMode = not followCamMode
            end

            if IsDisabledControlJustPressed(0, controls.changeSpeed) then
                currentSpeedIndex = math.min(currentSpeedIndex + 1, #speeds)
            end

            if IsDisabledControlJustPressed(0, controls.changeSpeedDown) then
                currentSpeedIndex = math.max(currentSpeedIndex - 1, 1)
            end
        end

        -- Reset player state when noclip is turned off
        SetEntityInvincible(playerPed, false)
        FreezeEntityPosition(playerPed, false)
        SetEntityCollision(playerPed, true, true)
        SetEveryoneIgnorePlayer(playerPed, false)
        SetPoliceIgnorePlayer(playerPed, false)
        SetEntityVisible(playerPed, true, false)
    end)
end

-- Get Camera Direction
function getCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
    local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

    if len ~= 0 then
        coords = coords / len
    end

    return coords
end

-- Register Command
RegisterCommand('noclip', function()
    toggleNoClip()
end)

-- Register Key Mapping
RegisterKeyMapping('noclip', 'Activer / désactiver le noclip', 'keyboard', 'F3')
