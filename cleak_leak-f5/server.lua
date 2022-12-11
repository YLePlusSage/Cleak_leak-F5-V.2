ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent("yoda:Recruter")
AddEventHandler(
    "yoda:Recruter",
    function(target, job, grade)
        local sourceXPlayer = ESX.GetPlayerFromId(source)
        local targetXPlayer = ESX.GetPlayerFromId(target)
        targetXPlayer.setJob(job, grade)
        TriggerClientEvent(
            "esx:showNotification",
            sourceXPlayer.source,
            "Vous avez ~g~recruté " .. targetXPlayer.name .. "~s~."
        )
        TriggerClientEvent(
            "esx:showNotification",
            target,
            "Vous avez été ~g~embauché par " .. sourceXPlayer.name .. "~s~."
        )
    end
)

RegisterServerEvent("yoda:Promouvoir")
AddEventHandler(
    "yoda:Promouvoir",
    function(target)
        local sourceXPlayer = ESX.GetPlayerFromId(source)
        local targetXPlayer = ESX.GetPlayerFromId(target)

        if (targetXPlayer.job.grade == tonumber(getMaximumGrade(sourceXPlayer.job.name)) - 1) then
            TriggerClientEvent(
                "esx:showNotification",
                sourceXPlayer.source,
                "Vous devez demander une autorisation du ~r~Gouvernement~s~."
            )
        else
            targetXPlayer.setJob(targetXPlayer.job.name, tonumber(targetXPlayer.job.grade) + 1)

            TriggerClientEvent(
                "esx:showNotification",
                sourceXPlayer.source,
                "Vous avez ~g~promu " .. targetXPlayer.name .. "~s~."
            )
            TriggerClientEvent(
                "esx:showNotification",
                target,
                "Vous avez été ~g~promu par " .. sourceXPlayer.name .. "~s~."
            )
            TriggerClientEvent("esx:showNotification", sourceXPlayer.source, "Vous n'avez pas ~r~l'autorisation~s~.")
        end
    end
)

RegisterServerEvent("yoda:Destiuer")
AddEventHandler(
    "yoda:Destiuer",
    function(target)
        local sourceXPlayer = ESX.GetPlayerFromId(source)
        local targetXPlayer = ESX.GetPlayerFromId(target)
        if (targetXPlayer.job.grade == 0) then
            TriggerClientEvent(
                "esx:showNotification",
                sourceXPlayer.source,
                "Vous ne pouvez pas ~r~rétrograder~s~ davantage."
            )
        else
            targetXPlayer.setJob(targetXPlayer.job.name, tonumber(targetXPlayer.job.grade) - 1)
            TriggerClientEvent(
                "esx:showNotification",
                sourceXPlayer.source,
                "Vous avez ~r~rétrogradé " .. targetXPlayer.name .. "~s~."
            )
            TriggerClientEvent(
                "esx:showNotification",
                target,
                "Vous avez été ~r~rétrogradé par " .. sourceXPlayer.name .. "~s~."
            )
        end
    end
)

RegisterServerEvent("yoda:Licencier")
AddEventHandler(
    "yoda:Licencier",
    function(target)
        local sourceXPlayer = ESX.GetPlayerFromId(source)
        local targetXPlayer = ESX.GetPlayerFromId(target)

        targetXPlayer.setJob("unemployed", 0)
        TriggerClientEvent(
            "esx:showNotification",
            sourceXPlayer.source,
            "Vous avez ~r~viré " .. targetXPlayer.name .. "~s~."
        )
        TriggerClientEvent("esx:showNotification", target, "Vous avez été ~g~viré par " .. sourceXPlayer.name .. "~s~.")
        TriggerClientEvent("esx:showNotification", sourceXPlayer.source, "Vous n'avez pas ~r~l'autorisation~s~.")
    end
)


ESX.RegisterServerCallback('yoda:getfacture', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		local bills = {}

		for i = 1, #result do
			bills[#bills + 1] = {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			}
		end

		cb(bills)
	end)
end)

