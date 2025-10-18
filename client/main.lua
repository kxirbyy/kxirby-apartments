local ESX = exports['es_extended']:getSharedObject()
local inApartment = false
local apartmentBlip = nil

-- Create blip for apartment entrance
local function createApartmentBlip()
    apartmentBlip = AddBlipForCoord(Config.ApartmentEntrance.x, Config.ApartmentEntrance.y, Config.ApartmentEntrance.z)
    SetBlipSprite(apartmentBlip, 475)
    SetBlipDisplay(apartmentBlip, 4)
    SetBlipScale(apartmentBlip, 0.8)
    SetBlipColour(apartmentBlip, 3)
    SetBlipAsShortRange(apartmentBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Alta Street Apartments')
    EndTextCommandSetBlipName(apartmentBlip)
end

-- Optimized distance checking
local function isPlayerNearLocation(coords, maxDistance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - coords) <= maxDistance
end

-- Open stash function
local function openStash()
    ESX.TriggerServerCallback('apartments:getStashId', function(stashId)
        if stashId then
            exports.ox_inventory:openInventory('stash', stashId)
        else
            lib.notify({
                title = 'Error',
                description = 'Failed to open stash',
                type = 'error'
            })
        end
    end)
end

-- Open clothing menu function
local function openClothingMenu()
    -- Try the correct export for illenium-appearance
    local success = pcall(function()
        exports['illenium-appearance']:startPlayerCustomization()
    end)
    
    if not success then
        lib.notify({
            title = 'Error',
            description = 'Failed to open clothing menu',
            type = 'error'
        })
    end
end

-- Main thread for markers and interactions
CreateThread(function()
    createApartmentBlip()
    
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        
        if not inApartment then
            -- Check entrance marker
            if isPlayerNearLocation(Config.ApartmentEntrance, Config.DrawDistance) then
                sleep = 0
                
                -- Draw entrance marker
                DrawMarker(Config.MarkerType, Config.ApartmentEntrance.x, Config.ApartmentEntrance.y, Config.ApartmentEntrance.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                    false, true, 2, false, nil, nil, false)
                
                -- Check interaction distance
                if isPlayerNearLocation(Config.ApartmentEntrance, Config.InteractionDistance) then
                    lib.showTextUI('[E] Enter Apartment', {
                        position = "top-center",
                        icon = 'home'
                    })
                    
                    if IsControlJustPressed(0, 38) then -- E key
                        lib.hideTextUI()
                        TriggerServerEvent('apartments:enter')
                    end
                else
                    lib.hideTextUI()
                end
            end
        else
            -- Check exit marker
            if isPlayerNearLocation(Config.ExitMarker, Config.DrawDistance) then
                sleep = 0
                
                -- Draw exit marker
                DrawMarker(Config.MarkerType, Config.ExitMarker.x, Config.ExitMarker.y, Config.ExitMarker.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                    255, 0, 0, 100,
                    false, true, 2, false, nil, nil, false)
                
                if isPlayerNearLocation(Config.ExitMarker, Config.InteractionDistance) then
                    lib.showTextUI('[E] Exit Apartment', {
                        position = "top-center",
                        icon = 'door-open'
                    })
                    
                    if IsControlJustPressed(0, 38) then -- E key
                        lib.hideTextUI()
                        TriggerServerEvent('apartments:exit')
                    end
                else
                    lib.hideTextUI()
                end
            end
            
            -- Check wardrobe marker
            if isPlayerNearLocation(Config.WardrobeLocation, Config.DrawDistance) then
                sleep = 0
                
                -- Draw wardrobe marker
                DrawMarker(Config.MarkerType, Config.WardrobeLocation.x, Config.WardrobeLocation.y, Config.WardrobeLocation.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                    0, 255, 0, 100,
                    false, true, 2, false, nil, nil, false)
                
                if isPlayerNearLocation(Config.WardrobeLocation, Config.InteractionDistance) then
                    lib.showTextUI('[E] Change Clothes', {
                        position = "top-center",
                        icon = 'shirt'
                    })
                    
                    if IsControlJustPressed(0, 38) then -- E key
                        lib.hideTextUI()
                        openClothingMenu()
                    end
                else
                    lib.hideTextUI()
                end
            end
            
            -- Check stash marker
            if isPlayerNearLocation(Config.StashLocation, Config.DrawDistance) then
                sleep = 0
                
                -- Draw stash marker
                DrawMarker(Config.MarkerType, Config.StashLocation.x, Config.StashLocation.y, Config.StashLocation.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                    255, 255, 0, 100,
                    false, true, 2, false, nil, nil, false)
                
                if isPlayerNearLocation(Config.StashLocation, Config.InteractionDistance) then
                    lib.showTextUI('[E] Open Stash', {
                        position = "top-center",
                        icon = 'box'
                    })
                    
                    if IsControlJustPressed(0, 38) then -- E key
                        lib.hideTextUI()
                        openStash()
                    end
                else
                    lib.hideTextUI()
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Teleport to apartment
RegisterNetEvent('apartments:teleportToApartment', function()
    local playerPed = PlayerPedId()
    
    -- Fade out
    DoScreenFadeOut(500)
    Wait(500)
    
    -- Teleport and set heading
    SetEntityCoords(playerPed, Config.ApartmentInterior.x, Config.ApartmentInterior.y, Config.ApartmentInterior.z, false, false, false, true)
    SetEntityHeading(playerPed, Config.ApartmentInterior.w)
    
    inApartment = true
    
    -- Fade in
    Wait(100)
    DoScreenFadeIn(500)
    
    -- Notification
    lib.notify({
        title = 'Apartment',
        description = 'Welcome to your apartment!',
        type = 'success'
    })
end)

-- Teleport to street
RegisterNetEvent('apartments:teleportToStreet', function()
    local playerPed = PlayerPedId()
    
    -- Fade out
    DoScreenFadeOut(500)
    Wait(500)
    
    -- Teleport back to entrance
    SetEntityCoords(playerPed, Config.ApartmentExit.x, Config.ApartmentExit.y, Config.ApartmentExit.z, false, false, false, true)
    SetEntityHeading(playerPed, Config.ApartmentExit.w)
    
    inApartment = false
    
    -- Fade in
    Wait(100)
    DoScreenFadeIn(500)
    
    -- Notification
    lib.notify({
        title = 'Apartment',
        description = 'You have left your apartment',
        type = 'inform'
    })
end)

-- Force exit (for resource restart)
RegisterNetEvent('apartments:forceExit', function()
    local playerPed = PlayerPedId()
    
    -- Immediate teleport without fade (since resource is stopping)
    SetEntityCoords(playerPed, Config.ApartmentExit.x, Config.ApartmentExit.y, Config.ApartmentExit.z, false, false, false, true)
    SetEntityHeading(playerPed, Config.ApartmentExit.w)
    
    inApartment = false
    
    -- Clear any UI elements
    lib.hideTextUI()
    
    -- Notification
    lib.notify({
        title = 'Apartment System',
        description = 'You have been moved to the street due to system restart',
        type = 'inform'
    })
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        lib.hideTextUI()
        if apartmentBlip then
            RemoveBlip(apartmentBlip)
        end
    end
end)