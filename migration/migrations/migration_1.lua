local Migration = {}

function Migration.up()
    local migrationsExists = MySQL.scalar.await('SELECT COUNT(*) FROM information_schema.tables WHERE table_name = ?', {'fd_advanced_banking_migrations'})

    if migrationsExists == 0 then
        local insert = MySQL.query.await('CREATE TABLE fd_advanced_banking_migrations (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(255) NOT NULL, PRIMARY KEY (id))')

        if not insert then
            error('Migration failed! (fd_advanced_banking_migrations)')
        end
    end
end

function Migration.down()
    MySQL.query.await('DROP TABLE fd_advanced_banking_migrations')
end


return Migration
