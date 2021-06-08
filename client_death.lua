local Tunnel = module("networkpvp","lib/Tunnel")
local Proxy = module("networkpvp","lib/Proxy")
networkPVP = Proxy.getInterface("networkPVP")

networkPVPserver = Tunnel.getInterface("networkpvp")

local nocauteado = false
local displayPress = false
local nameattacker = "SUICIDIO"
local deathtimer = 5

local posDeath = {
	["Area"] = {		
		--{1662.5201416016,-2303.0451660156,103.10614013672}
		{3768.8408203125,-482.65078735352,57.898040771484},
	}
}

function networkPVP.isInComa()
	return nocauteado
end

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local player = PlayerId()
		local ped = PlayerPedId()
		if GetEntityHealth(ped) <= 101 and deathtimer >= 0 then
			if not nocauteado then
				sleep = 5
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
				deathtimer = 5
				nocauteado = true
				networkPVPserver._updateHealth(101)
				SetEntityHealth(ped,101)
				SetEntityInvincible(ped,true)
				if IsPedInAnyVehicle(ped) then
					TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
				end
				TriggerEvent("radio:outServers")
			else
				sleep = 5
				if deathtimer > 0 then
					local killer = NetworkGetEntityKillerOfPlayer(player)
					if killer then
						local killerid
						if killer ~= ped and NetworkIsPlayerActive(killer) then 
							killerid = GetPlayerServerId(killer)
							NetworkSetInSpectatorMode(1, killerid)
							--NetworkSetActivitySpectatorMax(1, killerid)
							--NetworkSetActivitySpectator(1, killerid)
							nameattacker = killerid.name;
						else 
							killerid = -1
						end
					end
					SendNUIMessage({
						setDisplay = true,
						deathtimer = deathtimer,
						displayPress = false,
						nameattacker = nameattacker
					})
				else
					if not displayPress then
						displayPress = not displayPress
						SendNUIMessage({
							setDisplay = true,
							deathtimer = deathtimer,
							displayPress = displayPress,
							nameattacker = nameattacker
						})
					end
				end
				SetEntityHealth(ped,101)
				SetPedToRagdoll(ped,1000,1000,0,0,0,0)
				BlockWeaponWheelThisFrame()
				DisableControlAction(0,21,true)
				DisableControlAction(0,23,true)
				DisableControlAction(0,24,true)
				DisableControlAction(0,25,true)
				DisableControlAction(0,58,true)
				DisableControlAction(0,263,true)
				DisableControlAction(0,264,true)
				DisableControlAction(0,257,true)
				DisableControlAction(0,140,true)
				DisableControlAction(0,141,true)
				DisableControlAction(0,142,true)
				DisableControlAction(0,143,true)
				DisableControlAction(0,137,true)
				DisableControlAction(0,75,true)
				DisableControlAction(0,22,true)
				DisableControlAction(0,32,true)
				DisableControlAction(0,268,true)
				DisableControlAction(0,33,true)
				DisableControlAction(0,269,true)
				DisableControlAction(0,34,true)
				DisableControlAction(0,270,true)
				DisableControlAction(0,35,true)
				DisableControlAction(0,271,true)
				DisableControlAction(0,288,true)
				DisableControlAction(0,289,true)
				DisableControlAction(0,170,true)
				DisableControlAction(0,166,true)
				DisableControlAction(0,73,true)
				DisableControlAction(0,167,true)
				DisableControlAction(0,344,true)
				DisableControlAction(0,29,true)
				DisableControlAction(0,168,true)
				DisableControlAction(0,187,true)
				DisableControlAction(0,189,true)
				DisableControlAction(0,190,true)
				DisableControlAction(0,188,true)
			end
		end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if nocauteado and deathtimer > 0 then
			deathtimer = deathtimer - 1
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local ped = PlayerPedId()
		if IsControlJustPressed(0, 38) then
			respawnPlayer(ped, posDeath["Area"])
		end
		if IsControlJustPressed(0, 182) then
			respawnPlayer(ped, "Lobby")
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		SetPlayerHealthRechargeMultiplier(PlayerId(),0)
	end
end)

AddEventHandler('baseevents:onPlayerKilled', function(attackerID, deathData)
	local killerID = GetPlayerServerId(attackerID)
	local killerName = GetPlayerName(killerID);

	if (killerName == "**Invalid**") then
		nameattacker = "SUICIDIO"
	else
		nameattacker = killerName;
	end

	if (deathData[4]) then
		typekill = "Veículo: "..deathData[5];
	else
		typekill = deathData[2];
	end

	SendNUIMessage({
		addNotify = true,
		attacker = nameattacker,
		typekill = typekill,
		player = GetPlayerName(PlayerId())
	})
end)


function respawnPlayer (ped, pos)
	if (GetEntityHealth(ped) <= 101 and deathtimer <= 0) then
		SendNUIMessage({setDisplay = false})
		displayPress = false
		nameattacker = "SUICIDIO"
		local random = math.random(1, #pos)
		deathtimer = 5
		nocauteado = false
		SetEntityInvincible(ped,false)
		NetworkSetInSpectatorMode(0,  -1)
		DoScreenFadeOut(1000)
		SetEntityHealth(ped,400)
		SetPedArmour(ped,0)
		Citizen.Wait(1000)
		ClearPedBloodDamage(ped)
		if (pos == "Lobby") then
			TriggerEvent("callLobbyMenu")
		else
			SetEntityCoords(ped, pos[random][1] + 0.0001, pos[random][2] + 0.0001, pos[random][3] + 0.20 + 0.0001,1,0,0,1)
		end
		FreezeEntityPosition(ped,true)
		SetTimeout(5000,function()
			FreezeEntityPosition(ped,false)
			Citizen.Wait(1000)
			DoScreenFadeIn(1000)
		end)
	end
end

function networkPVP.getArenaRespawns (table)
	posDeath["Area"] = table
end

--[[Tela Escura Quando Morrer]]--
local locksound = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        if GetEntityHealth(ped) <= 101 then
            alreadyDead = true
            StartScreenEffect("DeathFailOut", 0, 0)
            if not locksound then
                locksound = true
            end
            ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
            local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(5)
            end
            if HasScaleformMovieLoaded(scaleform) then
                Citizen.Wait(5) 
                Citizen.Wait(500)
                PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)
                while GetEntityHealth(PlayerPedId()) <= 101 do
                    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
                    Citizen.Wait(5) 
                end
                StopScreenEffect("DeathFailOut")
                locksound = false
            end
        end
    end
end)