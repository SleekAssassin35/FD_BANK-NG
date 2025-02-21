RegisterNetEvent('fd_banking:client:fetchAccounts', function(accounts)
    sendAccounts(accounts)
end)


RegisterNetEvent("fd_banking:client:fetchAccount", function(account)
    sendAccount(account)
end)

RegisterNetEvent("fd_banking:client:updateCash", function(cash)
    sendCash(cash)
end)

RegisterNetEvent("fd_advanced_banking:client:account:updated", function(accountId)
    sendAccountUpdated(accountId)
end)

RegisterNetEvent("fd_advanced_banking:client:account:deleted", function(accountId)
    sendAccountDeleted(accountId)
end)
