local Migration = {}

function Migration.up()
    local migrationExists = MySQL.scalar.await('SELECT COUNT(*) FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_tracking'})

    if migrationExists == 0 then
        local insert = MySQL.query.await([[
            CREATE TABLE `fd_advanced_banking_tracking` (
                `id` INT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                `identifier` VARCHAR(50) NOT NULL,
                `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB;
        ]])

        if not insert then
            error('Migration failed! (fd_advanced_banking_migrations)')
        end

        MySQL.query.await('INSERT INTO fd_advanced_banking_migrations (name) VALUES (?)', {'fd_advanced_banking_tracking'})
    end
end

function Migration.down()
    MySQL.query.await('DROP TABLE fd_advanced_banking_tracking')

    MySQL.query.await('DELETE FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_tracking'})
end


return Migration
