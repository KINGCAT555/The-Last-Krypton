setfflag("HumanoidParallelRemoveNoPhysics", "False")
setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
setfflag("CrashPadUploadToBacktraceToBacktraceBaseUrl", "")
setfflag("CrashUploadToBacktracePercentage", "0")
setfflag("CrashUploadToBacktraceBlackholeToken", "")
setfflag("CrashUploadToBacktraceWindowsPlayerToken", "")

do
    local old;
    old = hookmetamethod(game, "__namecall", function(Self, ...)
        if getnamecallmethod() == "Kick" or getnamecallmethod() == "kick" and not checkcaller() then
            return
        end
        return old(Self, ...)
    end)

    spawn(function()
        while wait() do
            pcall(function()
                for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                    if v.ClassName == "Script" and v:FindFirstChild("") then
                        v:Destroy()
                    end
                end
            end)
        end
    end)
end
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
    Autokeyboard = {},
    Miscellaneous = {}
}

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
    "Thief",
    "Buggy pirate",
    "Attacking Noob",
    "Marine",
    "Fishmen",
    "Big Full Body Buso Noob",
    "Luffy"
}, function(Value)
    Cache.AutoFarm.SelectMonter = tostring(Value)
end)

Ui_Tab["AutoFarm"]:Toggle("Auto Farm", "", false, function(Boolean)
    Cache.AutoFarm.StartAutoFarm = Boolean
    Cache.AutoFarm.NoClip = Boolean
end)

game:GetService("RunService").Stepped:Connect(function()
    if Cache.AutoFarm.NoClip and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartAutoFarm and Cache.AutoFarm.SelectWeapon and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Backpack:FindFirstChild(Cache.AutoFarm.SelectWeapon) and not game.Players.LocalPlayer.Character:FindFirstChild(Cache.AutoFarm.SelectWeapon) then
                game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
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

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartAutoFarm then
                for _, v in pairs(game.Workspace.Npcs:GetChildren()) do
                    if string.match(v.Name, Cache.AutoFarm.SelectMonter) and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0) + game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * Cache.AutoFarm.Distance
                    end
                end
            end
        end)
    end
end)

Ui_Tab["AutoFarm"]:Line()
Ui_Tab["AutoFarm"]:Label("⭐ About Auto Quest ⭐")

local GetQuesting = function(QuestName)
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and v:FindFirstChild("Kills") and v:FindFirstChild("Target") then
            local X = string.split(v.ToolTip, "/")
            if tonumber(X[1]) == tonumber(X[2]) then
                v.Parent = game.Players.LocalPlayer.Character
            elseif v.Name == tostring(QuestName) then
                return
            end
        end
    end

    for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v.ClassName == "Tool" and v:FindFirstChild("Kills") and v:FindFirstChild("Target") then
            local X = string.split(v.ToolTip, "/")
            if tonumber(X[1]) == tonumber(X[2]) then
                v:Activate()
            elseif v.Name == tostring(QuestName) then
                return
            end
        end
    end

    local Path
    for i,v in pairs(game.Workspace:GetChildren()) do
        if v:FindFirstChild("Cutlass|Price:7500") or v:FindFirstChild("Bisento|Price:3000000") then
            Path = v
            break
        end
    end
    for i,v in pairs(Path:GetChildren()) do
        if v:FindFirstChild("QuestName") and v.QuestName.Value == tostring(QuestName) then
            for _ = 1, 3 do
                fireclickdetector(v.Head.ClickDetector)
            end
        end
    end
end

Ui_Tab["AutoFarm"]:Dropdown("Select Quest", {"Thief!", "Let them pay back!", "Annoying noobs....", "Sword Master", "The gunner!", "Marines!", "The Strongest..."}, function(DropDown)
    Cache.AutoFarm.SelectQuest = tostring(DropDown)
end)

Ui_Tab["AutoFarm"]:Toggle("Auto Quest", "", false, function(Boolean)
    Cache.AutoFarm.StartQuest = Boolean
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.AutoFarm.StartQuest then
                GetQuesting(Cache.AutoFarm.SelectQuest)
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

CreateTeleport("Starter Island", Vector3.new(-28.9588, -0.793887, 554.087))
CreateTeleport("Orange Town", Vector3.new(-4224.96, 0.78208, 1238.49))
CreateTeleport("Noob Island", Vector3.new(2982.76, -0.548868, 1589.55))
CreateTeleport("Shells Town", Vector3.new(3178, 6, 5960))
CreateTeleport("Foosha Village", Vector3.new(-2366.16, 16.1302, -3908.08))
CreateTeleport("Black Leg Island", Vector3.new(-1398, 46, 5016))
CreateTeleport("Black Market Island", Vector3.new(-4615, 58, 4005))
CreateTeleport("Devil Fruit Seller Island", Vector3.new(2208, 35, -3343))
CreateTeleport("Arlong Park", Vector3.new(-5185, 2, -4500))
CreateTeleport("Jungle Island",Vector3.new(-4680, 19, -2169))

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

Ui_Tab["Miscellaneous"]:Toggle("Auto Collect Chest", "" , false, function(Value)
    Cache.Miscellaneous.AutoCollectChest = Value
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.Miscellaneous.AutoCollectChest then
                for i,v in pairs(game.Workspace:GetDescendants()) do
                    if v.ClassName == "TouchTransmitter" and v.Parent.ClassName == "UnionOperation" then
                        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 0)
                    end
                end
                wait(10)
            end
        end)
    end
end)

Ui_Tab["Miscellaneous"]:Button("Safe Zone","", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(10000, 22000, 5000)
     local Baseplate = Instance.new("Part", game.Workspace)
     Baseplate.Size = Vector3.new(100, 1, 100)
     Baseplate.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,-1, 0)
     Baseplate.Anchored = true
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