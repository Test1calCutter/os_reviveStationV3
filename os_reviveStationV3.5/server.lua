ESX = exports['es_extended']:getSharedObject()


function CountAmbulanceJob()
  local count = 0
  for _, playerId in ipairs(GetPlayers()) do
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer ~= nil then
      if xPlayer.job.name == Config.Job then
        count = count + 1
        print(count)
      end
    end
  end
  return count
end


RegisterServerEvent('os_revivestation:client:count')
AddEventHandler('os_revivestation:client:count', function()
  if Config.HideOnJob then
    local count = CountAmbulanceJob()
    TriggerClientEvent('os_revivestation:client:receiveCount', source, count)
  end
end)


RegisterServerEvent('esx_billing:sendBill')
AddEventHandler('esx_billing:sendBill', function(playerId, society, label, amount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        -- Add the bill to the player's account
        MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)', {
            ['@identifier'] = 'Revive Station',
            ['@sender'] = society,
            ['@target_type'] = 'player',
            ['@target'] = xPlayer.identifier,
            ['@label'] = label,
            ['@amount'] = amount
        }, function(rowsChanged)
            TriggerClientEvent('esx:showNotification', playerId, 'You have been billed $' .. amount .. ' for ' .. label)
        end)
    end
end)

-- Handle payment
ESX.RegisterServerCallback('esx_billing:payBill', function(source, cb, billId)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM billing WHERE id = @id', {
        ['@id'] = billId
    }, function(bill)
        if bill[1] then
            local amount = bill[1].amount
            local society = bill[1].sender

            if xPlayer.getAccount('bank').money >= amount then
                xPlayer.removeAccountMoney('bank', amount)
                TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
                    account.addMoney(amount)
                end)
                MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
                    ['@id'] = billId
                })
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)



