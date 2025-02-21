local Migration = {}

function Migration.up()
    local migrationExists = MySQL.scalar.await('SELECT COUNT(*) FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_members'})

    if migrationExists == 0 then
        local insert = MySQL.query.await([[
            CREATE TABLE `fd_advanced_banking_accounts_members` (
                `id` INT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                `account_id` INT(20) UNSIGNED NOT NULL,
                `identifier` VARCHAR(255) NOT NULL COLLATE utf8mb4_general_ci,
                `can_deposit` TINYINT(4) NOT NULL DEFAULT '0',
                `can_withdraw` TINYINT(4) NOT NULL DEFAULT '0',
                `can_transfer` TINYINT(4) NOT NULL DEFAULT '0',
                `can_export` TINYINT(4) NOT NULL DEFAULT '0',
                `can_control_members` TINYINT(4) NOT NULL DEFAULT '0',
                `is_owner` TINYINT(4) NOT NULL DEFAULT '0',
                `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY `fd_advanced_banking_accounts_members_id_unique` (`id`) USING BTREE,
                INDEX `fd_advanced_banking_accounts_members_account_id_index` (`account_id`) USING BTREE,
                CONSTRAINT `fk_fd_accounts_members` FOREIGN KEY (`account_id`) REFERENCES `fd_advanced_banking_accounts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB;
        ]])

        if not insert then
            error('Migration failed! (fd_advanced_banking_migrations)')
        end

        MySQL.query.await('INSERT INTO fd_advanced_banking_migrations (name) VALUES (?)', {'fd_advanced_banking_accounts_members'})
    end
end

function Migration.down()
    MySQL.query.await('DROP TABLE fd_advanced_banking_accounts_members')

    MySQL.query.await('DELETE FROM fd_advanced_banking_migrations WHERE name = ?', {'fd_advanced_banking_accounts_members'})
end


return Migration
