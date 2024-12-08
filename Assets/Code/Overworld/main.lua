local dialogue = require("Assets/Code/Overworld/dialogue")
local playerModule = require("Assets/Code/Overworld/player")
local roomsModule = require("Assets/Code/Overworld/rooms")

local font = intraFont.load("Assets/regular.pgf") -- Загрузка шрифта для отображения информации

local player = playerModule.player
local camera = {
    x = 0,
    y = 0,
    w = 480,
    h = 272
}

roomsModule.setRoom(roomsModule.rooms.room1, player, roomsModule.rooms.room1.spawn)

local crossPressedLastFrame = false
local circlePressedLastFrame = false
local debugMode = false
local hitbox = Image.load("Assets/Sprites/Character/hitbox.png")
local hitboxBlock = Image.load("Assets/Sprites/Overworld/HitboxBlock.png")
local hitboxTransition = Image.load("Assets/Sprites/Overworld/HitboxTrans.png")

while true do
    screen.clear()
    buttons.read()

    if not dialogue.isDialogueDisplaying() then
        -- Check and handle transitions
        local newRoom, spawnPosition = roomsModule.checkTransitions(player)
        if newRoom then
            roomsModule.renderTransition(camera, player, playerModule, dialogue, true)
            roomsModule.setRoom(newRoom, player, spawnPosition)
            roomsModule.updateCamera(camera, player)
            roomsModule.renderTransition(camera, player, playerModule, dialogue, false)
        else
            crossPressedLastFrame = playerModule.updatePlayer(buttons, roomsModule.getCurrentRoom(), camera, crossPressedLastFrame, roomsModule.checkCollisions)
        end
    end

    -- Check for interaction with NPCs
    if buttons.pressed(buttons.cross) and not crossPressedLastFrame and not dialogue.isDialogueDisplaying() then
        for _, npc in ipairs(roomsModule.getCurrentRoom().npcs) do
            local distance = math.sqrt((npc.x - player.x) ^ 2 + (npc.y - player.y) ^ 2)
            if distance < 30 then
                dialogue.startDialogue(npc)
                break
            end
        end
    end

    local crossPressed, circlePressed = dialogue.updateDialogue()
    crossPressedLastFrame = crossPressed
    circlePressedLastFrame = circlePressed

    roomsModule.renderRoom(camera)
    playerModule.renderPlayer(camera)
    dialogue.renderDialogue()

    -- Получение информации о свободной ОЗУ в мегабайтах
    local freeRAM = LUA.getRAM() / (1024 * 1024)

    -- Визуализация информации на экране
    local freeRAMText = string.format("Free RAM: %.2f MB", freeRAM)
    intraFont.print(font, 10, 10, freeRAMText)

    local playerPosition = string.format("Player X: %d, Y: %d", player.x, player.y)
    intraFont.print(font, 10, 30, playerPosition)

    if debugMode then
        Image.draw(hitbox, player.x - 10 - camera.x, player.y - 14 - camera.y)
        for _, box in ipairs(roomsModule.getCurrentRoom().collisions) do
            Image.draw(hitboxBlock, box.x - 10 - camera.x, box.y - 30 - camera.y)
        end
        for _, transition in ipairs(roomsModule.getCurrentRoom().transitions) do
            Image.draw(hitboxTransition, transition.x - 10 - camera.x, transition.y - 30 - camera.y)
        end
    end

    screen.flip()
end
