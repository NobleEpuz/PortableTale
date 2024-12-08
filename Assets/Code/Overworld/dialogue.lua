local dialogueFrame = Image.load("Assets/Sprites/Overworld/textbox.png")

local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789.,'\"_+-=?/!$&()#%*:;<>[]\\^"

local lettersSprites = {}

for i = 1, #characters do
    local char = characters:sub(i, i)
    lettersSprites[char] = Image.load("Assets/Sprites/Symbols/" .. i .. ".png")
end

function drawText(text, x, y, printedCharsPerLine, showAvatar)
    local CHARACTER_WIDTH = 8
    local CHARACTER_HEIGHT = 16
    local lineHeight = CHARACTER_HEIGHT
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
                Image.draw(sprite, x, y)
                x = x + CHARACTER_WIDTH
            else
                x = x + 10 -- Пропуск неизвестного символа
            end
        end
    end
end

local dialogueDisplaying = false
local currentDialogue = ""
local printedChars = 0
local typingSpeed = 0.035
local timeElapsed = 0
local currentNPC = nil

local dialogueTimer = timer.create()
timer.start(dialogueTimer)

local avatarFrame = 0
local avatarFrameSpeed = 0.2
local avatarTimeElapsed = 0

local crossPressedLastFrame = false
local circlePressedLastFrame = false

function updateDialogue()
    buttons.read()

    local crossPressed = buttons.held(buttons.cross)
    local circlePressed = buttons.held(buttons.circle)

    if dialogueDisplaying then
        if circlePressed and not circlePressedLastFrame then
            printedChars = #currentDialogue
            avatarFrame = 0
        end

        if crossPressed and not crossPressedLastFrame and printedChars >= #currentDialogue then
            if currentNPC.currentDialogueIndex < #currentNPC.dialogues then
                currentNPC.currentDialogueIndex = currentNPC.currentDialogueIndex + 1
                currentDialogue = currentNPC.dialogues[currentNPC.currentDialogueIndex]
                printedChars = 0
                timer.reset(dialogueTimer)
                timer.start(dialogueTimer)
            else
                endDialogue()
            end
        else
            timeElapsed = timer.time(dialogueTimer) / 1000
            if timeElapsed > typingSpeed then
                if printedChars < #currentDialogue then
                    local nextChar = currentDialogue:sub(printedChars + 1, printedChars + 1)
                    if nextChar ~= " " then
                        sound.play("Assets/Audio/snd_type.wav", sound.WAV_2, false, false)
                    end
                    printedChars = math.min(printedChars + 1, #currentDialogue)
                    timer.reset(dialogueTimer)
                    timer.start(dialogueTimer)

                    avatarTimeElapsed = avatarTimeElapsed + timeElapsed
                    if type(currentNPC.avatar) == "table" then
                        if avatarTimeElapsed > avatarFrameSpeed then
                            avatarFrame = (avatarFrame + 1) % #currentNPC.avatar
                            avatarTimeElapsed = 0
                        end
                    end
                end
            end
        end
    end

    crossPressedLastFrame = crossPressed
    circlePressedLastFrame = circlePressed

    return crossPressed, circlePressed
end

function renderDialogue()
    if dialogueDisplaying then
        Image.draw(dialogueFrame, 96, 188)

        if currentNPC.showAvatar and currentNPC.avatar then
            local avatarSprite
            if type(currentNPC.avatar) == "table" then
                avatarSprite = currentNPC.avatar[avatarFrame + 1] or currentNPC.avatar[1]
            else
                avatarSprite = currentNPC.avatar
            end
            Image.draw(avatarSprite, 100, 192)
            drawText(currentDialogue, 164, 200, printedChars, true)
        else
            drawText(currentDialogue, 108, 200, printedChars, false)
        end
    end
end

function isDialogueDisplaying()
    return dialogueDisplaying
end

function endDialogue()
    dialogueDisplaying = false
    currentDialogue = ""
    printedChars = 0
    avatarFrame = 0
    avatarTimeElapsed = 0
    if currentNPC then
        currentNPC.currentDialogueIndex = 1
    end
    currentNPC = nil

    if sound.state(sound.WAV_2).state == "playing" then
        sound.stop(sound.WAV_2)
    end
    if not sound.state(sound.WAV_2).free then
        sound.unload(sound.WAV_2)
    end
end

return {
    updateDialogue = updateDialogue,
    renderDialogue = renderDialogue,
    startDialogue = function(npc)
        dialogueDisplaying = true
        currentNPC = npc
        currentDialogue = npc.dialogues[npc.currentDialogueIndex]
        printedChars = 0
        timer.reset(dialogueTimer)
        timer.start(dialogueTimer)
    end,
    isDialogueDisplaying = isDialogueDisplaying,
    endDialogue = endDialogue
}