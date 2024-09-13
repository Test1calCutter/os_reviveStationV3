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
