---@diagnostic disable: undefined-global
T = TranslationInv.Langs[Lang]
Core = exports.vorp_core:GetCore()


RegisterNetEvent('vorpinventory:send_slots', function(itemTotal, slots, mon, gol, rol)
    SendNUIMessage({ action = "changecheck", check = itemTotal, info = slots })
    SendNUIMessage({
        action = "updateStatusHud",
        show   = not IsRadarHidden(),
        money  = mon,
        gold   = gol,
        rol    = rol,
        id     = GetPlayerServerId(PlayerId()),
    })
end)

if Config.DevMode then
    AddEventHandler('onClientResourceStart', function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
            return
        end
        print('loading resource ^1DEV MODE IS ENABLED')
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "hide" })
        TriggerServerEvent("DEV:loadweapons")
        print("Loading Inventory")
        TriggerServerEvent("vorpinventory:getItemsTable")
        Wait(1000)
        TriggerServerEvent("vorpinventory:getInventory")
        Wait(1000)
        TriggerServerEvent("vorpCore:LoadAllAmmo")
        print("inventory loaded")
        Wait(100)
        TriggerEvent("vorpinventory:loaded")
    end)
end

local lastLantern = 0
CreateThread(function()
    if not Config.UseLanternPutOnBelt then
        return
    end

    repeat Wait(1000) until LocalPlayer.state.IsInSession

    local function checkLanterns(hash)
        local lanterns = { "WEAPON_MELEE_LANTERN", "WEAPON_MELEE_LANTERN_HALLOWEEN", "WEAPON_MELEE_DAVY_LANTERN", "WEAPON_MELEE_LANTERN_ELECTRIC" }
        for i = 1, #lanterns do
            if hash == joaat(lanterns[i]) then
                return true
            end
        end
        return false
    end

    while true do
        local weaponHeld = GetPedCurrentHeldWeapon(PlayerPedId())
        local isLantern = IsWeaponLantern(weaponHeld) == 1 or IsWeaponLantern(weaponHeld) == true
        if isLantern then
            lastLantern = weaponHeld
        end

        if lastLantern ~= 0 and not checkLanterns(weaponHeld) then
            SetCurrentPedWeapon(PlayerPedId(), lastLantern, true, 12, false, false)
            lastLantern = 0
        end
        Wait(1000)
    end
end)
