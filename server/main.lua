local function logTransaction(identifier, transactionType, amount)

    local insertQuery = [[
        INSERT INTO qtm_transactions (identifier, transaction_date, transaction_type, amount)
        VALUES (?, NOW(), ?, ?)
    ]]

    MySQL.query.await(insertQuery, { identifier, transactionType, amount })
end


lib.callback.register('qtm:server:awaitHistory', function(source)
    local src = source
    local identifier = qtm.Framework.GetIdentifier(src)
    local query = [[
        SELECT transaction_date, transaction_type, amount
        FROM qtm_transactions
        WHERE identifier = ?
        ORDER BY transaction_date DESC
    ]]

    local result = MySQL.query.await(query, { identifier })
    local history = {}

    if result and #result > 0 then
        for _, row in ipairs(result) do
            table.insert(history, {
                date = row.transaction_date,
                type = row.transaction_type,
                amount = row.amount,
            })
        end
    end

    return history
end)


lib.callback.register('qtm:server:awaitccData', function(source)
    local src = source
    local identifier = qtm.Framework.GetIdentifier(src)

    local query = [[
        SELECT long_num, name, expiry, cvv, correct_pin
        FROM qtm_card_details
        WHERE identifier = ?
    ]]

    local result = MySQL.query.await(query, { identifier })

    if result and #result > 0 then
        return {
            longNum = result[1].long_num,
            name = result[1].name,
            expiry = result[1].expiry,
            cvv = result[1].cvv,
            correctPin = result[1].correct_pin,
        }
    else
        return {}
    end
end)

lib.callback.register('qtm:server:awaitBalance', function(source)
    local src = source

    local balance = qtm.Framework.GetBank(src)
    return balance or 0
end)

lib.callback.register('qtm:server:awaitDeposit', function(source, depositAmount)
    local src = source
    local identifier = qtm.Framework.GetIdentifier(src)

    if depositAmount and depositAmount > 0 then
        qtm.Framework.AddMoney(src, depositAmount, "bank")
        logTransaction(identifier, "Deposit", depositAmount)  

        local currentBalance = qtm.Framework.GetBank(src) or 0
        local newBalance = currentBalance + depositAmount
        return newBalance
    else
        return { error = "Invalid deposit amount." }
    end
end)

lib.callback.register('qtm:server:awaitWithdrawal', function(source, withdrawalAmount)
    local src = source
    local identifier = qtm.Framework.GetIdentifier(src)
    
    local currentBalance = qtm.Framework.GetBank(src) or 0

    if withdrawalAmount and withdrawalAmount > 0 and withdrawalAmount <= currentBalance then
        qtm.Framework.RemoveMoney(src, withdrawalAmount, "bank")
        logTransaction(identifier, "Withdraw", withdrawalAmount)  
        local newBalance = currentBalance - withdrawalAmount
        return newBalance
    else
        return { error = "Invalid withdrawal amount or insufficient funds." }
    end
end)
