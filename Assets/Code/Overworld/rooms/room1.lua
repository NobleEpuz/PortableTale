local room1 = {
    backgrounds = {
        {image = Image.load("Assets/Rooms/bg_firstroom_1.png"), x = 0, y = 0},
        {image = Image.load("Assets/Rooms/bg_firstroom_2.png"), x = 480, y = 0}
    },
    spawn = {x = 240, y = 136},
    transitions = {
        {x = 607, y = 145, w = 40, h = 20, targetRoom = "room2", targetSpawn = {x = 240, y = 136}}
    },
    collisions = {
        {x = 70, y = 75, w = 183, h = 16},
        {x = 17, y = 109, w = 16, h = 100},
        {x = 92, y = 267, w = 140, h = 18},
        {x = 32, y = 208, w = 20, h = 22},
        {x = 54, y = 230, w = 16, h = 20},
        {x = 31, y = 92, w = 41, h = 18},
        {x = 71, y = 249, w = 22, h = 20},
        {x = 230, y = 247, w = 20, h = 20},
        {x = 249, y = 227, w = 421, h = 20},
        {x = 249, y = 91, w = 42, h = 20},
        {x = 288, y = 109, w = 19, h = 81},
        {x = 306, y = 172, w = 300, h = 18},
        {x = 670, y = 172, w = 16, h = 64},
        {x = 649, y = 172, w = 24, h = 16}
    },
    npcs = {
        {
            x = 300, y = 160,
            dialogues = {"* Hello, I'm an NPC\nin Room 1!\nWhat the hell?", "* Nice to meet you!", "* Goodbye!"},
            currentDialogueIndex = 1,
            sprite = Image.load("Assets/Sprites/Overworld/test.png"),
            voiceSoundID = 0,
            avatar = {Image.load("Assets/Sprites/Overworld/avatar1_1.png"), Image.load("Assets/Sprites/Overworld/avatar1_2.png")},
            showAvatar = true
        },
        {
            x = 350, y = 160,
            dialogues = {"* Another NPC here!\n* Fu blyat", "* How's it going?", "* See you later!"},
            currentDialogueIndex = 1,
            sprite = Image.load("Assets/Sprites/Overworld/test.png"),
            voiceSoundID = 0,
            avatar = {Image.load("Assets/Sprites/Overworld/avatar2.png")},
            showAvatar = false
        },
    },
    size = {w = 680, h = 260}
}

return room1
