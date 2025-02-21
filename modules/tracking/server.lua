function canToggleTracking(source)
    if bridge.isStaff(source, Config.AdminPermissionToTrack) then
        return true
    end

    if not Config.EnableUsageTracking then
        return false
    end

    local society, grade = bridge.currentSocietyWithGrade(source)

    if Config.SocietyCanUseTracking[society] and Config.SocietyCanUseTracking[society] <= grade then
        return true
    end

    return false
end

if Config.EnableUsageTracking then
    RegisterCommand(Config.TrackingCommand, function(source, args, raw)
        if not args[1] then
            return
        end

        if not canToggleTracking(source) then
            bridge.notify(source, locale('you_dont_have_permission_to_use_this_command'), 'error')
            return
        end

        if tonumber(args[1]) ~= nil then
            args[1] = bridge.getIdentifier(tonumber(args[1]))
        end

        if not args[1] then
            bridge.notify(source, locale('invalid_player_id'), 'error')
            return
        end

        local isTracked = MySQL.single.await('SELECT * FROM fd_advanced_banking_tracking WHERE identifier = ?', { args[1] })

        if isTracked then
            bridge.notify(source, locale('player_already_tracked'), 'error')
            return
        end

        MySQL.insert('INSERT INTO fd_advanced_banking_tracking (identifier) VALUES (?)', { args[1] })

        bridge.notify(source, locale('player_is_being_tracked', args[1]), 'success')
    end, false)

    RegisterCommand(Config.UntrackCommand, function(source, args, raw)
        if not args[1] then
            return
        end

        if not canToggleTracking(source) then
            bridge.notify(source, locale('you_dont_have_permission_to_use_this_command'), 'error')
            return
        end

        local isTracked = MySQL.single.await('SELECT * FROM fd_advanced_banking_tracking WHERE identifier = ?', { args[1] })

        if not isTracked then
            bridge.notify(source, locale('player_is_not_being_tracked'), 'error')
            return
        end

        MySQL.query('DELETE FROM fd_advanced_banking_tracking WHERE identifier = ?', { args[1] })

        bridge.notify(source, locale('player_tracking_removed', args[1]), 'success')
    end, false)
end

RegisterNetEvent("fd_banking:server:isTracked", function(coords, type)
    local identifier = bridge.getIdentifier(source)

    if not identifier then
        return
    end

    local isTracked = MySQL.single.await('SELECT * FROM fd_advanced_banking_tracking WHERE identifier = ?', { identifier })

    if not isTracked then
        return
    end

    bridge.trackedPlayerUsed(source, identifier, coords, type)
end)
