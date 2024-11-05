local ox_target = exports.ox_target

ox_target:addModel(Config.atmModels, {
    {
        label = "Use ATM",
        icon = "fa-solid fa-money-bill-wave",
        distance = 1.5,
        canInteract = function(entity, distance, coords, name, bone)
            return true
        end,
        onSelect = function(data)
            SetNuiFocus(true, true)
            SendNUIMessage({
                openNUI = true
            })
        end
    }
})

RegisterNUICallback('getCCData', function(data, cb)
    local ccData = lib.callback.await("qtm:server:awaitccData", false)
    if ccData then
        cb({ success = true, ccData = ccData })
    else
        cb({ success = false, message = "Failed to fetch credit card data." })
    end
end)

RegisterNUICallback('getBalance', function(data, cb)
    local balance = lib.callback.await("qtm:server:awaitBalance", false)
    if balance then
        cb({ success = true, balance = balance })
    else
        cb({ success = false, message = "Failed to fetch balance." })
    end
end)

RegisterNUICallback('history', function(data, cb)
    local history = lib.callback.await("qtm:server:awaitHistory", false)
    if history then
        cb({ success = true, history = history })
    else
        cb({ success = false, message = "Failed to fetch history." })
    end
end)


RegisterNUICallback('deposit', function(data, cb)
    local amount = tonumber(data.amount)
    local newBalance = lib.callback.await("qtm:server:awaitDeposit", false, amount)
    if newBalance then
        cb({ success = true, newBalance = newBalance })
    else
        cb({ success = false, message = "Invalid amount" })
    end
end)

RegisterNUICallback('withdraw', function(data, cb)
    local amount = tonumber(data.amount)
    local newBalance = lib.callback.await("qtm:server:awaitWithdrawal", false, amount)
    if newBalance then
        cb({ success = true, newBalance = newBalance })
    else
        cb({ success = false, message = "Invalid amount" })
    end
end)
