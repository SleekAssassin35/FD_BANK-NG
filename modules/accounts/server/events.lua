RegisterNetEvent('fd_banking:server:fetchAccounts', function()
    fetchAccounts(source)
end)

RegisterNetEvent('fd_banking:server:fetchAccount', function(id)
    fetchAccount(source, id)
end)

RegisterNetEvent('fd_banking:server:updateCash', function()
    fetchCash(source)
end)
