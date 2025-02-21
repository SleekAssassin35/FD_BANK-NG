RegisterNetEvent("fd_banking:client:displayLookup", function(identifier, count, sum)
    lib.alertDialog({
        header = locale('lookup_citizen_show_title'),
        content = ([[
**%s** \
`%s` \
\
**%s** \
`%s` \
\
**%s** \
`%s`
        ]]):format(locale('identifier'), identifier, locale('unpaid_invoices_count'), count or 0, locale('unpaid_invoices_sum'), sum or nil),
        centered = true
    })
end)

RegisterNetEvent("fd_banking:client:showInvoice", function(recipient, id, issued_by, status, amount, description)
    local statusText = nil

    if status == 2 then
        statusText = locale('invoice_paid_status')
    elseif status == 3 then
        statusText = locale('invoice_declined_status')
    elseif status == 4 then
        statusText = locale('invoice_force_paid_status')
    elseif status == 5 then
        statusText = locale('invoice_cancelled_status')
    else
        statusText = locale('invoice_unpaid_status')
    end


    lib.alertDialog({
        header = locale('lookup_invoice_show_title'),
        content = ([[
**%s** \
`%s` \
\
**%s** \
`%s` \
\
**%s** \
`%s` \
\
**%s** \
`%s` \
\
**%s** \
`%s` \
\
**%s** \
`%s`
        ]]):format(
            locale('recipient'),
            recipient,
            locale('invoice_id'),
            id,
            locale('invoice_issued_by'),
            issued_by,
            locale('invoice_status'),
            statusText,
            locale('invoice_amount'),
            amount,
            locale('invoice_description'),
            description
        ),
        centered = true
    })
end)
