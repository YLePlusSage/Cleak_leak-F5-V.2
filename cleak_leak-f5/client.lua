ESX = nil

Citizen.CreateThread(
    function()
        while ESX == nil do
            TriggerEvent(
                "esx:getSharedObject",
                function(obj)
                    ESX = obj
                end
            )
            Citizen.Wait(10)
        end
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
        if ESX.IsPlayerLoaded() then
            ESX.PlayerData = ESX.GetPlayerData()
        end

    end
)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end
end)

AddEventHandler("esx:onPlayerDeath", function()
    Player.isDead = true
    RageUI.CloseAll()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    ESX.PlayerData.job = job
end)
RegisterNetEvent("esx:setJob2")
AddEventHandler("esx:setJob2", function(job2)
    ESX.PlayerData.job2 = job2
end)

local billing = {}
local Menuf5 = RageUI.CreateMenu(Config.Title, "Menu")
local firstSubMenu = RageUI.CreateSubMenu(Menuf5 ,"Inventaire" ,'Inventaire')
local useitemmenu = RageUI.CreateSubMenu(firstSubMenu ,"Inventaire" ,'Inventaire')
local usewepmenu = RageUI.CreateSubMenu(firstSubMenu ,"Inventaire" ,'Inventaire')
local secondSubMenu = RageUI.CreateSubMenu(Menuf5 ,"Porte-monnaie" ,"Contenu du Porte-monnaie")
local thirdSubMenu = RageUI.CreateSubMenu(Menuf5 ,"Gestion du Vehicule" ,"Gestion du Vehicule")
local fourthSubMenu = RageUI.CreateSubMenu(Menuf5 ,"Gestion des factures" ,"Gestion des factures")
local fiveSubMenu = RageUI.CreateSubMenu(Menuf5 ,"Gestion Vêtements" ,"Gestion Vêtements")
local sixSubMenu = RageUI.CreateSubMenu(Menuf5 ,"Divers" ,"Divers")

yodaF5 = {
    List = {
        filterlist = {'Aucun', '0bjet(s)', 'Arme(s)'},
        moneylist = {'Jeter', 'Donner'},
        bmoneylist = {'Jeter', 'Donner'},
        actionPatronlist = {"Recruter", "Promouvoir", "Destituer", "Licencier"},
        paperlist = {"Regarder", "Montrez"},
        paper2list = {"Regarder", "Montrez"},
        paper3list = {"Regarder", "Montrez"},
        cart_onlist = {"Activer", "Desactiver"},
        windowlist = {'Avant Gauche', 'Avant Droite', 'Arrière Gauche', 'Arrière Droite', 'Toutes'},
        doorlist = {"Avant gauche", "Avant droite", "Arrière gauche", "Arrière droite", "Capot", "Coffre", FrontLeft = false, FrontRight = false, BackLeft = false, BackRight = false, Hood = false, Trunk = false},
        LimitateurList = {"Par défaut", "Personalisé", "50/KMH", "80/KMH", "130/KMH"},
        VueList = {"Aucun", "Vue & lumières améliorées", "Vue lumineux", "Couleurs amplifiées", "Noir & blancs", "Visual 1", "Blanc", "Dégats"}
    },
    Index = {
        filterindex = 1,
        moneyindex = 1,
        bmoneyindex = 1,
        actionPatronindex = 1,
        paperindex = 1,
        paper2index = 1,
        paper3index = 1,
        windowindex = 1,
        doorindex = 1,
        cart_onindex = 1,
        Limitateurindex = 1,
        Vueindex = 1,
    }
}

Citizen.CreateThread(function()
    yoda.WeaponData = ESX.GetWeaponList()
    for i = 1, #yoda.WeaponData, 1 do
        if yoda.WeaponData[i].name == "WEAPON_UNARMED" then
            yoda.WeaponData[i] = nil
        else
            yoda.WeaponData[i].hash = GetHashKey(yoda.WeaponData[i].name)
        end
    end
end)
yoda = {WeaponData = {}}

local openbag = false
local permadmin = false
local showitem,showweapon = true,true
local config = {
    groupadmin = {'admin'}
}
local styleonoff = '~y~Allumer~s~'
function RageUI.PoolMenus:F5menu()
	Menuf5:IsVisible(function(Items)
	    Items:CheckBox('Ouvrir Mon Sac a dos', nil, openbag, { IsDisabled = false}, function(onChecked)
	        if (onChecked) then
	            openbag = not openbag
	        end
	    end)
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            Inveh = false
        else
            Inveh = true
        end
        if openbag then
            ESX.PlayerData = ESX.GetPlayerData()
            Items:AddLine()
            Items:AddSeparator("Steam : [ ~y~".. GetPlayerName(PlayerId()) .."~s~ ] |  id : ( ~y~" .. GetPlayerServerId(PlayerId()) .. " ~s~)")
            Items:AddButton("Inventaire", nil, { RightLabel = '~b~'.. GetCurrentWeight() + 0.0 .. '~s~/~g~' .. ESX.PlayerData.maxWeight + 0.0 .. '~s~ kg(s)', IsDisabled = false}, function(onSelected) end, firstSubMenu)
            Items:AddButton("Porte-monnaie", nil, { IsDisabled = false}, function(onSelected) end, secondSubMenu)
            Items:AddButton("Gestion Véhicule", nil, { IsDisabled = Inveh }, function(onSelected) end, thirdSubMenu)
            Items:AddButton("Facture(s)", nil, { IsDisabled = false }, function(onSelected) end, fourthSubMenu)
            Items:AddButton("Gestion Vêtements", nil, { IsDisabled = false }, function(onSelected) end, fiveSubMenu)
            Items:AddButton("Divers", nil, { IsDisabled = false }, function(onSelected) end, sixSubMenu)
        end
	end, function()
	end)
    firstSubMenu:IsVisible(function(Items)
        ESX.PlayerData = ESX.GetPlayerData()
        Items:AddList("Trier par : ", yodaF5.List.filterlist, yodaF5.Index.filterindex, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                yodaF5.Index.filterindex = Index;
                if Index == 1 then
                    showweapon = true
                    showitem = true
                elseif Index == 2 then
                    showweapon = false
                    showitem = true
                elseif Index == 3 then
                    showweapon = true
                    showitem = false
                end
            end
        end)
        if showitem then
            Items:AddSeparator('↓↓↓ ~b~Objet(s)~s~ ↓↓↓')
            for k, v in pairs(ESX.PlayerData.inventory) do
                if v.count > 0 then
                haveitem = true
                    Items:AddButton('[ ~b~'..v.label..'~s~ ]', nil, { RightLabel = 'Quantité(es) : ~b~x'..v.count,IsDisabled = false}, function(onSelected)
                        if (onSelected) then
                            itemlabel = v.label
                            itemcount = v.count
                            itemname = v.name
                            haveitem = false
                        end
                    end, useitemmenu)
                end
            end
            if not haveitem then
            Items:AddSeparator('')
            Items:AddSeparator('~r~Aucun Objet')
            Items:AddSeparator('')
            end
        end
        if showweapon then
            Items:AddSeparator('↓↓↓ ~y~Arme(s)~s~ ↓↓↓')
            Items:AddButton('Déséquiper Mon Arme', nil, {RightLabel = '→→', IsDisabled = false}, function(onSelected)
                if (onSelected) then
                    SetCurrentPedWeapon(
                        GetPlayerPed(-1),
                        GetHashKey("WEAPON_UNARMED")
                    )
                end
            end)
             for i = 1, #yoda.WeaponData, 1 do
                 if HasPedGotWeapon(PlayerPedId(), yoda.WeaponData[i].hash, false) then
                     local ammo = GetAmmoInPedWeapon(PlayerPedId(), yoda.WeaponData[i].hash)
                     if ammo ~= 0 then havemun = 'Munitions : ~y~x'..ammo else havemun = '' end
                     havewep = true
                     Items:AddButton('[ ~y~'..yoda.WeaponData[i].label..'~s~ ]', nil, { RightLabel = havemun,IsDisabled = false}, function(onSelected)
                         if (onSelected) then
                             weplabel = yoda.WeaponData[i].label
                             wepcount = havemun
                             wepname = yoda.WeaponData[i].name
                             havewep = false
                         end
                     end, usewepmenu)
                 end
             end
             if not havewep then
             Items:AddSeparator('')
             Items:AddSeparator('~r~Aucune Arme')
             Items:AddSeparator('')
             end
        end
    end, function()
    end)
    usewepmenu:IsVisible(function(Items)
        if wepcount ~= '' then slash = '/ ' else slash = '' end
        Items:AddLine()
        Items:AddSeparator('Arme : [ ~y~'.. weplabel .. '~s~ ] '..slash .. wepcount)
        Items:AddLine()
        Items:AddButton('Équiper', nil, {RightBadge = RageUI.BadgeStyle.Gun, IsDisabled = false}, function(onSelected)
            if (onSelected) then
                SetCurrentPedWeapon(
                    GetPlayerPed(-1),
                    wepname
                )
                ESX.ShowNotification("Vous équiper : ~y~" .. weplabel.. ' ~s~' .. wepcount)
            end
        end)
        Items:AddButton('Donner', nil, {RightBadge = RageUI.BadgeStyle.Armour, IsDisabled = false}, function(onSelected)
            if (onSelected) then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestDistance ~= -1 and closestDistance <= 3 then
                    local closestPed = GetPlayerPed(closestPlayer)
                    TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(closestPlayer), "item_weapon", wepname, 1)
                    RageUI.GoBack()
                else
                    ESX.ShowNotification("Personne à proximité")
                end
            end
        end)
        Items:AddButton('Jeter', nil, {RightBadge = RageUI.BadgeStyle.Alert, IsDisabled = false}, function(onSelected)
            if (onSelected) then
                if IsPedOnFoot(PlayerPedId()) then
                    TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', wepname, 1);
                    RageUI.GoBack()
                    Citizen.Wait(150);
                else
                    ESX.ShowNotification("~r~action impossible");
                end
            end
        end)
    end, function()
    end)
    useitemmenu:IsVisible(function(Items)
        Items:AddLine()
        Items:AddSeparator('Objet : [ ~b~'.. itemlabel .. '~s~ ] / Quantité(es) : ~b~x' .. itemcount)
        Items:AddLine()
        Items:AddButton('Utiliser', nil, {RightBadge = RageUI.BadgeStyle.Tick, IsDisabled = false}, function(onSelected)
            if (onSelected) then
                TriggerServerEvent('esx:useItem', itemname)
                RageUI.GoBack()
            end
        end)
        Items:AddButton('Donner', nil, {RightBadge = RageUI.BadgeStyle.Armour, IsDisabled = false}, function(onSelected)
            if (onSelected) then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestDistance ~= -1 and closestDistance <= 3 then
                    local closestPed = GetPlayerPed(closestPlayer)

                    if IsPedOnFoot(closestPed) then
                        if itemname ~= nil and itemcount > 0 then
                            TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', itemname)
                            RageUI.GoBack()
                        else
                            ESX.ShowNotification("quantité invalide")
                        end
                    else
                        ESX.ShowNotification("~r~action impossible")
                    end
                else
                    ESX.ShowNotification("Aucun Joueur a Proximité")
                end
            end
        end)
        Items:AddButton('Jeter', nil, {RightBadge = RageUI.BadgeStyle.Alert, IsDisabled = false}, function(onSelected)
            if (onSelected) then
                local quantity = KeyboardInput('Quantité de '..itemlabel..' à jeter :', "", 25);
                if tonumber(quantity) then
                    if IsPedOnFoot(PlayerPedId()) then
                        RageUI.GoBack()
                        TriggerServerEvent('esx:removeInventoryItem', 'item_standard', itemname, tonumber(quantity));
                        Citizen.Wait(150);
                    else
                        ESX.ShowNotification("~r~action impossible");
                    end
                else
                    ESX.ShowNotification("~r~quantité invalide");
                end
            end
        end)
    end, function()
    end)
    secondSubMenu:IsVisible(function(Items)
        local playerInfos = {
            jobname = ESX.PlayerData.job.name,
            gangname = ESX.PlayerData.job2.name,
            job = ESX.PlayerData.job.label,
            job_grade = ESX.PlayerData.job.grade_label,
            gang = ESX.PlayerData.job2.label,
            gang_grade = ESX.PlayerData.job2.grade_label
        }
        if playerInfos.jobname == 'unemployed' then playerjob = 'Aucun' else playerjob = playerInfos.job..'~s~, Grade : ~b~' .. playerInfos.job_grade end
        if playerInfos.gangname == 'unemployed2' then playergang = 'Aucun' else playergang = playerInfos.gang .. '~s~, Grade : ~r~' .. playerInfos.gang_grade end
        Items:AddSeparator('Métier : ~b~' .. playerjob)
        Items:AddSeparator('Groupe : ~r~' .. playergang)
        Items:AddLine()
        for i = 1, #ESX.PlayerData.accounts, 1 do
            if ESX.PlayerData.accounts[i].name == 'bank' then
                Items:AddSeparator('Solde Banquaire : ~b~' .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money) .. '~s~$')
            end
        end
        for i = 1, #ESX.PlayerData.accounts, 1 do
            if ESX.PlayerData.accounts[i].name == 'money' then
                Items:AddList('Solde Cash : ~g~' .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).. '~s~$', yodaF5.List.moneylist, yodaF5.Index.moneyindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
                     yodaF5.Index.moneyindex = Index
                     if (onSelected) then
                         if Index == 1 then
                             local plyPed = PlayerPedId()
                             local check, quantity = QuantityUnderZero(KeyboardInput("Quantité d'argent à jeter :", '', 8))

                             if check then
                                 if not IsPedSittingInAnyVehicle(plyPed) then
                                     TriggerServerEvent('esx:removeInventoryItem', 'item_account', ESX.PlayerData.accounts[i].name, quantity)
                                 else
                                     ESX.ShowNotification('~r~sortez du véhicule')
                                 end
                             else
                                 ESX.ShowNotification('quantité invalide')
                             end

                         elseif Index == 2 then
                             local check, quantity = QuantityUnderZero(KeyboardInput("Quantité d'argent à donner", '', 8))

                             if check then
                                 local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                                 if closestDistance ~= -1 and closestDistance <= 3 then
                                     local closestPed = GetPlayerPed(closestPlayer)

                                     if not IsPedSittingInAnyVehicle(closestPed) then
                                         TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', ESX.PlayerData.accounts[i].name, quantity)
                                     else
                                         ESX.ShowNotification('~r~sortez du véhicule')
                                     end
                                 else
                                     ESX.ShowNotification('Aucun joueur')
                                 end
                             else
                                 ESX.ShowNotification('quantité invalide')
                             end
                         end
                     end
                end)
            end
        end
        for i = 1, #ESX.PlayerData.accounts, 1 do
            if ESX.PlayerData.accounts[i].name == 'black_money' then
                 Items:AddList('Solde Non-Déclaré : ~r~' .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).. '~s~$', yodaF5.List.bmoneylist, yodaF5.Index.bmoneyindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
                    yodaF5.Index.bmoneyindex = Index
                    if (onSelected) then
                         if Index == 1 then
                             local plyPed = PlayerPedId()
                             local check, quantity = QuantityUnderZero(KeyboardInput("Quantité d'argent à jeter :", '', 8))

                             if check then
                                 if not IsPedSittingInAnyVehicle(plyPed) then
                                     TriggerServerEvent('esx:removeInventoryItem', 'item_account', ESX.PlayerData.accounts[i].name, quantity)
                                 else
                                     ESX.ShowNotification('~r~sortez du véhicule')
                                 end
                             else
                                 ESX.ShowNotification('quantité invalide')
                             end
                         elseif Index == 2 then
                             local check, quantity = QuantityUnderZero(KeyboardInput("Quantité d'argent à donner", '', 8))

                             if check then
                                 local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                                 if closestDistance ~= -1 and closestDistance <= 3 then
                                     local closestPed = GetPlayerPed(closestPlayer)

                                     if not IsPedSittingInAnyVehicle(closestPed) then
                                         TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', ESX.PlayerData.accounts[i].name, quantity)
                                     else
                                         ESX.ShowNotification('~r~sortez du véhicule')
                                     end
                                 else
                                     ESX.ShowNotification('Aucun joueur')
                                 end
                             else
                                 ESX.ShowNotification('quantité invalide')
                             end
                         end
                    end
                 end)
             end
        end
        Items:AddLine()

        if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == "boss" then
        Items:AddSeparator('~y~↓↓↓~s~ Action sur l\'entreprise ~y~↓↓↓~s~')
            Items:AddList('Action sur l\'individus', yodaF5.List.actionPatronlist, yodaF5.Index.actionPatronindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
                yodaF5.Index.actionPatronindex = Index
                if onSelected then
                    if Index == 1 then
                        actionPatrons.recruter()
                    elseif Index == 2 then
                        actionPatrons.promouvoir()
                    elseif Index == 3 then
                        actionPatrons.destituer()
                    elseif Index == 4 then
                        actionPatrons.licencier()
                    end
                end
            end)
        end
        Items:AddSeparator('~o~↓↓↓~s~ Action avec Papiers ~o~↓↓↓~s~')
        Items:AddList('Papiers d\'identité', yodaF5.List.paperlist, yodaF5.Index.paperindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            yodaF5.Index.paperindex = Index
            if onSelected then
                if Index == 1 then
                     TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                elseif Index == 2 then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
                    else
                        ESX.ShowNotification('Aucun joueur à proximité')
                    end
                end
            end
        end)
        Items:AddList('Licence du permis de Voiture', yodaF5.List.paper2list, yodaF5.Index.paper2index,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            yodaF5.Index.paper2index = Index
            if onSelected then
                if Index == 1 then
                     TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
                elseif Index == 2 then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
                    else
                        ESX.ShowNotification('Aucun joueur à proximité')
                    end
                end
            end
        end)
        Items:AddList('Licence du P.P.A.', yodaF5.List.paper3list, yodaF5.Index.paper3index,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            yodaF5.Index.paper3index = Index
            if onSelected then
                if Index == 1 then
                     TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
                elseif Index == 2 then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
                    else
                        ESX.ShowNotification('Aucun joueur à proximité')
                    end
                end
            end
        end)
    end, function()
    end)
    thirdSubMenu:IsVisible(function(Items)
        if not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
            RageUI.GoBack()
        end
        local player = PlayerPedId()
        local Vehplayer = GetVehiclePedIsIn(player, false)
        local motor = GetVehicleEngineHealth(Vehplayer)/10
        local motorstyle = math.floor(motor)
        local model = GetEntityModel(Vehplayer)
        local displaytext = GetDisplayNameFromVehicleModel(model)
        local label = GetLabelText(displaytext)
        local fuel = math.floor(GetVehicleFuelLevel(Vehplayer))
        Items:AddSeparator('état du moteur : ~g~' .. motorstyle .. '~s~/100')
        Items:AddSeparator('Réservoir : ~y~' .. fuel .. '~s~/100')
        Items:AddSeparator('Modèle : ~b~' .. label)
        Items:AddButton('état du véhicule : ' .. styleonoff, nil, { RightBadge = RageUI.BadgeStyle.Car, IsDisabled = false }, function(onSelected)
            if onSelected then
                if GetIsVehicleEngineRunning(Vehplayer) then
                    SetVehicleEngineOn(Vehplayer, false, false, true)
                    SetVehicleUndriveable(Vehplayer, true)
                    styleonoff = '~r~Eteint~s~'
                elseif not GetIsVehicleEngineRunning(Vehplayer) then
                    SetVehicleEngineOn(Vehplayer, true, false, true)
                    SetVehicleUndriveable(Vehplayer, false)
                    styleonoff = '~y~Allumer~s~'
                end
            end
        end)
        Items:AddList('Gestion des fenêtres', yodaF5.List.windowlist, yodaF5.Index.windowindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            yodaF5.Index.windowindex = Index
            if onSelected then
                if Index == 1 then
                    if not avantg then
                        avantg = true
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 0)
                    elseif avantg then
                        avantg = false
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 0)
                    end
                end

                if Index == 2 then
                    if not avantd then
                        avantd = true
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 1)
                    elseif avantd then
                        avantd = false
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 1)
                    end
                end

                if Index == 3 then
                    if not arrg then
                        arrg = true
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 2)
                    elseif arrg then
                        arrg = false
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 2)
                    end
                end

                if Index == 4 then
                    if not arrd then
                        arrd = true
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 3)
                    elseif arrd then
                        arrd = false
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 3)
                    end
                end

                if Index == 5 then
                    if not allw then
                        allw = true
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 0)
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 1)
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 2)
                        RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 3)


                    elseif allw then
                        allw = false
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 0)
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 1)
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 2)
                        RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 3)

                    end
                end
            end
        end)
        Items:AddList('Gestion des portières', yodaF5.List.doorlist, yodaF5.Index.doorindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            yodaF5.Index.doorindex = Index
            if onSelected then
            local playerveh = GetVehiclePedIsIn(PlayerPedId(), false)
            CarSpeed = GetEntitySpeed(playerveh) * 3.6
            if CarSpeed <= 20.0 then
                if Index == 1 then
                if not yodaF5.List.doorlist.FrontLeft then
                    yodaF5.List.doorlist.FrontLeft = true
                    SetVehicleDoorOpen(Vehplayer, 0, false, false)
                elseif yodaF5.List.doorlist.FrontLeft then
                    yodaF5.List.doorlist.FrontLeft = false
                    SetVehicleDoorShut(Vehplayer, 0, false, false)
                end
                elseif Index == 2 then
                if not yodaF5.List.doorlist.FrontRight then
                    yodaF5.List.doorlist.FrontRight = true
                    SetVehicleDoorOpen(Vehplayer, 1, false, false)
                elseif yodaF5.List.doorlist.FrontRight then
                    yodaF5.List.doorlist.FrontRight = false
                    SetVehicleDoorShut(Vehplayer, 1, false, false)
                end
                elseif Index == 3 then
                if not yodaF5.List.doorlist.BackLeft then
                    yodaF5.List.doorlist.BackLeft = true
                    SetVehicleDoorOpen(Vehplayer, 2, false, false)
                elseif yodaF5.List.doorlist.BackLeft then
                    yodaF5.List.doorlist.BackLeft = false
                    SetVehicleDoorShut(Vehplayer, 2, false, false)
                end
                elseif Index == 4 then
                if not yodaF5.List.doorlist.BackRight then
                    yodaF5.List.doorlist.BackRight = true
                    SetVehicleDoorOpen(Vehplayer, 3, false, false)
                elseif yodaF5.List.doorlist.BackRight then
                    yodaF5.List.doorlist.BackRight = false
                    SetVehicleDoorShut(Vehplayer, 3, false, false)
                end
                elseif Index == 5 then
                if not yodaF5.List.doorlist.Hood then
                    yodaF5.List.doorlist.Hood = true
                    SetVehicleDoorOpen(Vehplayer, 4, false, false)
                elseif yodaF5.List.doorlist.Hood then
                    yodaF5.List.doorlist.Hood = false
                    SetVehicleDoorShut(Vehplayer, 4, false, false)
                end
                elseif Index == 6 then
                if not yodaF5.List.doorlist.Trunk then
                    yodaF5.List.doorlist.Trunk = true
                    SetVehicleDoorOpen(Vehplayer, 5, false, false)
                elseif yodaF5.List.doorlist.Trunk then
                    yodaF5.List.doorlist.Trunk = false
                    SetVehicleDoorShut(Vehplayer, 5, false, false)
                end
                end
            else
                ESX.ShowNotification("[~r~sécurité~s~] Vitesse du véhicule trop élevé \nralentissez pour effectuer cette action")
            end
            end
        end)
        Items:AddList('Limitateur de vitesse : ', yodaF5.List.LimitateurList, yodaF5.Index.Limitateurindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            yodaF5.Index.Limitateurindex = Index
            if onSelected then
                if Index == 1 then
                    SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 1000.0 / 3.6)
                    limitpersonalize = "Aucun(e)"
                    ESX.ShowNotification("Limitateur par ~b~défaut")
                elseif Index == 2 then
                    local limitpersonalize = KeyboardInput("Vitesse ?", "", 3)
                    if limitpersonalize ~= nil and tonumber(limitpersonalize) then
                        ESX.ShowNotification("Limitateur à ~b~" .. limitpersonalize .. "/KMH")
                        SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), limitpersonalize / 3.6)
                    else
                        ESX.ShowNotification("Champ invalide" )
                    end
                elseif Index == 3 then
                    ESX.ShowNotification("Limitateur à ~b~50/KMH")
                    SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 50.0 / 3.6)
                elseif Index == 4 then
                    ESX.ShowNotification("Limitateur à ~b~80/KMH")
                    SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 80.0 / 3.6)
                elseif Index == 5 then
                    ESX.ShowNotification("Limitateur à ~b~130/KMH")
                    SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 130.0 / 3.6)
                end
            end
        end)
    end, function()
    end)
    fourthSubMenu:IsVisible(function(Items)
        Items:AddSeparator("~p~↓↓↓~s~ Facture(s) ~p~↓↓↓~s~")
        if #billing == 0 then
            Items:AddSeparator("")
            Items:AddSeparator("~r~Aucune facture")
            Items:AddSeparator("")
        end
        for i = 1, #billing, 1 do
            Items:AddButton(billing[i].label, nil, { RightLabel = 'Montant : ~r~$' .. ESX.Math.GroupDigits(billing[i].amount.."~s~ →"), IsDisabled = false }, function(onSelected)
                if onSelected then
                    ESX.TriggerServerCallback('esx_billing:payBill', function()
                        ESX.TriggerServerCallback('yoda:getfacture', function(bills) billing = bills end)
                    end, billing[i].id)
                end
            end)
        end
    end, function()
    end)
    fiveSubMenu:IsVisible(function(Items)
        Items:AddSeparator("~b~↓↓↓~s~ Tenue ~b~↓↓↓~s~")
        Items:AddButton('Changer Le ~b~Haut~s~', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
                TriggerEvent('changerhaut')
            end
        end)
        Items:AddButton('Changer Le ~b~Bas~s~', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
                TriggerEvent('changerpantalon')
            end
        end)
        Items:AddButton('Changer Le ~b~Chaussure~s~', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
               TriggerEvent('changerchaussure')
            end
        end)
        Items:AddSeparator("~b~↓↓↓~s~ Accessoires ~b~↓↓↓~s~")
        Items:AddButton('Changer Le ~b~Masque~s~', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
                TriggerEvent('changermask')
            end
        end)
        Items:AddButton('Changer Le ~b~Sac~s~', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
                TriggerEvent('changersac')
            end
        end)
        Items:AddButton('Changer Le ~b~GPB~s~', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
                TriggerEvent('changergpb')
            end
        end)
    end, function()
    end)
    sixSubMenu:IsVisible(function(Items)
    Items:AddSeparator("~y~↓↓↓~s~ Divers ~y~↓↓↓~s~")
        Items:AddList('GPS', yodaF5.List.cart_onlist, yodaF5.Index.cart_onindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            yodaF5.Index.cart_onindex = Index
            if Index == 1 then
                DisplayRadar(true)
            elseif Index == 2 then
                DisplayRadar(false)
            end
        end)
        local ragdolling = false
        Items:AddButton('Tomber', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
                ragdolling = not ragdolling
                while ragdolling do
                     Wait(0)
                    local myPed = GetPlayerPed(-1)
                    SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
                    ResetPedRagdollTimer(myPed)
                    AddTextEntry(GetCurrentResourceName(), ('pour vous ~b~Levé~s~, Appuyez sur ~INPUT_JUMP~'))
                    DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
                    ResetPedRagdollTimer(myPed)
                    if IsControlJustPressed(0, 22) then
                    break
                    end
                end
            end
        end)
        Items:AddButton('Rejoindre Le Discord', nil, { RightLabel = "→→", IsDisabled = false }, function(onSelected)
            if onSelected then
                ESX.ShowNotification('discord.gg/'..Config.invite)
            end
        end)
        Items:AddSeparator("~y~↓↓↓~s~ Streameur ~y~↓↓↓~s~")
    Items:AddList('Filtre : ', yodaF5.List.VueList, yodaF5.Index.Vueindex,nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
        yodaF5.Index.Vueindex = Index
            if Index == 1 then
                SetTimecycleModifier('')
            elseif Index == 2 then
                SetTimecycleModifier('tunnel')
            elseif Index == 3 then
                SetTimecycleModifier('rply_vignette_neg')
            elseif Index == 4 then
                SetTimecycleModifier('rply_saturation')
            elseif Index == 5 then
                SetTimecycleModifier('rply_saturation_neg')
            elseif Index == 6 then
                SetTimecycleModifier('yell_tunnel_nodirect')
            elseif Index == 7 then
                SetTimecycleModifier('rply_contrast_neg')
            elseif Index == 8 then
                SetTimecycleModifier('rply_vignette')
            end
    end)
    end, function()
    end)
end

Keys.Register("F5", "F5", "Menuf5", function()
    ESX.TriggerServerCallback('yoda:getfacture', function(bills)
        billing = bills
        RageUI.Visible(Menuf5, not RageUI.Visible(Menuf5))
    end)
end)

KeyboardInput = function(textEntry, inputText, maxLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry);
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", inputText, "", "", "", maxLength);
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(1.0);
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult();
        Citizen.Wait(500);
        return result
    else
        Citizen.Wait(500);
        return nil
    end
end

function QuantityUnderZero(number)
    number = tonumber(number)

    if type(number) == "number" then
        number = ESX.Math.Round(number)

        if number > 0 then
            return true, number
        end
    end

    return false, number
end


actionPatrons = {
    recruter = function()
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer == -1 or closestDistance > 3.0 then
            ESX.ShowNotification("Aucun ~b~individus~s~ près de vous.")
        else
            TriggerServerEvent("yoda:Recruter", GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
        end
    end,
    promouvoir = function()
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer == -1 or closestDistance > 3.0 then
            ESX.ShowNotification("Aucun ~b~individus~s~ près de vous.")
        else
            TriggerServerEvent("yoda:Promouvoir", GetPlayerServerId(closestPlayer))
        end
    end,
    destituer = function()
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer == -1 or closestDistance > 3.0 then
            ESX.ShowNotification("Aucun ~b~individus~s~ près de vous.")
        else
            TriggerServerEvent("yoda:Destiuer", GetPlayerServerId(closestPlayer))
        end
    end,
    licencier = function()
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer == -1 or closestDistance > 3.0 then
            ESX.ShowNotification("Aucun ~b~individus~s~ près de vous.")
        else
            TriggerServerEvent("yoda:Licencier", GetPlayerServerId(closestPlayer))
        end
    end
}

function GetCurrentWeight()
    local currentWeight = 0
    for i = 1, #ESX.PlayerData.inventory do
        if ESX.PlayerData.inventory[i].count > 0 then
            currentWeight = currentWeight + (ESX.PlayerData.inventory[i].weight * ESX.PlayerData.inventory[i].count)
        end
    end
    return currentWeight
end

RegisterNetEvent('changerhaut')
AddEventHandler('changerhaut', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.torso_1 ~= skinb.torso_1 then
                vethaut = true
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = skina.torso_1, ['torso_2'] = skina.torso_2, ['tshirt_1'] = skina.tshirt_1, ['tshirt_2'] = skina.tshirt_2, ['arms'] = skina.arms})
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
                vethaut = false
            end
        end)
    end)
end)

RegisterNetEvent('changerpantalon')
AddEventHandler('changerpantalon', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtrousers', 'try_trousers_neutral_c'

            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.pants_1 ~= skinb.pants_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = skina.pants_1, ['pants_2'] = skina.pants_2})
                vetbas = true
            else
                vetbas = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 15, ['pants_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 61, ['pants_2'] = 1})
                end
            end
        end)
    end)
end)


RegisterNetEvent('changerchaussure')
AddEventHandler('changerchaussure', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingshoes', 'try_shoes_positive_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.shoes_1 ~= skinb.shoes_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = skina.shoes_1, ['shoes_2'] = skina.shoes_2})
                vetch = true
            else
                vetch = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 35, ['shoes_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 34, ['shoes_2'] = 0})
                end
            end
        end)
    end)
end)

RegisterNetEvent('changersac')
AddEventHandler('changersac', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bags_1 ~= skinb.bags_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = skina.bags_1, ['bags_2'] = skina.bags_2})
                vetsac = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = 0, ['bags_2'] = 0})
                vetsac = false
            end
        end)
    end)
end)


RegisterNetEvent('changergpb')
AddEventHandler('changergpb', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bproof_1 ~= skinb.bproof_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = skina.bproof_1, ['bproof_2'] = skina.bproof_2})
                vetgilet = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = 0, ['bproof_2'] = 0})
                vetgilet = false
            end
        end)
    end)
end)

RegisterNetEvent('changermask')
AddEventHandler('changermask', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'missfbi4', 'takeoff_mask'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.mask_1 ~= skinb.mask_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['mask_1'] = skina.mask_1, ['mask_2'] = skina.mask_2})
                vetmask = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['mask_1'] = 0, ['mask_2'] = 0})
                vetmask = false
            end
        end)
    end)
end)