ESX = nil

local logs = '' --paste your webhook here
local communityname = "Bank-Logs"
local communitylogo = "" -- paste your logo link hewre

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('vb-banking:server:GetPlayerName', function(source, cb)
	local _char = ESX.GetPlayerFromId(source)
	local _charname = _char.getName()
	cb(_charname)
end)

RegisterServerEvent('vb-banking:server:depositvb')
AddEventHandler('vb-banking:server:depositvb', function(amount, inMenu)
	local _src = source
	local _char = ESX.GetPlayerFromId(_src)
	amount = tonumber(amount)
	if amount == nil or amount <= 0 or amount > _char.getMoney() then
		TriggerClientEvent('chatMessage', _src, "Invalid Quantity.")
	else
		local name = GetPlayerName(source)
		local ip = GetPlayerEndpoint(source)
		local ping = GetPlayerPing(source)
		local steamhex = GetPlayerIdentifier(source)
		local disconnect = {
			{
				["color"] = "8663711",
				["title"] = "Player Depositing money to the bank",
				["description"] = "Player: **"..name.."**\nAmount **"..amount.. "** \nIP: **"..ip.."**\nSteam Hex: **"..steamhex.."**",
				["footer"] = {
					["text"] = communityname,
					["icon_url"] = communitylogo,
 				},
			}
		}
		PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "Bank Logs", embeds = disconnect}), {['Content-Type'] = 'application/json'})
		_char.removeMoney(amount)
		_char.addAccountMoney('bank', tonumber(amount))
		_char.showNotification("You've deposited  $"..amount)
	end
end)


RegisterServerEvent('vb-banking:server:withdrawvb')
AddEventHandler('vb-banking:server:withdrawvb', function(amount, inMenu)
	local _src = source
	local _char = ESX.GetPlayerFromId(_src)
	local _base = 0
	amount = tonumber(amount)
	_base = _char.getAccount('bank').money
	if amount == nil or amount <= 0 or amount > _base then
		TriggerClientEvent('chatMessage', _src, "Invalid Quantity")
	else
		local name = GetPlayerName(source)
		local ip = GetPlayerEndpoint(source)
		local ping = GetPlayerPing(source)
		local steamhex = GetPlayerIdentifier(source)
		local disconnect = {
			{
				["color"] = "8663711",
				["title"] = "Player taking money out to the bank",
				["description"] = "Player: **"..name.."**\nAmount **"..amount.. "** \nIP: **"..ip.."**\nSteam Hex: **"..steamhex.."**",
				["footer"] = {
					["text"] = communityname,
					["icon_url"] = communitylogo,
 				},
			}
		}
		PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "Bank Logs", embeds = disconnect}), {['Content-Type'] = 'application/json'})

		_char.removeAccountMoney('bank', amount)
		_char.addMoney(amount)
		_char.showNotification("You've withdrawn $"..amount)
	end
end)

RegisterServerEvent('vb-banking:server:balance')
AddEventHandler('vb-banking:server:balance', function(inMenu)
	local _src = source
	local _char = ESX.GetPlayerFromId(_src)
	local balance = _char.getAccount('bank').money
	TriggerClientEvent('vb-banking:client:refreshbalance', _src, balance)
end)

RegisterServerEvent('vb-banking:server:transfervb')
AddEventHandler('vb-banking:server:transfervb', function(to, amountt, inMenu)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local zPlayer = ESX.GetPlayerFromId(tonumber(to))
	local balance = 0
	if zPlayer ~= nil then
		balance = xPlayer.getAccount('bank').money
		if tonumber(_source) == tonumber(to) then
			TriggerClientEvent('chatMessage', _source, "You can't transfer money to yourself")	
		else
			if balance <= 0 or balance < tonumber(amountt) or tonumber(amountt) <= 0 then
				TriggerClientEvent('chatMessage', _source, "You don't have enough money in your bank account.")
			else
				local name = GetPlayerName(source)
				local ip = GetPlayerEndpoint(source)
				local ping = GetPlayerPing(source)
				local steamhex = GetPlayerIdentifier(source)
				local disconnect = {
					{
						["color"] = "8663711",
						["title"] = "Player transfering money to other player",
						["description"] = "Player: **"..xPlayer.name.."**\nAmount **"..amount.. "** \nTarget: **"..zPlayer.name.."**\nIP: **"..ip.."**\nSteam Hex: **"..steamhex.."**",
						["footer"] = {
							["text"] = communityname,
							["icon_url"] = communitylogo,
						 },
					}
				}
				PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "Bank Logs", embeds = disconnect}), {['Content-Type'] = 'application/json'})
		
				xPlayer.removeAccountMoney('bank', tonumber(amountt))
				zPlayer.addAccountMoney('bank', tonumber(amountt))
				zPlayer.showNotification("You've received a bank transfer of "..amountt.."$ from the ID: ".._source)
				xPlayer.showNotification("You've sent a bank transfer of "..amountt.."$ to the ID: "..to)
			end
		end
	else
		TriggerClientEvent('chatMessage', _source, "That Wallet ID is not valid or doesn't exist")
	end
end)