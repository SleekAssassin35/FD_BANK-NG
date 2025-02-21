RegisterNuiCallback('unpaidInvoices', function(data, cb)
    local response = fetchUnpaidInvoices(data)

    cb(response)
end)

RegisterNuiCallback('paidInvoices', function(data, cb)
    local response = fetchPaidInvoices(data)

    cb(response)
end)

RegisterNuiCallback('unpaidInvoicesSum', function(_, cb)
    local response = fetchUnpaidInvoicesSum()

    cb(response)
end)

RegisterNuiCallback('unpaidInvoicesCount', function(_, cb)
    local response = fetchUnpaidInvoicesCount()

    cb(response)
end)

RegisterNuiCallback('payInvoice', function(data, cb)
    local response = fetchPayInvoice(data)

    cb(response)
end)

RegisterNuiCallback('declineInvoice', function(data, cb)
    local response = fetchDeclineInvoice(data)

    cb(response)
end)


RegisterNuiCallback('payAllInvoices', function(_, cb)
    local response = payAllInvoices()

    cb(response)
end)
