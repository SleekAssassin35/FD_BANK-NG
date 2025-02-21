--- @param account<Account> - Account
function canDeposit(account)
    if not account then
        return false
    end

    if account.is_frozen then
        return false
    end

    if account.is_owner then
        return true
    end

    return account.can_deposit == 1
end

--- @param account<Account> - Account
function canTransfer(account)
    if not account then
        return false
    end

    if account.is_frozen then
        return false
    end

    if account.is_owner then
        return true
    end

    if account then
        return account.can_transfer == 1
    end

    return false
end

--- @param account<Account> - Account
function canWithdraw(account)
    if not account then
        return false
    end

    if account.is_frozen then
        return false
    end

    if account.is_owner then
        return true
    end

    if account then
        return account.can_withdraw == 1
    end

    return false
end

--- @param account<Account> - Account
function canExport(account)
    if not account then
        return false
    end

    if account.is_frozen then
        return false
    end

    if account.is_owner then
        return true
    end

    if account then
        return account.can_export == 1
    end

    return false
end

--- @param account<Account> - Account
function canDelete(account)
    if not account then
        return false
    end

    if account.is_society then
        return false
    end

    if account.is_frozen then
        return false
    end

    if account.type == 'personal' then
        return false
    end

    if account.is_owner then
        return true
    end

    return false
end

--- @param account<Account> - Account
function isAccountFrozen(account)
    if not account then
        return false
    end

    return type(account.is_frozen) == "boolean" and account.is_frozen or account.is_frozen == 1
end

--- @param source<number> - Source
function isPersonalAccountFrozenFromSource(source)
    local identifier = bridge.getIdentifier(source)
    local account = getPersonalAccount(identifier)

    if not account then
        return false
    end

    return type(account.is_frozen) == "boolean" and account.is_frozen or account.is_frozen == 1
end

--- @param account<Account> - Account
function getAccountOwner(account)
    if not account then
        return false
    end

    if account.is_frozen then
        return false
    end

    local owner = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts_members WHERE account_id = ? and is_owner = 1', { account.id })

    if owner then
        return owner
    end

    return false
end
exports('getAccountOwner', getAccountOwner)

-- @param source<number> - Source
-- @param id<number> - Account ID
function fetchMembers(source, id)
    local identifier = bridge.getIdentifier(source)
    local members = MySQL.query.await('SELECT * FROM fd_advanced_banking_accounts_members WHERE account_id = ?', { id })

    if not members then
        TriggerClientEvent("fd_banking:client:members:fetched", source, false, nil)
        return false
    end

    local currentMember = nil

    for _, member in pairs(members) do
        if member.identifier == identifier then
            currentMember = member
            break
        end
    end

    if not currentMember then
        TriggerClientEvent("fd_banking:client:members:fetched", source, false, nil)
        return false
    end

    if not currentMember.can_control_members then
        TriggerClientEvent("fd_banking:client:members:fetched", source, false, nil)
        return false
    end

    TriggerClientEvent("fd_banking:client:members:fetched", source, true, members)
    return true
end

--- @param source<number> - Source
--- @param account_id<number> - Account ID
--- @param identifier<string> - Member identifier
function getMember(source, account_id, identifier)
    local member = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts_members WHERE account_id = ? and identifier = ?', { account_id, identifier })

    if not member then
        return false
    end

    return member
end
exports('getMember', function(account_id, identifier)
    return getMember(nil, account_id, identifier)
end)

--- @param source<number> - Source
--- @param account_id<number> - Account ID
--- @param citizen_id<string> - Citizen ID
--- @param can_control_members<boolean> - Can control members
--- @param can_deposit<boolean> - Can deposit
--- @param can_withdraw<boolean> - Can withdraw
--- @param can_transfer<boolean> - Can transfer
--- @param can_export<boolean> - Can export
function addMember(source, account_id, citizen_id, can_control_members, can_deposit, can_withdraw, can_transfer, can_export)
    local identifier = bridge.getIdentifier(source)

    local account = getAccount(identifier, account_id, nil)

    if not account then
        TriggerClientEvent("fd_banking:client:members:addedMember", source, false)

        return false
    end

    if not account.is_owner and not account.can_control_members then
        TriggerClientEvent("fd_banking:client:members:addedMember", source, false)
        return false
    end

    local member = getMember(source, account_id, citizen_id)

    if member then
        TriggerClientEvent("fd_banking:client:members:addedMember", source, false)
        return false
    end

    MySQL.query(
        [[
            INSERT INTO
                fd_advanced_banking_accounts_members
                    (account_id, identifier, can_control_members, can_deposit, can_withdraw, can_transfer, can_export)
                VALUES
                    (?, ?, ?, ?, ?, ?, ?)
        ]],
        { account_id, citizen_id, can_control_members, can_deposit, can_withdraw, can_transfer, can_export },
        function()
            TriggerClientEvent("fd_banking:client:members:addedMember", source, true)

            local source = bridge.getSourceFromIdentifier(citizen_id)

            if source and bridge.isPlayerOnline(source) then
                TriggerClientEvent('fd_advanced_banking:client:account:updated', source, account_id)
            end

            sendMemberUpdatedEventToMembers(account_id, 'updated', {
                dontSendToIdentifier = identifier
            })
        end
    )
end

--- @param source<number> - Source
--- @param account_id<number> - Account ID
--- @param citizen_id<string> - Citizen ID
--- @param can_control_members<boolean> - Can control members
--- @param can_deposit<boolean> - Can deposit
--- @param can_withdraw<boolean> - Can withdraw
--- @param can_transfer<boolean> - Can transfer
--- @param can_export<boolean> - Can export
function editMember(source, account_id, citizen_id, can_control_members, can_deposit, can_withdraw, can_transfer, can_export)
    local identifier = bridge.getIdentifier(source)

    local account = getAccount(identifier, account_id, nil)
    if not account then
        TriggerClientEvent("fd_banking:client:members:editedMember", source, false)

        return false
    end

    if not account.is_owner and not account.can_control_members then
        TriggerClientEvent("fd_banking:client:members:editedMember", source, false)
        return false
    end

    local member = getMember(source, account_id, citizen_id)

    if not member then
        TriggerClientEvent("fd_banking:client:members:editedMember", source, false)
        return false
    end

    if member.is_owner == 1 then
        TriggerClientEvent("fd_banking:client:members:editedMember", source, false)
        return false
    end

    MySQL.query(
        [[
            UPDATE
                fd_advanced_banking_accounts_members
            SET
                can_control_members = ?,
                can_deposit = ?,
                can_withdraw = ?,
                can_transfer = ?,
                can_export = ?
            WHERE
                account_id = ? and identifier = ?
        ]],
        { can_control_members, can_deposit, can_withdraw, can_transfer, can_export, account_id, citizen_id },
        function()
            TriggerClientEvent("fd_banking:client:members:editedMember", source, true)

            local source = bridge.getSourceFromIdentifier(citizen_id)

            if source and bridge.isPlayerOnline(source) then
                TriggerClientEvent('fd_advanced_banking:client:account:updated', source, account_id)
            end

            sendMemberUpdatedEventToMembers(account_id, 'updated', {
                dontSendToIdentifier = identifier
            })
        end
    )
end


--- @param source<number> - Source
--- @param account_id<number> - Account ID
--- @param citizen_id<string> - Citizen ID
function deleteMember(source, account_id, citizen_id)
    local identifier = bridge.getIdentifier(source)

    local account = getAccount(identifier, account_id, nil)
    if not account then
        TriggerClientEvent("fd_banking:client:members:deletedMember", source, false)

        return false
    end

    if not account.is_owner and not account.can_control_members then
        TriggerClientEvent("fd_banking:client:members:deletedMember", source, false)
        return false
    end

    local member = getMember(source, account_id, citizen_id)

    if not member then
        TriggerClientEvent("fd_banking:client:members:deletedMember", source, false)
        return false
    end

    if member.is_owner == 1 then
        TriggerClientEvent("fd_banking:client:members:deletedMember", source, false)
        return false
    end

    MySQL.query(
        [[
            DELETE FROM
                fd_advanced_banking_accounts_members
            WHERE
                account_id = ? and identifier = ?
        ]],
        { account_id, citizen_id },
        function()
            TriggerClientEvent("fd_banking:client:members:deletedMember", source, true)

            local source = bridge.getSourceFromIdentifier(citizen_id)

            if source and bridge.isPlayerOnline(source) then
                TriggerClientEvent('fd_advanced_banking:client:account:deleted', source, account_id)
            end

            sendMemberUpdatedEventToMembers(account_id, 'updated', {
                dontSendToIdentifier = identifier
            })
        end
    )
end

--- @param accountId<number> - Account ID
--- @param event<string> - Event
--- @param data<table> - Data
function sendMemberUpdatedEventToMembers(accountId, event, data)
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

            if source and member.identifier ~= data.dontSendToIdentifier and bridge.isPlayerOnline(source) then
                TriggerClientEvent(('fd_advanced_banking:client:member:%s'):format(event), source, accountId)
            end
        end
    end)
end

--- @param accountId<number> - Account ID
function getMembers(accountId)
    local members = MySQL.query.await('SELECT * FROM fd_advanced_banking_accounts_members WHERE account_id = ?', { accountId })

    if not members then
        return false
    end

    return members
end
exports('getMembers', getMembers)
