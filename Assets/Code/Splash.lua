-- Загрузка музыки
Wav.load("Assets/Audio/mus_intronoise.wav", 0)
Wav.load("Assets/Audio/mus_menu0.wav", 1)

-- Загрузка необходимых изображений
local logo = Image.load("Assets/Sprites/Splash/Logo.png") -- Логотип игры размером 269x27
local tip = Image.load("Assets/Sprites/Splash/Tip.png") -- Подсказка размером 198x10
local controls = Image.load("Assets/Sprites/Splash/Controls.png") -- Экран управления размером 340x226
local fadeSprite = Image.load("Assets/Sprites/Splash/WhiteFade.png") -- Белый спрайт на весь экран для fade-эффекта

local screen_width, screen_height = 480, 272 -- Фиксированные размеры экрана
local logoWidth, logoHeight = 270, 26
local tipWidth, tipHeight = 136, 10
local controlsWidth, controlsHeight = 210, 170

local centerX = (screen_width - logoWidth) / 2
local centerY = (screen_height - logoHeight) / 2
local logoY = centerY - 30 -- Немного выше центра для визуального комфорта
local controlsX = (screen_width - controlsWidth) / 2
local controlsY = centerY - (controlsHeight / 2) + 20 -- Чуть ниже центра, чтобы освободить место для подсказки под логотипом

local tipX = (screen_width - tipWidth) / 2
local tipY = logoY + logoHeight + 20 -- Под логотипом

local showControls = false -- Сначала отображается только логотип
local startFading = false -- Флаг для начала fade-эффекта
local fadeAlpha = 0 -- Прозрачность белого спрайта
local fadeSpeed = 1 -- Скорость увеличения прозрачности

-- Таймер для отслеживания времени
local timer = Timer.new()
timer:start()
local autoTransitionTimer = 0

Wav.play(false, 0)

-- Основной цикл программы
while true do
    -- Очистка экрана перед каждой отрисовкой
    screen:clear()

    -- Проверка состояния кнопок
    local pad = Controls.read()

    -- Отображаем логотип и подсказку
    if not showControls and not startFading then
        screen:blit(centerX, logoY, logo)
        screen:blit(tipX, tipY, tip)
    end

    -- При нажатии START показываем экран управления
    if pad:start() and not showControls then
	    Wav.stop(0)
		Wav.play(true, 1)
        showControls = true
    end

    -- Отображаем экран управления
    if showControls and not startFading then
        screen:blit(controlsX, controlsY, controls)
        -- Отображаем невидимый спрайт fade
        screen:blit(0, 0, fadeSprite, 0)
    end

    -- Когда на экране управления нажата кнопка CROSS, начинаем fade-эффект
    if pad:cross() and showControls then
	    Wav.stop(1)
        startFading = true
    end

    -- Применяем fade-эффект с использованием белого спрайта
    if startFading then
	    screen:blit(controlsX, controlsY, controls)
        fadeAlpha = fadeAlpha + fadeSpeed
        if fadeAlpha > 255 then fadeAlpha = 255 end

        -- Отображаем белый спрайт на весь экран с текущей прозрачностью
        screen:blit(0, 0, fadeSprite, fadeAlpha)

        -- После достижения полной непрозрачности
        if fadeAlpha == 255 then
		    Wav.unload(0)
			Wav.unload(1)
            dofile("Assets/Code/Overworld.lua")
        end
    end

    -- Обновление экрана
    screen.flip()
end