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
local Ui_Tab = {};
local Cache = {
    AutoFarm = {},
    Miscellaneous = {},
    Boolean = {}
}

local KangFindNearest = function(Object, Path)
    local ObjectName = tostring(Object);
    local ObjectNearest;
    local NearestList = {};
    for i,v in pairs(Path:GetChildren()) do
        if string.match(v.Name, ObjectName) and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid").Health > 0 then
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
Cache.AutoFarm.TweenSpeed = 75
Cache.AutoFarm.Distance = 3
local DataOfTween

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

local KangTween = function(Object)
    pcall(function()
        if DataOfTween then
            DataOfTween:Destroy()
        end
        DataOfTween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Object.Position).magnitude/Cache.AutoFarm.TweenSpeed,
        Enum.EasingStyle.Linear),
    {CFrame = CFrame.new(Object.Position + Vector3.new(0, Cache.AutoFarm.Distance, 0), Object.Position)})
    DataOfTween:Play()
    end)
end

local GetQuest = function(Args, QuestName)
    repeat
        wait()
    until CheckPath(game.Workspace, "Quests", game.Players.LocalPlayer.Name)
    local Path = game:GetService("Workspace").Quests[game.Players.LocalPlayer.Name]
    if #Path:GetChildren() == 0 then
        game:GetService("ReplicatedStorage").Remotes.Quest.AcceptQuest:FireServer(Args, "Quest")
    else
        local Quest = Path:GetChildren()[1];
        if not string.match(string.lower(Quest.Name), string.lower(QuestName)) then
            game:GetService("ReplicatedStorage").Remotes.Quest.CancelQuest:FireServer("CancelQuestScript")
        end
        if Quest:FindFirstChild("AmountKilled") and Quest:FindFirstChild("AmountNeeded") and Quest.AmountKilled.Value == Quest.AmountNeeded.Value then
            game:GetService("ReplicatedStorage").Remotes.Quest.CompleteQuest:FireServer(Args, "Quest")
        end
    end
    return true
end


local Flux = loadstring(game:HttpGet"https://raw.githubusercontent.com/KangKung02/KryptonHub/main/script/non-obfuscate/CoreUI.lua")();
local win = Flux:Window("Krypton Free", "                  version : "..Global_V.Version_script, Color3.fromRGB(33, 30, 207), Enum.KeyCode.RightControl)

Ui_Tab["AutoFarm"] = win:Tab("Auto Farm", "http://www.roblox.com/asset/?id=6756586445")
Ui_Tab["AutoFarm"]:Line()
Ui_Tab["AutoFarm"]:Label("⭐ Auto Farm & Auto Quest ⭐")
Ui_Tab["AutoFarm"]:Line()

Ui_Tab["AutoFarm"]:Slider("Tween Speed", "", 0, 10000, 150,function(Slider)
    Cache.AutoFarm.TweenSpeed = tonumber(Slider)
end)

Ui_Tab["AutoFarm"]:Slider("Distance", "", -20, 20, 8,function(Slider)
    Cache.AutoFarm.Distance = tonumber(Slider)
end)

Ui_Tab["AutoFarm"]:Toggle("No Clip", "" , false, function(Value)
    Cache.Boolean.NoClip = Value
end)

game:GetService("RunService").Stepped:Connect(function()
    if Cache.Boolean.NoClip and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
    end
end)


Ui_Tab["AutoFarm"]:Dropdown("Select Monter Type Villain", 
{
    "Criminal",
    "Weak Villain",
    "Villain",
    "Weak Nomu",
    "High End",
    "Tomura",
    "Dabi",
    "Muscular",
    "Noumu",
    "Overhaul",
    "Gigantomachia",
    "AllForOne",
    "Awakened Tomura"
}
, function(Value)
    Cache.AutoFarm.SelectMonter = tostring(Value)
end)

Ui_Tab["AutoFarm"]:Dropdown("Select Monter Type Hero", 
{
    "Police",
    "UA Student",
    "Hero",
    "Pro Hero",
    "Forest Beast",
    "Present Mic",
    "Midnigth",
    "Gang Orca",
    "Mount Lady",
    "Endeavor",
    "Hawks",
    "All Migth",
    "Deku"
}
, function(Value)
    Cache.AutoFarm.SelectMonter = tostring(Value)
end)

Ui_Tab["AutoFarm"]:Toggle("Auto Farm", "" , false, function(Value)
    Cache.Boolean.AutoFarm = Value
end)

spawn(function()
    while wait() do
        if Cache.Boolean.AutoFarm then
            pcall(function()
                if Cache.AutoFarm.SelectMonter == "Criminal" and GetQuest("Injured Man", "Criminal") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Police" and GetQuest("Gang Member", "Police") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Weak Villain" and GetQuest("Aizawa", "Weak Villain") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "UA Student" and GetQuest("Suspicious Character", "UA Student") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Hero" and GetQuest("Super Villain", "Hero") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Villain" and GetQuest("Pro Hero", "Villain") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Forest Beast" and GetQuest("Twice", "Forest Beast") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Weak Nomu" and GetQuest("Best Jeanist", "Weak Nomu") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "High End" and GetQuest("Mirko", "High End") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Pro Hero" and GetQuest("Toga", "Pro Hero") then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter then
                    KangTween(KangFindNearest(Cache.AutoFarm.SelectMonter, game.Workspace.NPCs).HumanoidRootPart)
                end
            end)
        end
    end
end)

Ui_Tab["AutoAttack"] = win:Tab("Auto Attack", "http://www.roblox.com/asset/?id=6756586445")
Ui_Tab["AutoAttack"]:Line()
Ui_Tab["AutoAttack"]:Label("⭐ Auto Attack & Auto Skill ⭐")
Ui_Tab["AutoAttack"]:Line()
Cache.Boolean.AutoAttack = {}

Ui_Tab["AutoAttack"]:Toggle("Auto Attack", "" , false, function(Value)
    Cache.Boolean.AutoAttack["Auto Attack"] = Value
end)

spawn(function()
    while wait(0.1) do
        if Cache.Boolean.AutoAttack["Auto Attack"] then
            pcall(function()
                game:GetService("Players").LocalPlayer.Character.Main.Swing:FireServer(game.Players.LocalPlayer:GetMouse().Hit)
            end)
        end
    end
end)

local CreateAutoAttack = function(Text, Key)
    Ui_Tab["AutoAttack"]:Toggle(Text, "" , false, function(Value)
        Cache.Boolean.AutoAttack[Text] = Value
    end)

    spawn(function()
        while wait(0.1) do
            if Cache.Boolean.AutoAttack[Text] then
                pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Key, false, game)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Key, false, game)
                end)
            end
        end
    end)
end

CreateAutoAttack("Auto Skill Q", "Q")
CreateAutoAttack("Auto Skill E", "E")
CreateAutoAttack("Auto Skill Z", "Z")
CreateAutoAttack("Auto Skill X", "X")
CreateAutoAttack("Auto Skill C", "C")
CreateAutoAttack("Auto Skill V", "V")
CreateAutoAttack("Auto Skill F", "F")
CreateAutoAttack("Auto Skill B", "B")

Ui_Tab["Miscellaneous"] = win:Tab("Miscellaneous", "http://www.roblox.com/asset/?id=6756586445")
Ui_Tab["Miscellaneous"]:Line()
Ui_Tab["Miscellaneous"]:Label("⭐ Miscellaneous ⭐")
Ui_Tab["Miscellaneous"]:Line()

Ui_Tab["Miscellaneous"]:Toggle("Anti AFK", "" , false, function(Value)
    Cache.Boolean.AntiAFK = Value
end)

spawn(function()
    while wait() do
        if Cache.Boolean.AntiAFK then
            pcall(function()
                if game.Players.LocalPlayer.PlayerGui.SaveGui.AntiAutoClick.Visible then
                    local Color = function()
                        local Content = game.Players.LocalPlayer.PlayerGui.SaveGui.AntiAutoClick.TextFrame.ColorIndicator.Text
                        if string.find(Content, "Red") then
                            return "R";
                        elseif string.find(Content, "Orange") then
                            return "O";
                        elseif string.find(Content, "Yellow") then
                            return "Y";
                        elseif string.find(Content, "Green") then
                            return "G";
                        elseif string.find(Content, "Blue") then
                            return "B";
                        end
                    end
                    for _, v in pairs(game.Players.LocalPlayer.PlayerGui.SaveGui.AntiAutoClick.Colors:GetChildren()) do
                        if v:FindFirstChild("Button") and v.Button.Text == Color() then
                            firesignal(v.Button.MouseButton1Click)
                        end
                    end
                end
            end)
        end
    end
end)

Ui_Tab["Miscellaneous"]:Label("⭐ Auto Stats ⭐")
Ui_Tab["Miscellaneous"]:Line()

Cache.Miscellaneous.AutoStatsAmount = 1
Ui_Tab["Miscellaneous"]:Textbox("Amount", "", false, function(Text)
    xpcall(function()
        Cache.Miscellaneous.AutoStatsAmount = tonumber(Text) + 0
    end, function()
        Cache.Miscellaneous.AutoStatsAmount = 1
    end)
end)

Cache.Boolean.AutoStats = {};
local CreateAutoStats = function(Text)
    Ui_Tab["Miscellaneous"]:Toggle("Auto Stats : " .. Text, "" , false, function(Value)
        Cache.Boolean.AutoStats[Text] = Value
    end)

    spawn(function()
        while wait(0.1) do
            if Cache.Boolean.AutoStats[Text] then
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes[Text]:FireServer(Cache.Miscellaneous.AutoStatsAmount)
                end)
            end
        end
    end)
end

CreateAutoStats("Strength")
CreateAutoStats("Agility")
CreateAutoStats("Durability")

Ui_Tab["Miscellaneous"]:Line()
Ui_Tab["Miscellaneous"]:Label("⭐ Auto Random Quirk ⭐")


Cache.Miscellaneous.QuirkSlot = {}
local ListQuirk;
local ListShowQuirk = {};
pcall(function()
    ListQuirk = require(game:GetService("ReplicatedStorage").BeingReplacedModules.QuirkData).Quirks
    for _, v in pairs(ListQuirk) do
        if v.name then
            table.insert(ListShowQuirk, v.name)
        end
    end
end)

Ui_Tab["Miscellaneous"]:Dropdown("Select Quirk 1", ListShowQuirk, function(DropDown)
    for Index = 1, #ListQuirk do
        if ListQuirk[Index].name == tostring(DropDown) then
            Cache.Miscellaneous.QuirkSlot[1] = ListQuirk[Index].num
            break
        end
    end
end)
Ui_Tab["Miscellaneous"]:Dropdown("Select Quirk 2", ListShowQuirk, function(DropDown)
    for Index = 1, #ListQuirk do
        if ListQuirk[Index].name == tostring(DropDown) then
            Cache.Miscellaneous.QuirkSlot[2] = ListQuirk[Index].num
            break
        end
    end
end)
Ui_Tab["Miscellaneous"]:Dropdown("Select Quirk 3", ListShowQuirk, function(DropDown)
    for Index = 1, #ListQuirk do
        if ListQuirk[Index].name == tostring(DropDown) then
            Cache.Miscellaneous.QuirkSlot[3] = ListQuirk[Index].num
            break
        end
    end
end)

Ui_Tab["Miscellaneous"]:Toggle("Start Random", "" , false, function(Value)
    Cache.Boolean.StartRandom = Value
end)

spawn(function()
    while wait(0.1) do
        pcall(function()
            if Cache.Boolean.StartRandom and game:GetService("Workspace").S1c2R5i66p5t5s51.PlayerData[game.Players.LocalPlayer.Name].Cash.Value >= 5000 and not table.find(Cache.Miscellaneous.QuirkSlot, game:GetService("Workspace").S1c2R5i66p5t5s51.PlayerData[game.Players.LocalPlayer.Name].Quirk.Value) then
                game.Workspace.S1c2R5i66p5t5s51.Spin.Spinner:InvokeServer("Commons")
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