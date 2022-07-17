local QBCore = exports['qb-core']:GetCoreObject()

local InPreview = false

local InMenu = false

PlayerJob = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
	end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onClientResourceStart',function(resource)
	if GetCurrentResourceName() == resource then
		Citizen.CreateThread(function()
			while true do
				QBCore.Functions.GetPlayerData(function(PlayerData)
					if PlayerData.job then
						PlayerJob = PlayerData.job
					end
				end)
				break
			end
			Citizen.Wait(1)
		end)
	end
end)

local function InZone()
    for k, v in pairs(Config.RepairLocations) do
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.coords.x, v.coords.y, v.coords.z, false) < v.distance ) then
            return true
        end
        return false
    end
end

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function ShowHelpNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('CL-EMSGarage:Menu', function()
    local Menu = {
        {
            header = "EMS Garage",
            txt = "View Vehicles",
            params = {
                event = "CL-EMSGarage:Catalog",
            }
        }
    }
    Menu[#Menu+1] = {
        header = "Preview Vehicles",
        txt = "View Vehicles",
        params = {
            event = "CL-EMSGarage:PreviewCarMenu",
        }
    }
    if not Config.UseMarkerInsteadOfMenu then
        Menu[#Menu+1] = {
            header = "⬅ Store Vehicle",
            params = {
                event = "CL-EMSGarage:StoreVehicle"
            }
        }
    end
    Menu[#Menu+1] = {
        header = "⬅ Close Menu",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }
    exports['qb-menu']:openMenu(Menu)
end)

RegisterNetEvent("CL-EMSGarage:Catalog", function()
    local vehicleMenu = {
        {
            header = "EMS Garage",
            isMenuHeader = true,
        }
    }
    for k, v in pairs(Config.Vehicles) do
        vehicleMenu[#vehicleMenu+1] = {
            header = v.vehiclename,
            txt = "Buy: " .. v.vehiclename .. " For: " .. v.price .. "$",
            params = {
                event = "CL-EMSGarage:ChoosePayment",
                args = {
                    price = v.price,
                    vehiclename = v.vehiclename,
                    vehicle = v.vehicle
                }
            }
        }
    end
    vehicleMenu[#vehicleMenu+1] = {
        header = "⬅ Go Back",
        params = {
            event = "CL-EMSGarage:Menu"
        }
    }
    exports['qb-menu']:openMenu(vehicleMenu)
end)

RegisterNetEvent("CL-EMSGarage:ChoosePayment", function(data)
    local Payment = exports["qb-input"]:ShowInput({
        header = "Choose Payment Method",
        submitText = "Choose",
        inputs = {
            { 
                text = 'Payment Type', 
                name = 'paymenttype', 
                type = 'radio', 
                isRequired = true,
                options = { 
                    { 
                        value = "cash", 
                        text = "Cash" 
                    }, 
                    { 
                        value = "bank", 
                        text = "Bank" 
                    },
                } 
            }
        }
    })
    if Payment ~= nil then
        TriggerServerEvent("CL-EMSGarage:TakeMoney", Payment.paymenttype, data.price, data.vehiclename, data.vehicle) 
    end
end)

RegisterNetEvent('CL-EMSGarage:PreviewCarMenu', function()
    local PreviewMenu = {
        {
            header = "Preview Menu",
            isMenuHeader = true
        }
    }
    for k, v in pairs(Config.Vehicles) do
        PreviewMenu[#PreviewMenu+1] = {
            header = v.vehiclename,
            txt = "Preview: " .. v.vehiclename,
            params = {
                event = "CL-EMSGarage:PreviewVehicle",
                args = {
                    vehicle = v.vehicle,
                }
            }
        }
    end
    PreviewMenu[#PreviewMenu+1] = {
        header = "⬅ Go Back",
        params = {
            event = "CL-EMSGarage:Menu"
        }
    }
    exports['qb-menu']:openMenu(PreviewMenu)
end)

CreateThread(function()
    while true do
        local plyPed = PlayerPedId()
        local plyCoords = GetEntityCoords(plyPed) 
        local letSleep = true

        if PlayerJob.name == Config.Job then
            if (GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, Config.Locations["Marker"]["Coords"].x, Config.Locations["Marker"]["Coords"].y, Config.Locations["Marker"]["Coords"].z, true) < 10) then
                letSleep = false
                DrawMarker(36, Config.Locations["Marker"]["Coords"].x, Config.Locations["Marker"]["Coords"].y, Config.Locations["Marker"]["Coords"].z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, 255, 0, 0, 255, true, false, false, true, false, false, false)
                if Config.UseMarkerInsteadOfMenu then
                    if (GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, Config.Locations["Marker"]["Coords"].x, Config.Locations["Marker"]["Coords"].y, Config.Locations["Marker"]["Coords"].z, true) < 1.5) and not IsPedInAnyVehicle(PlayerPedId(), false) then
                        DrawText3D(Config.Locations["Marker"]["Coords"].x, Config.Locations["Marker"]["Coords"].y, Config.Locations["Marker"]["Coords"].z, "~g~E~w~ - EMS Garage") 
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("CL-EMSGarage:Menu")
                        end
                    end
                    if IsPedInAnyVehicle(PlayerPedId(), false) then   
                        DrawText3D(Config.Locations["Marker"]["Coords"].x, Config.Locations["Marker"]["Coords"].y, Config.Locations["Marker"]["Coords"].z, "~g~E~w~ - Store Vehicle (Will Get Impounded)") 
                    end
                    if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), false) then
                        TriggerEvent("CL-EMSGarage:StoreVehicle")
                    end
                else
                    if (GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, Config.Locations["Marker"]["Coords"].x, Config.Locations["Marker"]["Coords"].y, Config.Locations["Marker"]["Coords"].z, true) < 1.5) then
                        DrawText3D(Config.Locations["Marker"]["Coords"].x, Config.Locations["Marker"]["Coords"].y, Config.Locations["Marker"]["Coords"].z, "~g~E~w~ - EMS Garage") 
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("CL-EMSGarage:Menu")
                        end
                    end
                end
            end
        end

        if letSleep then
            Wait(2000)
        end

        Wait(1)
    end
end)

RegisterNetEvent('CL-EMSGarage:client:SetActive', function(status)
    InMenu = status
end)

RegisterNetEvent('CL-EMSGarage:StoreVehicle', function()
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(PlayerPedId(),true)
    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, car, 1)
        Citizen.Wait(2000)
        QBCore.Functions.Notify('Vehicle Stored!')
        DeleteVehicle(car)
        DeleteEntity(car)
    else
        QBCore.Functions.Notify("You Are Not In Any Vehicle !", "error")
    end
end)

RegisterNetEvent("CL-EMSGarage:SpawnVehicle", function(vehicle)
    local coords = Config.Locations["SpawnVehicleAfterPurchase"]["Coords"]
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        local VehicleProps = QBCore.Functions.GetVehicleProperties(veh)
        SetVehicleNumberPlateText(veh, "MED"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, Config.Locations["SpawnVehicleAfterPurchase"]["Heading"])
        exports[Config.FuelSystem]:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        TriggerServerEvent("CL-EMSGarage:AddVehicleSQL", VehicleProps, vehicle, GetHashKey(veh), QBCore.Functions.GetPlate(veh))
    end, coords, true)
end)

RegisterNetEvent("CL-EMSGarage:PreviewVehicle", function(data)
    if Config.UsePreviewMenuSync then
        QBCore.Functions.TriggerCallback('CL-EMSGarage:CheckIfActive', function(result)
            if result then
                InPreview = true
                local coords = Config.Locations["Preview"]["Coords"]["Vehicle"]
                QBCore.Functions.SpawnVehicle(data.vehicle, function(veh)
                    SetEntityVisible(PlayerPedId(), false, 1)
                    if Config.SetVehicleTransparency == 'low' then
                        SetEntityAlpha(veh, 400)
                    elseif Config.SetVehicleTransparency == 'medium' then
                        SetEntityAlpha(veh, 93)
                    elseif Config.SetVehicleTransparency == 'high' then
                        SetEntityAlpha(veh, 40)
                    elseif Config.SetVehicleTransparency == 'none' then
                        
                    end
                    FreezeEntityPosition(PlayerPedId(), true)
                    SetVehicleNumberPlateText(veh, "MED"..tostring(math.random(1000, 9999)))
                    exports['LegacyFuel']:SetFuel(veh, 0.0)
                    FreezeEntityPosition(veh, true)
                    SetVehicleEngineOn(veh, false, false)
                    SetEntityHeading(veh, Config.Locations["Preview"]["Heading"]["Vehicle"])
                    DoScreenFadeOut(200)
                    Citizen.Wait(500)
                    DoScreenFadeIn(200)
                    SetVehicleUndriveable(veh, true)
                
                    VehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Locations["Preview"]["Coords"]["Camera"].x, Config.Locations["Preview"]["Coords"]["Camera"].y, Config.Locations["Preview"]["Coords"]["Camera"].z, 50, 0.00, 81.362297, 80.00, false, 0)
                    SetCamActive(VehicleCam, true)
                    RenderScriptCams(true, true, 500, true, true)
            
                    Citizen.CreateThread(function()
                        while true do
                            if InPreview then
                                ShowHelpNotification("Press ~INPUT_FRONTEND_RRIGHT~ To Close")
                            elseif not InPreview then
                                break
                            end
                            if IsControlJustReleased(0, 177) then
                                SetEntityVisible(PlayerPedId(), true, 1)
                                FreezeEntityPosition(PlayerPedId(), false)
                                PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                QBCore.Functions.DeleteVehicle(veh)
                                DoScreenFadeOut(200)
                                Citizen.Wait(500)
                                DoScreenFadeIn(200)
                                RenderScriptCams(false, false, 1, true, true)
                                InPreview = false
                                TriggerServerEvent("CL-EMSGarage:server:SetActive", false)
                                break
                            end
                            Citizen.Wait(1)
                        end
                    end)
                end, coords, true)
            end
        end)
    else
        InPreview = true
        local coords = Config.Locations["Preview"]["Coords"]["Vehicle"]
        QBCore.Functions.SpawnVehicle(data.vehicle, function(veh)
            SetEntityVisible(PlayerPedId(), false, 1)
            if Config.SetVehicleTransparency == 'low' then
                SetEntityAlpha(veh, 400)
            elseif Config.SetVehicleTransparency == 'medium' then
                SetEntityAlpha(veh, 93)
            elseif Config.SetVehicleTransparency == 'high' then
                SetEntityAlpha(veh, 40)
            elseif Config.SetVehicleTransparency == 'none' then
                
            end
            FreezeEntityPosition(PlayerPedId(), true)
            SetVehicleNumberPlateText(veh, "MED"..tostring(math.random(1000, 9999)))
            exports['LegacyFuel']:SetFuel(veh, 0.0)
            FreezeEntityPosition(veh, true)
            SetVehicleEngineOn(veh, false, false)
            SetEntityHeading(veh, Config.Locations["Preview"]["Heading"]["Vehicle"])
            DoScreenFadeOut(200)
            Citizen.Wait(500)
            DoScreenFadeIn(200)
            SetVehicleUndriveable(veh, true)
        
            VehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Locations["Preview"]["Coords"]["Camera"].x, Config.Locations["Preview"]["Coords"]["Camera"].y, Config.Locations["Preview"]["Coords"]["Camera"].z, 50, 0.00, 81.362297, 80.00, false, 0)
            SetCamActive(VehicleCam, true)
            RenderScriptCams(true, true, 500, true, true)
            
            Citizen.CreateThread(function()
                while true do
                    if InPreview then
                        ShowHelpNotification("Press ~INPUT_FRONTEND_RRIGHT~ To Close")
                    elseif not InPreview then
                        break
                    end
                    if IsControlJustReleased(0, 177) then
                        SetEntityVisible(PlayerPedId(), true, 1)
                        FreezeEntityPosition(PlayerPedId(), false)
                        PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                        QBCore.Functions.DeleteVehicle(veh)
                        DoScreenFadeOut(200)
                        Citizen.Wait(500)
                        DoScreenFadeIn(200)
                        RenderScriptCams(false, false, 1, true, true)
                        InPreview = false
                        TriggerServerEvent("CL-EMSGarage:server:SetActive", false)
                        break
                    end
                    Citizen.Wait(1)
                end
            end)
        end, coords, true)
    end
end)

RegisterNetEvent("CL-EMSGarage:CheckZone", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        if InZone() then
            QBCore.Functions.Progressbar('hos_repair', 'Fixing Your Vehicle...', 8000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
            }, {}, {}, function()
                SetVehicleEngineHealth(veh, 1000)
                SetVehiclePetrolTankHealth(veh, 1000)
                SetVehicleFixed(veh)
                SetVehicleDeformationFixed(veh)
                SetVehicleUndriveable(veh, false)
                SetVehicleEngineOn(veh, true, true)
                QBCore.Functions.Notify("Vehicle Fixed !", "success", 3000)
            end, function()
                ClearPedTasks(PlayerPedId())
            end)
        else
            QBCore.Functions.Notify("You are not in a repair zone !", "error", 3000)
        end
    else
        QBCore.Functions.Notify("You are not in any vehicle !", "error")
    end
end)