local box = {
	startjob = false,
	process = false,
	markers = {
		{21, 961.35, -2108.57, 31.97, "startjob"},
		{21, 992.80322265625,-2159.7141113281,29.476469039917, "process"},
		{2, 986.13592529297,-2107.2895507812,30.47481918335, "hit", 0.1},
		{2, 986.60974121094,-2105.3488769531,30.474956512451, "hit", 0.1},
		{2, 997.52276611328,-2105.8688964844,30.475332260132, "hit", 0.1}, 
		{2, 999.74621582031,-2108.7248535156,30.475467681885, "hit", 0.1}, 
		{2,998.83233642578,-2119.2563476562,30.475675582886, "hit", 0.1},
		{2, 995.03521728516,-2125.1181640625,30.475713729858, "hit", 0.1}
	}
}

RegisterCommand("cam",
	function ()
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)

        pos = GetEntityCoords(PlayerPedId())
        camPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
        SetCamCoord(cam, camPos.x, camPos.y, camPos.z+0.75)
        PointCamAtCoord(cam, pos.x, pos.y + 0.5, pos.z+0.15)
	end
)
Citizen.CreateThread(function ()
	while true do
		local wait = 1000
		Citizen.Wait(5)
		local ped = PlayerPedId();
		for k, v in ipairs (box.markers) do
			local _, ground = GetGroundZFor_3dCoord(v[2], v[3], v[4])
			local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), v[2], v[3], ground, true);
			if (distance <= 30) then
				wait = 5
				DrawMarker(v[1], v[2], v[3], v[4]-0.6, 0, 0, 0, 0.0, 0, 0, 0.5, 0.5, 0.4, 255, 0, 0, 50, 0, 0, 0, 1);
				if (v[5] == "startjob") then
					if (distance <= 2.0) then
						wait = 5
						drawTxt("PRESSIONE  ~g~E~w~  PARA TRABALHAR COMO AÇOUGUEIRO", 4, 0.5, 0.93, 0.50, 255, 255, 255, 180);
						if IsControlJustPressed(0, 38) then
							emP.checkPayment({"açougueiro", "start"})
						end
					end
				elseif (v[5] == "process") then
					if (distance <= 5.0) then
						if (box.process) then
							wait = 5
							drawTxt("PRESSIONE  ~g~E~w~  PARA PROCESSAR A CARNE", 4, 0.5, 0.93, 0.50, 255, 255, 255, 180);
							if IsControlJustPressed(0, 38) then
								tnRP._playAnim(true,{{"pickup_object","pickup_low"}},false);
								SetTimeout(5000,function()
									tnRP._stopAnim(false);
									emP.checkPayment({"açougueiro", "process"});
									box.process = false;
								end)
							end
						end
					end
				elseif (v[5] == "hit") then
					if (distance <= 1.0) then
						if (not box.process) then
							if (v[6] >= 1.0) then
								TriggerEvent("Notify", "sucesso", "Agora leve a carne para processar");
								emP.checkPayment({"açougueiro", "hit"});
								box.process = true;
							else
							end
						end
					else
						v[6] = 0.1;
					end
				end
			end
		end
		Citizen.Wait(wait)
	end
end)

RegisterNetEvent("açougueiro:hitc")
AddEventHandler("açougueiro:hitc", function (m, value)
	box.markers[m][6] = box.markers[m][6] + value 
end)