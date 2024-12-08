local player = {
    x = 0,
    y = 0,
    direction = "down",
    frame = 0,
    frameTimer = 0,
    frameSpeed = 0.1,
    speed = 1.5
}

local upSprites = {}
local downSprites = {}
local leftSprites = {}
local rightSprites = {}

local function loadSprites(direction, maxFrame)
    local sprites = {}
    for i = 0, maxFrame do
        local path = string.format("Assets/Sprites/Character/spr_f_mainchara%s_%d.png", direction, i)
        local sprite = Image.load(path)
        if sprite then
            sprites[i] = sprite
        else
            break
        end
    end
    return sprites
end

upSprites = loadSprites("u", 3)
downSprites = loadSprites("d", 3)
leftSprites = loadSprites("l", 1)
rightSprites = loadSprites("r", 1)

local function updateFrame(player)
    player.frameTimer = 0
    if player.direction == "up" or player.direction == "down" then
        player.frame = (player.frame + 1) % (#upSprites + 1)
    elseif player.direction == "left" or player.direction == "right" then
        player.frame = (player.frame + 1) % (#leftSprites + 1)
    end
end

local function updatePlayer(pad, currentRoom, camera, crossPressedLastFrame, checkCollisions)
    local moving = false
    local dx, dy = 0, 0  -- Delta for X and Y movement

    -- Input handling using buttons
    if buttons.held(buttons.up) then
        dy = dy - player.speed
        player.direction = "up"
        moving = true
    end
    if buttons.held(buttons.down) then
        dy = dy + player.speed
        player.direction = "down"
        moving = true
    end
    if buttons.held(buttons.left) then
        dx = dx - player.speed
        if dy == 0 then  -- Set direction to "left" if no vertical movement
            player.direction = "left"
        end
        moving = true
    end
    if buttons.held(buttons.right) then
        dx = dx + player.speed
        if dy == 0 then  -- Set direction to "right" if no vertical movement
            player.direction = "right"
        end
        moving = true
    end

    -- Update player's position with collision check
    local newX = player.x + dx
    local newY = player.y + dy
    if not checkCollisions(newX, player.y + dy) then
        player.x = newX
    end
    if not checkCollisions(player.x, newY) then
        player.y = newY
    end

    -- Update animation frames
    if moving then
        player.frameTimer = player.frameTimer + player.frameSpeed
        if player.frameTimer >= 1 then
            updateFrame(player)
        end
    else
        player.frame = 0  -- Stop animation if not moving
    end

    -- Update camera position to follow player
    camera.x = math.max(0, math.min(player.x - camera.w / 2, currentRoom.size.w - camera.w))
    camera.y = math.max(0, math.min(player.y - camera.h / 2, currentRoom.size.h - camera.h))

    return crossPressedLastFrame
end

local function renderPlayer(camera)
    -- Select sprite based on direction and frame
    local sprite
    if player.direction == "up" then
        sprite = upSprites[player.frame] or upSprites[0]
    elseif player.direction == "down" then
        sprite = downSprites[player.frame] or downSprites[0]
    elseif player.direction == "left" then
        sprite = leftSprites[player.frame] or leftSprites[0]
    elseif player.direction == "right" then
        sprite = rightSprites[player.frame] or rightSprites[0]
    end

    -- Draw the player sprite
    if sprite then
        Image.draw(sprite, player.x - 10 - camera.x, player.y - 30 - camera.y)
    end
end

return {
    player = player,
    updatePlayer = updatePlayer,
    renderPlayer = renderPlayer
}