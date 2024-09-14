Config = {}
Config.Locale = 'de' -- de, en, at, es, fr, ru, ua


-- General things
Config.minDistance = 25 -- Spawns the NPC/Marker if player is in a radius of 25 meters
Config.reviveHealth = 0 -- Player health at 0%
Config.healHealth = 150 -- Player health at and below 50%
Config.maxHealth = 150 -- Player health at over 50%
Config.check = 5000 -- Check every 5 seconds if someone has the specified job below >> 1000 = 1s, 5000 = 5s, 10000 = 10s, ...

-- Job things
Config.Job = "ambulance" -- Job Name IMPORTANT: Changing this name will still require esx_ambulancejob!
Config.HideOnJob = true -- Hide station when user with job is online?
Config.count = 0 -- Hide if more than 0 people with the job are online


-- Billing things
Config.billing = true
Config.okokBilling = false
Config.society = "ambulance"
Config.revivePrice = 300
Config.healPrice = 300


-- Ped things
Config.Npc = true -- Spawn a NPC?
Config.model = "s_m_m_doctor_01" -- Ped ID
Config.npcCenter = vector4(320.2474, -588.8101, 43.2841, 157.2973) -- has to be vector4: X,Y,Z,H (H is heading)

-- Marker things
Config.drawMarker = true -- Draw a marker?
Config.circleCenter = vector3(320.2474, -588.8101, 43.2841) -- Where the marker is at
Config.circleRadius = 2 -- In meters IMPORTANT: This is also the interact range! Cannot be 0!
Config.markerType = 27 -- Marker type

-- Blip things
Config.BlipName = "Revive Station" -- Name displayed on the map
Config.BlipSprite = 621 -- Heart
Config.BlipDisplay = 2 -- Blip behaviour -- Check https://docs.fivem.net/natives/?_0x9029B2F3DA924928
Config.BlipScale = 0.8 -- Blip scale on map
Config.BlipColour = 29 -- Blip colour


