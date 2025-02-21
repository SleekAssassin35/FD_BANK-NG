RegisterNUICallback('createNewAccount', function(data, cb)
    local response = createNewSharedAccount(data)

    cb(response)
end)

RegisterNUICallback('loadAccount', function(data, cb)
    local response = loadAccount(data)

    cb(response)
end)

RegisterNUICallback('depositMoney', function(data, cb)
    local response = depositMoney(data)

    cb(response)
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    local response = withdrawMoney(data)

    cb(response)
end)

RegisterNUICallback('transferMoney', function(data, cb)
    local response = transferMoney(data)

    cb(response)
end)

RegisterNUICallback('deleteAccount', function(data, cb)
    local response = deleteAccount(data)

    cb(response)
end)

RegisterNUICallback('fetchCash', function(_, cb)
    TriggerServerEvent('fd_banking:server:updateCash')

    cb('ok')
end)

RegisterNUICallback('fetchAccounts', function(_, cb)
    TriggerServerEvent('fd_banking:server:fetchAccounts')

    cb('ok')
end)
