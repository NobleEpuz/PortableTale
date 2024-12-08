local room2 = {
    backgrounds = {
        {image = Image.load("Assets/Rooms/room1.png"), x = 25, y = 17}
    },
    spawn = {x = 240, y = 136},
    transitions = {
        {x = 216, y = 85, w = 40, h = 20, targetRoom = "room1", targetSpawn = {x = 600, y = 190}}
    },
    collisions = {
        {x = 95, y = 100, w = 280, h = 16},
        {x = 95, y = 110, w = 16, h = 100},
        {x = 370, y = 100, w = 16, h = 140},
        {x = 100, y = 200, w = 32, h = 32},
        {x = 116, y = 224, w = 32, h = 32},
        {x = 132, y = 240, w = 32, h = 48},
        {x = 132, y = 260, w = 80, h = 32},
    },
    npcs = {
        {
            x = 150, y = 100,
            dialogues = {"* Hello, I'm an NPC\nin Room 2!", "* Nice to meet you!", "* Goodbye!"},
            currentDialogueIndex = 1,
            sprite = Image.load("Assets/Sprites/Overworld/test.png"),
            voiceSoundID = 0,
            avatar = {Image.load("Assets/Sprites/Overworld/avatar1_1.png"), Image.load("Assets/Sprites/Overworld/avatar1_2.png")},
            showAvatar = true
        },
    },
    size = {w = 480, h = 272}
}

return room2