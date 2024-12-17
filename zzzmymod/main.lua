local mod = RegisterMod("zzzmymod", 1)

local LIMITLESS_ITEM_ID = Isaac.GetItemIdByName("limitless")
local LIMITLESS_SPEED_INCREASE = 0.1
local forceFieldRadius = 150
local radiusOffset = 0

local game = Game()

function mod:EvaluateCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        local count = player:GetCollectibleNum(LIMITLESS_ITEM_ID)
        player.MoveSpeed = player.MoveSpeed + (count * LIMITLESS_SPEED_INCREASE)
    end
end

-- function mod:Update()
--     if player:GetCollectibleNum(LIMITLESS_ITEM_ID) > 0 then
--         Game():MakeShockwave(player.Position, 0.01, 0.2, 1)
--     end
-- end

function mod:ForceField()
    local playerCount = game:GetNumPlayers()
    local entities = Isaac.GetRoomEntities()
    for playerIndex = 0, playerCount - 1 do
        local player = Isaac.GetPlayer(playerIndex)
        for i = 1, #entities do
            -- Only effect enemies and projectiles
            if not entities[i]:IsActiveEnemy() and entities[i].Type ~= EntityType.ENTITY_PROJECTILE then goto continue end

            local dist = entities[i].Position:Distance(player.Position)

            if dist > forceFieldRadius then goto continue end

            local forceAmount = 1
            if entities[i].Type == EntityType.ENTITY_PROJECTILE then
                local forceFactor = ((dist - radiusOffset + (forceFieldRadius * 0)) / ((forceFieldRadius * 1) - radiusOffset))
                local relativePos = player.Position:__sub(entities[i].Position)
                local angleMult = relativePos:Dot(entities[i].Velocity) /
                    (relativePos:Length() * entities[i].Velocity:Length())
                if angleMult > 0 then
                    forceAmount = (1 / forceFactor * angleMult)
                else
                    forceAmount = 1
                end

                entities[i].Velocity = entities[i].Velocity:__div(forceAmount)
            else
                forceAmount = 1 / ((dist - radiusOffset) / (forceFieldRadius - radiusOffset))
                entities[i].Velocity = entities[i].Velocity:__div(forceAmount)
            end
            ::continue::
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.ForceField)
-- mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.Update)
