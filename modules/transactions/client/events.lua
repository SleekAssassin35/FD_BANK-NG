RegisterNetEvent("fd_banking:client:transactions:exported", function(isSuccess, url)
    UI.sendExportAnswer(isSuccess, url)
end)
