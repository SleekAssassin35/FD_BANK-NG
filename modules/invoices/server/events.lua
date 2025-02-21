RegisterNetEvent("fd_banking:server:issueInvoice", function(playerId, amount, reason, isSociety)
    issueInvoice(source, playerId, amount, reason, isSociety)
    TriggerClientEvent('qb-phone:RefreshPhone', playerId)
end)

RegisterNetEvent("fd_banking:server:lookupCitizen", function(playerId)
    lookupCitizen(source, playerId)
end)

RegisterNetEvent("fd_banking:server:showInvoice", function(invoiceId)
    lookupInvoice(source, invoiceId)
end)

RegisterNetEvent("fd_banking:server:cancelInvoice", function(invoiceId)
    cancelInvoice(source, invoiceId)
end)
