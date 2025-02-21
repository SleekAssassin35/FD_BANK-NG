local resourceName = 'qb-core'
local qboxResourceName = 'qbx-core'

if not GetResourceState(resourceName):find('start') and not GetResourceState(qboxResourceName):find('start') then return end

SetTimeout(0, function()
    QB = exports[resourceName]:GetCoreObject()
    core = QB

    PlayerData = core.Functions.GetPlayerData()

    if PlayerData?.citizenid and LocalPlayer.state.isLoggedIn then end

    -- Handles state right when the player selects their character and location.
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = core.Functions.GetPlayerData()
    end)

    function bridge.getIdentifier()
        return PlayerData?.citizenid or cache.player
    end

    function bridge.notify(msg, type)
        lib.notify({
            description = msg,
            type = type,
        })
    end

    function bridge.progress(data)
        if lib.progressCircle(data) then
            return true
        end

        return false
    end

    function bridge.getPlayerJobInfo()
        return {
            name = PlayerData.job.name,
            label = PlayerData.job.label
        }
    end

    RegisterNetEvent("QBCore:Client:OnJobUpdate", function(job)
        if PlayerData.job.name ~= job.name and PlayerData.job.isboss then
            TriggerServerEvent('fd_banking:server:removedFromSociety', PlayerData.job.name)
        end

        if PlayerData.job.name == job.name and PlayerData.job.isboss and  not job.isboss then
            TriggerServerEvent('fd_banking:server:downgradedFromSociety', PlayerData.job.name)
        end

        if job.isboss then
            TriggerServerEvent('fd_banking:server:addedToSociety', job.name)
        end

        PlayerData.job = job
    end)

    RegisterNetEvent("QBCore:Client:OnGangUpdate", function(gang)
        if PlayerData.gang.name ~= gang.name and PlayerData.gang.isboss then
            TriggerServerEvent('fd_banking:server:removedFromSociety', PlayerData.gang.name, true)
        end

        if PlayerData.gang.name == gang.name and not gang.isboss then
            TriggerServerEvent('fd_banking:server:downgradedFromSociety', PlayerData.gang.name, true)
        end

        if gang.isboss then
            TriggerServerEvent('fd_banking:server:addedToSociety', gang.name, true)
        end

        PlayerData.gang = gang
    end)

end)
