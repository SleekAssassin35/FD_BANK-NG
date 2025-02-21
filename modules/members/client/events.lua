RegisterNetEvent("fd_banking:client:members:fetched", function(isSuccess, members)
    UI.sendMembersAnswer(isSuccess, members)
end)

RegisterNetEvent("fd_banking:client:members:addedMember", function(isSuccess)
    UI.sendAddMembersAnswer(isSuccess)
end)

RegisterNetEvent("fd_banking:client:members:editedMember", function(isSuccess)
    UI.sendEditMembersAnswer(isSuccess)
end)

RegisterNetEvent("fd_banking:client:members:deletedMember", function(isSuccess)
    UI.sendDeleteMembersAnswer(isSuccess)
end)


RegisterNetEvent("fd_advanced_banking:client:member:added", function(accountId)
    UI.sendMemberEvent(accountId, 'added')
end)

RegisterNetEvent("fd_advanced_banking:client:member:updated", function(accountId)
    UI.sendMemberEvent(accountId, 'updated')
end)

RegisterNetEvent("fd_advanced_banking:client:member:deleted", function(accountId)
    UI.sendMemberEvent(accountId, 'deleted')
end)
