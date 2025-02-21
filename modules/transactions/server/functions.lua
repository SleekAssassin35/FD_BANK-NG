---@param id<number> - Account ID
---@param page<number> - Current page number
---@param limit<number> - Records limit
function fetchTransactions(id, page, limit)
    page = page or 1
    limit = limit or 20

    local transactions = MySQL.query.await([[
            SELECT
                *,
                DATE_FORMAT(CONVERT_TZ(`created_at`, @@session.time_zone, '+00:00')  ,'%Y-%m-%dT%TZ') as created_at
            FROM
                fd_advanced_banking_accounts_transactions
            WHERE
                account_id = ?
            ORDER BY
                created_at DESC
            LIMIT
                ?, ?
        ]],
        { id, (page - 1) * limit, limit }
    )

    return transactions
end

---@param source<number> - Source
---@param account_id<number> - Acccount ID
---@param action<deposit | withdraw | transferin | transferout | payment> - Transaction action
---@param from<number> - From account
---@param to<number> - To account
---@param amount<number> - Amount
---@param reason<string> - Reason
function addTransaction(source, account_id, action, from, to, amount, reason)
    local doneBy = source

    if action ~= 'deposit' and action ~= 'withdraw' and action ~= 'transferin' and action ~= 'transferout' and action ~= 'payment' then
        return
    end

    if type(source) == 'number' then
        local identifier = bridge.getIdentifier(source)
        local firstLastName = bridge.firstLastName(source)

        doneBy = ('%s (%s)'):format(firstLastName, identifier)
    end

    MySQL.query([[
            INSERT INTO
                fd_advanced_banking_accounts_transactions
                (account_id, action, done_by, from_account, to_account, amount, description)
            VALUES
                (?, ?, ?, ?, ?, ?, ?)
        ]],
        { account_id, action, doneBy, from, to, amount, reason}
    )
end

---@param source<number> - Source
---@param id<number> - Account ID
---@param dates<[startDate, endDate]> - Dates
function exportTransactions(source, id, dates)
    exports[GetCurrentResourceName()]:exportTransactions(source, id, dates)

    return true
end


exports('exportWebhook', function()
    return Config.DiscordWebhooks.transactionExport
end)
