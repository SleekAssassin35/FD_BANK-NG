DROP TABLE IF EXISTS `fd_advanced_banking_accounts`;
CREATE TABLE IF NOT EXISTS `fd_advanced_banking_accounts` (
  `id` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `iban` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `balance` bigint(255) NOT NULL,
  `type` char(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'personal',
  `is_frozen` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `business` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_society` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fd_advanced_banking_accounts_id_unique` (`id`) USING BTREE,
  UNIQUE KEY `fd_advanced_banking_accounts_iban_unique` (`iban`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

DROP TABLE IF EXISTS `fd_advanced_banking_accounts_members`;
CREATE TABLE IF NOT EXISTS `fd_advanced_banking_accounts_members` (
  `id` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(20) unsigned NOT NULL,
  `identifier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `can_deposit` tinyint(4) NOT NULL DEFAULT 0,
  `can_withdraw` tinyint(4) NOT NULL DEFAULT 0,
  `can_transfer` tinyint(4) NOT NULL DEFAULT 0,
  `can_export` tinyint(4) NOT NULL DEFAULT 0,
  `can_control_members` tinyint(4) NOT NULL DEFAULT 0,
  `is_owner` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `fd_advanced_banking_accounts_members_id_unique` (`id`) USING BTREE,
  KEY `fd_advanced_banking_accounts_members_account_id_index` (`account_id`) USING BTREE,
  CONSTRAINT `fk_fd_accounts_members` FOREIGN KEY (`account_id`) REFERENCES `fd_advanced_banking_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

DROP TABLE IF EXISTS `fd_advanced_banking_accounts_transactions`;
CREATE TABLE IF NOT EXISTS `fd_advanced_banking_accounts_transactions` (
  `id` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(20) unsigned NOT NULL,
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `done_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `from_account` int(20) DEFAULT NULL,
  `to_account` int(20) DEFAULT NULL,
  `amount` bigint(255) NOT NULL DEFAULT 0,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `fd_advanced_banking_accounts_transactions_id_unique` (`id`) USING BTREE,
  KEY `fd_advanced_banking_accounts_transactions_account_id_index` (`account_id`) USING BTREE,
  CONSTRAINT `fk_fd_accounts_transactions` FOREIGN KEY (`account_id`) REFERENCES `fd_advanced_banking_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Dumping structure for table ReignQBox.fd_advanced_banking_invoices
DROP TABLE IF EXISTS `fd_advanced_banking_invoices`;
CREATE TABLE IF NOT EXISTS `fd_advanced_banking_invoices` (
  `id` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `recipient` varchar(75) NOT NULL,
  `issued_by` varchar(75) NOT NULL,
  `status` tinyint(2) NOT NULL DEFAULT 1,
  `amount` int(20) unsigned NOT NULL DEFAULT 0,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `transfer_to` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `due_on` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `can_be_declined` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

DROP TABLE IF EXISTS `fd_advanced_banking_migrations`;
CREATE TABLE IF NOT EXISTS `fd_advanced_banking_migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

DELETE FROM `fd_advanced_banking_migrations`;
INSERT INTO `fd_advanced_banking_migrations` (`id`, `name`) VALUES
	(1, 'fd_advanced_banking_accounts'),
	(2, 'fd_advanced_banking_accounts_members'),
	(3, 'fd_advanced_banking_accounts_transactions'),
	(4, 'fd_advanced_banking_tracking'),
	(5, 'fd_advanced_banking_accounts_update_1'),
	(6, 'fd_advanced_banking_accounts_update_2'),
	(7, 'fd_advanced_banking_invoices'),
	(8, 'fd_advanced_banking_invoices_update');

DROP TABLE IF EXISTS `fd_advanced_banking_tracking`;
CREATE TABLE IF NOT EXISTS `fd_advanced_banking_tracking` (
  `id` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
