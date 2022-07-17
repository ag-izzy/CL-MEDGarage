Config = Config or {}

-- Discord Logs Config

Config.LogsImage = "https://cdn.discordapp.com/attachments/926465631770005514/966038265130008576/CloudDevv.png"

Config.WebHook = "YOUR WEBHOOK"

Config.FuelSystem = "LegacyFuel" -- Put here your fuel system LegacyFuel by default

Config.UsePreviewMenuSync = false -- Sync for the preview menu when player is inside the preview menu other players cant get inside (can prevent bugs but not have to use)

Config.UseMarkerInsteadOfMenu = true -- Want to use the marker to return the vehice? if false you can do that by opening the menu

Config.SetVehicleTransparency = 'low' -- Want to make the vehicle more transparent? you have a lot of options to choose from: low, medium, high, none

Config.Job = 'ambulance' --The job needed to open the menu

Config.Locations = {
    Marker = {
        Coords = vector3(328.32864, -557.6098, 28.743776),
    },
    SpawnVehicleAfterPurchase = {
        Coords = vector3(328.32864, -557.6098, 28.743776),
        Heading = 345.44485,
    },
    Preview = {
        Coords = {
            Vehicle = vector3(331.46939, -549.1542, 28.743776),
            Camera = vector3(339.28573, -548.8952, 29.643766),
        },
        Heading = {
            Vehicle = 273.46887,
            Camera = 81.362297,
        }
    },
}

--You Can Add As Many As You Like
--DO NOT add vehicles that are not in your shared ! otherwise the qb-garages wont work
Config.Vehicles = {
    [1] = {
        ['vehiclename'] = "Bati", --Name
        ['vehicle'] = "bati", --Model
        ['price'] = 5000, --Price
    }, 
    [2] = {
        ['vehiclename'] = "Test", --Name
        ['vehicle'] = "t20", --Model
        ['price'] = 18000, --Price
    }, 
    [3] = {
        ['vehiclename'] = "Police2", --Name
        ['vehicle'] = "sultan", --Model
        ['price'] = 10000, --Price
    }, 
    [4] = {
        ['vehiclename'] = "SultanRS", --Name
        ['vehicle'] = "sultanrs", --Model
        ['price'] = 52000, --Price
    }, 
}

Config.RepairLocations = {
    --Hospital
    [1] = {
        ['coords'] = vector3(328.32864, -557.6098, 28.743776),
        ['distance'] = 32.0
    },  
}