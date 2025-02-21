UI = {}

function UI.openBank(dontCheckDistance)
    if not dontCheckDistance  then
        if not isNearBank() then
            return false
        end
    end

    UI.setFleecaTheme()


    isTrackedTrigger('bank')

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'bank:open',
        data = {}
    })

    return true
end

function UI.openAtm()

    isTrackedTrigger('atm')

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'atm:open',
        data = {}
    })
end

function UI.setAccounts(accounts)
    SendNUIMessage({
        action = 'bank:setAccounts',
        data = {
            accounts = accounts
        }
    })
end

function UI.setAccount(account)
    SendNUIMessage({
        action = 'bank:setAccount',
        data = {
            account = account
        }
    })
end

function UI.setCash(amount)
    SendNUIMessage({
        action = 'bank:setCash',
        data = {
            amount = amount
        }
    })
end

function UI.closeBank()
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'bank:close',
        data = {}
    })
end

function UI.openATM()
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'atm:open',
        data = {}
    })
end

function UI.closeATM()
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'atm:close',
        data = {}
    })
end

function UI.setFleecaTheme()
    SendNUIMessage({
        action = 'bank:fleecaTheme',
        data = {}
    })
end

function UI.setMazeTheme()
    SendNUIMessage({
        action = 'bank:mazeTheme',
        data = {}
    })
end

function UI.sendExportAnswer(isSuccess, url)
    SendNUIMessage({
        action = 'bank:exportAnswer',
        data = {
            isSuccess = isSuccess,
            url = url
        }
    })
end

function UI.sendMembersAnswer(isSuccess, members)
    SendNUIMessage({
        action = 'bank:fetchMembers',
        data = {
            isSuccess = isSuccess,
            members = members
        }
    })
end

function UI.sendAddMembersAnswer(isSuccess)
    SendNUIMessage({
        action = 'bank:addMemberAnswer',
        data = {
            isSuccess = isSuccess
        }
    })
end

function UI.sendEditMembersAnswer(isSuccess)
    SendNUIMessage({
        action = 'bank:editMemberAnswer',
        data = {
            isSuccess = isSuccess
        }
    })
end

function UI.sendDeleteMembersAnswer(isSuccess)
    SendNUIMessage({
        action = 'bank:deleteMemberAnswer',
        data = {
            isSuccess = isSuccess
        }
    })
end

function UI.informAboutAccountUpdate(accountId)
    SendNUIMessage({
        action = 'bank:accountUpdated',
        data = {
            accountId = accountId
        }
    })
end

function UI.informAboutAccountDeleted(accountId)
    SendNUIMessage({
        action = 'bank:accountDeleted',
        data = {
            accountId = accountId
        }
    })
end

function UI.sendMemberEvent(id, event)
    SendNUIMessage({
        action = 'bank:memberEvent',
        data = {
            id = id,
            event = event
        }
    })
end

exports('sendUIAction', function(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end)

RegisterNUICallback('bankClosed', function(data, cb)
    SetNuiFocus(false, false)


    cb('ok')
end)

RegisterNUICallback('atmClosed', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

function openBank(dontCheckDistance)
    local shouldOpen = UI.openBank(dontCheckDistance)

    if shouldOpen then
        TriggerServerEvent('fd_banking:server:fetchAccounts')
    end
end
exports('openBank', function(dontCheckDistance)
    openBank(dontCheckDistance)
end)

function openAtm()
    UI.openAtm()

    TriggerServerEvent('fd_banking:server:fetchAccounts')
end
exports('openAtm', function()
    openAtm()
end)
