ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('location:canAfford', function(source, cb, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        cb(true)
    else
        cb(false)
    end
end)