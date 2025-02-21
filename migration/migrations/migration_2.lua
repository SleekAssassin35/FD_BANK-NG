local Migration = {}

function Migration.up()
    local migrationExists = MySQL.scalar.await('SELECT COUNT(*) FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts'})

    if migrationExists == 0 then
        local insert = MySQL.query.await([[
            CREATE TABLE `fd_advanced_banking_accounts` (
                `id` INT(20) unsigned NOT NULL AUTO_INCREMENT,
                `iban` VARCHAR(255) NOT NULL COLLATE utf8mb4_general_ci,
                `name` VARCHAR(255) NULL DEFAULT NULL COLLATE utf8mb4_general_ci,
                `balance` BIGINT(255) NOT NULL,
                `type` CHAR(20) NOT NULL DEFAULT "personal" COLLATE utf8mb4_general_ci,
                `is_frozen` TINYINT(1) NOT NULL DEFAULT 0,
                `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY `fd_advanced_banking_accounts_id_unique` (`id`) USING BTREE,
                UNIQUE KEY `fd_advanced_banking_accounts_iban_unique` (`iban`) USING BTREE,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB;
        ]])

        if not insert then
            error('Migration failed! (fd_advanced_banking_accounts)')
        end

        MySQL.query.await('INSERT INTO fd_advanced_banking_migrations (name) VALUES (?)', {'fd_advanced_banking_accounts'})
    end
end

function Migration.down()
    MySQL.query.await('DROP TABLE fd_advanced_banking_accounts')

    MySQL.query.await('DELETE FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts'})
end


return Migration
