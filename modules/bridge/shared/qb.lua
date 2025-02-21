local resourceName = 'qb-core'
local qboxResourceName = 'qbx-core'

if not GetResourceState(resourceName):find('start') and not GetResourceState(qboxResourceName):find('start') then return end

SetTimeout(0, function()
    QBLogger = Logger.New("Bridge - QB")
end)
