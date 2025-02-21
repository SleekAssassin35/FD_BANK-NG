math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 9)))

function getFreeIbanNumber()
    local iban = math.random(1000, 1000000)

    local account = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE iban = ?', { iban })

    if account then
        return getFreeIbanNumber()
    end

    return iban
end
