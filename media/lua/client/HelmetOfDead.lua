local timer = nil

function HelmetOfDead_OnEquip(player, item)
    if item:getType() == "HelmetOfDead" then
        timer = ZombRand(60, 120) -- Tiempo customizable en segundos
        player:Say("El casco empieza a pitar...")
        Events.OnTick.Add(HelmetOfDead_OnTick)
    end
end

function HelmetOfDead_OnTick()
    if timer and timer > 0 then
        timer = timer - 1
        if timer == 0 then
            getPlayer():Say("El casco explota!")
            getPlayer():getBodyDamage():setHealth(0) -- Mata al jugador
            Events.OnTick.Remove(HelmetOfDead_OnTick)
        end
    end
end

function HelmetOfDead_OnUnequip(player, item)
    if item:getType() == "HelmetOfDead" then
        Events.OnTick.Remove(HelmetOfDead_OnTick)
    end
end

Events.OnEquipPrimary.Add(HelmetOfDead_OnEquip)
Events.OnUnequipPrimary.Add(HelmetOfDead_OnUnequip)
