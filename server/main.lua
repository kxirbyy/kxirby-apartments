local apartmentBuckets = {}
local nextBucketId = 1000

-- Get or create routing bucket for player
local function getPlayerBucket(playerId)
    if not apartmentBuckets[playerId] then
        apartmentBuckets[playerId] = nextBucketId
        nextBucketId = nextBucketId + 1
        SetPlayerRoutingBucket(playerId, apartmentBuckets[playerId])
    end
    return apartmentBuckets[playerId]
end

-- Enter apartment
RegisterNetEvent('apartments:enter', function()
    local src = source
    local bucket = getPlayerBucket(src)
    
    SetPlayerRoutingBucket(src, bucket)
    TriggerClientEvent('apartments:teleportToApartment', src)
end)

-- Exit apartment
RegisterNetEvent('apartments:exit', function()
    local src = source
    
    SetPlayerRoutingBucket(src, 0) -- Return to main world
    TriggerClientEvent('apartments:teleportToStreet', src)
end)

-- Register stash for player
ESX.RegisterServerCallback('apartments:getStashId', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local stashId = 'apartment_' .. xPlayer.identifier
        
        -- Register the stash if it doesn't exist
        if not exports.ox_inventory:GetInventory(stashId) then
            exports.ox_inventory:RegisterStash(stashId, 'Apartment Storage', 50, 100000)
        end
        
        cb(stashId)
    else
        cb(nil)
    end
end)

-- Cleanup on disconnect
AddEventHandler('playerDropped', function()
    local src = source
    if apartmentBuckets[src] then
        apartmentBuckets[src] = nil
    end
end)

-- Force all players out when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Force all players in apartments back to street
        for playerId, bucketId in pairs(apartmentBuckets) do
            if GetPlayerPed(playerId) ~= 0 then -- Player is still connected
                SetPlayerRoutingBucket(playerId, 0) -- Return to main world
                TriggerClientEvent('apartments:forceExit', playerId)
            end
        end
        apartmentBuckets = {}
    end
end)