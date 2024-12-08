local room1 = require("Assets/Code/Overworld/rooms/room1")
local room2 = require("Assets/Code/Overworld/rooms/room2")

local rooms = {
    room1 = room1,
    room2 = room2
}

local currentRoom = rooms.room1

local function setRoom(room, player, spawnPosition)
    currentRoom = room
    player.x = spawnPosition.x
    player.y = spawnPosition.y
end

local function checkCollisions(newX, newY)
    local hitbox = {x = newX, y = newY + 16, w = 20, h = 14}
    for _, box in ipairs(currentRoom.collisions) do
        if hitbox.x < box.x + box.w and hitbox.x + hitbox.w > box.x and
           hitbox.y < box.y + box.h and hitbox.y + hitbox.h > box.y then
            return true
        end
    end
    return false
end

local function updateCamera(camera, player)
    camera.x = math.max(0, math.min(currentRoom.size.w - camera.w, player.x - math.floor(camera.w / 2)))
    camera.y = math.max(0, math.min(currentRoom.size.h - camera.h, player.y - math.floor(camera.h / 2)))
end

local function checkTransitions(player)
    local hitbox = {x = player.x, y = player.y, w = 20, h = 40}
    for _, transition in ipairs(currentRoom.transitions) do
        if hitbox.x < transition.x + transition.w and hitbox.x + hitbox.w > transition.x and
           hitbox.y < transition.y + transition.h and hitbox.y + hitbox.h > transition.y then
            return rooms[transition.targetRoom], transition.targetSpawn
        end
    end
    return nil, nil
end

local function renderRoom(camera)
    -- Draw each background with its specified offset
    for _, background in ipairs(currentRoom.backgrounds) do
        Image.draw(background.image, -camera.x + background.x, -camera.y + background.y)
    end

    -- Draw NPCs
    for _, npc in ipairs(currentRoom.npcs) do
        if npc.sprite then
            Image.draw(npc.sprite, npc.x - camera.x, npc.y - camera.y)
        end
    end
end

local function renderTransition(camera, player, playerModule, dialogue, fadeIn)
    local alpha = fadeIn and 0 or 255
    local step = fadeIn and 10 or -10
    local transitionTimer = timer.create()
    timer.start(transitionTimer)

    while (fadeIn and alpha < 255) or (not fadeIn and alpha > 0) do
        screen.clear()
        renderRoom(camera)
        playerModule.renderPlayer(camera)
        dialogue.renderDialogue()

        screen.drawRect(0, 0, 480, 272, Color.new(0, 0, 0, alpha))
        screen.flip()
        alpha = alpha + step

        -- Wait for a moment using timer
        local elapsedTime = timer.time(transitionTimer) / 1000  -- convert to seconds
        if elapsedTime > 0.016 then  -- ~60 FPS (16 ms delay between frames)
            timer.reset(transitionTimer)
            timer.start(transitionTimer)
        end
    end

    timer.stop(transitionTimer)
    timer.remove(transitionTimer)
end

return {
    rooms = rooms,
    getCurrentRoom = function()
        return currentRoom
    end,
    setRoom = setRoom,
    checkCollisions = checkCollisions,
    checkTransitions = checkTransitions,
    renderRoom = renderRoom,
    updateCamera = updateCamera,
    renderTransition = renderTransition
}
