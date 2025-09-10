QBCore = exports['qb-core']:GetCoreObject()
local onDuty = false
local key = 38 -- E key

-- Create Bartender Shop Blip
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(-548.75, -52.82, 42.18)

    SetBlipSprite(blip, 93)        -- Icon (shop)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(true)
    SetBlipColour(blip, 2)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("superstars bar")
    EndTextCommandSetBlipName(blip)
end)

-- Helpers
local function getDrinkByNumber(num)
    local index = tonumber(num)
    if index and Config.Recipes[index] then
        return Config.Recipes[index].name
    end
    return nil
end

local function buildDrinkList()
    local str = ""
    for i, recipe in pairs(Config.Recipes) do
        str = str .. i .. ": " .. recipe.name:sub(1,1):upper()..recipe.name:sub(2) .. "\n"
    end
    return str
end

-- Clock-in/out and crafting station
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- Clock-in/out
        if #(pos - Config.ClockIn) < 5.0 then
            DrawMarker(2, Config.ClockIn.x, Config.ClockIn.y, Config.ClockIn.z + 1.0, 0,0,0,0,0,0,0.3,0.3,0.3, 0,255,0,150, false, false, false, true)
            if #(pos - Config.ClockIn) < 1.5 then
                QBCore.Functions.DrawText3D(Config.ClockIn.x, Config.ClockIn.y, Config.ClockIn.z, "[E] Clock In/Out")
                if IsControlJustReleased(0, key) then
                    onDuty = not onDuty
                    if onDuty then
                        QBCore.Functions.Notify("You are now on duty!", "success")
                    else
                        QBCore.Functions.Notify("You are now off duty!", "error")
                    end
                end
            end
        end

        -- Crafting station
        if onDuty and #(pos - Config.CraftingStation) < 5.0 then
            DrawMarker(2, Config.CraftingStation.x, Config.CraftingStation.y, Config.CraftingStation.z + 1.0, 0,0,0,0,0,0,0.3,0.3,0.3, 0,0,255,150, false, false, false, true)
            if #(pos - Config.CraftingStation) < 1.5 then
                QBCore.Functions.DrawText3D(Config.CraftingStation.x, Config.CraftingStation.y, Config.CraftingStation.z, "[E] Craft Drink")
                if IsControlJustReleased(0, key) then
                    local drinkList = buildDrinkList()
                    local result = exports['qb-input']:ShowInput({
                        header = "Enter the number of the drink you want to craft:\n"..drinkList,
                        submitText = "Craft",
                        inputs = {
                            { type = "text", isRequired = true, name = "drink", text = "1" }
                        }
                    })

                    if result and result.drink then
                        local drinkName = getDrinkByNumber(result.drink)
                        if drinkName then
                            TriggerServerEvent('superstar-tenderjob:craftRecipe', drinkName)
                        else
                            QBCore.Functions.Notify("Invalid selection!", "error")
                        end
                    end
                end
            end
        end

        Citizen.Wait(3)
    end
end)

-- Craft animation + progress bar
RegisterNetEvent('superstar-tenderjob:craftRecipeClient', function(item, recipeName)
    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BEVERAGE", 0, true)

    QBCore.Functions.Progressbar("craft_recipe", "Crafting "..recipeName:sub(1,1):upper()..recipeName:sub(2).."...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasks(ped)
        TriggerServerEvent('QBCore:Server:AddItem', item, 1)
        QBCore.Functions.Notify("You crafted a "..recipeName:sub(1,1):upper()..recipeName:sub(2).."!", "success")
    end, function()
        ClearPedTasks(ped)
        QBCore.Functions.Notify("Crafting cancelled", "error")
    end)
end)
