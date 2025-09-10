QBCore = exports['qb-core']:GetCoreObject()

-- Craft recipe
RegisterNetEvent('superstar-tenderjob:craftRecipe', function(recipeName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local recipe = nil

    -- Find the recipe from config
    for _, r in pairs(Config.Recipes) do
        if r.name:lower() == recipeName:lower() then
            recipe = r
            break
        end
    end

    if not recipe then
        TriggerClientEvent('QBCore:Notify', src, "Recipe not found!", "error")
        return
    end

    -- Check ingredients
    local hasAll = true
    for ingredient, amount in pairs(recipe.ingredients) do
        local invItem = Player.Functions.GetItemByName(ingredient)
        if not invItem or invItem.amount < amount then
            hasAll = false
            break
        end
    end

    if not hasAll then
        TriggerClientEvent('QBCore:Notify', src, "You don't have the required ingredients!", "error")
        return
    end

    -- Remove ingredients
    for ingredient, amount in pairs(recipe.ingredients) do
        Player.Functions.RemoveItem(ingredient, amount)
    end

    -- Give crafted item
    Player.Functions.AddItem(recipe.item, 1)

    -- Trigger client for animation and progress bar
    TriggerClientEvent('superstar-tenderjob:craftRecipeClient', src, recipe.item, recipe.name)
end)
