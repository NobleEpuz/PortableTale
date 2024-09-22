-- Загрузка звуков
Wav.load("Assets/Audio/snd_type.wav", 0)

-- Загрузка спрайтов для направлений и кадров
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

local hitbox = Image.load("Assets/Sprites/Character/hitbox.png")
local hitboxBlock = Image.load("Assets/Sprites/Overworld/HitboxBlock.png")
local debugMode = true  -- Включение режима отладки

local rooms = {
    room1 = {
        background = Image.load("Assets/Rooms/room1.png"),
        spawn = {x = 240, y = 136},
        backgroundOffset = {x = 25, y = 17},
        collisions = {
            {x = 100, y = 117, w = 280, h = 16},
        },
        npcs = {
            {
                x = 300, y = 150, 
                dialogues = {"* Hello, I'm an NPC in Room 1!", "* Nice to meet you!", "* Goodbye!"},
                currentDialogueIndex = 1,
                sprite = Image.load("Assets/Sprites/Overworld/test.png"),
                voiceSoundID = 0 -- ID канала звука для этого NPC (например, звук на канале 1)
            },
            {
                x = 350, y = 160, 
                dialogues = {"* Another NPC here!", "* How's it going?", "* See you later!"},
                currentDialogueIndex = 1,
                sprite = Image.load("Assets/Sprites/Overworld/test.png"),
                voiceSoundID = 0 -- ID канала звука для этого NPC (например, звук на канале 2)
            },
        },
        size = {w = 480, h = 272}
    },
}

local currentRoom = rooms.room1

local function setRoom(room)
    currentRoom = room
    player.x = currentRoom.spawn.x
    player.y = currentRoom.spawn.y
end

local camera = {
    x = 0,
    y = 0,
    w = 480,
    h = 272
}

local player = {
    x = currentRoom.spawn.x,
    y = currentRoom.spawn.y,
    direction = "down",
    frame = 0,
    frameTimer = 0,
    frameSpeed = 0.1,
    speed = 1
}

local upSprites = loadSprites("u", 3)
local downSprites = loadSprites("d", 3)
local leftSprites = loadSprites("l", 1)
local rightSprites = loadSprites("r", 1)

local dialogueFrame = Image.load("Assets/Sprites/Overworld/textbox.png")

-- Символы, которые распознает система
local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789.,'\"_+-=?/!$&()#%*:;<>[]\\^"

-- Таблица для хранения спрайтов символов
local lettersSprites = {}

-- Предполагается, что файлы спрайтов символов находятся в папке Assets/Sprites/Symbols и имеют имена в формате "1.png", "2.png" и т.д., соответственно порядку символов в строке characters
for i = 1, #characters do
    local char = characters:sub(i, i)
    lettersSprites[char] = Image.load("Assets/Sprites/Symbols/" .. i .. ".png")
end

-- Функция для рендеринга строк текста на экран, используя загруженные спрайты
function drawText(text, x, y, printedCharsPerLine)
    local CHARACTER_WIDTH = 8 -- Примерное значение ширины одного символа
    local CHARACTER_HEIGHT = 16 -- Примерное значение высоты одного символа
    local lineHeight = CHARACTER_HEIGHT -- Высота строки
    local charsToShow = printedCharsPerLine or #text
    local startX = x

    for i = 1, charsToShow do
        local char = text:sub(i, i)
        
        if char == "\n" then
            y = y + lineHeight
            x = startX
        else
            local sprite = lettersSprites[char]
            if sprite then
                screen:blit(x, y, sprite)
                x = x + CHARACTER_WIDTH -- Используем фиксированную ширину для каждого символа
            else
                x = x + 10 -- Пропуск или замена неизвестного символа пробелом фиксированной ширины
            end
        end
    end
end

local dialogueDisplaying = false
local currentDialogue = ""
local printedChars = 0
local typingSpeed = 0.035 -- Интервал времени между печатью символов в секундах
local timeElapsed = 0
local currentNPC = nil -- Переменная для хранения текущего NPC в диалоге

-- Таймер для отслеживания времени
local timer = Timer.new()
timer:start()

-- Collision detection
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

-- Update frame with check
local function updateFrame(player)
    player.frameTimer = 0
    if player.direction == "up" or player.direction == "down" then
        player.frame = (player.frame + 1) % (#upSprites + 1)
    elseif player.direction == "left" or player.direction == "right" then
        player.frame = (player.frame + 1) % (#leftSprites + 1)
    end
end

-- Main loop
local crossPressedLastFrame = false
local circlePressedLastFrame = false

while true do
    -- Clear screen before each render
    screen:clear()
    
    -- Read controls
     local pad = Controls.read()
     local crossPressed = pad:cross()
     local circlePressed = pad:circle()
     
     local moving = false
     local dx, dy = 0, 0  -- Delta for X and Y movement
     
     if dialogueDisplaying then
         -- Если диалог отображается и нажата кнопка "круг", показываем весь текст
         if circlePressed and not circlePressedLastFrame then
             printedChars = #currentDialogue
         end
         
         -- If the dialogue is displayed and cross is pressed, continue the dialogue
         if crossPressed and not crossPressedLastFrame and printedChars >= #currentDialogue then
             if currentNPC.currentDialogueIndex < #currentNPC.dialogues then
                 currentNPC.currentDialogueIndex = currentNPC.currentDialogueIndex + 1
                 currentDialogue = currentNPC.dialogues[currentNPC.currentDialogueIndex]
                 printedChars = 0
                 timer:reset()
                 timer:start()
             else
                 dialogueDisplaying = false
                 currentDialogue = ""
                 printedChars = 0
                 currentNPC.currentDialogueIndex = 1 -- Reset диалогового индекса к первому диалогу
             end
         else
             timeElapsed = timer:time() / 1000 -- Convert milliseconds to seconds
             if timeElapsed > typingSpeed then
                 if printedChars < #currentDialogue then
                     local nextChar = currentDialogue:sub(printedChars + 1, printedChars + 1)
                     if nextChar ~= " " then
                         Wav.stop(currentNPC.voiceSoundID)
                         Wav.play(false, currentNPC.voiceSoundID)
                     end
                     printedChars = math.min(printedChars + 1, #currentDialogue)
                     timer:reset()
                     timer:start()
                 end
             end
         end
     else
         -- Input handling
         if pad:up() then
             dy = dy - player.speed
             player.direction = "up"
             moving = true
         end
         if pad:down() then
             dy = dy + player.speed
             player.direction = "down"
             moving = true
         end
         if pad:left() then
             dx = dx - player.speed
             if dy == 0 then  -- Set direction to "left" if no vertical movement
                 player.direction = "left"
             end
             moving = true
         end
         if pad:right() then
             dx = dx + player.speed
             if dy == 0 then  -- Set direction to "right" if no vertical movement
                 player.direction = "right"
             end
             moving = true
         end
         
        -- Update player's position with collision check
        local newX = player.x + dx
        local newY = player.y + dy
        -- Check horizontal collisions
        if not checkCollisions(newX, player.y + dy) then
            player.x = newX
        end
        -- Check vertical collisions
        if not checkCollisions(player.x, newY) then
            player.y = newY
        end
 
         -- Check for interaction with NPCs
         if crossPressed and not crossPressedLastFrame then
             for _, npc in ipairs(currentRoom.npcs) do
                 local distance = math.sqrt((npc.x - player.x) ^ 2 + (npc.y - player.y) ^ 2)
                 if distance < 30 then -- Check distance to NPC (customize as needed)
                     dialogueDisplaying = true
                     currentNPC = npc
                     currentDialogue = npc.dialogues[npc.currentDialogueIndex]
                     printedChars = 0
                     timer:reset()
                     timer:start()
                     break
                 end
             end
         end
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
     
     -- Draw background with offset
     screen:blit(-camera.x + currentRoom.backgroundOffset.x, -camera.y + currentRoom.backgroundOffset.y, currentRoom.background)
     
     -- Draw NPCs
     for _, npc in ipairs(currentRoom.npcs) do
         if npc.sprite then
             screen:blit(npc.x - camera.x, npc.y - camera.y, npc.sprite)
         end
     end
     
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
     
     -- Draw hitbox under the player sprite in debug mode
     if debugMode then
         screen:blit(player.x - 10 - camera.x, player.y - 14 - camera.y, hitbox)
         -- Draw collision rectangles
         for _, box in ipairs(currentRoom.collisions) do
             screen:blit(box.x - 10 - camera.x, box.y - 30 - camera.y, hitboxBlock, 255, 0, 0, 0, box.w, box.h)
         end
     end
     
     -- Draw the player sprite
     if sprite then
         screen:blit(player.x - 10 - camera.x, player.y - 30 - camera.y, sprite)
     end
     
     -- Display dialogue if needed
     if dialogueDisplaying then
         -- Draw dialogue frame
         screen:blit(90, 188, dialogueFrame)
         -- Draw dialogue text
         drawText(currentDialogue, 102, 200, printedChars)
     end
     
     -- Update screen
     screen.flip()
 
     -- Update the state of the cross and circle buttons
     crossPressedLastFrame = crossPressed
     circlePressedLastFrame = circlePressed
 end
