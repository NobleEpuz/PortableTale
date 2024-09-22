-- Загрузка музыки
Wav.load("Assets/Audio/mus_story.wav", 0)
Wav.load("Assets/Audio/snd_type.wav", 1)

require("Assets/Code/debug_info")

-- Символы, которые распознает система
local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789.,'\"_+-=?/!$&()#%*:;<>[]\\^"

-- Таблица для хранения спрайтов символов
local lettersSprites = {}

-- Предполагается, что файлы спрайтов символов находятся в папке Assets/Sprites/Symbols и имеют имена в формате "1.png", "2.png" и т.д., соответственно порядку символов в строке characters
for i = 1, #characters do
    local char = characters:sub(i, i)
    lettersSprites[char] = Image.load("Assets/Sprites/Symbols/" .. i .. ".png")
end

-- Размеры изображения
local pictureWidth, pictureHeight = 200, 110 -- Фиксированные размеры картинки

-- Функция для рендеринга строк текста на экран, используя загруженные спрайты
function drawText(text, x, y, printedCharsPerLine)
    DrawDebugInfo()
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

-- Пример параграфов текста
local paragraphs = {
    "Long ago, two races\nruled over Earth:\nHUMANS and MONSTERS.        ",
    "One day, war broke\nout between the two races.        ",
    "After a long battle,\nthe humans were\nvictorious.        ",
    "They sealed the monsters\nunderground with a magic\nspell.        ",
    "Many years later...        ",
    "        MT. EBOTT      \n        201X              ",
    "Legends say that those\nwho climb the mountain\nnever return.           ",
    "                              ",
    "                              ",
    "                              ",
    "                              ",
    "                              "
}

local screen_width, screen_height = 480, 272 -- Фиксированные размеры экрана
local x, y = 140, 10 -- Начальные координаты для текста
local imageY = 35
local textYOffset = imageY + pictureHeight + 25 -- Сдвиг текста вниз на высоту картинки плюс отступ

local currentParagraph = 1
local printedChars = 0
local typingSpeed = 0.05 -- Интервал времени между печатью символов в секундах
local timeElapsed = 0

local fadeAlpha = 255 -- Прозрачность изображения
local fadeSpeed = 10 -- Скорость изменения прозрачности

local autoTransitionDelay = 1 -- Задержка перед авто-переходом к следующему параграфу
local autoTransitionTimer = 0
local transitioning = false -- Флаг для отслеживания процесса перехода
local fadeInNewPage = false -- Флаг для управления прозрачностью новой страницы
local startFading = false -- Флаг для начала черной дымки
local fadeAlphaD = 0 -- Прозрачность дымки

-- Таймер для отслеживания времени
local timer = Timer.new()
timer:start()

-- Загрузка картинок для всех параграфов
local pictures = {}
for i = 1, #paragraphs do
    pictures[i] = Image.load("Assets/Sprites/Intro/Page" .. i .. ".png")
end
local blackFade = Image.load("Assets/Sprites/Splash/BlackFade.png") -- Загрузка черной дымки

Wav.play(false, 0)

-- Основной цикл программы
while true do
    -- Очистка экрана перед каждой отрисовкой
    screen:clear()

    -- Проверка состояния кнопок
    local pad = Controls.read()
    if pad:cross() then
	    Wav.stop(0)
        startFading = true -- Начинаем черную дымку при нажатии на крестик
    end

    -- Рендеринг текущего параграфа текста
    local text = paragraphs[currentParagraph]
    if not transitioning and not fadeInNewPage then
        timeElapsed = timer:time() / 1000 -- Переводим миллисекунды в секунды
        if timeElapsed > typingSpeed then
            -- Проверка, является ли следующий символ пробелом
            if printedChars < #text then
                local nextChar = text:sub(printedChars + 1, printedChars + 1) -- Получаем следующий символ
                if nextChar ~= " " then -- Если это не пробел, воспроизводим звук
                    Wav.stop(1)
                    Wav.play(false, 1)
                end
            end
            
            -- Увеличиваем количество напечатанных символов
            printedChars = math.min(printedChars + 1, #text)
            timer:reset()
            timer:start()
        end
    end

    -- Вычисление координат для центрирования картинки по горизонтали
    local centerX = (screen_width - pictureWidth) / 2

    -- Плавное исчезновение текущего изображения
    if printedChars >= #text and not transitioning and not fadeInNewPage then
        fadeAlpha = math.max(fadeAlpha - fadeSpeed, 0)
        if fadeAlpha == 0 then
            autoTransitionTimer = autoTransitionTimer + timeElapsed
            if autoTransitionTimer >= autoTransitionDelay then
                transitioning = true
                autoTransitionTimer = 0
                currentParagraph = currentParagraph + 1
                printedChars = 0
                fadeInNewPage = true
                if currentParagraph > #paragraphs then
                    -- Переход на другой Lua-скрипт после последнего параграфа
                    Wav.stop(0)
                    dofile("Assets/Code/Splash.lua")
                    break
                end
            end
        end
    end

     -- Плавное появление нового изображения
     if fadeInNewPage then
         fadeAlpha = math.min(fadeAlpha + fadeSpeed, 255)
         if fadeAlpha == 255 then
             fadeInNewPage = false
             transitioning = false
         end
     end
 
     local currentImage = pictures[currentParagraph]
     -- Отрисовка изображения с применением прозрачности
     screen:blit(centerX, imageY, currentImage, fadeAlpha)
 
     -- Рендеринг текста только в период неподконтрольного перехода и появления страницы
     if not fadeInNewPage then
         drawText(text, x, textYOffset, printedChars)
     end
 
     -- Если начато затухание по нажатии крестика, применяем черную дымку
     if startFading then
         fadeAlphaD = fadeAlphaD + fadeSpeed
         if fadeAlphaD > 255 then fadeAlphaD = 255 end
         screen:blit(0, 0, blackFade, fadeAlphaD)
 
         if fadeAlphaD >= 255 then
             dofile("Assets/Code/Splash.lua")
		     Wav.unload(0)
	         Wav.unload(1)
             break
         end
     end
 
     -- Обновление экрана
     screen.flip()
 end