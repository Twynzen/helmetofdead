print("CheckClothing.lua loaded")

-- Variables para el estado del casco y el objeto especial
local helmetActive = false
local hasKeyHelmet = false
local helmetItem = "HelmetAsDead"
local keyItem = "HelmetExplosiveKey"

function DisableDefaultOptions(context)
    local optionsToRemove = {"Dejar de usar", "Soltar"}
    for i = #context.options, 1, -1 do
        local option = context.options[i]
        for _, optToRemove in ipairs(optionsToRemove) do
            if option.name == optToRemove then
                table.remove(context.options, i)
            elseif string.find(option.name, "Poner en contenedor") or string.find(option.name, "Colocar")then
                table.remove(context.options, i)
            end
        end
    end
end


-- Función para manejar el menú contextual del casco
function HelmetOfDead_ContextMenu(player, context, items)
    print("Entrando en HelmetOfDead_ContextMenu")
    local player = getSpecificPlayer(0) -- Obtener el jugador
    if player then

        local hat = player:getWornItem("Hat")
        if hat and hat:getType() == "HelmetAsDead" and hat:hasTag("HelmetOfDeadTag") then
            print("El jugador tiene puesto el casco HelmetAsDead con el tag HelmetOfDeadTag")
        -- Iterar sobre los ítems seleccionados
            for _, v in ipairs(items) do
                local item = v
                if not instanceof(item, "InventoryItem") then
                    item = item.items[1]
                end

                print("Revisando item:", item:getType())

                -- Verificar si el ítem es una instancia de InventoryItem y es HelmetAsDead
                if instanceof(item, "InventoryItem") and item:getType() == "HelmetAsDead" and item:hasTag("HelmetOfDeadTag") then
                    print("El ítem es HelmetAsDead y tiene el tag HelmetOfDeadTag")

                    -- Solo añadir opciones al casco específico
                    if helmetActive then
                        if hasKeyHelmet then
                            context:addOption("Desactivar Casco Explosivo", item, HelmetOfDead_Deactivate, player, item)
                        else
                            DisableDefaultOptions(context)
                            local deactivateOption = context:addOption("Desactivar Casco Explosivo", item, function() end)
                            deactivateOption.notAvailable = true
                        end
                    else
                        context:addOption("Activar Casco Explosivo", item, HelmetOfDead_Activate, player, item)
                    end
                else
                    print("El ítem no es HelmetAsDead o no tiene el tag HelmetOfDeadTag")
                end
            end
        end    
    else
        print("No se pudo obtener el jugador.")
    end
end


--lOGICA PARA ITERAR INVENTARIO
-- local inventory = player:getInventory()
--         for i = 0, inventory:getItems():size() - 1 do
--             local item = inventory:getItems():get(i)
--             print("Revisando item en inventario:", item:getType())
--             if instanceof(item, "InventoryItem") then
--                 print("El item ", item,"es una instancia de InventoryItem")
            
--             else
--                 print("El item no es una instancia de InventoryItem")
--             end
--         end




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
        local hat = player:getWornItem("Hat")
        
        -- Verificar si el casco sigue equipado
        if not hat or hat:getType() ~= "HelmetAsDead" or not hat:hasTag("HelmetOfDeadTag") then
            player:Say("El casco se ha quitado, explotando!")
            player:getBodyDamage():ReduceGeneralHealth(1000) -- Mata al jugador
            helmetActive = false
            Events.OnTick.Remove(HelmetOfDead_Countdown)
            return -- Salir de la función para evitar la ejecución adicional
        end

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


-- Función para verificar si el jugador tiene el Key Helmet
function CheckKeyHelmet()
    local player = getPlayer()
    if player then
        local inventory = player:getInventory()
        if inventory then
            hasKeyHelmet = inventory:contains("KeyHelmet")
        end
    end
end

-- Añadir la función al evento OnTick para verificar el Key Helmet
Events.OnTick.Add(CheckKeyHelmet)
print("Added CheckKeyHelmet to Events.OnTick")

-- Añadir la función al evento OnFillInventoryObjectContextMenu
Events.OnFillInventoryObjectContextMenu.Add(HelmetOfDead_ContextMenu)
print("Added HelmetOfDead_ContextMenu to OnFillInventoryObjectContextMenu")
