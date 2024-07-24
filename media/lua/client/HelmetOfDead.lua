print("CheckClothing.lua loaded")

-- Variable para mantener el estado del casco
local helmetActive = false

-- Función para manejar el menú contextual del casco
function HelmetOfDead_ContextMenu(playerIndex, context, worldobjects)
    local player = getSpecificPlayer(playerIndex)
    local helmet = player and player:getWornItem("Hat")

    if helmet and helmet:getType() == "HelmetAsDead" then
        if helmetActive then
            context:addOption("Desactivar", worldobjects, HelmetOfDead_Deactivate, playerIndex)
        else
            context:addOption("Activar", worldobjects, HelmetOfDead_Activate, playerIndex)
        end
    end
end

-- Función para activar el casco
function HelmetOfDead_Activate(worldobjects, playerIndex)
    local player = getSpecificPlayer(playerIndex)
    helmetActive = true
    print("HelmetOfDead activado")
    player:Say("Casco activado")
end

-- Función para desactivar el casco
function HelmetOfDead_Deactivate(worldobjects, playerIndex)
    local player = getSpecificPlayer(playerIndex)
    helmetActive = false
    print("HelmetOfDead desactivado")
    player:Say("Casco desactivado")
end

-- Función para detectar la ropa del personaje
function CheckPlayerClothing(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if player then
        local helmet = player:getWornItem("Hat")
        if helmet and helmet:getType() == "HelmetAsDead" then
            print("HelmetAsDead equipped: ", helmet:getType())
            player:Say("Quitenme esta locura!.")
            Events.OnTick.Remove(CheckPlayerClothing)
        end
    end
end

-- Añadir la función al evento OnTick para cada jugador
for i = 0, getNumActivePlayers() - 1 do
    Events.OnTick.Add(function() CheckPlayerClothing(i) end)
end

-- Añadir la función al evento OnFillInventoryObjectContextMenu para cada jugador
for i = 0, getNumActivePlayers() - 1 do
    Events.OnFillInventoryObjectContextMenu.Add(function(player, context, worldobjects) HelmetOfDead_ContextMenu(i, context, worldobjects) end)
end

print("Added CheckPlayerClothing and HelmetOfDead_ContextMenu to Events")
