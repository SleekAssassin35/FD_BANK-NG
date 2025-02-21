lib.callback.register('fd_banking:server:cb:createSharedAccount', function(source, name)
    return createAccount(source, name, 'shared')
end)

lib.callback.register('fd_banking:server:cb:depositMoney', function(source, amount, id, reason)
    return depositMoney(source, amount, id, reason)
end)

lib.callback.register('fd_banking:server:cb:withdrawMoney', function(source, amount, id, reason)
    return withdrawMoney(source, amount, id, reason)
end)

lib.callback.register('fd_banking:server:cb:transferMoney', function(source, accountId, playerId, amount, id, reason)
    return transferMoney(source, accountId, playerId, amount, id, reason)
end)

lib.callback.register('fd_banking:server:cb:deleteAccount', function(source, id)
    return deleteAccount(source, id)
end)
