RegisterNUICallback("fetchMembers", function(data, cb)
    TriggerServerEvent("fd_banking:server:members:fetch", data.id)

    cb('ok')
end)

RegisterNUICallback("addNewMember", function(data, cb)
    TriggerServerEvent("fd_banking:server:members:add", data)

    cb('ok')
end)

RegisterNUICallback("editNewMember", function(data, cb)
    TriggerServerEvent("fd_banking:server:members:edit", data)

    cb('ok')
end)


RegisterNUICallback("deleteNewMember", function(data, cb)
    TriggerServerEvent("fd_banking:server:members:delete", data)

    cb('ok')
end)
