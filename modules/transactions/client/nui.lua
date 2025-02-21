RegisterNuiCallback('transactions', function(data, cb)
    local response = fetchTransactions(data)

    cb(response)
end)

RegisterNuiCallback('exportTransactions', function(data, cb)
    local response = exportTransactions(data)

    cb(response)
end)
