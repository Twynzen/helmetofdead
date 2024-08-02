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
                        if CheckKeyHelmet() then -- Verificar si el jugador tiene la llave
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
            if not CheckKeyHelmet() then
                player:Say("El casco se ha quitado, explotando!")
                player:getBodyDamage():ReduceGeneralHealth(1000) -- Mata al jugador
                helmetActive = false
                Events.OnTick.Remove(HelmetOfDead_Countdown)
            else
                -- El jugador tiene la llave, por lo que puede quitarse el casco sin morir
                helmetActive = false
                Events.OnTick.Remove(HelmetOfDead_Countdown)
                player:Say("Casco desactivado con éxito")
            end
            return -- Salir de la función para evitar la ejecución adicional
        end

        -- Si el casco está equipado y la cuenta regresiva continúa, procedemos con los "pips"
        if timer == 1150 then
            player:Say("Pip")
        elseif timer <= 900 and timer % 150 == 0 then
            player:Say("Pip Pip")
        elseif timer <= 600 and timer % 50 == 0 then
            player:Say("Pip Pip Pip")
        end

        -- Si el temporizador llega a 0 y el casco sigue equipado, explota
        if timer == 0 then
            player:Say("El casco explota!")
            player:getBodyDamage():ReduceGeneralHealth(1000) -- Mata al jugador
            helmetActive = false
            Events.OnTick.Remove(HelmetOfDead_Countdown)
        end
    end
end

function CheckKeyHelmet()
    local player = getSpecificPlayer(0)
    if player then
        local inventory = player:getInventory()
        if inventory then
            local items = inventory:getItems()
            
            for i = 0, items:size() - 1 do
                local item = items:get(i)
                print(item:getType(), "ITEMS") -- Imprime el tipo de cada ítem en el inventario
                if item:getType() == "HelmetKey" then
                    return true -- La llave fue encontrada
                end
            end
        end
    end
    return false -- La llave no fue encontrada
end



-- Añadir la función al evento OnFillInventoryObjectContextMenu
Events.OnFillInventoryObjectContextMenu.Add(HelmetOfDead_ContextMenu)
print("Added HelmetOfDead_ContextMenu to OnFillInventoryObjectContextMenu")
