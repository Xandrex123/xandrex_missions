local QBCore = exports['qb-core']:GetCoreObject()

-- Verificar se jogador pertence à organização
local function CheckOrg(playerId, mission)
    local Player = QBCore.Functions.GetPlayer(playerId)
    local job = Player.PlayerData.job.name
    local grade = Player.PlayerData.job.grade.level

    for _, org in pairs(mission.orgs) do
        if Config.AllowedOrgs[org] and job == org and grade >= Config.AllowedOrgs[org].minGrade then
            return true
        end
    end
    return false
end

-- Iniciar missão
RegisterServerEvent('org-missions:startMission')
AddEventHandler('org-missions:startMission', function(missionId)
    local src = source
    local mission = nil

    -- Encontrar missão pelo ID
    for _, m in pairs(Config.Missions) do
        if m.id == missionId then
            mission = m
            break
        end
    end

    if not mission then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Invalid mission!' })
        return
    end

    -- Verificar organização
    if not CheckOrg(src, mission) then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'You do not have permission for this mission!' })
        return
    end

    -- Iniciar missão no cliente
    TriggerClientEvent('org-missions:beginMission', src, mission)
end)

-- Concluir missão
RegisterServerEvent('org-missions:completeMission')
AddEventHandler('org-missions:completeMission', function(missionId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local mission = nil

    for _, m in pairs(Config.Missions) do
        if m.id == missionId then
            mission = m
            break
        end
    end

    if not mission then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Invalid mission!' })
        return
    end

    -- Verificar se o jogador ainda tem o job correto
    if not CheckOrg(src, mission) then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'You no longer have the required job!' })
        return
    end

    -- Verificar item (se for entrega)
    if mission.objective.type == 'delivery' then
        local item = mission.objective.item
        local amount = mission.objective.amount
        local count = exports.ox_inventory:GetItem(src, item, nil, true)
        if count < amount then
            TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'You do not have the required item!' })
            return
        end
        exports.ox_inventory:RemoveItem(src, item, amount)
    end

    -- Dar recompensas
    Player.Functions.AddMoney('cash', mission.rewards.money)
    for _, item in pairs(mission.rewards.items or {}) do
        exports.ox_inventory:AddItem(src, item.name, item.amount)
    end

    TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = 'Mission completed! Reward received.' })
end)