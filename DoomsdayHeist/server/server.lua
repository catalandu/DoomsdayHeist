local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('esx_holdupfacility:toofar')
AddEventHandler('esx_holdupfacility:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at') .. facilitys[robb].nameoffacility)
			TriggerClientEvent('esx_holdupfacility:killblip', xPlayers[i])
		end
	end
	if(robbers[source])then
		TriggerClientEvent('esx_holdupfacility:toofarlocal', source)
		robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, _U('robbery_has_cancelled') .. facilitys[robb].nameoffacility)
	end
end)

RegisterServerEvent('esx_holdupfacility:rob')
AddEventHandler('esx_holdupfacility:rob', function(robb)

	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local pendrive = xPlayer.getInventoryItem('pendrive')
	local xPlayers = ESX.GetPlayers()
	
	if facilitys[robb] then

		local facility = facilitys[robb]

		if (os.time() - facility.lastrobbed) < 43200 and facility.lastrobbed ~= 0 then

			TriggerClientEvent('esx:showNotification', source, _U('already_robbed') .. (2 - (os.time() - facility.lastrobbed)) .. _U('seconds'))
			return
		end


		local cops = 0
		for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end


		if rob == false then
		   
		  if xPlayer.getInventoryItem('pendrive').count >= 1 then
		     xPlayer.removeInventoryItem('pendrive', 1)

			if(cops >= Config.NumberOfCopsRequired)then

				rob = true
				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer.job.name == 'police' then
							TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog') .. facility.nameoffacility)
							TriggerClientEvent('esx_holdupfacility:setblip', xPlayers[i], facilitys[robb].position)
					end
				end

				TriggerClientEvent('esx:showNotification', source, _U('started_to_rob') .. facility.nameoffacility .. _U('do_not_move'))
				TriggerClientEvent('esx:showNotification', source, _U('alarm_triggered'))
				TriggerClientEvent('esx:showNotification', source, _U('hold_pos'))
				TriggerClientEvent('WORLD_HUMAN_DRINKING', source)
				TriggerClientEvent('esx_holdupfacility:currentlyrobbing', source, robb)
				facilitys[robb].lastrobbed = os.time()
				robbers[source] = robb
				local savedSource = source
				SetTimeout(600000, function()

					if(robbers[savedSource])then

						rob = false
						TriggerClientEvent('esx_holdupfacility:robberycomplete', savedSource, job)
						if(xPlayer)then

							xPlayer.addAccountMoney('black_money', facility.reward)
							local xPlayers = ESX.GetPlayers()
							for i=1, #xPlayers, 1 do
								local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
								if xPlayer.job.name == 'police' then
										TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at') .. facility.nameoffacility)
										TriggerClientEvent('esx_holdupfacility:killblip', xPlayers[i])
								end
							end
						end
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', source, _U('min_two_police') .. Config.NumberOfCopsRequired)
			end
		end
		else
			TriggerClientEvent('esx:showNotification', source, _U('robbery_already'))
		end
	end
end)
