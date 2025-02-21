local Migration = {}

function Migration.up()
    local migrationExists = MySQL.scalar.await('SELECT COUNT(*) FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_update_2'})

    if migrationExists == 0 then
        local insert = MySQL.query.await([[
            ALTER TABLE `fd_advanced_banking_accounts`
                ADD COLUMN `is_society` TINYINT(1) NOT NULL DEFAULT 0
        ]])

        if not insert then
            error('Migration failed! (fd_advanced_banking_accounts_update_2)')
        end

        MySQL.query.await('INSERT INTO fd_advanced_banking_migrations (name) VALUES (?)', {'fd_advanced_banking_accounts_update_2'})
    end
end

function Migration.down()
    MySQL.query.await([[
        ALTER TABLE
            DROP COLUMN `is_society`
    ]])

    MySQL.query.await('DELETE FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_update_2'})
end


return Migration
