local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789.,'\"_+-=?/!$&()#%*:;<>[]\\^"
local lettersSprites = {}

-- Загрузка спрайтов символов
for i = 1, #characters do
    lettersSprites[characters:sub(i, i)] = Image.load("Assets/Sprites/Symbols/" .. i .. ".png")
end

local paragraphs = {
    "Long ago, two races\nruled over Earth:\nHUMANS and MONSTERS.",
    "One day, war broke\nout between the two races.",
    "After a long battle,\nthe humans were\nvictorious.",
    "They sealed the monsters\nunderground with a magic\nspell.",
    "Many years later...",
    "        MT. EBOTT\n        201X",
    "Legends say that those\nwho climb the mountain\nnever return.",
    " ", " ", " ", " ", " "
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
local endTransitionTime, autoTransitionTimer = 0, 0
local fadeSpeed = 10

-- Загрузка картинок для всех параграфов
local pictures = {}
for i = 1, #paragraphs do
    pictures[i] = Image.load("Assets/Sprites/Intro/Page" .. i .. ".png")
end

sound.play("Assets/Audio/mus_story.wav", sound.WAV_1, true, true)
sound.volume(sound.WAV_1, 50)

-- Функция отрисовки текста
local function drawText(text, x, y, printedCharsPerLine)
    local startX = x
    for i = 1, printedCharsPerLine or #text do
        local sprite = lettersSprites[text:sub(i, i)]
        if sprite then
            Image.draw(sprite, x, y)
            x = x + 8
        elseif text:sub(i, i) == "\n" then
            y = y + 16
            x = startX
        else
            x = x + 10
        end
    end
end

-- Основной цикл программы
while true do
    screen.clear()
    buttons.read()

    if buttons.pressed(buttons.cross) then startFading = true end

    local text = paragraphs[currentParagraph]
    if not transitioning and not fadeInNewPage then
        if timer.time(timered) / 1000 > 0.05 then
            if printedChars < #text then
                local nextChar = text:sub(printedChars + 1, printedChars + 1)
                if nextChar ~= " " then sound.play("Assets/Audio/snd_type.wav", sound.WAV_2, false, false) end
            end
            printedChars = math.min(printedChars + 1, #text)
            timer.reset(timered)
            timer.start(timered)
        end
    end

    if printedChars >= #text and not transitioning and not fadeInNewPage then
        fadeAlpha = fadeAlpha > 0 and math.max(fadeAlpha - fadeSpeed, 0) or fadeAlpha
        if fadeAlpha == 0 then
            autoTransitionTimer = autoTransitionTimer + timer.time(timered) / 1000
            if autoTransitionTimer >= 1 then
                currentParagraph = currentParagraph + 1
                printedChars = 0
                fadeInNewPage = true
                fadeAlpha = 0
                autoTransitionTimer = 0
                if currentParagraph > #paragraphs then
                    dofile("Assets/Code/Splash.lua")
                    break
                end
            end
        end
    end

    if fadeInNewPage then
        fadeAlpha = math.min(fadeAlpha + fadeSpeed, 255)
        if fadeAlpha == 255 then
            fadeInNewPage = false
        end
    end

    Image.draw(pictures[currentParagraph], (screen_width - pictureWidth) / 2, imageYOffset, pictureWidth, pictureHeight, nil, 0, 0, pictureWidth, pictureHeight, 0, fadeAlpha)
    if not transitioning then drawText(text, 140, textYOffset, printedChars) end

    if startFading then
        fadeAlphaD = math.min(fadeAlphaD + fadeSpeed, 255)
        screen.drawRect(0, 0, screen_width, screen_height, Color.new(0, 0, 0, fadeAlphaD))
        if fadeAlphaD == 255 then
            dofile("Assets/Code/Splash.lua")
            sound.stop(sound.WAV_1)
            sound.unload(sound.WAV_1)
            sound.unload(sound.WAV_2)
            break
        end
    end

    screen.flip()
end

timer.stop(timered)
timer.remove(timered)