setfflag("HumanoidParallelRemoveNoPhysics", "False")
setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
setfflag("CrashPadUploadToBacktraceToBacktraceBaseUrl", "")
setfflag("CrashUploadToBacktracePercentage", "0")
setfflag("CrashUploadToBacktraceBlackholeToken", "")
setfflag("CrashUploadToBacktraceWindowsPlayerToken", "")


game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait()
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local Global_V = {}
pcall(function()
    local req = (syn and syn.request) or request
    local GetDataFormServer = req({
        Url = 'http://kangisloser.xyz/GetData',
        Method = 'POST',
        Headers = {
            ["Content-Type"] = "application/json"
        };
        Body = game:GetService('HttpService'):JSONEncode({
            GameId = tostring(game.PlaceId)
        }),
    })
    local Body = game:GetService("HttpService"):JSONDecode(GetDataFormServer.Body)
    Global_V = {
        Version_script = Body.Version,
        Script_enabled = Body.ScriptEnabled
    }
end)
if not Global_V.Script_enabled then
    return game.Players.LocalPlayer:Kick("Script was disabled.")
end
local Ui_Tab = {
    Cache = {}
};
local Cache = {
    AutoFarm = {},
    AutoStats = {},
    Autokeyboard = {},
    Miscellaneous = {}
};

local GetingQuest = function(QuestArgument)
    if game.Players.LocalPlayer.Quest.Doing.Value == "None" and game.Players.LocalPlayer.Quest.Doing.Value ~= tostring(QuestArgument) then
        game:GetService("ReplicatedStorage").FuncQuest:InvokeServer(tostring(QuestArgument));
        return false
    end
    return true
end

local GetingLevel = function()
    return game.Players.LocalPlayer.PlayerStats.Level.Value;
end
local KangFindNearest = function(Object, Path)
    local ObjectName = tostring(Object);
    local ObjectNearest;
    local NearestList = {};
    if ObjectName == "MarineBoss" then
        Path = game.Workspace
    end
    for i,v in pairs(Path:GetChildren()) do
        if string.find(v.Name, ObjectName) and (#v.Name - #ObjectName) < 14 and not v:FindFirstChild("Stats") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid").Health > 0 then
            table.insert(NearestList, v)
        end
    end
    if NearestList[1] ~= nil then
        ObjectNearest = NearestList[1]
    end
    if ObjectNearest ~= nil then
        for i,v in pairs(NearestList) do
            if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("HumanoidRootPart").Position).magnitude <= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - ObjectNearest:FindFirstChild("HumanoidRootPart").Position).magnitude then
                ObjectNearest = v
            end
        end
    end
    return ObjectNearest
end

local CheckPath = function(Path, ...)
    local Args = {...};
    for _, v in pairs(Args) do
        if Path:FindFirstChild(v) then
            Path = Path[v]
        else
            return false
        end
    end
    return true
end

local Flux = loadstring(game:HttpGet"https://raw.githubusercontent.com/KangKung02/H2O/main/Flux_Ui.lua")();
local win = Flux:Window("Krypton Free", "                  version : "..Global_V.Version_script, Color3.fromRGB(33, 30, 207), Enum.KeyCode.RightControl)

Ui_Tab["AutoFarm"] = win:Tab("Auto Farm", "http://www.roblox.com/asset/?id=6756586445")
Ui_Tab["AutoFarm"]:Line()
Ui_Tab["AutoFarm"]:Label("⭐ About Weapon ⭐")


Ui_Tab["Cache"].SelectWeapon = Ui_Tab["AutoFarm"]:Dropdown("Select Weapon", {""}, function(Value)
    Cache.AutoFarm.SelectWeapon = tostring(Value)
end)

Ui_Tab["AutoFarm"]:Button("Refresh Weapon", "", function()
    Ui_Tab["Cache"].SelectWeapon:Clear();
    for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" then
            Ui_Tab["Cache"].SelectWeapon:Add(v.Name)
        end
    end
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v.ClassName == "Tool" then
            Ui_Tab["Cache"].SelectWeapon:Add(v.Name)
        end
    end
end)

Ui_Tab["AutoFarm"]:Line()
Ui_Tab["AutoFarm"]:Label("⭐ About Auto Farm ⭐")

Cache.AutoFarm.Distance = 8
Ui_Tab["AutoFarm"]:Slider("Distance", "", -20, 20, 8,function(Slider)
    Cache.AutoFarm.Distance = tonumber(Slider)
end)

Ui_Tab["AutoFarm"]:Dropdown("Select Monter", {
    "Bandit",
    "Pirates",
    "BagyPirates",
    "Clown Pirate",
    "BlackCoat Pirate", --Boss
    "Revolutionary Troop",
    "Marines",
    "MarineBoss", -- workspace  --Boss
    "Skilled Chef",
    "Head Chef", -- Boss
    "Fishman",
    "WinterBandit",
    "Eskimo", -- not match lv  --Boss
    "Sky Bandit",
    "SkyBandit Boss",  --Boss
    "Monkey",
    "Monkey King",  --Boss
    "Skeleton",
    "Woman Pirate"
}, function(Value)
    Cache.AutoFarm.SelectMonter = tostring(Value)
end)

Ui_Tab["AutoFarm"]:Toggle("Auto Select", "", false, function(Boolean)
    Cache.AutoFarm.StartAutoSelect = Boolean
end)

Ui_Tab["AutoFarm"]:Toggle("Auto Select Without Boss", "", false, function(Boolean)
    Cache.AutoFarm.StartAutoSelectWithoutBoss = Boolean
end)

Ui_Tab["AutoFarm"]:Toggle("Auto Quest", "", false, function(Boolean)
    Cache.AutoFarm.StartAutoQuest = Boolean
end)

Ui_Tab["AutoFarm"]:Toggle("Auto Farm", "", false, function(Boolean)
    Cache.AutoFarm.StartAutoFarm = Boolean
    Cache.AutoFarm.NoClip = Boolean
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartAutoSelect then
                local VerifyLevel = function(Minimal, Maximal)
                    local Level = GetingLevel();
                    if Level > Minimal - 1 and Level < Maximal - 1 then
                        return true
                    else
                        return false
                    end
                end
                if VerifyLevel(1, 15) then
                    Cache.AutoFarm.SelectMonter = "Bandit";
                elseif VerifyLevel(15, 30) then
                    Cache.AutoFarm.SelectMonter = "Pirates";
                elseif VerifyLevel(30, 60) then
                    Cache.AutoFarm.SelectMonter = "BagyPirates";
                elseif VerifyLevel(60, 100) then
                    Cache.AutoFarm.SelectMonter = "Clown Pirate";
                elseif VerifyLevel(100, 150) then
                    Cache.AutoFarm.SelectMonter = "BlackCoat Pirate";
                elseif VerifyLevel(150, 200) then
                    Cache.AutoFarm.SelectMonter = "Revolutionary Troop";
                elseif VerifyLevel(200, 300) then
                    Cache.AutoFarm.SelectMonter = "Marines";
                elseif VerifyLevel(300, 400) then
                    Cache.AutoFarm.SelectMonter = "MarineBoss";
                elseif VerifyLevel(400, 500) then
                    Cache.AutoFarm.SelectMonter = "Skilled Chef";
                elseif VerifyLevel(500, 600) then
                    Cache.AutoFarm.SelectMonter = "Head Chef";
                elseif VerifyLevel(600, 700) then
                    Cache.AutoFarm.SelectMonter = "Fishman";
                elseif VerifyLevel(700, 800) then
                    Cache.AutoFarm.SelectMonter = "WinterBandit";
                elseif VerifyLevel(800, 850) then
                    Cache.AutoFarm.SelectMonter = "Eskimo";
                elseif VerifyLevel(850, 950) then
                    Cache.AutoFarm.SelectMonter = "Sky Bandit";
                elseif VerifyLevel(950, 1100) then
                    Cache.AutoFarm.SelectMonter = "SkyBandit Boss";
                elseif VerifyLevel(1100, 1200) then
                    Cache.AutoFarm.SelectMonter = "Monkey";
                elseif VerifyLevel(1200, 1400) then
                    Cache.AutoFarm.SelectMonter = "Monkey King";
                 elseif VerifyLevel(1400, 1600) then
                    Cache.AutoFarm.SelectMonter = "Skeleton";
                elseif VerifyLevel(1600, 99999999) then
                    Cache.AutoFarm.SelectMonter = "Woman Pirate";
                end
    
            end
        end)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartAutoSelectWithoutBoss then
                local VerifyLevel = function(Minimal, Maximal)
                    local Level = GetingLevel();
                    if Level > Minimal - 1 and Level < Maximal - 1 then
                        return true
                    else
                        return false
                    end
                end
                if VerifyLevel(1, 15) then
                    Cache.AutoFarm.SelectMonter = "Bandit";
                elseif VerifyLevel(15, 60) then
                    Cache.AutoFarm.SelectMonter = "Pirates";
                elseif VerifyLevel(60, 150) then
                    Cache.AutoFarm.SelectMonter = "Clown Pirate";
                elseif VerifyLevel(150, 200) then
                    Cache.AutoFarm.SelectMonter = "Revolutionary Troop";
                elseif VerifyLevel(200, 400) then
                    Cache.AutoFarm.SelectMonter = "Marines";
                elseif VerifyLevel(400, 600) then
                    Cache.AutoFarm.SelectMonter = "Skilled Chef";
                elseif VerifyLevel(600, 700) then
                    Cache.AutoFarm.SelectMonter = "Fishman";
                elseif VerifyLevel(700, 850) then
                    Cache.AutoFarm.SelectMonter = "WinterBandit";
                elseif VerifyLevel(850, 1100) then
                    Cache.AutoFarm.SelectMonter = "Sky Bandit";
                elseif VerifyLevel(1100, 1400) then
                    Cache.AutoFarm.SelectMonter = "Monkey";
                elseif VerifyLevel(1400, 1600) then
                    Cache.AutoFarm.SelectMonter = "Skeleton";
                elseif VerifyLevel(1600, 99999999) then
                    Cache.AutoFarm.SelectMonter = "Woman Pirate";
                end
            end
        end)
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if Cache.AutoFarm.NoClip and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartAutoFarm then
                if Cache.AutoFarm.StartAutoQuest and GetingQuest(Cache.AutoFarm.SelectMonter) and CheckPath(game.Players.LocalPlayer, "Quest", "Doing") then
                    local MonterRootPart = KangFindNearest(game.Players.LocalPlayer.Quest.Doing.Value, game.Workspace.Lives).HumanoidRootPart;
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =  CFrame.new(MonterRootPart.Position + Vector3.new(0, Cache.AutoFarm.Distance, 0), MonterRootPart.Position)
                elseif not Cache.AutoFarm.StartAutoQuest and CheckPath(game.Players.LocalPlayer, "Quest", "Doing") then
                    local MonterRootPart = KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.Lives).HumanoidRootPart;
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =  CFrame.new(MonterRootPart.Position + Vector3.new(0, Cache.AutoFarm.Distance, 0), MonterRootPart.Position)
                end
            end
        end)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartAutoFarm and Cache.AutoFarm.SelectWeapon and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Backpack:FindFirstChild(Cache.AutoFarm.SelectWeapon) and not game.Players.LocalPlayer.Character:FindFirstChild(Cache.AutoFarm.SelectWeapon) then
                game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
                game.Players.LocalPlayer.Backpack[Cache.AutoFarm.SelectWeapon]:WaitForChild("Handle")
                game.Players.LocalPlayer.Backpack[Cache.AutoFarm.SelectWeapon].Parent = game.Players.LocalPlayer.Character
            end
        end)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartAutoFarm and Cache.AutoFarm.SelectWeapon and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild(Cache.AutoFarm.SelectWeapon) then
                game.Players.LocalPlayer.Character[Cache.AutoFarm.SelectWeapon]:Activate()
            end
        end)
    end
end)

Ui_Tab["AutoStats"] = win:Tab("Auto Stats", "http://www.roblox.com/asset/?id=6756586445")

Cache.AutoStats.AutoStatsAmount = 1
Ui_Tab["AutoStats"]:Textbox("Amount", "", false, function(Text)
    xpcall(function()
        Cache.AutoStats.AutoStatsAmount = tonumber(Text) + 0
    end, function()
        Cache.AutoStats.AutoStatsAmount = 1
    end)
end)

Ui_Tab["AutoStats"]:Toggle("Auto Stat Melee", "", false, function(Boolean)
    Cache.AutoFarm.Melee = Boolean
end)

Ui_Tab["AutoStats"]:Toggle("Auto Stat Sword", "", false, function(Boolean)
    Cache.AutoFarm.Sword = Boolean
end)

Ui_Tab["AutoStats"]:Toggle("Auto Stat Defense", "", false, function(Boolean)
    Cache.AutoFarm.Defense = Boolean
end)

Ui_Tab["AutoStats"]:Toggle("Auto Stat Devil Fruit", "", false, function(Boolean)
    Cache.AutoFarm.DevilFruit = Boolean
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.Melee then
                game:GetService("ReplicatedStorage").okStats:FireServer(Cache.AutoStats.AutoStatsAmount, "1")
            elseif Cache.AutoFarm.Sword then
                game:GetService("ReplicatedStorage").okStats:FireServer(Cache.AutoStats.AutoStatsAmount, "2")
            elseif Cache.AutoFarm.Defense then
                game:GetService("ReplicatedStorage").okStats:FireServer(Cache.AutoStats.AutoStatsAmount, "3")
            elseif Cache.AutoFarm.DevilFruit then
                game:GetService("ReplicatedStorage").okStats:FireServer(Cache.AutoStats.AutoStatsAmount, "4")
            end
        end)
    end
end)

Ui_Tab["Teleport"] = win:Tab("Teleport", "http://www.roblox.com/asset/?id=6756586445")

local CreateTeleport = function(Name, Position)
    Ui_Tab["Teleport"]:Button(Name, "", function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Position)
    end)
end

CreateTeleport("Starter Island", Vector3.new(351, 40, -1777))
CreateTeleport("Judas Island", Vector3.new(-6151, 11, 3752))
CreateTeleport("Rock Island", Vector3.new(-2173, 17, -2559))
CreateTeleport("Colosseum", Vector3.new(-5056, 19, -2273))
CreateTeleport("Justica Island", Vector3.new(-2235, 14, 700))
CreateTeleport("Chef Ship", Vector3.new(1163, 83, -5233))
CreateTeleport("Carnival Island", Vector3.new(1939, 34, 635))
CreateTeleport("Snow Island", Vector3.new(2420, 18, 4524))
CreateTeleport("Fishman Island", Vector3.new(4742, 31, 2288))
CreateTeleport("Banadian Island", Vector3.new(2990, 35, -2921))
CreateTeleport("Sky Island", Vector3.new(-67, 251, 3506))

Ui_Tab["Autokeyboard"] = win:Tab("Auto Keyboard", "http://www.roblox.com/asset/?id=6756586445")

Ui_Tab["Autokeyboard"]:Textbox("Delay", "", false, function(Value)
    xpcall(function()
        Cache.Autokeyboard.DelayOfAutoKeyboard = tonumber(Value) + 0
    end, function()
        Cache.Autokeyboard.DelayOfAutoKeyboard = 0
    end)
end)

Cache.Autokeyboard.KeyboardKey = {}
for i = 1, 10 do
    Ui_Tab["Autokeyboard"]:Textbox("Keyboard Keys :", "", false, function(Value)
        Cache.Autokeyboard.KeyboardKey[i] = string.upper(tostring(Value))
    end)
end

Ui_Tab["Autokeyboard"]:Toggle("Auto Keyboard", "input space for stop." , false, function(Value)
    Cache.Autokeyboard.AutoKeyboardPress = Value
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.Autokeyboard.AutoKeyboardPress then
                wait(Cache.Autokeyboard.DelayOfAutoKeyboard)
                for _, Value in pairs(Cache.Autokeyboard.KeyboardKey) do
                    if Value ~= " " or Value ~= "" then
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Value, false, game)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Value, false, game)                  
                    end
                    wait(0.1)
                end
            end
        end)
    end
end)

Ui_Tab["Miscellaneous"] = win:Tab("Miscellaneous", "http://www.roblox.com/asset/?id=6756586445")

Ui_Tab["Miscellaneous"]:Toggle("Auto Buso Haki", "", false, function(Boolean)
    Cache.Miscellaneous["Auto Buso Haki"] = Boolean
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.Miscellaneous["Auto Buso Haki"] then
                if not game.Players.LocalPlayer.Character:FindFirstChild("Buso") then
                    game:GetService("ReplicatedStorage").Haki:FireServer("Buso")
                end
            end
        end)
    end
end)

Ui_Tab["Credit"] = win:Tab("Credit", "http://www.roblox.com/asset/?id=6756586445")
Ui_Tab["Credit"]:Line()
Ui_Tab["Credit"]:Label("⭐ Credit To Kang Yes Only Kang 😢 ⭐")
Ui_Tab["Credit"]:Label("Made By : Kang Kung#7271")
Ui_Tab["Credit"]:Label("Discord : https://discord.gg/B659FscCBz")
Ui_Tab["Credit"]:Button("Copy","Copy This Link.", function()
    setclipboard("https://discord.gg/B659FscCBz")
    local req = (syn and syn.request) or request
    req({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = game:GetService("HttpService"):JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {
                code = "B659FscCBz"
            },
            nonce = game:GetService("HttpService"):GenerateGUID(false)
        }),
    })
    Flux:Notification("Copy Done!", "Okay!")
end)