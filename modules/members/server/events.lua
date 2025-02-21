RegisterNetEvent("fd_banking:server:members:fetch", function(id)
    fetchMembers(source, id)
end)

RegisterNetEvent("fd_banking:server:members:add", function(data)
    addMember(source, data.id, data.citizen_id, data.can_control_members, data.can_deposit, data.can_withdraw, data.can_transfer, data.can_export)
end)

RegisterNetEvent("fd_banking:server:members:edit", function(data)
    editMember(source, data.id, data.citizen_id, data.can_control_members, data.can_deposit, data.can_withdraw, data.can_transfer, data.can_export)
end)

RegisterNetEvent("fd_banking:server:members:delete", function(data)
    deleteMember(source, data.id, data.citizen_id)
end)
