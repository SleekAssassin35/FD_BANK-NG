local Migration = {}

function Migration.up()
    local migrationExists = MySQL.scalar.await('SELECT COUNT(*) FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_transactions'})

    if migrationExists == 0 then
        local insert = MySQL.query.await([[
            CREATE TABLE `fd_advanced_banking_accounts_transactions` (
                `id` INT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                `account_id` INT(20) UNSIGNED NOT NULL,
                `action` VARCHAR(255) NOT NULL COLLATE utf8mb4_general_ci,
                `done_by` VARCHAR(255) NOT NULL COLLATE utf8mb4_general_ci,
                `from_account` INT(20) NULL DEFAULT NULL,
                `to_account` INT(20) NULL DEFAULT NULL,
                `amount` BIGINT(255) NOT NULL DEFAULT 0,
                `description` VARCHAR(255) NULL DEFAULT NULL COLLATE utf8mb4_general_ci,
                `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY `fd_advanced_banking_accounts_transactions_id_unique` (`id`) USING BTREE,
                INDEX `fd_advanced_banking_accounts_transactions_account_id_index` (`account_id`) USING BTREE,
                CONSTRAINT `fk_fd_accounts_transactions` FOREIGN KEY (`account_id`) REFERENCES `fd_advanced_banking_accounts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB;
        ]])

        if not insert then
            error('Migration failed! (fd_advanced_banking_migrations)')
        end

        MySQL.query.await('INSERT INTO fd_advanced_banking_migrations (name) VALUES (?)', {'fd_advanced_banking_accounts_transactions'})
    end
end

function Migration.down()
    MySQL.query.await('DROP TABLE fd_advanced_banking_accounts_transactions')

    MySQL.query.await('DELETE FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_transactions'})
end


return Migration
