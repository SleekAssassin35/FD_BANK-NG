local loansResource = Config.LoansResource or 'fd_banking_loans'

if not GetResourceState(loansResource):find('start') then return end

RegisterNUICallback('getLoansResource', function(data, cb)
    cb(loansResource)
end)
