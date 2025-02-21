local Migration = {}

function Migration.up()
    local migrationExists = MySQL.scalar.await('SELECT COUNT(*) FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_invoices'})

    if migrationExists == 0 then
        local insert = MySQL.query.await([[
            CREATE TABLE `fd_advanced_banking_invoices` (
                `id` INT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                `recipient` VARCHAR(75) NOT NULL,
                `issued_by` VARCHAR(75) NOT NULL,
                `status` TINYINT(2) NOT NULL DEFAULT '1',
                `amount` INT(20) UNSIGNED NOT NULL DEFAULT '0',
                `description` VARCHAR(255) NOT NULL COLLATE utf8mb4_general_ci,
                `transfer_to` VARCHAR(255) NOT NULL COLLATE utf8mb4_general_ci,
                `due_on` TIMESTAMP NULL,
                `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB;
        ]])

        if not insert then
            error('Migration failed! (fd_advanced_banking_migrations)')
        end

        MySQL.query.await('INSERT INTO fd_advanced_banking_migrations (name) VALUES (?)', {'fd_advanced_banking_invoices'})
    end
end

function Migration.down()
    MySQL.query.await('DROP TABLE fd_advanced_banking_invoices')

    MySQL.query.await('DELETE FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_invoices'})
end


return Migration
