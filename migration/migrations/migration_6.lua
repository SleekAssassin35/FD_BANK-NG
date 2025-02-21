local Migration = {}

function Migration.up()
    local migrationExists = MySQL.scalar.await('SELECT COUNT(*) FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_update_1'})

    if migrationExists == 0 then
        local insert = MySQL.query.await([[
            ALTER TABLE `fd_advanced_banking_accounts`
                ADD COLUMN `business` VARCHAR(255) NULL COLLATE utf8mb4_general_ci
        ]])

        if not insert then
            error('Migration failed! (fd_advanced_banking_accounts_update_1)')
        end

        MySQL.query.await('INSERT INTO fd_advanced_banking_migrations (name) VALUES (?)', {'fd_advanced_banking_accounts_update_1'})
    end
end

function Migration.down()
    MySQL.query.await([[
        ALTER TABLE
            DROP COLUMN `business`
    ]])

    MySQL.query.await('DELETE FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_update_1'})
end


return Migration
