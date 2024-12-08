-- Загрузка необходимых изображений и шрифта
local logo = Image.load("Assets/Sprites/Splash/Logo.png")
local tip = Image.load("Assets/Sprites/Splash/Tip.png")
local controls = Image.load("Assets/Sprites/Splash/Controls.png")

local showControls = false
local startFading = false
local fadeAlpha = 0
local fadeSpeed = 1

local timered = timer.create()
timer.start(timered)

sound.play("Assets/Audio/mus_intronoise.wav", sound.WAV_1, true, true)

while true do
    screen.clear()
    buttons.read()

    -- Отображение логотипа и подсказки
    if not showControls and not startFading then
        Image.draw(logo, 105, 101)
        Image.draw(tip, 172, 147)
    end

    -- При нажатии START показываем экран управления
    if buttons.pressed(buttons.start) and not showControls then
        sound.stop(sound.WAV_1)
        sound.play("Assets/Audio/mus_menu0.wav", sound.WAV_2, true, true)
        showControls = true
    end

    -- Отображение экрана управления
    if showControls and not startFading then
        Image.draw(controls, 135, 60)
    end

    -- Начало fade-эффекта при нажатии CROSS
    if buttons.pressed(buttons.cross) and showControls and not startFading then
        sound.stop(sound.WAV_2)
        startFading = true
    end

    -- Применение fade-эффекта
    if startFading then
        fadeAlpha = math.min(fadeAlpha + fadeSpeed, 255)

        Image.draw(controls, 135, 60)
        screen.drawRect(0, 0, 480, 272, Color.new(255, 255, 255, fadeAlpha))

        if fadeAlpha == 255 then
            dofile("Assets/Code/Overworld/main.lua")
            sound.unload(sound.WAV_1)
            sound.unload(sound.WAV_2)
            break
        end
    end

    screen.flip()
end

timer.stop(timered)
timer.remove(timered)
