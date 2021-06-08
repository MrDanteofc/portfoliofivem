local Tunnel = module("tnrp","lib/Tunnel")
local Proxy = module("tnrp","lib/Proxy")
tnRP = Proxy.getInterface("tnRP")
emP = Tunnel.getInterface("tnrp_empregos")
vGARAGES = Tunnel.getInterface("tnrp_garages")

paymentJobs = {
	["onibus"] = {min = 220, max = 330, bonus = 90},
	["jardineiro"] = {min = 100, max = 300, bonus = 50},
	["carteiro"] = {min = 140, max = 190, bonus = "quantidade"},
	["mecanico"] = {min = 1050, max = 1390, bonus = 200},
	["policia"] = {min = 220, max = 330, bonus = 90},
	["paramedico"] = {min = 150, max = 300, bonus = 90},
	["lixeiro"] = {min = 250, max = 380},
	["lenhador"] = {min = 300, max = 400, bonus = "quantidade"},
	["leiteiro"] = {min = 230, max = 280, bonus = "quantidade"},
	["bobs"] = {min = 300, max = 500},
	["encanador"] = {min = 150, max = 200},
	["caminhao"] = {
		["diesel"] = {min = 3000, max = 4500}, 
		["gas"] = {min = 2500, max = 5000},
		["cars"] = {min = 2500, max = 6000}, 
		["woods"] = {min = 4000, max = 6000},
		["show"] = {min = 5000, max = 6000}
	}
}

clothesJobs = {
	["Macacão"] = {
		[1885233650] = {                                      
            [1] = { 0, 0 },
            [2] = { 72,0 },
            [3] = { 33,0 },
            [4] = { 39,1 },
            [5] = { 41,0 },
            [6] = { 25,0 },
            [7] = { 0,0 },
            [8] = { 89,0 },
            [10] = { 0,0 },
            [11] = { 66,1 },
            ["p0"] = { 58,2 },
            ["p1"] = { 0,0 }
        },
        [-1667301416] = {
            [1] = { 0, 0 },
            [2] = { 72, 0 },
            [3] = { 57, 0 },
            [4] = { 49, 0 },
            [5] = { 41, 0 },
            [6] = { 36, 0 },
            [7] = { 0, 0 },
            [8] = { 56, 0 },
            [9] = { 0, 0 },
            [10] = { 0, 0 },
            [11] = { 88, 0 },
            ["p0"] = { 58, 0 },
            ["p1"] = { -1, 0 }
        }
	},
	["Entregador"] = {
		[1885233650] = {                                      
            [1] = { 0, 0 },
            [3] = { 0, 0 },
            [4] = { 14, 7, 2 },
            [5] = { 0, 0 },
            [6] = { 9, 2, 2 },
            [7] = { 0, 0 },
            [8] = { 15, 0, 2 },
            [10] = { 0, 0 },
            [11] = { 242, 3, 2 }
        },
        [-1667301416] = {
            [1] = { 0, 0 },
            [3] = { 0, 0 },
            [4] = { 50, 4, 2 },
            [5] = { 0, 0 },
            [6] = { 13, 0, 2 },
            [7] = { 0, 0 },
            [8] = { 8, 0, 2 },
            [10] = { 0, 0 },
            [11] = { 250, 3, 2 }
        }

	}
}

function getClothesJob(type)
	local custom = clothesJobs[type]
	if custom then
		local old_custom = tnRP.getCustomization()
		local idle_copy = {}
		idle_copy = emP.getIdleCustom(1, old_custom)
		idle_copy.modelhash = nil
		for l,w in pairs(custom[old_custom.modelhash]) do
			idle_copy[l] = w
		end

		Fade(1200)
		tnRP.setCustomization(idle_copy)
	end
end

function textNotify(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function DrawText3D(x,y,z,text,scl,font)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
	local scale = (1/dist)*scl
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
	if onScreen then
		SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 180)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
		DrawText(_x, _y)
	end
end

function DrawJob3D(x, y, z, principal, text, font)
	if principal then
		DrawText3D(x, y, z+0.37, principal, 1.8, font or 1)
	end
	if text then
		DrawText3D(x, y, z+0.20, text, 1.5, font or 1)
	end
end

function Fade(time)
	DoScreenFadeOut(800)
	Wait(time)
	DoScreenFadeIn(800)
end

function CriandoBlip(locs, selecionado, text)
	local blips = AddBlipForCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blips)
	return blips
end

function modelRequest(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(10)
	end
end

function GetVehiclePosition(radius)
	local ped = PlayerPedId()
	local coordsx = GetEntityCoords(ped, 1)
	local coordsy = GetOffsetFromEntityInWorldCoords(ped, 0.0, radius+0.00001, 0.0)
	local nearVehicle = GetMotoDirection(coordsx, coordsy)
	if IsEntityAVehicle(nearVehicle) then
	    return nearVehicle
	else
		local x,y,z = table.unpack(coordsx)
	    if IsPedSittingInAnyVehicle(ped) then
	        local veh = GetVehiclePedIsIn(ped,true)
	        return veh
	    else
	        local veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001,radius+0.0001,0,8192+4096+4+2+1) 
	        if not IsEntityAVehicle(veh) then 
	        	veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001,radius+0.0001,0,4+2+1) 
	        end 
	        return veh
	    end
	end
end

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function removePeds()
	SetTimeout(20000,function()
		if emservico and lastpassageiro and passageiro == nil then
			TriggerServerEvent("trydeleteped",PedToNet(lastpassageiro))
		end
	end)
end

function IsInVehicle()
	local ply = PlayerPedId()
	if IsPedSittingInAnyVehicle(ply) then
		return true
	else
		return false
	end
end

function spawnVehicle (name, table)
    local mhash = GetHashKey(name)
    if not nveh then
		
		while not HasModelLoaded(mhash) do
			RequestModel(mhash)
			Citizen.Wait(10)
		end
        local checkslot = 1
        while true do
            local checkPos = GetClosestVehicle(table[checkslot][1],table[checkslot][2],table[checkslot][3],3.001,0,71)
            if DoesEntityExist(checkPos) and checkPos ~= nil then
                checkslot = checkslot + 1
                if checkslot > #table then
                    checkslot = -1
                    TriggerEvent("Notify","importante","Todas as vagas estão ocupadas no momento.",10000)
                    break
                end
            else
                break
            end
            Citizen.Wait(10)
			print("foi?")
        end
        if checkslot ~= -1 then
            local ped = PlayerPedId()
            local x,y,z = tnRP.getPosition()
            local nveh = CreateVehicle(mhash,table[checkslot][1],table[checkslot][2],table[checkslot][3],table[checkslot][4],true,false)
            SetVehicleIsStolen(nveh,false)
            SetVehicleOnGroundProperly(nveh)
            SetEntityInvincible(nveh,false)
            SetVehicleNumberPlateText(nveh,tnRP.getRegistrationNumber())
            Citizen.InvokeNative(0xAD738C3085FE7E11,nveh,true,true)
            SetVehicleHasBeenOwnedByPlayer(nveh,true)
            SetVehicleDirtLevel(nveh,0.0)
            SetVehRadioStation(nveh,"OFF")
            SetVehicleEngineOn(GetVehiclePedIsIn(ped,false),true)
            SetEntityAsMissionEntity(nveh,true,true)
            SetModelAsNoLongerNeeded(mhash)
			
			return nveh
        end
    end
end