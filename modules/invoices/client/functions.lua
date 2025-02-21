function fetchUnpaidInvoices(data)
    local response = lib.callback.await("fd_banking:server:cb:fetchUnpaidInvoices", false, data.page, data.limit)

    return response
end

function fetchPaidInvoices(data)
    local response = lib.callback.await("fd_banking:server:cb:fetchOtherInvoices", false, data.page, data.limit)

    return response
end

local function invoiceDialog(isSociety)
    local input = lib.inputDialog(('Fatura Kes'), {
        {type = 'number', label = ("Oyuncu ID")},
        {type = 'number', label = ("Ceza Miktarı")},
        {type = 'input', label = ("Açıklama")},
    })

    if input then

        TriggerServerEvent("fd_banking:server:issueInvoice", tonumber(input[1]), tonumber(input[2]), input[3], isSociety)
    end
end

function lookupCitizen()
    local input = lib.inputDialog(locale('lookup_citizen_dialog_title'), {
        {type = 'number', label = locale("player_id_title")},
    })

    if input then
        if tonumber(input[1]) < 1 then
            bridge.notify(locale('invalid_player_id'), 'error')

            return
        end

        TriggerServerEvent("fd_banking:server:lookupCitizen", tonumber(input[1]))
    end
end

function lookupInvoice()
    local input = lib.inputDialog(locale('lookup_invoice_dialog_title'), {
        {type = 'number', label = locale("invoice_id_title")},
    })

    if input then
        if tonumber(input[1]) < 1 then
            bridge.notify(locale('invalid_invoice_id'), 'error')

            return
        end

        TriggerServerEvent("fd_banking:server:showInvoice", tonumber(input[1]))
    end
end

function cancelInvoice()
    local input = lib.inputDialog(locale('cancel_invoice_dialog_title'), {
        {type = 'number', label = locale("invoice_id_title")},
    })

    if input then
        if tonumber(input[1]) < 1 then
            bridge.notify(locale('invalid_invoice_id'), 'error')

            return
        end

        TriggerServerEvent("fd_banking:server:cancelInvoice", tonumber(input[1]))
    end
end

function payAllInvoices()
    local response = lib.callback.await("fd_banking:server:cb:payAllInvoices")

    return response
end

function openBilling()
    local menus = {}

    local job = bridge.getPlayerJobInfo()

    if Config.SocietiesInvoicesEnabled[job.name] then
        table.insert(menus, {
            title = ('Fatura Kes'),
            description = ('Bu işletmeye bağlı bir faturadır, ceza işletme hesabına düşecektir.'),
            icon = 'money-check-dollar',
            onSelect = function()
                Citizen.CreateThread(function()
                    invoiceDialog(true)
                end)
            end,
          })
    end

    lib.registerContext({
        id = 'billing_menu',
        title = ('Fatura Menüsü'),
        options = menus
    })

    lib.showContext('billing_menu')
end
exports('openBilling', openBilling)

function fetchUnpaidInvoicesSum()
    local response = lib.callback.await("fd_banking:server:cb:fetchUnpaidInvoicesSum")

    return response
end

function fetchUnpaidInvoicesCount()
    local response = lib.callback.await("fd_banking:server:cb:fetchUnpaidInvoicesCount")

    return response
end

function fetchPayInvoice(data)
    local response = lib.callback.await("fd_banking:server:cb:fetchPayInvoice", false, data.id)

    return response
end

function fetchDeclineInvoice(data)
    local response = lib.callback.await("fd_banking:server:cb:fetchDeclineInvoice", false, data.id)

    return response
end

exports('openBilling', openBilling)

if Config.BillingCommand then
    RegisterCommand(Config.BillingCommand, function()
        openBilling()
    end)
end
