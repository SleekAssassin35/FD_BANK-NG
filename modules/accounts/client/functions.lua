---@param accounts<Accounts> - Accounts
function sendAccounts(accounts)
    UI.setAccounts(accounts)
end

---@param account<Account> - Account
function sendAccount(account)
    UI.setAccount(account)
end

---@param amount<number> - Amount
function sendCash(amount)
    UI.setCash(amount)
end

---@param data<NUIData> - Data
function createNewSharedAccount(data)
    local isSuccess = lib.callback.await("fd_banking:server:cb:createSharedAccount", false, data.name)

    if isSuccess then
        TriggerServerEvent('fd_banking:server:fetchAccounts')
    end

    return isSuccess
end

---@param data<NUIData> - Data
function depositMoney(data)
    local isSuccess = lib.callback.await("fd_banking:server:cb:depositMoney", false, data.amount, data.id, data.reason)

    if isSuccess then
        TriggerServerEvent('fd_banking:server:fetchAccounts')
    end

    return isSuccess
end

---@param data<NUIData> - Data
function withdrawMoney(data)
    local isSuccess = lib.callback.await("fd_banking:server:cb:withdrawMoney", false, data.amount, data.id, data.reason)

    if isSuccess then
        TriggerServerEvent('fd_banking:server:fetchAccounts')
    end

    return isSuccess
end

---@param data<NUIData> - Data
function transferMoney(data)
    local isSuccess = lib.callback.await("fd_banking:server:cb:transferMoney", false, data.account_number, data.player_id, data.amount, data.id, data.reason)

    if isSuccess then
        TriggerServerEvent('fd_banking:server:fetchAccounts')
    end

    return isSuccess
end

---@param data<NUIData> - Data
function deleteAccount(data)
    local isSuccess = lib.callback.await("fd_banking:server:cb:deleteAccount", false, data.id)

    if isSuccess then
        TriggerServerEvent('fd_banking:server:fetchAccounts')
    end

    return isSuccess
end

---@param accountId<number> - Account ID
function sendAccountUpdated(accountId)
    UI.informAboutAccountUpdate(accountId)
end

---@param accountId<number> - Account ID
function sendAccountDeleted(accountId)
    UI.informAboutAccountDeleted(accountId)
end

---@param data<NUIData> - Data
function loadAccount(data)
    TriggerServerEvent('fd_banking:server:fetchAccount', data.id)

    return false
end
