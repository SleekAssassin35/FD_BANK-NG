local function runMigrations()
    for m=1, 10, 1 do
        local migrationName = ('migration.migrations.migration_%s'):format(m)
        local success, migration = pcall(require, migrationName)

        if success then
            migration.up()
        end
    end

    print('^2Migrations ran successfully!^0')

    TriggerEvent("fd_banking:migrationsFinished")
end

local function rerunMigrations()
    for m=1, 10, 1 do
        local migrationName = ('migration.migrations.migration_%s'):format(m)
        local success, migration = pcall(require, migrationName)

        if success then
            migration.down()
            migration.up()
        end
    end

    print('^2Migrations ran successfully!^0')

    TriggerEvent("fd_banking:migrationsFinished")
end

RegisterCommand('banking:migrate', function(source)
    if source ~= 0 then
        return
    end

    rerunMigrations()
end)

Citizen.CreateThread(function()
    MySQL.ready(function()
        runMigrations()
    end)
end)
