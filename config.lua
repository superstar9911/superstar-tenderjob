Config = {}

Config.JobName = "bartender"

-- Locations
Config.ClockIn = vector3(-524.31, -52.8, 42.42)
Config.CraftingStation = vector3(-530.87, -52.05, 42.42)

-- Single recipe example
Config.Recipes = {
    {
        name = "vodka",
        item = "vodka",
        ingredients = { ["water_bottle"] = 1, ["phone"] = 1 }
    },
    {
        name = "beer",
        item = "beer",
        ingredients = { ["water_bottle"] = 1, ["beer"] = 1 }
    },
    {
        name = "whiskey",
        item = "whiskey",
        ingredients = { ["whiskey"] = 1, ["water_bottle"] = 1 }
    }
}
