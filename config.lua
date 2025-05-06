Config = {}

-- Configurações do NPC
Config.NPC = {
    model = 'a_m_m_business_01', -- Modelo do NPC
    coords = vector4(90.73, 298.02, 110.21, 336.44), -- Coordenadas (x, y, z, heading)
    name = 'João Missioneiro', -- Nome exibido
    blip = {
        sprite = 280, -- Ícone do blip
        color = 3, -- Cor do blip
        scale = 0.8,
        name = 'Missões de Organização'
    }
}

-- Organizações permitidas
Config.AllowedOrgs = {
    ['police'] = { minGrade = 1 }, -- Polícia, mínimo rank 1
    ['mafia'] = { minGrade = 0 }, -- Máfia, qualquer rank
    ['ambulance'] = { minGrade = 2 } -- EMS, mínimo rank 2
}

-- Missões disponíveis
Config.Missions = {
    {
        id = 'delivery', -- ID único
        name = 'Entrega de Pacote', -- Nome da missão
        description = 'Entregue um pacote em um local específico.',
        orgs = {'police', 'mafia'}, -- Organizações que podem fazer
        objective = {
            type = 'delivery', -- Tipo de missão
            item = 'phone', -- Item a ser entregue (deve existir no ox_inventory)
            amount = 1, -- Quantidade
            dropoff = vector3(103.49, 236.0, 108.26), -- Local de entrega
            timeLimit = 300 -- Tempo em segundos
        },
        rewards = {
            money = 5000, -- Dinheiro
            items = { {name = 'water', amount = 2} } -- Itens (opcional)
        }
    },
    {
        id = 'eliminate',
        name = 'Eliminar Alvo',
        description = 'Elimine um alvo marcado.',
        orgs = {'ambulance'},
        objective = {
            type = 'eliminate',
            target = { model = 'g_m_y_mexgoon_01', coords = vector3(300.0, 400.0, 70.0) },
            timeLimit = 600
        },
        rewards = {
            money = 10000,
            items = { {name = 'ammo-9', amount = 50} }
        }
    }
}