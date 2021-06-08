local servico = false
local locais = 0
local processo = false
local tempo = 0
local animacao = false
local coordsent = vector3(152.64,-3208.45,5.9)
local coordsveh = vector3(159.23091125488,-3207.2587890625,6.011073589325)
local nameveh = "burrito"
local vehSpawn = {
	{133.61518859863,-3216.2985839844,5.6739716529846,269.60177612305},
	{133.4349822998,-3210.552734375,5.6734495162964,269.01040649414},
	{144.56272888184,-3210.7436523438,5.6739630699158,269.01898193359}
}

local encanador = {
	[1] = { ['x'] = -798.38, ['y'] = 175.85, ['z'] = 72.84 },
	[2] = { ['x'] = -820.32, ['y'] = 106.88, ['z'] = 56.55 },
	[3] = { ['x'] = -843.46, ['y'] = -13.18, ['z'] = 39.89 },
	[4] = { ['x'] = -1127.7, ['y'] = 307.63, ['z'] = 66.18 }, 
	[5] = { ['x'] = -1560.74, ['y'] = 23.53, ['z'] = 59.56 },
	[6] = { ['x'] = -1032.92, ['y'] = 349.39, ['z'] = 71.37 },
	[7] = { ['x'] = -900.8, ['y'] = 99.6, ['z'] = 55.11 },
	[8] = { ['x'] = -1476.82, ['y'] = -339.75, ['z'] = 45.44 },
	[9] = { ['x'] = -806.15, ['y'] = -957.62, ['z'] = 15.29 },
	[10] = { ['x'] = 183.47, ['y'] = -161.23, ['z'] = 56.32 },
	[11] = { ['x'] = 141.92, ['y'] = -292.32, ['z'] = 46.31 },
	[12] = { ['x'] = 158.7, ['y'] = -284.7, ['z'] = 46.31 },
	[13] = { ['x'] = 67.26, ['y'] = -1387.56, ['z'] = 29.35 },
	[14] = { ['x'] = 17.71, ['y'] = -1300.08, ['z'] = 29.38 },
	[15] = { ['x'] = -16.18, ['y'] = -1076.93, ['z'] = 26.68 },
	[16] = { ['x'] = -218.67, ['y'] = -1165.74, ['z'] = 23.02 },
	[17] = { ['x'] = -690.3, ['y'] = -1391.3, ['z'] = 5.16 },
	[18] = { ['x'] = -1325.21, ['y'] = -919.99, ['z'] = 11.29 },
	[19] = { ['x'] = 424.22, ['y'] = -995.81, ['z'] = 30.72 }
}

local function serviceJob()
	Citizen.CreateThread(function()
		while true do
			local wait = 1000
			local ped = GetPlayerPed(-1)

			local _, cdz_veh = GetGroundZFor_3dCoord(coordsveh.x,coordsveh.y,coordsveh.z)
			local distance_veh = GetDistanceBetweenCoords(GetEntityCoords(ped), coordsveh.x, coordsveh.y, cdz_veh, true)

			local _, cdz_fer = GetGroundZFor_3dCoord(coordsfer.x,coordsfer.y,coordsfer.z)
			local distance_fer = GetDistanceBetweenCoords(GetEntityCoords(ped), coordsfer.x, coordsfer.y, cdz_fer, true)

			local _, cdz_local = GetGroundZFor_3dCoord(encanador[locais].x,encanador[locais].y,encanador[locais].z)
			local distance_local = GetDistanceBetweenCoords(GetEntityCoords(ped), encanador[locais].x,encanador[locais].y,cdz_local, true)
			
			if (servico) then
				-- MARKER PEGAR O VEICULO
				if (distance_veh <= 30) then
					wait = 5
					DrawMarker(39, coordsveh.x,coordsveh.y,coordsveh.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 65, 105, 255, 50, 0)
					if (distance_veh <= 1.2) then
						textNotify("Pressione ~INPUT_PICKUP~ para pegar o veiculo")
						if IsControlJustPressed(0,38) then
							if (not nveh) then
								nveh = spawnVehicle(nameveh, vehSpawn)
								TriggerEvent("Notify","importante","Você pegou o veiculo. Agora se dirija a bancada e pegue os materias!")
							end
						end
					end
				end

				-- MARKER COLETAR FERRAMENTAS
				if (distance_fer <= 30) then
					wait = 5
					if (not processo) then
						DrawMarker(27,coordsfer.x,coordsfer.y,coordsfer.z-1.0,0,0,0,0,0,0,0.5,0.5,0.5,178,236,177,100,0,300,0,1)
						if (distance_fer <= 1.2) then
							textNotify("Pressione ~INPUT_PICKUP~ para coletar os Equipamentos")
							if (IsControlJustPressed(0,38)) then
								processo = true
								tnRP._playAnim(false,{{"anim@amb@business@coc@coc_packing_hi@","full_cycle_v1_pressoperator"}},true)
								TriggerEvent("progress",10000,"Coletando Equipamento")
								TriggerEvent("cancelando", true)
								SetTimeout(10000,function()
									if (emP.checkPayment("coletar","ferramenta", 3)) then
										tnRP._stopAnim()
										TriggerEvent("cancelando", false)
										processo = false
									end
								end)	
							end
						end
					end
				end

				-- MARKER CONSERTAR O CANO
				if (distance_local <= 30) then
					if (not processo) then
						wait = 5
						if (distance_local <= 1.2) then
							textNotify("Pressione ~INPUT_PICKUP~ para consertar o cano")
							if (IsControlJustPressed(0,38)) then
								if (emP.takeItem("ferramenta", 1)) then
									RemoveBlip(blips)
									TriggerEvent("progress",10000,"Consertando o cano")
									TriggerEvent("cancelando", true)
									processo = true
									tnRP._playAnim(false,{{"amb@world_human_hammering@male@base","base"}},true)
									SetTimeout(10000, function()
										emP.checkPayment("giveMoney", math.random(paymentJobs.encanador.min, paymentJobs.encanador.max))
										processo = false
										TriggerEvent("cancelando", false)	
										tnRP._stopAnim();
										if (locais == #encanador) then
											locais = 1
										else
											locais = math.random(1, #encanador)
										end

										blips = CriandoBlip(encanador, locais, "Local do Encanamento")
									end)
								end
							end
						end
					end
				end

				if IsControlJustPressed(0, 168) then
					Fade(1000)
					if (nveh) then
						DeleteVehicle(nveh)
						nveh = nil
					end
					emP.getIdleCustom()
					servico = false
					TriggerEvent("Notify", "sucesso", "Você saiu do serviço")
				end
			end

			Citizen.Wait(wait)
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		local wait = 1000
		if not servico then
			local ped = GetPlayerPed(-1)
			local _, cdz = GetGroundZFor_3dCoord(coordsent.x,coordsent.y,coordsent.z)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), coordsent.x, coordsent.y, cdz, true)
			if (distance <= 30.0) then
				wait = 5
				DrawMarker(27,coordsent.x,coordsent.y,coordsent.z-1.0,0,0,0,0,0,0,0.5,0.5,0.5,178,236,177,100,0,300,0,1)
				if distance <= 1.2 then
					DrawJob3D(coordsent.x, coordsent.y, coordsent.z, "Trabalho de ~b~Encanador")
					textNotify("Pressione ~INPUT_PICKUP~ para iniciar o serviço")
					if IsControlJustPressed(0, 38) then
						Fade(1000)
						getClothesJob("Macacão")
						TriggerEvent("Notify","sucesso","Você entrou em serviço")
						servico = true
						locais = math.random(1,#encanador)
						CriandoBlip(encanador,locais, "Local do Encanamento")
						serviceJob();
					end
				end
			end
		end
		Citizen.Wait(wait)
	end
end)
