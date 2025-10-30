--[[
    пофикси скип через кнопку которая  А в xbox
]]

----------------------------------------------------
-- ЗАГРУЗКА АССЕТОВ
----------------------------------------------------
local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789.,'\"_+-=?/!$&()#%*:;<>[]\\^>"
local lettersSprites = {}

-- Загрузка спрайтов символов
for i = 1, #characters do
    lettersSprites[characters:sub(i, i)] = Image.load("Assets/Sprites/Symbols/" .. i .. ".png")
end
local froggitSprite = Image.load("Assets/Sprites/froggit.png")

----------------------------------------------------
-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
----------------------------------------------------
local gameState = "MENU"

----------------------------------------------------
-- ФУНКЦИИ
----------------------------------------------------

-- Функция отрисовки текста
function drawText(text, x, y, printedCharsPerLine)
    local startX = x
    for i = 1, printedCharsPerLine or #text do
        local sprite = lettersSprites[text:sub(i, i)]
        if sprite then Image.draw(sprite, x, y); x = x + 8
        elseif text:sub(i, i) == "\n" then y = y + 16; x = startX
        else x = x + 8 end
    end
end

-- Функция отрисовки рамок
function drawBox(x, y, w, h)
    local c = Color.new(255, 255, 255); local thickness = 2
    screen.drawRect(x, y, w, thickness, c); screen.drawRect(x, y + h - thickness, w, thickness, c)
    screen.drawRect(x, y, thickness, h, c); screen.drawRect(x + w - thickness, y, thickness, h, c)
end

-- Функция запуска полной игры с интро
function runFullGame()
    local paragraphs = {
        "Long ago, two races\nruled over Earth:\nHUMANS and MONSTERS.        ", "One day, war broke\nout between the two races.        ",
        "After a long battle,\nthe humans were\nvictorious.        ", "They sealed the monsters\nunderground with a magic\nspell.        ",
        "Many years later...        ", "        MT. EBOTT      \n        201X              ",
        "Legends say that those\nwho climb the mountain\nnever return.           ", "                              ", "                              ",
        "                              ", "                              ", "                              "
    }

    local screen_width, screen_height = 480, 272
    local pictureWidth, pictureHeight, imageYOffset = 200, 110, 35
    local textYOffset = imageYOffset + pictureHeight + 25

    local currentParagraph = 1
    local printedChars = 0
    local timered = timer.create()
    timer.start(timered)
    local fadeAlpha, fadeAlphaD = 255, 0
    local transitioning, fadeInNewPage, startFading = false, false, false
    local autoTransitionTimer = 0
    local fadeSpeed = 10

    -- Загрузка картинок для всех параграфов
    local pictures = {}
    for i = 1, #paragraphs do pictures[i] = Image.load("Assets/Sprites/Intro/Page" .. i .. ".png") end
    
    sound.play("Assets/Audio/mus_story.wav", sound.WAV_1, true, true)
    sound.volume(sound.WAV_1, 50)

    -- Основной цикл интро
    while true do
        screen.clear(); buttons.read()
        if buttons.pressed(buttons.cross) then startFading = true end
        local text = paragraphs[currentParagraph]
        if not transitioning and not fadeInNewPage then
            if timer.time(timered) / 1000 > 0.05 then
                if printedChars < #text and text:sub(printedChars + 1, printedChars + 1) ~= " " then sound.play("Assets/Audio/snd_type.wav", sound.WAV_2, false, false) end
                printedChars = math.min(printedChars + 1, #text); timer.reset(timered); timer.start(timered)
            end
        end
        if printedChars >= #text and not transitioning and not fadeInNewPage then
            fadeAlpha = fadeAlpha > 0 and math.max(fadeAlpha - fadeSpeed, 0) or fadeAlpha
            if fadeAlpha == 0 then
                autoTransitionTimer = autoTransitionTimer + timer.time(timered) / 1000
                if autoTransitionTimer >= 1 then
                    currentParagraph = currentParagraph + 1
                    printedChars = 0; fadeInNewPage = true; fadeAlpha = 0; autoTransitionTimer = 0
                    if currentParagraph > #paragraphs then dofile("Assets/Code/Splash.lua"); break end
                end
            end
        end
        if fadeInNewPage then fadeAlpha = math.min(fadeAlpha + fadeSpeed, 255); if fadeAlpha == 255 then fadeInNewPage = false end end
        Image.draw(pictures[currentParagraph], (screen_width - pictureWidth) / 2, imageYOffset, pictureWidth, pictureHeight, nil, 0, 0, pictureWidth, pictureHeight, 0, fadeAlpha)
        if not transitioning then drawText(text, 140, textYOffset, printedChars) end
        if startFading then
            fadeAlphaD = math.min(fadeAlphaD + fadeSpeed, 255)
            screen.drawRect(0, 0, screen_width, screen_height, Color.new(0, 0, 0, fadeAlphaD))
            if fadeAlphaD == 255 then
                sound.stop(sound.WAV_1); sound.unload(sound.WAV_1); sound.unload(sound.WAV_2)
                dofile("Assets/Code/Splash.lua"); break
            end
        end
        screen.flip()
    end
    timer.stop(timered); timer.remove(timered)
end


-- Функция запуска тестового режима боя
function startBattle()
    gameState = "BATTLE"

    -- Состояния боя
    local battleState = "PLAYER_TURN"
    
    -- Параметры игрока
    local player = { name = "Uberd1", lv = 1, x = 0, y = 0, speed = 2, hp = 20, maxHp = 20 }

    -- Параметры врага
    local enemy = { name = "Froggit", hp = 30, maxHp = 30, flavorText = "* Froggit hopped close!" }

    -- Параметры меню
    local menuOptions = {"FIGHT", "ACT", "ITEM", "MERCY"}
    local selectedOption = 1; local enemyTurnTimer = 0
    
    -- Параметры шкалы атаки
    local attackBar = { x = 40, y = 160, width = 400, height = 20, cursorPos = 40, cursorSpeed = 5 }
    
    -- Координаты для курсора-сердца
    local menuPositions = { { x = 25, y = 205 }, { x = 135, y = 205 }, { x = 245, y = 205 }, { x = 355, y = 205 } }
    
    -- Параметры боевого поля
    local battleBox = { x = 180, y = 130, width = 120, height = 100 }

    -- Отрисовка шкалы атаки
    local function drawAttackBar() screen.drawRect(attackBar.x, attackBar.y, attackBar.width, attackBar.height, Color.new(255, 255, 255)); screen.drawRect(attackBar.x + attackBar.width/2 - 5, attackBar.y, 10, attackBar.height, Color.new(180, 180, 180)); screen.drawRect(attackBar.cursorPos, attackBar.y - 5, 3, attackBar.height + 10, Color.new(255, 0, 0)) end
    
    -- Отрисовка боевого интерфейса
    local function drawBattleUI()
        drawBox(20, 150, 440, 80); drawText(enemy.flavorText, 40, 165)
        drawBox(20, 230, 440, 40)
        drawText(player.name, 40, 240); drawText("LV " .. player.lv, 130, 240); drawText("HP", 220, 240)
        local hp_percentage = player.hp / player.maxHp
        screen.drawRect(250, 240, 30 * hp_percentage, 16, Color.new(255, 255, 0))
        drawText(player.hp .. " / " .. player.maxHp, 290, 240)
        for i, option in ipairs(menuOptions) do drawText(option, 40 + (i - 1) * 110, 205) end
    end

    -- Главная функция отрисовки боя
    local function drawBattleScreen()
        Image.draw(froggitSprite, 210, 80)
        if battleState == "PLAYER_TURN" then
            drawBattleUI()
            player.x, player.y = menuPositions[selectedOption].x, menuPositions[selectedOption].y
            screen.drawRect(player.x, player.y, 8, 8, Color.new(255, 0, 0))
        elseif battleState == "ENEMY_TURN" then
            drawBox(battleBox.x, battleBox.y, battleBox.width, battleBox.height)
            screen.drawRect(player.x, player.y, 8, 8, Color.new(255, 0, 0))
        elseif battleState == "PLAYER_ATTACK" then
            drawAttackBar(); drawText(enemy.name, 210, 65); drawText("HP " .. player.hp .. " / " .. player.maxHp, 340, 250)
        end
    end

    -- Логика атаки игрока
    local function runPlayerAttack()
        attackBar.cursorPos = attackBar.cursorPos + attackBar.cursorSpeed
        if buttons.pressed(buttons.cross) then
            local damage = 0; local distance = math.abs(attackBar.cursorPos - (attackBar.x + attackBar.width / 2))
            if distance < 8 then damage = 15 elseif distance < 50 then damage = 8 else damage = 2 end
            enemy.hp = enemy.hp - damage; enemy.flavorText = "* You dealt " .. damage .. " damage."
            battleState = "ENEMY_TURN"; player.x, player.y = battleBox.x + battleBox.width/2, battleBox.y + battleBox.height/2; enemyTurnTimer = 180; return
        end
        if attackBar.cursorPos > attackBar.x + attackBar.width then
            enemy.flavorText = "* Miss."; battleState = "ENEMY_TURN"
            player.x, player.y = battleBox.x + battleBox.width/2, battleBox.y + battleBox.height/2; enemyTurnTimer = 180
        end
    end
    
    -- Управление в бою
    local function controlsBattle()
        buttons.read()
        if buttons.pressed(buttons.start) then gameState = "MENU" end
        if battleState == "PLAYER_TURN" then
            if buttons.pressed(buttons.left) then selectedOption = (selectedOption == 1) and 4 or selectedOption - 1 end
            if buttons.pressed(buttons.right) then selectedOption = (selectedOption == 4) and 1 or selectedOption + 1 end
            if buttons.pressed(buttons.cross) then
                if selectedOption == 1 then
                    battleState = "PLAYER_ATTACK"; attackBar.cursorPos = attackBar.x
                else
                    battleState = "ENEMY_TURN"; enemyTurnTimer = 180
                    player.x, player.y = battleBox.x + battleBox.width/2, battleBox.y + battleBox.height/2
                end
            end
        elseif battleState == "PLAYER_ATTACK" then
            runPlayerAttack()
        elseif battleState == "ENEMY_TURN" then
            if buttons.held(buttons.left) and player.x > battleBox.x then player.x = player.x - player.speed end
            if buttons.held(buttons.right) and player.x < (battleBox.x + battleBox.width - 8) then player.x = player.x + player.speed end
            if buttons.held(buttons.up) and player.y > battleBox.y then player.y = player.y - player.speed end
            if buttons.held(buttons.down) and player.y < (battleBox.y + battleBox.height - 8) then player.y = player.y + player.speed end
            enemyTurnTimer = enemyTurnimer - 1
            if enemyTurnTimer <= 0 then
                battleState = "PLAYER_TURN"; enemy.flavorText = "* Froggit is waiting expectantly."
            end
        end
    end
    
    -- Основной цикл боя
    while gameState == "BATTLE" do
        screen.clear(); drawBattleScreen(); controlsBattle(); screen.flip()
    end
end

----------------------------------------------------
-- ГЛАВНЫЙ ЦИКЛ ПРОГРАММЫ
----------------------------------------------------
while true do
    if gameState == "MENU" then
        screen.clear()
        drawText("Press TRIANGLE for Full Game, no broken skip", 100, 120)
        drawText("Press CROSS for Battle Test", 100, 140)
        buttons.read()
        if buttons.pressed(buttons.triangle) then
            runFullGame()
            break 
        end
        if buttons.pressed(buttons.cross) then
            startBattle()
        end
        screen.flip()
    end
end