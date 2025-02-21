
---@param src<number> - Source
function createDefaultAccountOrSync(src)
    local identifier = bridge.getIdentifier(src)
    local amount = bridge.getAccountAmount(src, 'bank')

    if not identifier then
        return
    end

    local account = MySQL.single.await([[
            SELECT
                fd_advanced_banking_accounts.id,
                fd_advanced_banking_accounts.iban,
                fd_advanced_banking_accounts.balance,
                fd_advanced_banking_accounts_members.identifier
            FROM
                fd_advanced_banking_accounts
            INNER JOIN
                fd_advanced_banking_accounts_members on fd_advanced_banking_accounts.id = fd_advanced_banking_accounts_members.account_id
            WHERE
            fd_advanced_banking_accounts.type = 'personal' AND
                fd_advanced_banking_accounts_members.identifier = ? AND
                fd_advanced_banking_accounts_members.is_owner = 1
        ]],
        { identifier }
    )

    if account then
        if not amount then
            amount = 0
        end

        if account.balance ~= amount then
            accountsLogger:info('Syncing default account for ' .. identifier .. ' with id: ' .. account.id .. ', iban: ' .. account.iban)
            createLog(src, {
                type = 'account',
                action = 'sync',
                account_id = account.id,
                account_iban = account.iban,
                account_balance = account.balance,
                account_new_balance = amount,
                message = 'Synced account balance from ' .. account.balance .. ' to ' .. amount
            })
            MySQL.update('UPDATE fd_advanced_banking_accounts SET balance = ? WHERE id = ?', { account.balance, account.id })
        end
    end

    if not account then
        accountsLogger:info('Creating default account for ' .. identifier)
        local iban = getFreeIbanNumber()

        local accountId = MySQL.insert.await('INSERT INTO fd_advanced_banking_accounts (iban, balance) VALUES (?, ?)', { iban, amount })
        MySQL.insert('INSERT INTO fd_advanced_banking_accounts_members (account_id, identifier, is_owner) VALUES (?, ?, ?)', { accountId, identifier, 1 })

        createLog(src, {
            type = 'account',
            action = 'create',
            account_id = accountId,
            account_iban = iban,
            account_balance = amount,
            message = 'Created default account for ' .. identifier .. ' with id: ' .. accountId .. ', iban: ' .. iban
        })
        accountsLogger:info('Created default account for ' .. identifier .. ' with id: ' .. accountId .. ', iban: ' .. iban)
    end
end

---@param src<number> - Source
---@param name<string> - Name
---@param type<string> - Type
function createAccount(source, name, type)
    local identifier = bridge.getIdentifier(source)

    if not name then
        return false
    end

    if type ~= 'personal' and type ~= 'shared' and type ~= 'business' then
        return false
    end

    if(type == 'shared' and Config.MaxSharedAccounts > 0) then
        local sharedAccountsOwned = MySQL.scalar.await([[
                SELECT
                    COUNT(*)
                FROM
                    fd_advanced_banking_accounts
                INNER JOIN
                    fd_advanced_banking_accounts_members on fd_advanced_banking_accounts.id = fd_advanced_banking_accounts_members.account_id
                WHERE
                    type = 'shared' AND
                    identifier = ? AND
                    fd_advanced_banking_accounts_members.is_owner = 1
            ]],
            { identifier }
        )

        if sharedAccountsOwned >= Config.MaxSharedAccounts then
            bridge.notify(source, ('You have reached the maximum amount of shared accounts owned (%s)'):format(Config.MaxSharedAccounts), 'error')
            return false
        end
    end

    local iban = getFreeIbanNumber()
    local accountId = createRawAccount(name, iban, 0, type)
    MySQL.insert.await('INSERT INTO fd_advanced_banking_accounts_members (account_id, identifier, is_owner) VALUES (?, ?, ?)', { accountId, identifier, 1 })

    createLog(source, {
        type = 'account',
        action = 'create',
        account_id = accountId,
        account_iban = iban,
        account_balance = 0,
        message = 'Created shared account for ' .. identifier .. ' with id: ' .. accountId .. ', iban: ' .. iban
    })

    return true
end

---@param name<string> - Name
---@param iban<string> - IBAN
---@param balance<number> - Balance
---@param type<string> - Type
---@param business<string|nil> - Business
---@param is_society<number|nil> - Is society
function createRawAccount(name, iban, balance, type, business, is_society)
    local accountId = MySQL.insert.await('INSERT INTO fd_advanced_banking_accounts (name, iban, balance, type, business, is_society) VALUES (?, ?, ?, ?, ?, ?)', { name, iban, balance, type, business or nil, is_society or 0})

    createLog(source, {
        type = 'account',
        action = 'create',
        account_id = accountId,
        account_iban = iban,
        account_balance = 0,
        message = 'Created shared account with id: ' .. accountId .. ', iban: ' .. iban
    })
    return accountId
end

---@param src<number> - Source
---@param id<number> - Account ID
function fetchAccount(src, id)
    local identifier = bridge.getIdentifier(src)

    if identifier then
        MySQL.single([[
                SELECT
                    accounts.id,
                    accounts.iban,
                    accounts.name,
                    accounts.type,
                    accounts.is_frozen,
                    accounts.balance,
                    accounts.business,
                    accounts.is_society,
                    members.account_id,
                    members.identifier,
                    members.can_deposit,
                    members.can_withdraw,
                    members.can_transfer,
                    members.can_export,
                    members.can_control_members,
                    members.is_owner
                FROM
                    fd_advanced_banking_accounts accounts
                INNER JOIN
                    fd_advanced_banking_accounts_members members on accounts.id = members.account_id
                WHERE
                    accounts.id = ? AND
                    members.identifier = ?
            ]],
            { id, identifier },
            function(account)
                if account then
                    account.transactions = {}

                    TriggerClientEvent('fd_banking:client:fetchAccount', src, account)
                end
            end
        )
    end
end

---@param src<number> - Source
function fetchAccounts(src)
    local identifier = bridge.getIdentifier(src)

    if identifier then
        MySQL.query(
            [[
                SELECT
                    accounts.id,
                    accounts.iban,
                    accounts.name,
                    accounts.balance,
                    accounts.type,
                    accounts.is_frozen,
                    accounts.business,
                    accounts.is_society,
                    members.identifier,
                    members.can_deposit,
                    members.can_withdraw,
                    members.can_transfer,
                    members.can_export,
                    members.can_control_members,
                    members.is_owner
                FROM
                    fd_advanced_banking_accounts accounts
                INNER JOIN
                    fd_advanced_banking_accounts_members members on accounts.id = members.account_id
                WHERE
                    members.identifier = ?
                GROUP BY
                    accounts.id
            ]],
            { identifier },
            function(accounts)
                TriggerClientEvent('fd_banking:client:fetchAccounts', src, accounts)
            end
        )
    end
end

---@param source<number> - Source
function fetchCash(source)
    TriggerClientEvent('fd_banking:client:updateCash', source, bridge.getAccountAmount(source, 'cash'))
end

---@param identifier<string> - Identifier
---@param id<number> - Account ID
---@param iban<string> - IBAN
function getAccount(identifier, id, iban)
    local account = MySQL.single.await([[
        SELECT
            accounts.id,
            accounts.iban,
            accounts.name,
            accounts.type,
            accounts.is_frozen,
            accounts.balance,
            accounts.business,
            members.account_id,
            members.identifier,
            members.can_deposit,
            members.can_withdraw,
            members.can_transfer,
            members.can_export,
            members.can_control_members,
            members.is_owner
        FROM
            fd_advanced_banking_accounts accounts
        INNER JOIN
            fd_advanced_banking_accounts_members members on accounts.id = members.account_id
        WHERE
            members.identifier = ? AND
            (accounts.id = ? OR accounts.iban = ?)

    ]],
        { identifier, id, iban }
    )

    if not account then
        return false
    end

    return account
end

---@param identifier<string> - Identifier
function getPersonalAccount(identifier)
    local account = MySQL.single.await([[
        SELECT
            accounts.id,
            accounts.iban,
            accounts.name,
            accounts.type,
            accounts.is_frozen,
            accounts.balance,
            accounts.business,
            members.account_id,
            members.identifier,
            members.can_deposit,
            members.can_withdraw,
            members.can_transfer,
            members.can_export,
            members.can_control_members,
            members.is_owner
        FROM
            fd_advanced_banking_accounts accounts
        INNER JOIN
            fd_advanced_banking_accounts_members members on accounts.id = members.account_id
        WHERE
            members.identifier = ? AND
            accounts.type = 'personal'

    ]],
        { identifier }
    )

    if not account then
        return false
    end

    return account
end
exports('getPersonalAccount', getPersonalAccount)

---@param id<number|nil> - Account ID
---@param iban<string|nil> - IBAN
function getAccountWithoutMember(id, iban)
    local account = MySQL.single.await([[
        SELECT
            accounts.id,
            accounts.iban,
            accounts.name,
            accounts.type,
            accounts.is_frozen,
            accounts.balance,
            accounts.business,
            accounts.is_society
        FROM
            fd_advanced_banking_accounts accounts
        WHERE
            accounts.id = ? OR
            accounts.iban = ?

    ]],
        { id, iban }
    )

    if not account then
        return false
    end

    return account
end
exports('getAccountById', function(id)
    return getAccountWithoutMember(id)
end)
exports('getAccountByIban', function(iban)
    return getAccountWithoutMember(nil, iban)
end)

---@param source<number> - Source
function canFreezeAccount(source)
    if bridge.isStaff(source, Config.AdminPermissionToFreeze) then
        return true
    end

    if not Config.IsFreezingEnabled then
        return false
    end

    local society, grade = bridge.currentSocietyWithGrade(source)

    if Config.SocietyCanFreeze[society] and Config.SocietyCanFreeze[society] <= grade then
        return true
    end

    return false
end

---@param business<string> - Business
function getBusinessAccount(business)
    local account = MySQL.single.await([[
        SELECT
            accounts.id,
            accounts.iban,
            accounts.name,
            accounts.type,
            accounts.is_frozen,
            accounts.balance,
            accounts.business,
            accounts.is_society
        FROM
            fd_advanced_banking_accounts accounts
        WHERE
            accounts.business = ?

    ]],
        { business }
    )

    if not account then
        return false
    end

    return account
end
exports('getBusinessAccount', getBusinessAccount)

---@param source<number> - Source
---@param amount<number> - Amount
---@param id<number> - Account ID
---@param reason<string> - Reason
function depositMoney(source, amount, id, reason)
    if not amount or amount <= 0 then
        return false
    end

    local identifier = bridge.getIdentifier(source)
    local account = getAccount(identifier, id)

    if not account then
        return false
    end

    local canMemberDeposit = canDeposit(account)

    if not canMemberDeposit then
        return false
    end

    local playerCash = bridge.getAccountAmount(source, 'cash')

    if playerCash < amount then
        return false
    end

    bridge.removeMoney(source, 'cash', amount, reason)
    local newBalance = account.balance + amount

    if account.type == 'personal' then
        newBalance = (bridge.getAccountAmount(source, 'bank') or 0) + amount

        bridge.addMoney(source, 'bank', amount, reason, {
            skipTransaction = true
        })
    end

    MySQL.query([[
            UPDATE
                fd_advanced_banking_accounts
            SET
                balance = ?
            WHERE
                id = ?
        ]],
        { newBalance, account.id },
        function()
            fetchAccounts(source)
            fetchCash(source)
            addTransaction(source, account.id, 'deposit', 0, account.iban, amount, reason)

            sendAccountUpdatedEventToMembers(account.id, 'updated', {
                dontSendToIdentifier = identifier,
            })

            if Config.UpdateQbManagementTable and account.business then
                MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {newBalance, account.business})
            end

            createLog(source, {
                type = 'account',
                action = 'deposit',
                account_id = account.id,
                account_iban = account.iban,
                account_balance = 0,
                message = ("Deposited money into account %s (%s), new balance: %s, old balance: %s. Done by: %s"):format(account.iban, account.id, newBalance, account.balance, identifier)
            })
        end
    )

    return true
end

---@param source<number> - Source
---@param amount<number> - Amount
---@param id<number> - Account ID
---@param reason<string> - Reason
---@param transactionCallback<function|nil> - Transaction Callback
function withdrawMoney(source, amount, id, reason, transactionCallback)
    if not amount or amount <= 0 then
        return false
    end

    local identifier = bridge.getIdentifier(source)
    local account = getAccount(identifier, id)

    if not account then
        return false
    end

    local canMemberWithdraw = canWithdraw(account)

    if not canMemberWithdraw then
        return false
    end

    local accountBalance = account.balance

    if account.type == 'personal' then
        accountBalance = bridge.getAccountAmount(source, 'bank') or 0
    end

    if accountBalance < amount then
        return false
    end

    local newBalance = account.balance - amount

    if account.type == 'personal' then
        newBalance = (bridge.getAccountAmount(source, 'bank') or 0) - amount

        bridge.removeMoney(source, 'bank', amount, reason, {
            skipTransaction = true
        })
    end

    MySQL.query([[
            UPDATE
                fd_advanced_banking_accounts
            SET
                balance = ?
            WHERE
                id = ?
        ]],
        { newBalance, account.id },
        function()
            if transactionCallback ~= nil then
                transactionCallback()
            else
                addTransaction(source, account.id, 'withdraw', account.iban, 0, amount, reason)
            end

            fetchAccounts(source)

            sendAccountUpdatedEventToMembers(account.id, 'updated', {
                dontSendToIdentifier = identifier,
            })

            if Config.UpdateQbManagementTable and account.business then
                MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {newBalance, account.business})
            end

            bridge.addMoney(source, 'cash', amount, reason)

            createLog(source, {
                type = 'account',
                action = 'withdraw',
                account_id = account.id,
                account_iban = account.iban,
                account_balance = 0,
                message = ("Withdrawn money from account %s (%s), new balance: %s, old balance: %s. Done by: %s"):format(account.iban, account.id, newBalance, account.balance, identifier)
            })
        end
    )

    return true
end

---@param source<number> - Source
---@param targetAccountId<number> - Target Account ID
---@param playerId<string|nil> - Player ID
---@param amount<number> - Amount
---@param localAccountId<number|nil> - Local Account ID
---@param reason<string> - Reason
---@param transactionCallback<function|nil> - Transaction Callback
---@param forcePay<boolean|nil> - Force Pay
function transferMoney(source, targetAccountId, playerId, amount, localAccountId, reason, transactionCallback, forcePay)
    if not amount or amount <= 0 then
        return false
    end

    local identifier = bridge.getIdentifier(source)
    local account = getAccount(identifier, localAccountId)

    if not account then
        return false
    end

    local canMemberTransfer = canTransfer(account)

    if not canMemberTransfer then
        return false
    end

    local accountBalance = account.balance

    if account.type == 'personal' then
        accountBalance = bridge.getAccountAmount(source, 'bank') or 0
    end

    if accountBalance < amount and not forcePay then
        return false
    end

    if not playerId and not targetAccountId then
        return false
    end

    if account.type == 'personal' and playerId == identifier then
        return false
    end

    local targetAccount = getAccountWithoutMember(_, targetAccountId)

    if type(targetAccountId) == 'table' then
        targetAccount = getAccountWithoutMember(targetAccountId.id, nil)
    end

    if type(playerId) == "number" and playerId > 0 then
        if not bridge.isPlayerOnline(playerId) then
            return false
        end

        local targetIdentifier = bridge.getIdentifier(playerId)

        targetAccount = getPersonalAccount(targetIdentifier)
    end

    if not targetAccount then
        return false
    end

    local newBalance = account.balance - amount
    local targetBalance = targetAccount.balance + amount

    if account.type == 'personal' then
        newBalance = (bridge.getAccountAmount(source, 'bank') or 0) - amount

        local removed = bridge.removeMoney(source, 'bank', amount, reason, {
            skipTransaction = true
        })

        if not removed then
            return false
        end
    end

    if targetAccount.type == 'personal' then
        local targetOwner = getAccountOwner(targetAccount)

        if targetOwner then
            local targetSource = bridge.getSourceFromIdentifier(targetOwner.identifier)

            if targetSource then
                targetBalance = (bridge.getAccountAmount(targetSource, 'bank') or 0) + amount

                bridge.addMoney(targetSource, 'bank', amount, reason, {
                    skipTransaction = true
                })
            end
        end
    end

    local updateTargetBalance = true
    if account.iban == targetAccount.iban then
        updateTargetBalance = false

        newBalance = account.balance
        targetBalance = targetAccount.balance
    end

    MySQL.query([[
            UPDATE
                fd_advanced_banking_accounts
            SET
                balance = ?
            WHERE
                id = ?
        ]],
        { newBalance, account.id },
        function()
            fetchAccounts(source)

            if transactionCallback ~= nil then
                transactionCallback(account.iban, targetAccount.iban)
            else
                addTransaction(source, account.id, 'transferout', account.iban, targetAccount.iban, amount, reason)
                addTransaction(source, targetAccount.id, 'transferin', account.iban, targetAccount.iban, amount, reason)
            end

            if Config.UpdateQbManagementTable and account.business then
                MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {newBalance, account.business})
            end

            sendAccountUpdatedEventToMembers(account.id, 'updated', {
                dontSendToIdentifier = identifier,
            })

            createLog(source, {
                type = 'account',
                action = 'transfer',
                account_id = account.id,
                account_iban = account.iban,
                account_balance = account.balance,
                account_newBalance = newBalance,
                target_account_id = targetAccount.id,
                target_account_iban = targetAccount.iban,
                target_account_balance = targetAccount.balance,
                target_account_newBalance = targetBalance,
                message = ("Transfered %s from account %s (%s) to account %s (%s). Done by: %s"):format(amount, account.iban, account.id, targetAccount.iban, targetAccount.id, identifier)
            })
        end
    )

    if updateTargetBalance then
        MySQL.query([[
            UPDATE
                fd_advanced_banking_accounts
            SET
                balance = ?
            WHERE
                id = ?
        ]],
            { targetBalance, targetAccount.id },
            function()
                if Config.UpdateQbManagementTable and targetAccount.business then
                    MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {targetBalance, targetAccount.business})
                end

                sendAccountUpdatedEventToMembers(targetAccount.id, 'updated', {
                    dontSendToIdentifier = identifier,
                })
            end
        )
    end

    return true
end
exports('doTransfer', transferMoney)

---@param accountId<number> - Account ID
---@param event<string> - Event
---@param dontSendToIdentifier<string|nil> - Don't Send To Identifier
---@param data<table|nil> - Data
function sendAccountUpdatedEventToMembers(accountId, event, dontSendToIdentifier, data)
    Citizen.CreateThread(function()
        local account = getAccountWithoutMember(accountId)

        if not account then
            return false
        end

        local members = getMembers(accountId)

        if not members then
            return false
        end

        for _, member in pairs(members) do
            local source = bridge.getSourceFromIdentifier(member.identifier)

            if source and member.identifier ~= dontSendToIdentifier and bridge.isPlayerOnline(source) then
                TriggerClientEvent(('fd_advanced_banking:client:account:%s'):format(event), source, accountId)
            end
        end
    end)
end

---@param source<number> - Source
---@param id<number> - Account ID
function deleteAccount(source, id)
    local identifier = bridge.getIdentifier(source)
    local account = getAccount(identifier, id)

    if not account then
        return false
    end

    local canDelete = canDelete(account)

    if not canDelete then
        return false
    end

    MySQL.query([[
            DELETE FROM
                fd_advanced_banking_accounts
            WHERE
                id = ?
        ]],
        { account.id },
        function()
            fetchAccounts(source)

            createLog(source, {
                type = 'account',
                action = 'delete',
                account_id = account.id,
                account_iban = account.iban,
                account_balance = 0,
                message = ("Deleted account %s (%s). Done by: %s"):format(account.iban, account.id, identifier)
            })
            TriggerClientEvent('fd_advanced_banking:client:account:deleted', -1, account.id)
        end
    )

    return true
end

---@param source<number> - Source
---@param amount<number> - Amount
---@param balance<number> - Balance
---@param reason<string> - Reason
function handleDepositToPersonalAccount(source, amount, balance, reason)
    Citizen.CreateThread(function()
        local identifier = bridge.getIdentifier(source)
        local account = getPersonalAccount(identifier)

        if not account then
            return false
        end

        MySQL.query([[
                UPDATE
                    fd_advanced_banking_accounts
                SET
                    balance = ?
                WHERE
                    id = ?
            ]],
            { balance, account.id },
            function()
                addTransaction(source, account.id, 'transferin', 1, account.iban, amount, reason)

                sendAccountUpdatedEventToMembers(account.id, 'updated')

                createLog(source, {
                    type = 'account',
                    action = 'transferin',
                    account_id = account.id,
                    account_iban = account.iban,
                    account_balance = 0,
                    message = ("Transfer into account %s (%s). Old balance: %s, new balance: %s. Done by: %s"):format(account.iban, account.id, account.balance, balance, identifier)
                })
            end
        )
    end)
end

---@param source<number> - Source
---@param amount<number> - Amount
---@param balance<number> - Balance
---@param reason<string> - Reason
function handleWithdrawFromPersonalAccount(source, amount, balance, reason)
    Citizen.CreateThread(function()
        local identifier = bridge.getIdentifier(source)
        local account = getPersonalAccount(identifier)

        if not account then
            return false
        end

        MySQL.query([[
                UPDATE
                    fd_advanced_banking_accounts
                SET
                    balance = ?
                WHERE
                    id = ?
            ]],
            { balance, account.id },
            function()
                addTransaction(source, account.id, 'transferout', account.iban, 1, amount, reason)

                sendAccountUpdatedEventToMembers(account.id, 'updated')

                createLog(source, {
                    type = 'account',
                    action = 'transferout',
                    account_id = account.id,
                    account_iban = account.iban,
                    account_balance = balance,
                    message = ("Transfer from account %s (%s). Old balance: %s, new balance: %s. Done by: %s"):format(account.iban, account.id, account.balance, balance, identifier)
                })
            end
        )
    end)
end

---@param source<number> - Source
---@param account<account> - Account
---@param amount<number> - Amount
---@param balance<number> - Balance
---@param reason<string> - Reason
function handleDepositToAnyAccount(source, account, amount, balance, reason)
    if not amount or amount <= 0 then
        return false
    end

    if not account then
        return false
    end

    MySQL.query([[
            UPDATE
                fd_advanced_banking_accounts
            SET
                balance = ?
            WHERE
                id = ?
        ]],
        { balance, account.id },
        function()
            addTransaction(source, account.id, 'transferin', 2, account.iban, amount, reason)

            if Config.UpdateQbManagementTable and account.business then
                MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {balance, account.business})
            end

            sendAccountUpdatedEventToMembers(account.id, 'updated')

            if account.type == 'personal' then
                local member = getAccountOwner(account)

                if member then
                    local source = bridge.getSourceFromIdentifier(member.identifier)

                    if source and bridge.isPlayerOnline(source) then
                        bridge.setAccountAmount(source, 'bank', balance)
                    end
                end
                --
            end

            createLog(source, {
                type = 'account',
                action = 'transferin',
                account_id = account.id,
                account_iban = account.iban,
                account_balance = 0,
                message = ("Transfer into account %s (%s). Old balance: %s, new balance: %s. Done by: %s"):format(account.iban, account.id, account.balance, balance, identifier)
            })
        end
    )

    return true
end
exports('handleDepositToAnyAccount', handleDepositToAnyAccount)

---@param source<number> - Source
---@param account<account> - Account
---@param amount<number> - Amount
---@param balance<number> - Balance
---@param reason<string> - Reason
function handleWithdrawalFromAccount(source, account, amount, balance, reason)
    if not amount or amount <= 0 then
        return false
    end

    if not account then
        return false
    end


    MySQL.query([[
            UPDATE
                fd_advanced_banking_accounts
            SET
                balance = ?
            WHERE
                id = ?
        ]],
        { balance, account.id },
        function()
            addTransaction(source, account.id, 'transferout', account.iban, 2, amount, reason)

            sendAccountUpdatedEventToMembers(account.id, 'updated')

            if account.type == 'personal' then
                local member = getAccountOwner(account)

                if member then
                    local source = bridge.getSourceFromIdentifier(member.identifier)

                    if source and bridge.isPlayerOnline(source) then
                        bridge.setAccountAmount(source, 'bank', balance)
                    end
                end
                --
            end

            if Config.UpdateQbManagementTable and account.business then
                MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {balance, account.business})
            end

            createLog(source, {
                type = 'account',
                action = 'transferout',
                account_id = account.id,
                account_iban = account.iban,
                account_balance = balance,
                message = ("Transfer from account %s (%s). Old balance: %s, new balance: %s. Done by: %s"):format(account.iban, account.id, account.balance, balance, identifier)
            })
        end
    )

    return true
end
exports('handleWithdrawalFromAccount', handleWithdrawalFromAccount)

---@param source<number> - Source
---@param amount<number> - Amount
---@param reason<string> - Reason
function forceSetPersonalBalance(source, amount, reason)
    local identifier = bridge.getIdentifier(source)
    local account = getPersonalAccount(identifier)

    if not account then
        return false
    end

    MySQL.query([[
            UPDATE
                fd_advanced_banking_accounts
            SET
                balance = ?
            WHERE
                id = ?
        ]],
        { amount, account.id },
        function()
            sendAccountUpdatedEventToMembers(account.id, 'updated')

            createLog(source, {
                type = 'account',
                action = 'transferout',
                account_id = account.id,
                account_iban = account.iban,
                message = ("Forced personal account balance %s (%s). Balance: %s. Done by: %s"):format(account.iban, account.id, amount, identifier)
            })
        end
    )

    return true
end
