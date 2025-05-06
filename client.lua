local activeMission = nil
local QBCore = exports['qb-core']:GetCoreObject()

-- Criar NPC e blip
Citizen.CreateThread(function()
    -- Carregar modelo do NPC
    RequestModel(GetHashKey(Config.NPC.model))
    while not HasModelLoaded(GetHashKey(Config.NPC.model)) do
        Wait(100)
    end

    -- Criar NPC
    local npc = CreatePed(4, GetHashKey(Config.NPC.model), Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z, Config.NPC.coords.w, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    -- Criar blip
    local blip = AddBlipForCoord(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
    SetBlipSprite(blip, Config.NPC.blip.sprite)
    SetBlipColour(blip, Config.NPC.blip.color)
    SetBlipScale(blip, Config.NPC.blip.scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.NPC.blip.name)
    EndTextCommandSetBlipName(blip)

    -- Adicionar interação com ox_target
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'talk_to_npc',
            icon = 'fas fa-comment',
            label = 'Talk to ' .. Config.NPC.name,
            onSelect = function()
                -- Verificar se o jogador tem um job permitido
                local Player = QBCore.Functions.GetPlayerData()
                local job = Player.job.name
                local grade = Player.job.grade.level
                local hasAllowedJob = false

                for org, data in pairs(Config.AllowedOrgs) do
                    if job == org and grade >= data.minGrade then
                        hasAllowedJob = true
                        break
                    end
                end

                if hasAllowedJob then
                    OpenMissionMenu()
                else
                    lib.notify({ type = 'error', description = 'You do not have the required job to talk to this NPC!' })
                end
            end
        }
    })
end)

-- Abrir menu de missões
function OpenMissionMenu()
    local Player = QBCore.Functions.GetPlayerData()
    local job = Player.job.name
    local options = {}

    -- Filtrar missões disponíveis para o job do jogador
    for _, mission in pairs(Config.Missions) do
        for _, missionOrg in pairs(mission.orgs) do
            if missionOrg == job then
                table.insert(options, {
                    title = mission.name,
                    description = mission.description,
                    onSelect = function()
                        TriggerServerEvent('org-missions:startMission', mission.id)
                    end
                })
                break
            end
        end
    end

    if #options == 0 then
        lib.notify({ type = 'error', description = 'No missions available for your job!' })
        return
    end

    lib.registerContext({
        id = 'mission_menu',
        title = 'Available Missions',
        options = options
    })
    lib.showContext('mission_menu')
end

-- Iniciar missão
RegisterNetEvent('org-missions:beginMission')
AddEventHandler('org-missions:beginMission', function(mission)
    activeMission = mission
    lib.notify({ type = 'inform', description = 'Mission started: ' .. mission.name })

    if mission.objective.type == 'delivery' then
        StartDeliveryMission(mission)
    elseif mission.objective.type == 'eliminate' then
        StartEliminateMission(mission)
    end
end)

-- Missão de entrega
function StartDeliveryMission(mission)
    local dropoff = mission.objective.dropoff
    local blip = AddBlipForCoord(dropoff.x, dropoff.y, dropoff.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 3)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Delivery Point')
    EndTextCommandSetBlipName(blip)

    Citizen.CreateThread(function()
        while activeMission do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(dropoff.x, dropoff.y, dropoff.z))
            if distance < 5.0 then
                DrawMarker(1, dropoff.x, dropoff.y, dropoff.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 200, false, true, 2, nil, nil, false)
                if distance < 1.5 then
                    if lib.progressCircle({ duration = 5000, label = 'Delivering package...' }) then
                        TriggerServerEvent('org-missions:completeMission', mission.id)
                        RemoveBlip(blip)
                        activeMission = nil
                    end
                end
            end
            Wait(0)
        end
    end)
end

-- Missão de eliminação
function StartEliminateMission(mission)
    local target = mission.objective.target
    RequestModel(GetHashKey(target.model))
    while not HasModelLoaded(GetHashKey(target.model)) do
        Wait(100)
    end

    local npc = CreatePed(4, GetHashKey(target.model), target.coords.x, target.coords.y, target.coords.z, 0.0, true, false)
    SetPedAsEnemy(npc, true)
    TaskCombatPed(npc, PlayerPedId(), 0, 16)

    local blip = AddBlipForEntity(npc)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 1)

    Citizen.CreateThread(function()
        while activeMission do
            if IsEntityDead(npc) then
                if lib.progressCircle({ duration = 3000, label = 'Confirming elimination...' }) then
                    TriggerServerEvent('org-missions:completeMission', mission.id)
                    RemoveBlip(blip)
                    DeletePed(npc)
                    activeMission = nil
                end
            end
            Wait(0)
        end
    end)
end