---@param source<number> - Source
---@param page<number> - Page
---@param limit<number> - Limit
---@return QueryResult|{ [number]: { [string]: unknown  }}
function fetchUnpaidInvoices(source, page, limit)
    page = page or 1
    limit = limit or 20

    local identifier = bridge.getIdentifier(source)

    local invoices = MySQL.query.await([[
            SELECT
                *,
                DATE_FORMAT(CONVERT_TZ(`created_at`, @@session.time_zone, '+00:00')  ,'%Y-%m-%dT%TZ') as created_at,
                DATE_FORMAT(CONVERT_TZ(`due_on`, @@session.time_zone, '+00:00')  ,'%Y-%m-%dT%TZ') as due_on
            FROM
                fd_advanced_banking_invoices
            WHERE
                recipient = ? AND
                status = 1
            ORDER BY
                created_at DESC
            LIMIT
                ?, ?
        ]],
        { identifier, (page - 1) * limit, limit }
    )

    return invoices
end

---@param source<number> - Source
---@param page<number> - Page
---@param limit<number> - Limit
---@return QueryResult|{ [number]: { [string]: unknown  }}
function fetchOtherInvoices(source, page, limit)
    page = page or 1
    limit = limit or 20

    local identifier = bridge.getIdentifier(source)

    local invoices = MySQL.query.await([[
            SELECT
                *,
                DATE_FORMAT(CONVERT_TZ(`created_at`, @@session.time_zone, '+00:00')  ,'%Y-%m-%dT%TZ') as created_at,
                DATE_FORMAT(CONVERT_TZ(`updated_at`, @@session.time_zone, '+00:00')  ,'%Y-%m-%dT%TZ') as updated_at
            FROM
                fd_advanced_banking_invoices
            WHERE
                recipient = ? AND
                status != 1
            ORDER BY
                created_at DESC
            LIMIT
                ?, ?
        ]],
        { identifier, (page - 1) * limit, limit }
    )

    return invoices
end

---@param source<number> - Source
---@param playerId<number> - Player ID
---@param amount<number> - Amount
---@param reason<string> - Reason
---@param isSociety<boolean> - Is society
function issueInvoice(source, playerId, amount, reason, isSociety)
    local identifier = bridge.getIdentifier(source)

    if not identifier then
        return
    end

    local recipient = #tostring(playerId) > 3 and playerId or bridge.getIdentifier(playerId)
    local recipientSource = bridge.getSourceFromIdentifier(recipient)

    if not recipient or not recipientSource then
        bridge.notify(source, locale('player_not_online'), 'error')

        return
    end

    if source then
        local distance = #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(playerId)))

        if distance > 20 then
            bridge.notify(source, locale('player_is_too_far'), 'error')

            return
        end
    end

    if amount < 1 then
        bridge.notify(source, locale('invalid_amount'), 'error')

        return
    end

    if not isSociety then
        local account = getPersonalAccount(identifier)

        if not account then
            bridge.notify(source, locale('no_personal_account'), 'error')

            return
        end

        local issuer = source and bridge.firstLastName(source) or 'System'

        local insertId = addInvoice(recipient, issuer, 1, amount, reason, account.id, true)

        bridge.notify(source, locale('invoice_issued', insertId), 'success')

        return
    end

    local job = bridge.currentSociety(source)

    if not job then
        bridge.notify(source, locale('not_in_society'), 'error')

        return
    end

    if not Config.SocietiesInvoicesEnabled[job] then
        bridge.notify(source, locale('society_invoices_disabled'), 'error')

        return
    end

    local account = getBusinessAccount(job)

    if not account then
        bridge.notify(source, locale('no_business_account'), 'error')

        return
    end

    local issuer = bridge.firstLastName(source)
    local jobLabel = bridge.getJobLabel(job)

    local insertId = addInvoice(recipient, ("%s (%s)"):format(issuer, jobLabel), 1, amount, reason, account.id, false)

    bridge.notify(source, locale('invoice_issued', insertId), 'success')

    if Config.ForceInvoicePaymentForSocietys[job] then
        fetchPayInvoice(playerId, insertId, true)
    end
end
exports('issueInvoice', issueInvoice)

---@param recipient<string> - Recipient (Character identifier)
---@param issued_by<string> - Issued by
---@param status<number> - Status (1 = unpaid, 2 = paid, 3 = declined)
---@param amount<number> - Amount
---@param description<string> - Description
---@param transfer_to<number> - Transfer to
---@param canBeDeclined<boolean> - Can be declined
function addInvoice(recipient, issued_by, status, amount, description, transfer_to, canBeDeclined)
    local currentTime = os.time(os.date("!*t"))
    local dueOn = currentTime + Config.InvoiceDueInDays * 86400

    local insert = MySQL.insert.await([[
            INSERT INTO fd_advanced_banking_invoices (recipient, issued_by, status, amount, description, transfer_to, can_be_declined, due_on)
            VALUES (?, ?, ?, ?, ?, ?, ?, STR_TO_DATE(?, "%Y-%m-%d %H:%i:%s"))
        ]],

        { recipient, issued_by, status, amount, description, transfer_to, canBeDeclined, os.date("%Y-%m-%d %H:%M:%S", dueOn) }
    )

    if not insert then
        return false
    end

    return insert
end
exports("addInvoice", addInvoice)

---@param source<number> - Source
function fetchUnpaidInvoicesSum(source)
    local identifier = bridge.getIdentifier(source)

    local sum = MySQL.scalar.await([[
            SELECT
                SUM(amount) as sum
            FROM
                fd_advanced_banking_invoices
            WHERE
                recipient = ?
            AND
                status = 1
        ]],
        { identifier }
    )

    return sum
end

---@param source<number> - Source
function fetchUnpaidInvoicesCount(source)
    local identifier = bridge.getIdentifier(source)

    local count = MySQL.scalar.await([[
            SELECT
                COUNT(*) as count
            FROM
                fd_advanced_banking_invoices
            WHERE
                recipient = ?
            AND
                status = 1
        ]],
        { identifier }
    )

    return count
end
exports("fetchUnpaidInvoicesCount", fetchUnpaidInvoicesCount)

---@param source<number> - Source
---@param id<number> - Invoice ID
function fetchDeclineInvoice(source, id)
    local identifier = bridge.getIdentifier(source)

    local invoice = MySQL.single.await([[
            SELECT
                *
            FROM
                fd_advanced_banking_invoices
            WHERE
                id = ?
        ]],
        { id }
    )

    if not invoice then
        return false
    end

    if invoice.status ~= 1 then
        return false
    end

    if invoice.recipient ~= identifier then
        return false
    end

    if not invoice.can_be_declined then
        return false
    end

    MySQL.update([[
            UPDATE
                fd_advanced_banking_invoices
            SET
                status = 3
            WHERE
                id = ?
        ]],
        { id }
    )

    Citizen.CreateThread(function()
        local targetAccount = getAccountWithoutMember(invoice.transfer_to, nil)

        if targetAccount.type == 'personal' then
            local owner = getAccountOwner(targetAccount)

            if not owner then
                return
            end

            local targetSource = bridge.getSourceFromIdentifier(owner.identifier)

            if not targetSource then
                return
            end

            if not bridge.isPlayerOnline(targetSource) then
                return
            end

            bridge.notify(targetSource, locale('invoice_declined', invoice.id, invoice.description), 'success')
        end
    end)

    return true
end

---@param source<number> - Source
---@param id<number> - Invoice ID
---@param forcePay<boolean> - Force pay
---@param status<number> - Status
function fetchPayInvoice(source, id, forcePay, status)
    local identifier = bridge.getIdentifier(source)

    local invoice = MySQL.single.await([[
            SELECT
                *
            FROM
                fd_advanced_banking_invoices
            WHERE
                id = ?
        ]],
        { id }
    )

    if not invoice then
        return false
    end

    if invoice.status ~= 1 then
        return false
    end

    local account = getPersonalAccount(identifier)


    if not account then
        return false
    end

    local payed = transferMoney(source, { id = invoice.transfer_to }, nil, invoice.amount, account.id, invoice.description, function(_, targetIban)
        addTransaction(source, account.id, 'payment', account.iban, targetIban, invoice.amount, invoice.description)
        addTransaction(source, invoice.transfer_to, 'transferin', account.iban, targetIban, invoice.amount, locale('payment_for_invoice', invoice.id, invoice.description ))
    end, forcePay)

    if not payed then
        return false
    end

    MySQL.update.await([[
            UPDATE
                fd_advanced_banking_invoices
            SET
                status = ?
            WHERE
                id = ?
        ]],
        { status or 2, id }
    )

    Citizen.CreateThread(function()
        local targetAccount = getAccountWithoutMember(invoice.transfer_to, nil)

        if targetAccount.type == 'personal' then
            local owner = getAccountOwner(targetAccount)

            if not owner then
                return
            end

            local targetSource = bridge.getSourceFromIdentifier(owner.identifier)

            if not targetSource then
                return
            end

            if not bridge.isPlayerOnline(targetSource) then
                return
            end

            bridge.notify(targetSource, locale('invoice_payed', invoice.id, invoice.description), 'success')
        end
    end)

    return true
end
exports('payInvoice', fetchPayInvoice)

---@param source<number> - Source
---@param playerId<number> - Player ID
function lookupCitizen(source, playerId)
    local identifier = bridge.getIdentifier(playerId)

    if not identifier then
        bridge.notify(source, locale('player_not_online'), 'error')

        return false
    end

    local query = MySQL.single.await([[
        SELECT
            *,
            SUM(amount) as sum,
            COUNT(*) as unpaidCount
        FROM
            fd_advanced_banking_invoices
        WHERE
            recipient = ? AND
            status = 1
    ]], { identifier })

    if not query then
        return false
    end

    local distance = #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(playerId)))

    if distance > 20 then
        bridge.notify(source, locale('player_is_too_far'), 'error')

        return
    end

    TriggerClientEvent("fd_banking:client:displayLookup", source, identifier, query.unpaidCount, query.sum)
end

---@param source<number> - Source
---@param invoiceId<number> - Invoice ID
function lookupInvoice(source, invoiceId)
    local identifier = bridge.getIdentifier(source)

    if not identifier then
        return false
    end

    local issuer = bridge.firstLastName(source)
    local society = bridge.currentSociety(source)
    local label = bridge.getJobLabel(society)

    local invoice = MySQL.single.await([[
        SELECT
            *
        FROM
            fd_advanced_banking_invoices
        WHERE
            id = ?
    ]], { invoiceId })

    if not invoice then
        return false
    end

    if not string.find(invoice.issued_by, issuer) and not string.find(invoice.issued_by, label) then
        return false
    end

    TriggerClientEvent("fd_banking:client:showInvoice", source, invoice.recipient, invoice.id, invoice.issued_by, invoice.status, invoice.amount, invoice.description)
end
exports('lookupInvoice', lookupInvoice)

---@param source<number> - Source
---@param invoiceId<number> - Invoice ID
function cancelInvoice(source, invoiceId)
    local identifier = bridge.getIdentifier(source)

    if not identifier then
        return false
    end

    local issuer = bridge.firstLastName(source)
    local society = bridge.currentSociety(source)
    local label = bridge.getJobLabel(society)

    local invoice = MySQL.single.await([[
        SELECT
            *
        FROM
            fd_advanced_banking_invoices
        WHERE
            status = 1 AND
            id = ?
    ]], { invoiceId })

    if not invoice then
        return false
    end

    if not string.find(invoice.issued_by, issuer) and not string.find(invoice.issued_by, label) then
        return false
    end

    MySQL.update([[
            UPDATE
                fd_advanced_banking_invoices
            SET
                status = 5
            WHERE
                id = ?
        ]],
        { invoiceId }
    )

    bridge.notify(source, locale('invoice_cancelled'), "success")
end
exports('cancelInvoice', cancelInvoice)

---@param source<number> - Source
---@param invoiceId<number> - Invoice ID
function processOverdueInvoices(src)
    Citizen.CreateThread(function()
        local identifier = bridge.getIdentifier(src)

        if not identifier then
            return
        end


        local invoices = MySQL.query.await([[
            SELECT
                *
            FROM
                fd_advanced_banking_invoices
            WHERE
                recipient = ? AND
                status = 1 AND
                due_on < ?
        ]], { identifier, os.date("%Y-%m-%d %H:%M:%S", os.time(os.date("!*t"))) })

        if not invoices then
            return
        end

        for _, invoice in pairs(invoices) do
            fetchPayInvoice(src, invoice.id, true, 4)
        end

        if #invoices > 0 then
            bridge.notify(src, locale('overdue_invoices_processed', #invoices), "success")
        end
    end)
end

---@param source<number> - Source
function payAllInvoices(source)
    local identifier = bridge.getIdentifier(source)

    if not identifier then
        return false
    end

    local account = getPersonalAccount(identifier)

    if not account then
        return false
    end

    local query = MySQL.single.await([[
        SELECT
            *,
            SUM(amount) as sum,
            COUNT(*) as unpaidCount
        FROM
            fd_advanced_banking_invoices
        WHERE
            recipient = ? AND
            status = 1
    ]], { identifier })

    if not query then
        return false
    end

    if tonumber(query.unpaidCount) == 0 then
        bridge.notify(source, locale('no_invoices_to_pay'), "error")

        return false
    end

    if account.balance < tonumber(query.sum) then
        bridge.notify(source, locale('not_enough_money'), "error")

        return false
    end

    local invoices = MySQL.query.await([[
        SELECT
            *
        FROM
            fd_advanced_banking_invoices
        WHERE
            recipient = ? AND
            status = 1
    ]], { identifier })

    if not invoices then
        return false
    end

    local total = 0

    for _, invoice in pairs(invoices) do
        local payed = fetchPayInvoice(source, invoice.id, true, 2)

        if payed then
            total = total + invoice.amount
        end
    end

    if total > 0 then
        bridge.notify(source, locale('invoices_payed', total), "success")
    end

    return true
end
