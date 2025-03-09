Config = {}

Config.Locations = {
    {
        name = "Location 1",--Nom de la location
        pedModel = "s_m_m_highsec_01",  -- Modèle du ped
        position = vector3(215.76, -810.83, 30.73),  -- Position du pnj
        spawnPoint = vector3(220.0, -820.0, 30.73),  -- Point où le véhicule spawnera
        vehicles = { -- Véhicules disponibles pour la location
            {label = "Panto", model = "panto",price = 500},
            {label = "Sanchez", model = "sanchez",price = 1000},
        },
    },



}
