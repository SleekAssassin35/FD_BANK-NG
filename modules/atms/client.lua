local atmPoints = {}

local ATMObjects = {
    -870868698,
    -1126237515,
    -1364697528,
    506770882,
}

local prop = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
}

exports['qb-target']:AddTargetModel(prop, {
    options = {
        {
            type = "client",
            event = "qb-banking:ATM",
            icon = "fas fa-dollar-sign",
            label = "ATM",
        },
    },
    distance = 1.5    
})

RegisterNetEvent('qb-banking:ATM', function()
    openAtm()
end)

function prepareAtms()
    if Config.ForInteractionsUse == 'ox_target' then
        if Config.ATMModels then
            exports.ox_target:addModel(Config.ATMModels, {
                {
                    name = 'box',
                    onSelect = function()
                        openAtm()
                    end,
                    icon = 'fa-solid fa-piggy-bank',
                    label = locale('open_atm_target'),
                }
            })
        end
    end

    if Config.ForInteractionsUse == 'points' then
        if Config.ATMPoints then
            for _, position in pairs(Config.ATMPoints) do
                local index = #atmPoints + 1

                atmPoints[index] = {}

                if type(position) == "table" then
                    atmPoints[index].point = lib.points.new(vector3(position.coords.x, position.coords.y, position.coords.z), 1, {
                        type = "maze"
                    })
                else
                    atmPoints[index].point = lib.points.new(vector3(position.x, position.y, position.z), 1, {
                        type="fleeca"
                    })
                end
                local point = atmPoints[index].point

                function point:nearby()
                    if self.currentDistance < 1 and IsControlJustReleased(0, 38) then
                        if self.type == 'maze' then
                            UI.setMazeTheme()
                        else
                            UI.setFleecaTheme()
                        end

                        openAtm()
                    end
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    prepareAtms()
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, point in pairs(atmPoints) do
            local point = point.point
            point:remove()
        end
    end
end)
