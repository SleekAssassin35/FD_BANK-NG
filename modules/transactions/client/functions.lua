function fetchTransactions(data)
    local response = lib.callback.await("fd_banking:server:cb:fetchTransactions", false, data.id, data.page, data.limit)

    return response
end

function exportTransactions(data)
    local response = lib.callback.await("fd_banking:server:cb:exportTransactions", false, data.id, data.dates)

    return response
end
