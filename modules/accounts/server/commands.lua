if Config.IsFreezingEnabled then
    RegisterCommand(Config.FreezingCommand, function(source, args, raw)
        if not args[1] then
            return
        end

        local identifier = bridge.getIdentifier(source)

        if not identifier then
            return
        end

        if not canFreezeAccount(source) then
            bridge.notify(source, locale('you_dont_have_permission_to_use_this_command'), 'error')
            return
        end

        local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE iban = ? OR id = ?', { args[1] })

        if tonumber(args[1]) < 1000 then
            local targetPlayerIdentifier = bridge.getIdentifier(tonumber(args[1]))

            if not targetPlayerIdentifier then
                bridge.notify(source, locale('player_not_online'), 'error')
                return
            end

            account = getPersonalAccount(targetPlayerIdentifier)
        end

        if not account then
            bridge.notify(source, locale('account_not_found'), 'error')
            return
        end

        if account.is_frozen then
            bridge.notify(source, locale('account_frozen'), 'error')
            return
        end

        MySQL.update('UPDATE fd_advanced_banking_accounts SET is_frozen = 1 WHERE id = ?', { account.id })

        bridge.notify(source, locale('account_frozen_successfully'), 'success')
    end, false)

    RegisterCommand(Config.UnfreezingCommand, function(source, args, raw)
        if not args[1] then
            return
        end

        local identifier = bridge.getIdentifier(source)

        if not identifier then
            return
        end

        if not canFreezeAccount(source) then
            bridge.notify(source, locale('you_dont_have_permission_to_use_this_command'), 'error')
            return
        end

        local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE iban = ? OR id = ?', { args[1] })

        if tonumber(args[1]) < 1000 then
            local targetPlayerIdentifier = bridge.getIdentifier(source)

            if not targetPlayerIdentifier then
                bridge.notify(locale('player_not_online'), 'error')
                return
            end

            account = getPersonalAccount(targetPlayerIdentifier)
        end

        if not account then
            bridge.notify(source, locale('account_not_found'), 'error')
            return
        end

        if not account.is_frozen then
            bridge.notify(source, locale('account_not_frozen'), 'error')
            return
        end

        MySQL.update('UPDATE fd_advanced_banking_accounts SET is_frozen = 0 WHERE id = ?', { account.id })

        bridge.notify(source, locale('account_unfrozen_successfully'), 'success')
    end, false)
end
