local blips = false
local servico = false
local selecionado = 0
local coordsent = vector3(-349.84, -1569.79, 25.22)
local coordsdeh = vector3(-329.45,-1566.93,25.23)
local coordsveh = vector3(-341.15, -1567.94, 25.22)
local namao = false
local processo = false
local nameveh = "trash"
local stockadeVeh = 0
local locs = {
	[1] = { ['x'] = -362.00, ['y'] = -1864.88, ['z'] = 20.52 }, 
	[2] = { ['x'] = 120.71, ['y'] = -2057.40, ['z'] = 18.33 }, 
	[3] = { ['x'] = 144.04, ['y'] = -1870.33, ['z'] = 24.09 }, 
	[4] = { ['x'] = 158.01, ['y'] = -1817.61, ['z'] = 28.12 }, 
	[5] = { ['x'] = 238.92, ['y'] = -1947.97, ['z'] = 23.12 }, 
	[6] = { ['x'] = 452.12, ['y'] = -1908.68, ['z'] = 24.31 }, 
	[7] = { ['x'] = 488.70, ['y'] = -1511.15, ['z'] = 29.00 }, 
	[8] = { ['x'] = 423.46, ['y'] = -1520.45, ['z'] = 28.99 }, 
	[9] = { ['x'] = 271.28, ['y'] = -1500.86, ['z'] = 28.92 }, 
	[10] = { ['x'] = 121.33, ['y'] = -1540.67, ['z'] = 29.32 },
	[11] = { ['x'] = 139.33, ['y'] = -1363.72, ['z'] = 28.95 }, 
	[12] = { ['x'] = -17.17, ['y'] = -1389.49, ['z'] = 29.10 },
	[13] = { ['x'] = 488.28, ['y'] = -1282.21, ['z'] = 29.25 }, 
	[14] = { ['x'] = 438.92, ['y'] = -1062.36, ['z'] = 28.92 }, 
	[15] = { ['x'] = 307.45, ['y'] = -1033.31, ['z'] = 29.20 }, 
	[16] = { ['x'] = 243.00, ['y'] = -824.68, ['z'] = 29.62 }, 
	[17] = { ['x'] = 14.10, ['y'] = -559.67, ['z'] = 36.34 }, 
	[18] = { ['x'] = 22.68, ['y'] = -366.31, ['z'] = 40.23 }, 
	[19] = { ['x'] = 294.24, ['y'] = -268.79, ['z'] = 53.67 },
	[20] = { ['x'] = 971.72, ['y'] = -145.31, ['z'] = 73.09 }, 
	[21] = { ['x'] = 945.40, ['y'] = 82.43, ['z'] = 80.48 }, 
	[22] = { ['x'] = 885.23, ['y'] = -180.86, ['z'] = 72.63 },
	[23] = { ['x'] = 600.70, ['y'] = 76.13, ['z'] = 93.18 }, 
	[24] = { ['x'] = 309.96, ['y'] = 344.89, ['z'] = 105.16 }, 
	[25] = { ['x'] = -392.94, ['y'] = 298.09, ['z'] = 84.55 }, 
	[26] = { ['x'] = -599.93, ['y'] = 279.71, ['z'] = 81.69 }, 
	[27] = { ['x'] = -1231.54, ['y'] = 384.25, ['z'] = 75.35 }, 
	[28] = { ['x'] = -1787.17, ['y'] = -491.88, ['z'] = 39.42 },
	[29] = { ['x'] = -1989.19, ['y'] = -489.31, ['z'] = 11.45 }, 
	[30] = { ['x'] = -1324.23, ['y'] = -1215.71, ['z'] = 4.49 }, 
}

local vehSpawn = {
	{-336.17352294922,-1563.2098388672,25.231252670288,51.74361038208},
	{-347.54501342773,-1562.537109375,24.949556350708,85.033538818359}
}

local function serviceJob()
	Citizen.CreateThread(function()
		while true do
			local wait = 1000
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			if servico then
				local bowz,cdz = GetGroundZFor_3dCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
				local _, cdz_veh = GetGroundZFor_3dCoord(coordsveh.x, coordsveh.y, coordsveh.z)
				local distance_veh = GetDistanceBetweenCoords(x,y,z,coordsveh.x,coordsveh.y,coordsveh.z,true)
				local distance = GetDistanceBetweenCoords(locs[selecionado].x,locs[selecionado].y,cdz,x,y,z,true)
				local vehicle = GetPlayersLastVehicle()
				local cx, cy, cz = table.unpack(GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.00, 0.0))
				local distance_car = GetDistanceBetweenCoords(x,y,z,cx,cy,cz,true)
				local model = GetEntityModel(vehicle)
				local displaytext = GetDisplayNameFromVehicleModel(model)
				local name = GetLabelText(displaytext)


				if distance <= 30.0 then
					wait = 5
					DrawMarker(21,locs[selecionado].x,locs[selecionado].y,locs[selecionado].z+0.20,0,0,0,0,180.0,130.0,1.0,1.0,1.0,255,0,0,50,1,0,0,1)
					if distance <= 2.5 then
						if not namao then
							textNotify("Pressione  ~INPUT_PICKUP~  para coletar os Sacos de Lixo")
							if IsControlJustPressed(0,38) then
								if not IsPedInAnyVehicle(ped, true) then
									prop = CreateObject(GetHashKey("prop_cs_rub_binbag_01"), x+5.5, y+5.5, z-0.1,  true,  true, true)
									AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 64016), 0.25, -0.021, -0.004, 15.0, 285.0, 270.0, true, true, false, true, 1, true)
									TriggerEvent("Notify","importante","Leve o lixo até o Caminhão")
									namao = true
									selecionado = math.random(1, #locs)
									RemoveBlip(blips)
									blips = CriandoBlip(locs,selecionado, "Coleta de Lixo")
								else
									TriggerEvent("Notify","importante","Saia do veiculo para coletar o saco de lixo.")
								end
							end
						end
					end
				end

				if distance_veh <= 25 then
					wait = 5
					DrawMarker(39,coordsveh.x,coordsveh.y,coordsveh.z-0.6,0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 65, 105, 255, 50, 0)
					if distance_veh <= 1.2 then
						textNotify("Pressione  ~INPUT_PICKUP~ para pegar o veiculo")
						if IsControlJustPressed(0, 38) then
							if (not nveh) then
								Fade(1000)
								nveh = spawnVehicle(nameveh, vehSpawn)
								--TriggerEvent("Notify","sucesso","Você pegou o caminhão, agora vá coletar o <b>Lixo</b>")
							end
						end
					end
				end

				if nveh then
					if distance_car <= 2.0 then 
						if IsVehicleModel(nveh,GetHashKey(nameveh)) then
							wait = 5
							
							textNotify("Pressione  ~INPUT_PICKUP~ para "..(namao and "jogar" or "pegar").." o lixo no Caminhão")

							if IsControlJustPressed(0,38) then
								if (namao) then
									stockadeVeh = stockadeVeh + math.random(1, 3) 
									tnRP._playAnim(false,{"anim@heists@narcotics@trash","throw_ranged_a"},false)
									FreezeEntityPosition(ped, true)
									SetVehicleDoorOpen(nveh, 5, 0, 0);
									SetTimeout(2000,function()
										repeat
											if prop then
												DeleteEntity(prop)
												prop = nil
											end
										until (namao == false)
										SetVehicleDoorShut(nveh, 5, 0)
										tnRP._DeletarObjeto()
										tnRP._stopAnim(false)
										FreezeEntityPosition(ped, false)
									end)
								else
									if (stockadeVeh > 0) then
										SetVehicleDoorOpen(nveh, 5, 0, 0);
										SetTimeout(1000,function()
											SetVehicleDoorShut(nveh, 5, 0)
											prop = CreateObject(GetHashKey("prop_cs_rub_binbag_01"), x+5.5, y+5.5, z-0.1,  true,  true, true)
											AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 64016), 0.25, -0.021, -0.004, 15.0, 285.0, 270.0, true, true, false, true, 1, true)
											stockadeVeh = stockadeVeh - 1
										end)
									end
								end

								namao = not namao			
							end
						end
						
					end
				end

				if IsControlJustPressed(0,168) then
					servico = false
					Fade(1000)
					RemoveBlip(blips)
					if namao then
						tnRP._DeletarObjeto()
						tnRP._stopAnim(false)
					end
					TriggerEvent("Notify","importante","Você saiu de serviço.")
					if (nveh) then
						
						DeleteVehicle(nveh)
						nveh = nil
					end
				end
				if not processo then
					local distancia = GetDistanceBetweenCoords(GetEntityCoords(ped),coordsdeh.x, coordsdeh.y, coordsdeh.z)
					wait = 5
					DrawMarker(21,coordsdeh.x, coordsdeh.y, coordsdeh.z-0.6,0,0,0,0.0,0,0,0.5,0.5,0.4,150,50,0,100,0,0,0,1)
					if distancia <= 1.5 then
						if namao then
							textNotify("Pressione ~INPUT_PICKUP~ para despejar o Lixo")
							if IsControlJustPressed(0,38) then
								TriggerEvent('cancelando',true)
								tnRP._playAnim(false,{"anim@heists@narcotics@trash","throw_ranged_a"},false)
								processo = true
								TriggerEvent("progress", 3000, "DESPEJANDO")
								
								SetTimeout(3000,function()
									namao = false
									repeat
										if prop then
											DeleteEntity(prop)
											prop = nil
										end
									until (namao == false)
									
									tnRP._DeletarObjeto()
									tnRP._stopAnim(false)
									processo = false
									emP.checkPayment("giveMoney", math.random(paymentJobs.lixeiro.min, paymentJobs.lixeiro.max))
									TriggerEvent('cancelando',false)
								end)			
							end
						else
							textNotify("Pegue o Lixo no caminhão e despeje aqui")
						end
					end
				end
			end
			Citizen.Wait(wait)
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		local wait = 1000
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped))
		if not servico then
			local bowz,cdz = GetGroundZFor_3dCoord(coordsent.x,coordsent.y,coordsent.z)
			local distance = GetDistanceBetweenCoords(coordsent.x,coordsent.y,cdz,x,y,z,true)
			if distance <= 5.0 then
				wait = 5
				DrawJob3D(coordsent.x,coordsent.y, coordsent.z, "~w~Catador de ~g~Lixo~g~")
				DrawMarker(27,coordsent.x,coordsent.y,coordsent.z-0.99,0,0,0,0.0,0,0,1.0,1.0,1.0,255,150,0,255,0,0,0,1)
				if distance <= 1.2 then
					textNotify("Pressione ~INPUT_PICKUP~ para iniciar o serviço")
					if IsControlJustPressed(0,38) then
						Fade(1000)
						servico = true
						selecionado = 1
						blips = CriandoBlip(locs,selecionado, "Coleta de Lixo")
						TriggerEvent("Notify","sucesso","Você entrou em serviço. Pegue o <b>caminhão</b> ao lado")
						serviceJob()
					end
				end
			end
		end
		Citizen.Wait(wait)
	end
end)

