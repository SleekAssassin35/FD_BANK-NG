local resourceName = 'qb-core'
local qboxResourceName = 'qbx-core'

if not GetResourceState(resourceName):find('start') and not GetResourceState(qboxResourceName):find('start') then return end

SetTimeout(0, function()
    QB = exports[resourceName]:GetCoreObject()
    core = QB

    RegisterNetEvent("QBCore:Server:PlayerLoaded", function(player)
        if not player then
            player  = core.Functions.GetPlayer(source)
        end

        createDefaultAccountOrSync(player.PlayerData.source)

        core.Functions.AddPlayerMethod(player.PlayerData.source, 'AddMoney', function(moneytype, amount, reason, data)
            reason = reason or locale('not_provided')
            amount = tonumber(amount)

            if amount < 0 then
                return false
            end

            amount = math.floor(amount)

            local player = core.Functions.GetPlayer(player.PlayerData.source)

            if not player.PlayerData.money[moneytype] then
                return false
            end

            player.PlayerData.money[moneytype] = player.PlayerData.money[moneytype] + amount

            if not player.Offline then
                player.Functions.SetPlayerData('money', player.PlayerData.money)

                if moneytype == 'bank' and not data?.skipTransaction then
                    CreateThread(function()
                        handleDepositToPersonalAccount(player.PlayerData.source, amount, player.PlayerData.money[moneytype], reason)
                    end)
                end

                if amount > 100000 then
                    TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(player.PlayerData.source) .. ' (citizenid: ' .. player.PlayerData.citizenid .. ' | id: ' .. player.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. player.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
                else
                    TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(player.PlayerData.source) .. ' (citizenid: ' .. player.PlayerData.citizenid .. ' | id: ' .. player.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. player.PlayerData.money[moneytype] .. ' reason: ' .. reason)
                end

                TriggerClientEvent('hud:client:OnMoneyChange', player.PlayerData.source, moneytype, amount, false)
                TriggerClientEvent('QBCore:Client:OnMoneyChange', player.PlayerData.source, moneytype, amount, "add", reason)
                TriggerEvent('QBCore:Server:OnMoneyChange', player.PlayerData.source, moneytype, amount, "add", reason)

                return true
            end

            return false
        end)

        core.Functions.AddPlayerMethod(player.PlayerData.source, 'RemoveMoney', function(moneytype, amount, reason, data)
            reason = reason or locale('not_provided')
            amount = tonumber(amount)

            if amount < 0 then
                return false
            end

            amount = math.floor(amount)

            local player = core.Functions.GetPlayer(player.PlayerData.source)

            if not player.PlayerData.money[moneytype] then
                return false
            end

            for _, mtype in pairs(core.Config.Money.DontAllowMinus) do
                if mtype == moneytype then
                    if (player.PlayerData.money[moneytype] - amount) < 0 then
                        return false
                    end
                end
            end

            player.PlayerData.money[moneytype] = player.PlayerData.money[moneytype] - amount

            if not player.Offline then
                local isFrozen = isPersonalAccountFrozenFromSource(player.PlayerData.source)

                if isFrozen then
                    return false
                end

                player.Functions.SetPlayerData('money', player.PlayerData.money)

                if moneytype == 'bank' and not data?.skipTransaction then
                    CreateThread(function()
                        handleWithdrawFromPersonalAccount(player.PlayerData.source, amount, player.PlayerData.money[moneytype], reason)
                    end)
                end

                if amount > 100000 then
                    TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(player.PlayerData.source) .. ' (citizenid: ' .. player.PlayerData.citizenid .. ' | id: ' .. player.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. player.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
                else
                    TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(player.PlayerData.source) .. ' (citizenid: ' .. player.PlayerData.citizenid .. ' | id: ' .. player.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. player.PlayerData.money[moneytype] .. ' reason: ' .. reason)
                end

                TriggerClientEvent('hud:client:OnMoneyChange', player.PlayerData.source, moneytype, amount, true)

                if moneytype == 'bank' then
                    TriggerClientEvent('qb-phone:client:RemoveBankMoney', player.PlayerData.source, amount)
                end

                TriggerClientEvent('QBCore:Client:OnMoneyChange', player.PlayerData.source, moneytype, amount, "remove", reason)
                TriggerEvent('QBCore:Server:OnMoneyChange', player.PlayerData.source, moneytype, amount, "remove", reason)

                return true
            end

            return false
        end)

        processOverdueInvoices(player.PlayerData.source)
    end)

    AddEventHandler("QBCore:Server:OnMoneyChange", function(source, moneytype, amount, action, reason)
        if moneytype ~= 'bank' then
            return false
        end

        if action ~= 'set' then
            return false
        end

        forceSetPersonalBalance(source, amount, reason)
    end)

    function bridge.getIdentifier(source)
        local player = core.Functions.GetPlayer(source)

        if player then
            return player.PlayerData.citizenid
        end

        return false
    end

    function bridge.getSourceFromIdentifier(identifier)
        local player = core.Functions.GetPlayerByCitizenId(identifier)

        if player then
            return player.PlayerData.source
        end

        return false
    end

    function bridge.isPlayerOnline(source)
        local player = core.Functions.GetPlayer(source)

        if player then
            return true
        end

        return false
    end

    function bridge.currentSociety(source, isGang)
        local player = core.Functions.GetPlayer(source)

        if player then
            if isGang then
                return player.PlayerData.gang.name
            end

            return player.PlayerData.job.name
        end

        return false
    end

    function bridge.currentSocietyWithGrade(source, isGang)
        local player = core.Functions.GetPlayer(source)

        if player then
            if isGang then
                return player.PlayerData.gang.name, player.PlayerData.gang.grade.level
            end

            return player.PlayerData.job.name, player.PlayerData.job.grade.level
        end

        return false
    end

    function bridge.getJobLabel(job)
        return core.Shared.Jobs[job]?.label or nil
    end

    function bridge.isPlayerBoss(source, isGang)
        local player = core.Functions.GetPlayer(source)

        if player then
            if isGang then
                return player.PlayerData.gang.isboss
            end

            return player.PlayerData.job.isboss
        end

        return false
    end

    function bridge.firstLastName(source)
        local player = core.Functions.GetPlayer(source)

        if player then
            return ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
        end

        return source
    end

    function bridge.getAccountAmount(source, account)
        local player = core.Functions.GetPlayer(source)

        if player then
            return player.PlayerData.money[account] or false
        end

        return false
    end

    function bridge.setAccountAmount(source, account, amount, reason, data)
        local player = core.Functions.GetPlayer(source)

        if player then
            return player.Functions.SetMoney(account, amount, reason, data)
        end

        return false
    end

    function bridge.removeMoney(source, account, amount, reason, data)
        local player = core.Functions.GetPlayer(source)

        if player then
            return player.Functions.RemoveMoney(account, amount, reason, data)
        end

        return false
    end

    function bridge.addMoney(source, account, amount, reason, data)
        local player = core.Functions.GetPlayer(source)

        if player then
            return player.Functions.AddMoney(account, amount, reason, data)
        end

        return false
    end

    function bridge.notify(source, message, type)
        TriggerClientEvent('QBCore:Notify', source, message, type)
    end

    function bridge.getJobs()
        local societys = {}

        if Config.UseSocietyAccounts then
            local jobs = core.Shared.Jobs

            for k, v in pairs(jobs) do
                societys[k] = v
            end
        end

        if Config.UseGangAccounts then
            local gangs = core.Shared.Gangs

            for k, v in pairs(gangs) do
                societys[k] = v
            end
        end

        return societys
    end

    function bridge.isStaff(source, permission)
        return core.Functions.HasPermission(source, permission)
    end

    function bridge.getPlayersByGrade(job, grade)
        return MySQL.query.await([[
            SELECT
                *
            FROM
                players
            WHERE
                JSON_CONTAINS(job, ?, '$.name') AND
                JSON_CONTAINS(job, ?, '$.grade.level')
        ]], { ('"%s"'):format(job), ('%s'):format(grade) })
    end

    function bridge.createLog(source, data)
        TriggerEvent('qb-log:server:CreateLog', 'banking', 'Banking', 0, data.message, false)
    end

    function bridge.trackedPlayerUsed(source, identifier, coords, type)
        Citizen.CreateThread(function()
            local players = core.Functions.GetQBPlayers()
            for _, v in pairs(players) do
                if v and v.PlayerData.job.name == "police" then
                    bridge.notify(v.PlayerData.source, ('%s used %s, at %s'):format(identifier, type, coords), 'error')
                end
            end
        end)
    end

    AddEventHandler('QBCore:Server:UpdateObject', function()
        QB = exports[resourceName]:GetCoreObject()
        core = QB

        TriggerEvent("fd_banking:UpdateObject")
    end)
end)
