print("CheckClothing.lua loaded")

-- Contador de ticks
local tickCounter = 0

-- Función para detectar la ropa del personaje
function CheckPlayerClothing()
    -- Incrementar el contador de ticks
    tickCounter = tickCounter + 1
    
    -- Solo ejecutar cada 1000 ticks
    if tickCounter >= 1000 then
        -- Resetear el contador
        tickCounter = 0
        
        -- Obtener el jugador
        local player = getPlayer()
        if player then
            print("Player detected: ", tostring(player))
            
            -- Obtener la ropa del jugador
            local clothing = player:getWornItems()
            if clothing then
                print("Clothing items detected")
                -- Iterar sobre las prendas y mostrar en consola
                for i = 0, clothing:size() - 1 do
                    local item = clothing:getItemByIndex(i)
                    if item then
                        print("Clothing item: ", item:getDisplayName(), ", Type: ", item:getType())
                        -- Comprobar si el casco HelmetAsDead está equipado
                        if item:getType() == "HelmetAsDead" then
                            print("HelmetAsDead equipped: ", item:getType())
                            player:Say("El casco HelmetAsDead está equipado.")
                        end
                    end
                end
            else
                print("No clothing items found.")
            end
        else
            print("No se pudo obtener el jugador.")
        end
    end
end

-- Añadir la función al evento OnTick
Events.OnTick.Add(CheckPlayerClothing)
print("Added CheckPlayerClothing to Events.OnTick")
