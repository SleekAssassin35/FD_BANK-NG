
local QBCore = exports['qb-core']:GetCoreObject()
local bankBlips = {}
local bankPoints = {}


local banks = {
    {name = "Banka", id = 108, x = 150.0490, y = -1040.83, z = 29.374}, -- 150.0490, -1040.83, 29.374
    {name = "Banka", id = 108, x = -1212.980, y = -330.841, z = 37.787},
    {name = "Banka", id = 108, x = -2962.582, y = 482.627, z = 15.703},
    {name = "Banka", id = 108, x = -112.202, y = 6469.295, z = 31.626},
    {name = "Banka", id = 108, x = 314.187, y = -278.621, z = 54.170},
    {name = "Banka", id = 108, x = -351.534, y = -49.529, z = 49.042},
}

CreateThread(function()
    for k, v in pairs(banks) do
        exports['qb-target']:AddBoxZone("bank_"..k, vector3(v.x, v.y, v.z), 5.0, 1.9, {
            name = "bankalar",
            heading = 11.0,
            debugPoly = false,
            minZ = v.z - 3,
            maxZ = v.z + 3,
        }, {
            options = {
                {
                    type = "client",
                    event = "qb-banking:openBankScreen",
                    icon = "fas fa-university",
                    label = "Banka",
                },
            },
            distance = 2.5
        })
    end
end)

RegisterNetEvent('qb-banking:openBankScreen', function()
    openBank()
end)

local blip = false
local aktifblipler = {}
RegisterNetEvent("seindBanking:blipAcKapa")
AddEventHandler("seindBanking:blipAcKapa", function()
	if blip then
		pasifblip()
        QBCore.Functions.Notify("Haritada banka görünümleri kapatıldı.", "error")
		blip = false
	else
		aktifblip()
        QBCore.Functions.Notify("Haritada banka görünümleri açıldı.", "success")
		blip = true
	end
end)

function aktifblip()
	for k, v in ipairs(banks)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.5)
		SetBlipColour(blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Banka")
		EndTextCommandSetBlipName(blip)
		table.insert(aktifblipler, blip)
	end
end

function pasifblip()
	for i = 1, #aktifblipler do
		RemoveBlip(aktifblipler[i])
	end
	aktifblipler = {}
end

function isNearBank()
    local isNear = false
    local coords = GetEntityCoords(cache.ped)
    for key, bank in pairs(Config.Banks) do
        for _, position in pairs(bank.locations) do
            if Config.ForInteractionsUse == 'ox_target' and position.target and not isNear then
                local distance = #(vector3(position.target.coords.x, position.target.coords.y, position.target.coords.z) - coords)
                if distance < 10 then
                    isNear = true
                    break
                end
            end

            if Config.ForInteractionsUse == 'points' and position.point and not isNear then
                local distance = #(vector3(position.point.x, position.point.y, position.point.z) - coords)
                if distance < 10 then
                    isNear = true
                    break
                end
            end
        end
    end


    return isNear
end

function prepareBanks()
    for key, bank in pairs(Config.Banks) do
        for _, position in pairs(bank.locations) do
            if Config.ForInteractionsUse == 'ox_target' and position.target then
                exports.ox_target:addBoxZone({
                    coords = position.target.coords,
                    size = position.target.size,
                    rotation = position.target.rotation,
                    debug = false,
                    options = {
                        {
                            name = 'box',
                            onSelect = function()
                                openBank()
                            end,
                            icon = 'fa-solid fa-piggy-bank',
                            label = locale('open_bank_target'),
                        }
                    }
                })
            end

            if Config.ForInteractionsUse == 'points' and position.point then
                local index = #bankPoints + 1

                bankPoints[index] = {}
                bankPoints[index].point = lib.points.new(vector3(position.point.x, position.point.y, position.point.z), 1, {})
                local point = bankPoints[index].point


                function point:nearby()
                 

                    
                end
            end
        end

        if bank.blip and bank.blip?.enabled then
            local index = #bankBlips + 1

            bankBlips[index] = AddBlipForCoord(bank.blip.coords.x, bank.blip.coords.y, bank.blip.coords.z)
            SetBlipSprite(bankBlips[index], bank.blip.sprite)
            SetBlipDisplay(bankBlips[index], bank.blip.display or 4)
            SetBlipScale  (bankBlips[index], bank.blip.scale or 0.8)
            SetBlipColour (bankBlips[index], bank.blip.color or 2)
            SetBlipAsShortRange(bankBlips[index], bank.blip.isShortRange)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(tostring(bank.blip.label))
            EndTextCommandSetBlipName(bankBlips[index])
        end
    end
end

Citizen.CreateThread(function()
    prepareBanks()
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, blip in pairs(bankBlips) do
            RemoveBlip(blip)
        end

        for _, point in pairs(bankPoints) do
            local point = point.point
            point:remove()
        end
    end
end)
