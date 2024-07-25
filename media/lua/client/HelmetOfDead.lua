print("CheckClothing.lua loaded")

-- Variable para mantener el estado del casco
local helmetActive = false

-- Función para manejar el menú contextual del casco
function HelmetOfDead_ContextMenu(player, context, worldobjects)
    local player = getSpecificPlayer(0) -- Obtener el jugador
    if player then
        local helmet = player:getWornItem("Hat")
        print("Helmet object: ", helmet)

        if helmet then
            print("Helmet type: ", helmet:getType())
            if helmet:getType() == "HelmetAsDead" then
                if helmetActive then
                    context:addOption("Desactivar", worldobjects, HelmetOfDead_Deactivate, player, helmet)
                else
                    context:addOption("Activar", worldobjects, HelmetOfDead_Activate, player, helmet)
                end
            end
        else
            print("No helmet found.")
        end
    else
        print("No se pudo obtener el jugador.")
    end
end

-- Función para activar el casco
function HelmetOfDead_Activate(worldobjects, player, helmet)
    helmetActive = true
    timer = 1200 -- 2 minutos en ticks (60 ticks por segundo * 120 segundos)
    print("HelmetOfDead activado")
    player:Say("Casco activado")
    Events.OnTick.Add(HelmetOfDead_Countdown)
end

-- Función para desactivar el casco
function HelmetOfDead_Deactivate(worldobjects, player, helmet)
    helmetActive = false
    timer = nil
    print("HelmetOfDead desactivado")
    player:Say("Casco desactivado")
    Events.OnTick.Remove(HelmetOfDead_Countdown)
end

-- Función para la cuenta regresiva
function HelmetOfDead_Countdown()
    if not helmetActive or not timer then return end
    timer = timer - 1
    local player = getSpecificPlayer(0)
    if player then
        if timer == 1150 then
            player:Say("Pip")
        elseif timer <= 900 and timer % 150 == 0 then
            player:Say("Pip Pip")
        elseif timer <= 600 and timer % 50 == 0 then
            player:Say("Pip Pip Pip")
        end

        if timer == 0 then
            player:Say("El casco explota!")
            player:getBodyDamage():ReduceGeneralHealth(1000) -- Mata al jugador
            helmetActive = false
            Events.OnTick.Remove(HelmetOfDead_Countdown)
        end
    end
end

-- Función para detectar la ropa del personaje
function CheckPlayerClothing()
    local player = getPlayer()
    if player then
        local helmet = player:getWornItem("Hat")
        if helmet then
            if helmet:getType() == "HelmetAsDead" then
                print("HelmetAsDead equipped: ", helmet:getType())
                player:Say("Quitenme esta locura!.")
                Events.OnTick.Remove(CheckPlayerClothing)
            end
        end
    end
end

-- Añadir la función al evento OnTick
Events.OnTick.Add(CheckPlayerClothing)
print("Added CheckPlayerClothing to Events.OnTick")

-- Añadir la función al evento OnFillInventoryObjectContextMenu
Events.OnFillInventoryObjectContextMenu.Add(HelmetOfDead_ContextMenu)
print("Added HelmetOfDead_ContextMenu to OnFillInventoryObjectContextMenu")

--p PRUEBA ESTE CODIGO