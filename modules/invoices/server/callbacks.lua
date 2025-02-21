lib.callback.register('fd_banking:server:cb:fetchUnpaidInvoices', function(source, page, limit)
    return fetchUnpaidInvoices(source, page, limit)
end)

lib.callback.register('fd_banking:server:cb:fetchOtherInvoices', function(source, page, limit)
    return fetchOtherInvoices(source, page, limit)
end)

lib.callback.register('fd_banking:server:cb:fetchUnpaidInvoicesSum', function(source)
    return fetchUnpaidInvoicesSum(source)
end)

lib.callback.register('fd_banking:server:cb:fetchUnpaidInvoicesCount', function(source)
    return fetchUnpaidInvoicesCount(source)
end)

lib.callback.register('fd_banking:server:cb:fetchPayInvoice', function(source, id)
    return fetchPayInvoice(source, id)
end)

lib.callback.register('fd_banking:server:cb:fetchDeclineInvoice', function(source, id)
    return fetchDeclineInvoice(source, id)
end)

lib.callback.register('fd_banking:server:cb:payAllInvoices', function(source)
    return payAllInvoices(source)
end)
