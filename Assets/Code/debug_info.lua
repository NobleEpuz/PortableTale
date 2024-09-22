local ffmp = 0
local freeram = 0
function GetRAM()
    ffmp = ffmp + 1
    if(ffmp > 10) then
        ffmp = 0
        freeram = math.floor(System.getFreeMemory() / 1024 / 10.24) / 100
    end
    return freeram
end

-- Символы, которые распознает система
local debug_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789.,'\"_+-=?/!$&()#%*:;<>[]\\^"

-- Таблица для хранения спрайтов символов
local debug_lettersSprites = {}

-- Предполагается, что файлы спрайтов символов находятся в папке Assets/Sprites/Symbols и имеют имена в формате "1.png", "2.png" и т.д., соответственно порядку символов в строке characters
for i = 1, #debug_characters do
    local char = debug_characters:sub(i, i)
    debug_lettersSprites[char] = Image.load("Assets/Sprites/Symbols/" .. i .. ".png")
end

-- Функция для рендеринга строк текста на экран, используя загруженные спрайты
function drawDebugText(text, x, y)
    local CHARACTER_WIDTH = 8 -- Примерное значение ширины одного символа
    local CHARACTER_HEIGHT = 16 -- Примерное значение высоты одного символа
    local startX = x

    for i = 1, #text do
        local char = text:sub(i, i)
        
        if char == "\n" then
            y = y + CHARACTER_HEIGHT
            x = startX
        else
            local sprite = debug_lettersSprites[char]
            if sprite then
                screen:blit(x, y, sprite)
                x = x + 8 -- Используем фиксированную ширину для каждого символа
            else
                x = x + 10 -- Пропуск или замена неизвестного символа пробелом фиксированной ширины
            end
        end
    end
end

function DrawDebugInfo()
    drawDebugText("Free RAM:" .. GetRAM() .. "Mb", 5, 5)
end
