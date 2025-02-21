lib.callback.register('fd_banking:server:cb:fetchTransactions', function(source, id, page, limit)
    return fetchTransactions(id, page, limit)
end)

lib.callback.register('fd_banking:server:cb:exportTransactions', function(source, id, dates)
    return exportTransactions(source, id, dates)
end)
