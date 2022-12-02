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

local Global_V
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
    if Path:FindFirstChild(Object) then
        local ObjectName = tostring(Object);
        local ObjectNearest;
        local NearestList = {};
        for i,v in pairs(Path:GetChildren()) do
            if v.Name == ObjectName and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid").Health > 0 then
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

local CheckLevel = function()
    repeat
        wait()
    until CheckPath(game.Players.LocalPlayer.PlayerGui, "CoreGUI", "Frame", "EXPBAR", "TextLabel")
    return tonumber(string.match(game.Players.LocalPlayer.PlayerGui.CoreGUI.Frame.EXPBAR.TextLabel.Text,"%d+"))
end

local GetingQuest = function(Args1,Args2)
    Args1 = tostring(Args1);
    if not game.Players.LocalPlayer.PlayerGui.Quest.Quest:FindFirstChild(Args1) then
        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game.Workspace:FindFirstChild(Args2).HumanoidRootPart.Position).magnitude >= 25 then
            KangTween(game.Workspace:FindFirstChild(Args2).HumanoidRootPart)
            return false
        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game.Workspace:FindFirstChild(Args2).HumanoidRootPart.Position).magnitude <= 25 then
            fireclickdetector(game.Workspace:FindFirstChild(Args2).ClickDetector)
            return false
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

Ui_Tab["AutoFarm"]:Dropdown("Select Monter", 
{
    "Thug 1-30"
    ,"Brute 30-80"
    ,"Gorilla 80-150"
    ,"Werewolf 150-300"
    ,"Zombie 300-450"
    ,"Vampire 450-650"
    ,"HamonGolem 650-1000"
    ,"Golem King Boss"
    ,"Chief Chimp"
}
    , function(DropDown)
    Cache.AutoFarm.SelectMonter = tostring(DropDown)
end)

Ui_Tab["AutoFarm"]:Toggle("Start Auto Select", "" , false, function(Value)
    Cache.Boolean.StartAutoSelect = Value
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.Boolean.StartAutoSelect then
                if CheckLevel() >= 1  and CheckLevel() <= 9 then
                    Cache.AutoFarm.SelectMonter = "Thug 1-30"
                elseif  CheckLevel() >= 10 and CheckLevel() <= 19 then
                    Cache.AutoFarm.SelectMonter = "Brute 30-80"
                elseif CheckLevel() >= 20 and CheckLevel() <= 29 then
                    Cache.AutoFarm.SelectMonter = "Gorilla 80-150"
                elseif CheckLevel() >= 30 and CheckLevel() <= 44 then
                    Cache.AutoFarm.SelectMonter = "Werewolf 150-300"
                elseif CheckLevel() >= 45 and CheckLevel() <= 59 then
                    Cache.AutoFarm.SelectMonter = "Zombie 300-450"
                elseif CheckLevel() >= 60 and CheckLevel() <= 79 then
                    Cache.AutoFarm.SelectMonter = "Vampire 450-650"
                elseif CheckLevel() >= 80 and CheckLevel() <= 1000 then
                    Cache.AutoFarm.SelectMonter = "HamonGolem 650-1000"
                end
            end
        end)
    end
end)

Ui_Tab["AutoFarm"]:Toggle("Start Auto Farm Monter", "" , false, function(Value)
    Cache.Boolean.StartAutoFarm = Value
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.Boolean.StartAutoFarm then
                if Cache.AutoFarm.SelectMonter == "Thug 1-30" and GetingQuest("ThugQuest","Thug Quest LV. 1 - 30") then
                    KangTween(KangFindNearest("Thug",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Brute 30-80" and GetingQuest("BruteQuest","Brute Quest LV. 30 - 80") then
                    KangTween(KangFindNearest("Brute",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Gorilla 80-150" and GetingQuest("GorillaQuest","🦍😡💢 Quest LV. 80 - 150") then
                    KangTween(KangFindNearest("🦍",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Werewolf 150-300" and GetingQuest("WerewolfQuest","Werewolf Quest LV. 150 - 300 ") then
                    KangTween(KangFindNearest("Werewolf",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Zombie 300-450" and GetingQuest("ZombieQuest","Zombie Quest LV. 300 - 450") then
                    KangTween(KangFindNearest("Zombie",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Vampire 450-650" and GetingQuest("VampireQuest","Vampire Quest LV. 450 - 650") then
                    KangTween(KangFindNearest("Vampire",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "HamonGolem 650-1000" and GetingQuest("GolemQuest","Golem Quest LV. 650 -1000") then
                    KangTween(KangFindNearest("HamonGolem",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Golem King Boss" then
                    KangTween(KangFindNearest("Golem King",game.Workspace).HumanoidRootPart)
                elseif Cache.AutoFarm.SelectMonter == "Chief Chimp" then
                    KangTween(KangFindNearest("Chief Chimp",game.Workspace).HumanoidRootPart)
                end
            end
        end)
    end
end)
Ui_Tab["AutoAttack"] = win:Tab("Auto Attack", "http://www.roblox.com/asset/?id=6756586445")
Ui_Tab["AutoAttack"]:Line()
Ui_Tab["AutoAttack"]:Label("⭐ Auto Attack & Auto Skill ⭐")
Ui_Tab["AutoAttack"]:Line()

Cache.Boolean.AutoSkill = {}

Ui_Tab["AutoAttack"]:Toggle("Auto Summon Stand", "" , false, function(Value)
    Cache.Boolean.AutoSkill["Summon Stand"] = Value
end)

spawn(function()
    while wait() do
        if Cache.Boolean.AutoSkill["Summon Stand"] then
            pcall(function()
                repeat
                    wait()
                until CheckPath(game.Players.LocalPlayer.Character, "Status", "StandOut") and CheckPath(game.Players.LocalPlayer.PlayerGui, "CoreGUI", "Events", "SummonStand") and game.Players.LocalPlayer.Character.Status.StandOut.Value == false
                game.Players.LocalPlayer.PlayerGui.CoreGUI.Events.SummonStand:InvokeServer()
            end)
        end
    end
end)

local CreateAutoSkill = function(Text, Remote)
    Ui_Tab["AutoAttack"]:Toggle("Auto " .. Text, "" , false, function(Value)
        Cache.Boolean.AutoSkill[Text] = Value
    end)

    spawn(function()
        while wait() do
            if Cache.Boolean.AutoSkill[Text] then
                pcall(function()
                    repeat
                        wait()
                    until CheckPath(game.Players.LocalPlayer.Character, "Status", "StandOut") and CheckPath(game.Players.LocalPlayer.PlayerGui, "CoreGUI", "Events", Remote) and CheckPath(game.Players.LocalPlayer.PlayerGui, "CoreGUI", "MoveUsing2") and CheckPath(game.Players.LocalPlayer.PlayerGui, "CoreGUI", "MoveUsing") and game.Players.LocalPlayer.Character.Status.StandOut.Value == true and game.Players.LocalPlayer.PlayerGui.CoreGUI.MoveUsing.Value == false and game.Players.LocalPlayer.PlayerGui.CoreGUI.MoveUsing2.Value == false
                    game.Players.LocalPlayer.PlayerGui.CoreGUI.Events[Remote]:InvokeServer()
                end)
            end
        end
    end)
end

CreateAutoSkill("Attak", "Punch")
CreateAutoSkill("Skill E", "Barrage")
CreateAutoSkill("Skill R", "Heavy")


Ui_Tab["Miscellaneous"] = win:Tab("Miscellaneous", "http://www.roblox.com/asset/?id=6756586445")
Ui_Tab["Miscellaneous"]:Line()
Ui_Tab["Miscellaneous"]:Label("⭐ Miscellaneous ⭐")
Ui_Tab["Miscellaneous"]:Line()

Ui_Tab["Miscellaneous"]:Toggle("Auto Prestige", "" , false, function(Value)
    Cache.Boolean.AutoPrestige = Value
end)

spawn(function()
    pcall(function()
        while wait(1) do
            if shared.AutoPrestige and not _G.StopingAutoFarm then
                if CheckLevel() == 100 then
                    repeat
                        game.Players.LocalPlayer.PlayerGui.CoreGUI.Events.Prestige:InvokeServer()
                        wait(1)
                    until CheckLevel() ~= 100
                end
            end
        end
    end)
end)

Ui_Tab["Miscellaneous"]:Toggle("Auto Farm Item", "" , false, function(Value)
    Cache.Boolean.AutoFarmItem = Value
end)

spawn(function()
    while wait() do
        pcall(function()
            if Cache.Boolean.AutoFarmItem then
                for _, v1 in pairs(game.Workspace:GetChildren()) do
                    if pcall(function() local a = tonumber(v1.Name) + 0; end) then
                        for _, v2 in pairs(v1:GetChildren()) do
                            if v2.ClassName == "Tool" and v2:FindFirstChild("Handle") then
                                local Object = v2.Handle
                                game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart,
                                TweenInfo.new((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Object.Position).magnitude/275,
                                Enum.EasingStyle.Linear),
                                {CFrame = CFrame.new(Object.Position)}):Play()
                            end
                        end
                    end
                end
            end
        end)
    end
end)





Cache.Miscellaneous.AutoStats = {};
local CheckSkillPoint = function()
    repeat
        wait()

    until CheckPath(game.Players.LocalPlayer.PlayerGui, "CoreGUI", "Stats", "Stats", "aSkillPoints")
    return tonumber(string.match(game.Players.LocalPlayer.PlayerGui.CoreGUI.Stats.Stats.aSkillPoints.Text, "%d+"))
end

Ui_Tab["Miscellaneous"]:Textbox("Amount", "", false, function(Text)
    xpcall(function()
        Cache.Miscellaneous.AutoStatsAmount = tonumber(Text) + 0
    end, function()
        Cache.Miscellaneous.AutoStatsAmount = 1
    end)
end)

local CreateAutoStats = function(Stats)
    Ui_Tab["Miscellaneous"]:Toggle("Auto Up " .. Stats, "" , false, function(Value)
        Cache.Miscellaneous.AutoStats[Stats] = Value
    end)

    spawn(function()
        while wait() do
            if Cache.Miscellaneous.AutoStats[Stats] then
                pcall(function()
                    if CheckSkillPoint() > 0 then
                        game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Stats.Stats.Stats:InvokeServer(Stats, Cache.Miscellaneous.AutoStatsAmount)
                    end
                end)
            end
        end
    end)
end

CreateAutoStats("Health")
CreateAutoStats("Strength")
CreateAutoStats("Special")
CreateAutoStats("HTalent")

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
