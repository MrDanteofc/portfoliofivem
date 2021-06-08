local Tunnel = module("tnrp","lib/Tunnel")
local Proxy = module("tnrp","lib/Proxy")
local Tools = module("tnrp","lib/Tools")
tnRP = Proxy.getInterface("tnRP")
tnRPclient = Tunnel.getInterface("tnRP")
emP = {}
Tunnel.bindInterface("tnrp_empregos", emP)
local blips = {}
local quantidade = {}
local idgens = Tools.newIDGenerator()
local porcentagem = 0
local itemname_rural = ""
local antic =  {}
local peixes = {
	[1] = { x = "dourado" },
	[2] = { x = "corvina" },
	[3] = { x = "salmao" },
	[4] = { x = "pacu" },
	[5] = { x = "pintado" },
	[6] = { x = "pirarucu" },
	[7] = { x = "tilapia" },
	[7] = { x = "lambari" },
	[8] = { x = "tucunare" }
}

function emP.checkWeight(tipo)
	emP.Quantidade(tipo)
	local source = source
	local user_id = tnRP.getUserId(source)
	if user_id then
		porcentagem = math.random(100)
		if tipo == "minerio" then
			if porcentagem <= 15 then
				itemname_rural = "bronze"
			elseif porcentagem >= 16 and porcentagem <= 30 then
				itemname_rural = "ferro"
			elseif porcentagem >= 31 and porcentagem <= 40 then
				itemname_rural = "ouro"
			elseif porcentagem >= 41 and porcentagem <= 50 then
				itemname_rural = "rubi"
			elseif porcentagem >= 51 and porcentagem <= 60 then
				itemname_rural = "esmeralda"
			elseif porcentagem >= 61 and porcentagem <= 70 then
				itemname_rural = "safira"
			elseif porcentagem >= 71 and porcentagem <= 80 then
				itemname_rural = "diamante"
			elseif porcentagem >= 81 and porcentagem <= 90 then
				itemname_rural = "topazio"
			elseif porcentagem >= 91 then
				itemname_rural = "ametista"
			end
		end
		if tipo == "açougueiro" then
			if porcentagem <= 19 then
				itemname_rural = "carnedeaguia"
			elseif porcentagem >= 20 and porcentagem <= 30 then
				itemname_rural = "carnedecervo"
			elseif porcentagem >= 31 and porcentagem <= 40 then
				itemname_rural = "carnedecormorao"
			elseif porcentagem >= 41 and porcentagem <= 50 then
				itemname_rural = "carnedecorvo"
			elseif porcentagem >= 51 and porcentagem <= 60 then
				itemname_rural = "carnedecoyote"
			elseif porcentagem >= 61 and porcentagem <= 70 then
				itemname_rural = "carnedejavali"
			elseif porcentagem >= 71 and porcentagem <= 80 then
				itemname_rural = "carnedelobo"
			elseif porcentagem >= 81 and porcentagem <= 90 then
				itemname_rural = "carnedepuma"
			end			
		end
		return tnRP.getInventoryWeight(user_id)+tnRP.getItemWeight(itemname_rural)*quantidade[source] <= tnRP.getInventoryMaxWeight(user_id)
	end
end

function emP.checkServices(name, quantidade)
	local source = source
	local user_id = tnRP.getUserId(source)
	if user_id then
		local perm = tnRP.getUsersByPermission(name..".permissao")
		if parseInt(#paramedicos) >= quantidade then
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Não há "..name.." suficientes em serviço.") 
			return false
		end
	end
end

function emP.checkItens(item, quantidade)
	local source = source
	local user_id = tnRP.getUserId(source)
	if user_id then
		if tnRP.getInventoryItemAmount(user_id,item) >= quantidade then
			return true 
		else
			TriggerClientEvent("Notify",source,"negado","<b>"..tnRP.itemNameList(item).."</b> insuficientes.") 
			return false
		end
	end
end

function emP.takeItem(item, quantidade)
	local source = source
	local user_id = tnRP.getUserId(source)
	if user_id then
		if emP.checkItens(item, quantidade) then
			if tnRP.tryGetInventoryItem(user_id, item, quantidade) then
				return true
			end
		end
	end
end


function emP.Quantidade(min, max, tipo)
	local source = source
	if quantidade[source] == nil then
		quantidade[source] = math.random(min, max)
		if (tipo) then
			TriggerClientEvent("quantidade-"..tipo,source,parseInt(quantidade[source]))
		end
	end	
end

function emP.MarcarOcorrencia(text)
	local source = source
	local user_id = tnRP.getUserId(source)
	local x,y,z = tnRPclient.getPosition(source)
	if user_id then
		local soldado = tnRP.getUsersByPermission("policia.permissao")
		for l,w in pairs(soldado) do
			local player = tnRP.getUserSource(parseInt(w))
			if player then
				async(function()
					local id = idgens:gen()
					blips[id] = tnRPclient.addBlip(player,x,y,z,153,84,"Ocorrência",0.5,false)
					tnRPclient._playSound(player,"CONFIRM_BEEP","HUD_MINI_GAME_SOUNDSET")
					TriggerClientEvent('chatMessage',player,"911",{64,64,255},"Recebemos a denuncia de "..text..", verifique o ocorrido.")
					SetTimeout(15000,function() tnRPclient.removeBlip(player,blips[id]) idgens:free(id) end)
				end)
			end
		end
	end
end

function emP.getIdleCustom(type, old_custom)
	local source = source
	if type and type == 1 then
		return tnRP.save_idle_custom(source, old_custom)
	else
		tnRP.removeCloak(source)
	end
end

function emP.addGroup(group)
	local source = source
	local user_id = tnRP.getUserId(source)
	tnRP.addUserGroup(user_id,group)
end

function emP.removeGroup(group)
	local source = source
	local user_id = tnRP.getUserId(source)
	tnRP.removeUserGroup(user_id,group)
end

function emP.checkPermission(perm)
	local source = source
	local user_id = tnRP.getUserId(source)
	if (type(perm) == "table") then
		for k, v in ipairs(perm) do
			return tnRP.hasPermission(user_id, v..".permissao");	
		end
	end
	return tnRP.hasPermission(user_id, perm..".permissao");
end

RegisterCommand("tc", function ()
	local source = source
	local user_id = tnRP.getUserId(source)
	local identity = tnRP.getUserIdentity(user_id)
	local nplayer = tnRPclient.getNearestPlayer(source, 2)
	local nuser_id = parseInt(tnRP.getUserId(nplayer))
	if tnRP.getUData(nuser_id, "tcowner") then
		return TriggerClientEvent("Notify", source, "negado", "Ele já está em um trabalho coletivo.")
	end

	if tnRP.getUData(user_id, "tcowner") then
		return TriggerClientEvent("Notify", source, "negado", "Apenas quem iniciou o trabalho coletivo pode convidar mais pessoas.")
	end

	if tnRP.getUData(user_id, "tc") and tnRP.getUData(user_id, "tcmax") then
		local qtd = json.encode(tnRP.getUData("tc"))
		if tnRP.getUData(user_id, "tcmax") >= #qtd then
			return TriggerClientEvent("Notify", source, "negado", "Limite de trabalhadores excedido.")
		end

		if vRP.request(nplayer, "Deseja iniciar trabalho coletivo com "..identity.firstname.." "..identity.name.."?",20) then
			tnRP.setUData(user_id, "tc", json.encode(nuser_id))
			tnRP.setUData(nuser_id, "tcowner", user_id)
		else
			TriggerClientEvent("Notify", source, "negado", "Seu pedido de trabalho coletivo foi recusado")
		end
	end
end)

RegisterCommand("tcsair", function ()
	local source = source
	local user_id = tnRP.getUserId(source)
	local nuser_id = tnRP.getUserId(parseInt(tnRP.getUData("tcowner")))
	local identity = tnRP.getUserIdentity(user_id)
	local nsource = tnRP.getUserSource(nuser_id)
	if tnRP.getUData(user_id, "tcowner") then
		if vRP.request(source, "Deseja mesmo sair do trabalho coletivo?",20) then
			local tcplayers = json.decode(tnRP.getUData(nuser_id, "tc")) or {}
			if tcplayers then
				table.remove(tcplayers, user_id)
				tnRP.setUData(nuser_id, "tc", json.encode(tcplayers))
				TriggerClientEvent("Notify", nsource, "negado", identity.firstname.." "..identity.name.." saiu do trabalho coletivo")
				TriggerClientEvent("Notify", source, "sucesso", "Você saiu do trabalho coletivo")
			end
			tnRP.setUData(user_id, "tcowner", json.encode(0))
		end
	end
end)

function emP.checkPayment(args)
	local source = source
	local user_id = tnRP.getUserId(source)
	if (user_id) then

		if (args[1] == "coletar" and args[4]) then
			emP.Quantidade(args[3], args[4])
			if tnRP.getInventoryWeight(user_id)+tnRP.getItemWeight(args[2])*quantidade[source] <= tnRP.getInventoryMaxWeight(user_id) then
				tnRP.giveInventoryItem(user_id,args[2],quantidade[source])
				TriggerClientEvent("Notify",source,"sucesso","Você coletou <b>"..quantidade[source].."x "..tnRP.itemNameList(args[2]).."</b>.",8000)
				quantidade[source] = nil
				return true
			else
				TriggerClientEvent("Notify",source,"negado","<b>Mochila</b> cheia.")
				return false
			end
		end 
		if (args[1] == "coletar") then
			if tnRP.getInventoryWeight(user_id)+tnRP.getItemWeight(args[2]) <= tnRP.getInventoryMaxWeight(user_id) then
				tnRP.giveInventoryItem(user_id,args[2],args[3])
				TriggerClientEvent("Notify",source,"sucesso","Você coletou <b>"..args[3].."x "..tnRP.itemNameList(args[2]).."</b>.",8000)
				return true
			else
				TriggerClientEvent("Notify",source,"negado","<b>Mochila</b> cheia.")
				return false
			end
		end

		if (args[1] == "leiteiro_coletar") then
			if tnRP.getInventoryWeight(user_id)+tnRP.getItemWeight("garrafadeleite")*3 <= tnRP.getInventoryMaxWeight(user_id) then
				if tnRP.tryGetInventoryItem(user_id,"garrafavazia",3) then
					tnRP.giveInventoryItem(user_id,"garrafadeleite",3)
					return true
				else
					TriggerClientEvent("Notify",source,"negado","<b>Garrafas</b> vazias insuficientes.") 
					return false
				end
			else
				TriggerClientEvent("Notify",source,"negado","<b>Mochila</b> cheia.") 
				return false
			end
		end

		if (args[1] == "colheita") then
			if tnRP.tryGetInventoryItem(user_id,"graosimpuros",5) then
				rgraos = math.random(2,4)
				tnRP.giveInventoryItem(user_id,"graos",parseInt(rgraos))
				TriggerClientEvent("Notify",source,"sucesso","Você recebeu <b>"..rgraos.."</b> Grãos.")
			end
		end

		if (args[1] == "quantidade") then
			if antic[user_id] == 0 or not antic[user_id] then
				if tnRP.tryGetInventoryItem(user_id, args[2],quantidade[source]) then
					quantidade[source] = nil
					emP.Quantidade(args[3], args[4], args[2])
					antic[user_id] = 15
					return true
				else
					TriggerClientEvent("Notify",source,"negado","Você precisa de <b>"..quantidade[source].."x "..tnRP.itemNameList(args[2]).."</b>.")
					return false 
				end
			else
				SendWebhookMessage(webhookmonster,"```prolog\n[ID]: "..user_id.." \n[TENTOU USAR MONSTERMENU E FOI PEGO NO PULO]\n>>>> "..quantidade[source].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```<@&665612122545324042>")
			end
		end
		
		if (args[1] == "rural") then
			tnRP.giveInventoryItem(user_id,itemname_rural,quantidade[source])
			TriggerClientEvent("Notify",source,"sucesso","Encontrou <b>"..quantidade[source].."x "..tnRP.itemNameList(itemname_rural).."</b>.",8000)
			quantidade[source] = nil	
		end

		if (args[1] == "pescador") then
			if tnRP.getInventoryWeight(user_id)+tnRP.getItemWeight("dourado") <= tnRP.getInventoryMaxWeight(user_id) then
				if tnRP.tryGetInventoryItem(user_id, "varadepescar") then
					if tnRP.tryGetInventoryItem(user_id,"isca",1) then
						if not args[2] then return true end
						if args[2] >= 98 then
							tnRP.giveInventoryItem(user_id,"lambari",1)
							TriggerClientEvent("Notify", source, "sucesso", "Você pescou 1 Lambari!")
						elseif args[2] <= 30 then
							return true
						else
							tnRP.giveInventoryItem(user_id,peixes[#peixes].x,1)
							TriggerClientEvent("Notify", source, "sucesso", "Você pescou 1 "..peixes[#peixes].x.."!")
						end
						return true
					else
						TriggerClientEvent("Notify", source, "negado", "Você não tem isca para pescar!")
						return false
					end
				else
					TriggerClientEvent("Notify", source, "negado", "Você não tem Vara de Pescar!")
					return false					
				end
			else
				TriggerClientEvent("Notify", source, "negado", "<b>Você não tem espaço na Mochila para os peixes</b>")
				return false
			end
		end
		--[[
		if (args[1] == "açougueiro") then
			if (args[2] == "start") then
				if tnRP.getInventoryItemAmount(user_id, "wbody|WEAPON_MACHETE") >= 1 then
					TriggerClientEvent("Notify",source,"sucesso","Trabalho iniciado, vá até as Carnes e começa a cortar.</b>.")
				else
					TriggerClientEvent("Notify",source,"negado","Você precisa de <b>1 Machete para iniciar o trabalho.</b>.")
				end
			elseif (args[2] == "hit") then
				emP.quantidade(1, 2)
				tnRP.giveInventoryItem(user_id, "carnenprocessada", quantidade[source])
			elseif (args[2] == "process") then
				if tnRP.tryGetInventoryItem(user_id, "carnenprocessada", quantidade[source]) then
					tnRP.giveInventoryItem(user_id, itemname_rural, quantidade[source])
				end
			end
		end
		--]]
		if (args[1] == "giveMoney") then
			TriggerEvent("top_empregos:receber", (args[2]));
		end
	end
end

RegisterServerEvent('top_empregos:receber')
AddEventHandler('top_empregos:receber', function(pagamento)
	local source = source
	local user_id = tnRP.getUserId(source)
    if (user_id) then
		tnRP.giveMoney(user_id,parseInt(pagamento))
		TriggerClientEvent("tnRP_sound:source",source,'coins',0.3)
		TriggerClientEvent("Notify",source,"financeiro","Você recebeu <b>$"..tnRP.format(parseInt(parseInt)).." dólares</b>.")
	end
end)