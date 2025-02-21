local syncing = false

RegisterNetEvent("fd_banking:server:removedFromSociety", function(society, isGang)
    local src = source

    if not Config.UseSocietyAccounts and not Config.UseGangAccounts then
        return
    end

    local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {society})

    if not account then
        return
    end

    local identifier = bridge.getIdentifier(src)

    if not identifier then
        return
    end

    if bridge.currentSociety(src, isGang) == society then
        return
    end

    MySQL.query.await('DELETE FROM fd_advanced_banking_accounts_members WHERE account_id = ? AND identifier = ?', {account.id, identifier})
end)

RegisterNetEvent("fd_banking:server:downgradedFromSociety", function(society, isGang)
    local src = source

    if not Config.UseSocietyAccounts and not Config.UseGangAccounts then
        return
    end

    local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {society})

    if not account then
        return
    end

    local identifier = bridge.getIdentifier(src)

    if not identifier then
        return
    end

    if bridge.currentSociety(src, isGang) ~= society then
        return
    end

    MySQL.query.await('DELETE FROM fd_advanced_banking_accounts_members WHERE account_id = ? AND identifier = ?', {account.id, identifier})
end)

RegisterNetEvent("fd_banking:server:addedToSociety", function(society, isGang)
    local src = source

    if not Config.UseSocietyAccounts and not Config.UseGangAccounts then
        return
    end

    local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {society})

    if not account then
        return
    end

    local identifier = bridge.getIdentifier(src)

    if not identifier then
        return
    end

    if bridge.currentSociety(src, isGang) ~= society then
        return
    end

    if not bridge.isPlayerBoss(src, isGang) then
        return
    end

    MySQL.query.await('INSERT INTO fd_advanced_banking_accounts_members (account_id, identifier, is_owner) VALUES (?, ?, ?)', {account.id, identifier, true})
end)

local function syncBosses(jobs)
    societyLogger:info('Syncing bosses')

    local queries = {}

    for job, info in pairs(jobs) do
        if not info.account_id then
            local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {job})
            if not account then
                goto continue
            end

            info.account_id = account.id
        end

        MySQL.query.await('DELETE FROM fd_advanced_banking_accounts_members WHERE account_id = ? AND is_owner = 1', {info.account_id})

        for _, grade in pairs(info.grades) do
            local players = bridge.getPlayersByGrade(job, grade)

            for _, player in pairs(players) do
                societyLogger:info('Adding ' .. player.citizenid .. ' to ' .. job)

                table.insert(queries, {
                    query = 'INSERT INTO fd_advanced_banking_accounts_members (account_id, identifier, is_owner) VALUES (:account_id, :identifier, :is_owner)',
                    values = {["account_id"] = info.account_id, ["identifier"] = player.citizenid, ["is_owner"] = true}
                })
            end
        end

        ::continue::
    end

    local success = MySQL.transaction.await(queries)

    if not success then
        societyLogger:error('Failed to sync bosses')
        return
    end

    societyLogger:info('Society bosses synced!')
    syncing = false
end

local function syncSocietyAccounts()
    if Config.UseSocietyAccounts then
        syncing = true
        local societys = bridge.getJobs()

        local accounts = MySQL.query.await('SELECT * FROM fd_advanced_banking_accounts WHERE business IS NOT NULL AND is_society = 1')
        local updatedAccounts = {}
        local queries = {}

        for key, society in pairs(societys) do
            local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {key})

            local bossGrades = {}

            for gradeKey, grade in pairs(society.grades) do
                if grade.isboss then
                    table.insert(bossGrades, gradeKey)
                end
            end

            if #bossGrades < 1 then
                goto continue
            end
            if account then
                table.insert(queries, {
                    query = 'UPDATE fd_advanced_banking_accounts SET name = :name WHERE business = :business',
                    values = {["name"] = society.label or 'Unknown', ["business"] = key}
                })
            else
                local iban = getFreeIbanNumber()
                table.insert(queries, {
                    query = 'INSERT INTO fd_advanced_banking_accounts (name, iban, balance, type, business, is_society) VALUES (:name, :iban, :balance, :type, :business, :is_society)',
                    values = {["name"] = society.label, ["iban"] = iban, ["balance"] = 0, ["type"] = 'business', ["business"] = key, ["is_society"] = true}
                })

                societyLogger:info('Created society account for ' .. key)
            end

            updatedAccounts[key] = {
                account_id = account?.id or nil,
                job = key,
                grades = bossGrades
            }

            ::continue::
        end

        local success = MySQL.transaction.await(queries)

        if not success then
            societyLogger:error('Failed to sync society accounts')
            return
        end

        for _, account in pairs(accounts) do
            if not updatedAccounts[account.business] then
                MySQL.query.await('DELETE FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {account.business})
            end
        end

        societyLogger:info('Society accounts synced!')
        syncBosses(updatedAccounts)
    end
end

-- Compatibility for qb-management
local function getSocietyAccount(society)
    local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {society})

    if account then
        return account.balance
    end

    return 0
end
exports('GetAccount', getSocietyAccount)
exports('GetGangAccount', getSocietyAccount)

local function addSocietyMoney(society, amount, reason)
    local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {society})

    if account then
        local newBalance = math.floor(account.balance + amount)

        Citizen.CreateThread(function()
            handleDepositToAnyAccount(locale('system'), account, amount, newBalance, reason)
        end)

        if Config.UpdateQbManagementTable then
            MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {newBalance, society})
        end

        return true
    end

    return false
end
exports('AddMoney', addSocietyMoney)
exports('AddGangMoney', addSocietyMoney)

local function removeSocietyMoney(society, amount, reason)
    local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE business = ? AND is_society = 1', {society})

    if account then
        local newBalance = math.floor(account.balance - amount)

        Citizen.CreateThread(function()
            handleWithdrawalFromAccount(locale('system'), account, amount, math.floor(account.balance - amount), reason)
        end)

        if Config.UpdateQbManagementTable then
            MySQL.query.await('UPDATE `' .. Config.QbManagementTableName ..'` SET `amount` = ? WHERE `job_name` = ?', {newBalance, society})
        end

        return true
    end

    return false
end
exports('RemoveMoney', removeSocietyMoney)
exports('RemoveGangMoney', removeSocietyMoney)


AddEventHandler("fd_banking:migrationsFinished", function()
    Citizen.CreateThread(function()
        syncSocietyAccounts()
    end)
end)

AddEventHandler("fd_banking:UpdateObject", function()
    Citizen.CreateThread(function()
        while syncing do
            Citizen.Wait(1000)
        end

        syncSocietyAccounts()
    end)
end)
