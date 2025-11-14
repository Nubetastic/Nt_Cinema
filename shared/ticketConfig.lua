TicketConfig = {}

TicketConfig.SpawnDistance = 40

TicketConfig.NPCActions = {
    "WORLD_HUMAN_STAND_WAITING",
    "WORLD_HUMAN_STAND_WAITING",
    "WORLD_HUMAN_STAND_WAITING",
    "WORLD_HUMAN_STAND_WAITING",
    "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
    "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
    "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
    "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
    "WORLD_HUMAN_WRITE_NOTEBOOK",
    "WORLD_HUMAN_COFFEE_DRINK",
    "WORLD_HUMAN_COFFEE_DRINK",
}

TicketConfig.TimeToShow = 60000  -- time in milliseconds before show starts after being triggered
TicketConfig.NotifyToShow = "1 minute"

TicketConfig.ShowPrice = {
    Cinema = 10,
    Tent = 5,
    Stage = 20
}

TicketConfig.ShowList = {
        Cinema = {
            "BEAR",
            "JOSIAH",
            "SECRET_OF_MANFLIGHT",
            "SAVIORS_AND_SAVAGES",
            "GHOST_STORY",
            "DIRECT_CURRENT_DAMNATION",
            "FARMERS_DAUGHTER",
            "MODERN_MEDICINE",
            "WORLDS_STRONGEST_MAN",
            "SKETCHING_FOR_SWEETHEART"
        },
        Tent = {
            "BEAR_TENT",
            "JOSIAH_TENT",
            "SECRET_OF_MANFLIGHT_TENT",
            "SAVIORS_AND_SAVAGES_TENT",
            "GHOST_STORY_TENT"
        },
        Stage = {
            "BIGBAND_A",
            "BIGBAND_B",
            "BULLETCATCH",
            "CANCAN_A",
            "CANCAN_B",
            "ESCAPEARTIST",
            "ESCAPENOOSE",
            "FIREBREATH",
            "FIREDANCE_A",
            "FIREDANCE_B",
            "FLEXFIGHT",
            "ODDFELLOWS",
            "SNAKEDANCE_A",
            "SNAKEDANCE_B",
            "STRONGWOMAN",
            "SWORDDANCE"
        }
}







TicketConfig.TicketVendors = {

    ["Blackwater"] = {
        LocationName = "Blackwater",
        NPC_Model = "a_m_m_nbxupperclass_01",
        NPC_Cords = vector4(-789.7953, -1362.5765, 43.8222, 266.4162),
        Promp_Cords = vector3(-788.6028, -1362.6261, 43.8222),
        ShowTypes = "Cinema",
        ShowCount = 5,
        showblip = true,
    },
    ["Valentine"] = {
        LocationName = "Valentine",
        NPC_Model = "a_m_m_rhdupperclass_01",
        NPC_Cords = vector4(-355.1857, 705.0748, 116.9362, 334.4353),
        Promp_Cords = vector3(-354.4966, 706.0643, 116.9335),
        ShowTypes = "Tent",
        ShowCount = 3,
        showblip = true,
    },
    ["Saint Denis Cinema"] = {
        LocationName = "Saint Denis",
        NPC_Model = "a_m_m_blwupperclass_01",
        NPC_Cords = vector4(2686.8394, -1361.9767, 48.2142, 133.0013),
        Promp_Cords = vector3(2685.9177, -1362.8942, 48.2138),
        ShowTypes = "Cinema",
        ShowCount = 4,
        showblip = true,
    },
    ["Saint Denis Stage"] = {
        LocationName = "Saint Denis Theater",
        NPC_Model = "a_m_o_sdupperclass_01",
        NPC_Cords = vector4(2542.2529, -1282.5973, 49.2182, 47.8236),
        Promp_Cords = vector3(2541.0693, -1281.4495, 49.2179),
        ShowTypes = "Stage",
        ShowCount = 4,
        showblip = true,
    },
}