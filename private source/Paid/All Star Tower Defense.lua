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
repeat
    wait()
until game.Players and game.ReplicatedStorage and game.ReplicatedStorage:FindFirstChild("Lobby") and game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Input")

game.StarterGui:SetCore("SendNotification", {
    Title = "Read Me Pls UWU";
    Text = "LeftControl + K + L\n for stop auto join.";
    Icon = "rbxassetid://6756586445";
    Duration = 10;
})
wait(5)
game:GetService("UserInputService").InputBegan:Connect(function()
    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.K) and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.L) then
        _G.Stopeverything = true
    end
 end)
local Ui_Tab = {};
local Cache = {
    Summon = {},
    Quest = {},
    AutoPlay = {
        MacroMode = "None",
        Pausing = false,
    }
}

local DataFormFile = {};
pcall(function()
    DataFormFile = game:GetService("HttpService"):JSONDecode(readfile("H2O_Folder/AllStar_Settings.json"))
end)
-- function zone
local GetUntiInventory = function()
    local Content = {};
    for i, v in pairs(game.Players.LocalPlayer.PlayerGui.HUD.Inventory.Inventory:GetChildren()) do
        if v.Name ~= "UIGridLayout" and v.ClassName == "ImageLabel" then
            table.insert(Content, v)
        end
    end
    return Content
end

local GetingStarData = function(x)
    local Content = {};
    for i, v in pairs(GetUntiInventory()) do
        if tonumber(v.View.ImageLabel.TextLabel.Text) == tonumber(x) then
            table.insert(Content, v)
        end
    end
    return Content;
end

local CheckUnti = function(x)
    local a = game.Players.LocalPlayer.PlayerGui.HUD.Inventory.MaxUnit.Text
    local b = string.split(a, "/")
    if tonumber(b[2]) - tonumber(b[1]) > tonumber(x) then
        return true
    end
    return false
end

local CheckGems = function(x)
    return tonumber(game.Players.LocalPlayer.PlayerGui.HUD.Others.Gem.TextLabel.Text) > tonumber(x)
end

local CheckCoins = function(x)
    return tonumber(game.Players.LocalPlayer.PlayerGui.HUD.Others.Coins.Coin.Text) > tonumber(x)
end

local GetingJoinFunction = {}
--

spawn(function()
    repeat wait() until game:GetService("ReplicatedStorage"):FindFirstChild("Lobby")
    wait(20)
    repeat wait() until game:GetService("ReplicatedStorage").Lobby.Value and game:GetService("Workspace").Queue
    local Flux = loadstring(game:HttpGet"https://pastebin.com/raw/nsk9XGtz")();
    local win = Flux:Window("Krypton Premium", "                  version : "..Global_V.Version_script, Color3.fromRGB(33, 30, 207), Enum.KeyCode.RightControl)
    
    Ui_Tab["Summon"] = win:Tab("Auto Summon", "http://www.roblox.com/asset/?id=6756586445")
    
    
    Ui_Tab["Summon"]:Line()
    Ui_Tab["Summon"]:Label("💎 Gems 💎")
    
    Ui_Tab["Summon"]:Line()
    Ui_Tab["Summon"]:Label("⭐ 5 Stars ⭐")
    
    Cache.Summon.AutoRandom = {}
    Ui_Tab["Summon"]:Toggle("Auto 5 Star Unti By Gems Part 1", "", false, function(Boolean)
        Cache.Summon.AutoRandom["5SGems1U1P"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(5);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["5SGems1U1P"] then
                pcall(function()
                    if CheckGems(50) and CheckUnti(1) and Cache.Summon.OldCount == #GetingStarData(5) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart", 1)
                        repeat wait() until game.Players.LocalPlayer.PlayerGui.HUD:FindFirstChild("SUMMONGUI")
                        wait(1)
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Toggle("Auto 5 Star Unti By Gems Part 1 x10", "", false, function(Boolean)
        Cache.Summon.AutoRandom["5SGems1U1Px10"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(5);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["5SGems1U1Px10"] then
                pcall(function()
                    if CheckGems(450) and CheckUnti(10) and Cache.Summon.OldCount == #GetingStarData(5) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart10", 1)
                        repeat wait() until game:GetService("Workspace").CurrentCamera.CameraType.Name == "Scriptable"
                        repeat
                            wait(1)
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                        until game:GetService("Workspace").CurrentCamera.CameraType.Name ~= "Scriptable"
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Toggle("Auto 5 Star Unti By Gems Part 2", "", false, function(Boolean)
        Cache.Summon.AutoRandom["5SGems1U2P"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(5);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["5SGems1U2P"] then
                pcall(function()
                    if CheckGems(50) and CheckUnti(1) and Cache.Summon.OldCount == #GetingStarData(5) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart", 2)
                        repeat wait() until game.Players.LocalPlayer.PlayerGui.HUD:FindFirstChild("SUMMONGUI")
                        wait(1)
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Toggle("Auto 5 Star Unti By Gems Part 2 x10", "", false, function(Boolean)
        Cache.Summon.AutoRandom["5SGems1U2Px10"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(5);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["5SGems1U2Px10"] then
                pcall(function()
                    if CheckGems(450) and CheckUnti(10) and Cache.Summon.OldCount == #GetingStarData(5) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart10", 2)
                        repeat wait() until game:GetService("Workspace").CurrentCamera.CameraType.Name == "Scriptable"
                        repeat
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                            wait(0.1)
                        until game:GetService("Workspace").CurrentCamera.CameraType.Name ~= "Scriptable"
                    end
                end)
            end
        end
    end)
    Ui_Tab["Summon"]:Line()
    Ui_Tab["Summon"]:Label("⭐ 4 Stars ⭐")
    
    Ui_Tab["Summon"]:Toggle("Auto 4 Star Unti By Gems Part 1", "", false, function(Boolean)
        Cache.Summon.AutoRandom["4SGems1U1P"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(4);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["4SGems1U1P"] then
                pcall(function()
                    if CheckGems(50) and CheckUnti(1) and Cache.Summon.OldCount == #GetingStarData(4) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart", 1)
                        repeat wait() until game.Players.LocalPlayer.PlayerGui.HUD:FindFirstChild("SUMMONGUI")
                        wait(1)
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Toggle("Auto 4 Star Unti By Gems Part 1 x10", "", false, function(Boolean)
        Cache.Summon.AutoRandom["4SGems1U1Px10"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(4);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["4SGems1U1Px10"] then
                pcall(function()
                    if CheckGems(50) and CheckUnti(1) and Cache.Summon.OldCount == #GetingStarData(4) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart", 1)
                        repeat wait() until game:GetService("Workspace").CurrentCamera.CameraType.Name == "Scriptable"
                        repeat
                            wait(0.1)
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                        until game:GetService("Workspace").CurrentCamera.CameraType.Name ~= "Scriptable"
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Toggle("Auto 4 Star Unti By Gems Part 2", "", false, function(Boolean)
        Cache.Summon.AutoRandom["4SGems1U2P"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(4);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["4SGems1U2P"] then
                pcall(function()
                    if CheckGems(50) and CheckUnti(1) and Cache.Summon.OldCount == #GetingStarData(4) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart", 2)
                        repeat wait() until game.Players.LocalPlayer.PlayerGui.HUD:FindFirstChild("SUMMONGUI")
                        wait(1)
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Toggle("Auto 4 Star Unti By Gems Part 2", "", false, function(Boolean)
        Cache.Summon.AutoRandom["4SGems1U2P"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(4);
        end
    end)
    
    Cache.Summon.OldCount = 0;
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["4SGems1U2P"] then
                pcall(function()
                    if CheckGems(50) and CheckUnti(1) and Cache.Summon.OldCount == #GetingStarData(4) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("SummonStart", 2)
                        repeat wait() until game:GetService("Workspace").CurrentCamera.CameraType.Name == "Scriptable"
                        repeat
                            wait(0.1)
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                        until game:GetService("Workspace").CurrentCamera.CameraType.Name ~= "Scriptable"
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Line()
    Ui_Tab["Summon"]:Label("💰 Coins 💰")
    
    Ui_Tab["Summon"]:Toggle("Auto 4 Star Unti By Coin", "", false, function(Boolean)
        Cache.Summon.AutoRandom["4SCOIN1U1P"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(4);
        end
    end)
    
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["4SCOIN1U1P"] then
                pcall(function()
                    if CheckCoins(150) and CheckUnti(1) and Cache.Summon.OldCount == #GetingStarData(4) then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("GoldSummonStart")
                        repeat wait() until game.Players.LocalPlayer.PlayerGui.HUD:FindFirstChild("SUMMONGUI")
                        wait(1)
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Summon"]:Toggle("Auto 4 Star Unti By Coin x10", "", false, function(Boolean)
        Cache.Summon.AutoRandom["4SCOIN1U1Px10"] = Boolean
        if Boolean then
            Cache.Summon.OldCount = #GetingStarData(4);
        end
    end)
    
    
    spawn(function()
        while wait(0.1) do
            if Cache.Summon.AutoRandom["4SCOIN1U1Px10"] then
                pcall(function()
                    if CheckCoins(1100) and CheckUnti(10) and Cache.Summon.OldCount == #GetingStarData(4) and game:GetService("Workspace").CurrentCamera.CameraType.Name ~= "Scriptable" then
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("GoldSummonStart10")
                        repeat wait() until game:GetService("Workspace").CurrentCamera.CameraType.Name == "Scriptable"
                        repeat
                            wait(0.1)
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(99999, 99999))
                        until game:GetService("Workspace").CurrentCamera.CameraType.Name ~= "Scriptable"
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Quest"] = win:Tab("Auto Quest", "http://www.roblox.com/asset/?id=6756586445")
    
    Ui_Tab["Quest"]:Line()
    Ui_Tab["Quest"]:Label("⭐ Auto Quest? ⭐")
    
    Ui_Tab["Quest"]:Toggle("Clams All Quest", "", false, function(Boolean)
        Cache.Quest.ClamsAllQuest = Boolean
    end)
    
    spawn(function()
        while wait() do
            if Cache.Quest.ClamsAllQuest then
                pcall(function()
                    for _, v1 in pairs(game.Players.LocalPlayer.PlayerGui.HUD.Tasks:GetChildren()) do
                        if v1.Name == "Tasks" or v1.Name == "DayTasks" then
                            for _, v in pairs(v1:GetChildren()) do
                                if v:FindFirstChild("Claim") and v.Claim.BackgroundColor3.R > 0.8 then
                                    game:GetService("ReplicatedStorage").Remotes.Input:FireServer("ClaimTask", v.Name)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    Ui_Tab["Teleport"] = win:Tab("Teleport", "http://www.roblox.com/asset/?id=6756586445")
    
    Ui_Tab["Teleport"]:Line()
    Ui_Tab["Teleport"]:Label("⭐ Lazy to walk? ⭐")
    
    local CreateTeleportPostiton = function(a, b)
        Ui_Tab["Teleport"]:Button(tostring(a), "", function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = b
        end)
    end
    
    CreateTeleportPostiton("Spawn", CFrame.new(-688, 51, -620))
    CreateTeleportPostiton("AFK", CFrame.new(-541, 46, -471))
    CreateTeleportPostiton("Summon", CFrame.new(-689, 65, -277))
    CreateTeleportPostiton("Orbs", CFrame.new(-863, 46, -810))
    CreateTeleportPostiton("Orbs Farm", CFrame.new(-965, 42, -898))
    CreateTeleportPostiton("Stroy Mode", CFrame.new(-935, 61, -620))
    CreateTeleportPostiton("Infinity Mode", CFrame.new(-688, 60, -904))
    CreateTeleportPostiton("Trial 1", CFrame.new(-161, 54, -876))
    CreateTeleportPostiton("Trial 2", CFrame.new(-508, 94, -804))
    CreateTeleportPostiton("Trial 3", CFrame.new(-784, 160, -987))
    CreateTeleportPostiton("Raid 1", CFrame.new(-1007, 172, -847))
    CreateTeleportPostiton("Raid 2", CFrame.new(-1136, 189, -624))
    CreateTeleportPostiton("Raid 3", CFrame.new(-982, 189, -295))
    CreateTeleportPostiton("Challenge 1", CFrame.new(-784, 245, -230))
    CreateTeleportPostiton("Challenge 2", CFrame.new(-548, 289, -170))
    CreateTeleportPostiton("Challenge 3", CFrame.new(-356, 289, -444))
    
    Ui_Tab["AutoPlay"] = win:Tab("Auto Play", "http://www.roblox.com/asset/?id=6756586445")
    Ui_Tab["AutoPlay"]:Line()
    Ui_Tab["AutoPlay"]:Label("⭐ Some Content Here! ⭐")
    
    Ui_Tab["AutoPlay"]:Dropdown("Macro Mode", {"None", "Record Mode", "Play Mode"}, function(DropDown)
        Cache.AutoPlay.MacroMode  = tostring(DropDown)
    end)
    
    Ui_Tab["AutoPlay"]:Dropdown("Select Mode", {"Story Mode","Infinite Mode", "Farming Mode", "Trial Mode"}, function(DropDown)
        Cache.AutoPlay.SelectMode  = tostring(DropDown)
    end)
    
    Ui_Tab["AutoPlay"]:Textbox("Room Id", "Input room id", false, function(Value)
        Cache.AutoPlay.RoomId = tonumber(Value) + 0
    end)

    
    Ui_Tab["AutoPlay"]:Toggle("Auto Save When End", "", false, function(Boolean)
        Cache.AutoPlay.AutoSaveWhenEnd = Boolean
    end)

    Ui_Tab["AutoPlay"]:Toggle("Auto Exit When End", "", false, function(Boolean)
        Cache.AutoPlay.AutoExitWhenEnd = Boolean
    end)

    Ui_Tab["AutoPlay"]:Button("Save Data To File", "", function()
        if Cache.AutoPlay.SelectMode then
            DataFormFile.SelectMode = tostring(Cache.AutoPlay.SelectMode)
        end
        if Cache.AutoPlay.RoomId then
            DataFormFile.RoomId = tostring(Cache.AutoPlay.RoomId)
        end
        if Cache.AutoPlay.MacroMode then
            DataFormFile.MacroMode = tostring(Cache.AutoPlay.MacroMode)
        end
        if Cache.AutoPlay.AutoSaveWhenEnd then
            DataFormFile.AutoSaveWhenEnd = Cache.AutoPlay.AutoSaveWhenEnd
        end

        if Cache.AutoPlay.AutoExitWhenEnd then
            DataFormFile.AutoExitWhenEnd = Cache.AutoPlay.AutoSaveWhenEnd
        end

        if not isfolder("H2O_Folder") then
            makefolder("H2O_Folder")
        end
        writefile("H2O_Folder/AllStar_Settings.json", game:GetService("HttpService"):JSONEncode(DataFormFile))
        Flux:Notification("Saved!", "Ok...")
    end)
    
    GetingJoinFunction.FindStoryRoom = function(id)
        while wait(0.1) do
            for i,v in pairs(game:GetService("Workspace").Queue["Story"]:GetChildren()) do
                if v.SurfaceGui.Frame.TextLabel.Text == "Empty" then
                    return v
                end
            end
        end
    end
    
    GetingJoinFunction.FindInfiniteRoom = function(id)
        local Number = tonumber(id)
        if Number == 1 then
            Number = -1
        elseif Number == 2 then
            Number = -1.1
        else
            Number = (1 + (Number * 0.1)) * -1
        end
        while wait() do
            for i, v in pairs(game:GetService("Workspace").Queue.Infinite:GetChildren()) do
                if v.Value.Value == Number and v.SurfaceGui.Frame.TextLabel.Text == "Empty" then
                    return v
                end
            end
        end
    end
    
    GetingJoinFunction.FindTrainRoom = function(id)
        local Number = tonumber(id);
        local First, Last, FullName;
        if Number <= 3 and Number < 4 then
            First = "Trial"
            Last = Number
        elseif Number <= 6 and Number < 7 then
            First = "Raid"
            Last = Number - 3
        elseif Number <= 9 and Number < 10 then
            First = "Challenge"
            Last = Number - 6
        else
            return "Can't Find!";
        end
        FullName = string.format("%s %s", First, Last)
        if First == "Trial" then
            return game:GetService("Workspace").Queue["Exam" .. Last].ExamDoor
        elseif First == "Raid" then
            return game:GetService("Workspace").Queue["Raid " .. Number].ExamDoor
        elseif First == "Challenge" then
            return game:GetService("Workspace").Queue["Raid " .. Number + 3].ExamDoor
        end
    end
    
    GetingJoinFunction.FindFarmingRoom = function()
        for i, v in pairs(game:GetService("Workspace").Queue.Farm.Collisions:GetChildren()) do
            if v:FindFirstChild("TouchInterest") then
                return v
            end
        end
    end
    Ui_Tab["AutoPlay"]:Button("Instant Join", "", function()
        local Postiton;
        if Cache.AutoPlay.SelectMode == "Story Mode" then
            Postiton = GetingJoinFunction.FindStoryRoom(Cache.AutoPlay.RoomId)
        elseif Cache.AutoPlay.SelectMode == "Infinite Mode"  then
            Postiton = GetingJoinFunction.FindInfiniteRoom(Cache.AutoPlay.RoomId)
        elseif Cache.AutoPlay.SelectMode == "Trial Mode"  then
            Postiton = GetingJoinFunction.FindTrainRoom(Cache.AutoPlay.RoomId)
        elseif Cache.AutoPlay.SelectMode == "Farming Mode"  then
            Postiton = GetingJoinFunction.FindFarmingRoom()
        end
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Postiton.CFrame
        wait(3)
        if Cache.AutoPlay.SelectMode == "Story Mode" then
            game:GetService("ReplicatedStorage").Remotes.Input:FireServer("Level", tostring(Cache.AutoPlay.RoomId), false)
        end
        wait(1)
        game:GetService("ReplicatedStorage").Remotes.Input:FireServer("Start")
    end)
    
    spawn(function()
        repeat wait() until DataFormFile.SelectMode and DataFormFile.RoomId and not _G.Stopeverything
        local Postiton;
        if DataFormFile.SelectMode == "Story Mode" then
            Postiton = GetingJoinFunction.FindStoryRoom(DataFormFile.RoomId)
        elseif DataFormFile.SelectMode == "Infinite Mode"  then
            Postiton = GetingJoinFunction.FindInfiniteRoom(DataFormFile.RoomId)
        elseif DataFormFile.SelectMode == "Trial Mode"  then
            Postiton = GetingJoinFunction.FindTrainRoom(DataFormFile.RoomId)
        elseif DataFormFile.SelectMode == "Farming Mode"  then
            Postiton = GetingJoinFunction.FindFarmingRoom()
        end
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Postiton.CFrame
        wait(3)
        if DataFormFile.SelectMode == "Story Mode" then
            game:GetService("ReplicatedStorage").Remotes.Input:FireServer("Level", tostring(DataFormFile.RoomId), false)
        end
        wait(1)
        game:GetService("ReplicatedStorage").Remotes.Input:FireServer("Start")
    end)    
end)

spawn(function()
    repeat wait() until game:GetService("ReplicatedStorage"):FindFirstChild("Lobby") and not game:GetService("ReplicatedStorage").Lobby.Value
    local Console = loadstring(game:HttpGet("https://raw.githubusercontent.com/KangKung02/KryptonHub/main/script/non-obfuscate/Console_library.lua"))()
    Console:Start("Krypton Premium", "@@YELLOW@@")
    Console:AddChoice("Marco Mode", "Set marco mode.", {"None", "Record Mode", "Play Mode"}, function(Value)
        DataFormFile.MacroMode = Value
        rconsoleprint("Set Marco Mode To : " .. Value .. "\n")
    end)

    -- DataFormFile.Pausing = DataFormFile.Pausing or _G.Stopeverything
    Console:AddToggle("Pause", "Pause or unpause.", function(Value)
        DataFormFile.Pausing = Value
        rconsoleprint("Set Pausing Mode To : " .. tostring(Value) .. "\n")
    end)
    
    Console:AddInput("showconfig", "show all config.", function()
        local Content = "\n";
        for i, v in pairs(DataFormFile) do
            Content = string.format("%s Index : %s Value : %s\n", Content, tostring(i), tostring(v))
        end
        rconsoleprint(Content)
    end)
    
    local GetMineUnti = function()
        local Content = {};
        for i, v in pairs(game.Workspace.Unit:GetChildren()) do
            if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == game.Players.LocalPlayer.Name then
                table.insert(Content, v)
            end
        end
        return Content
    end
    
    local GetIndexFormTag = function(Tag)
        for i, v in pairs(GetMineUnti()) do
            if v:FindFirstChild(tostring(Tag)) then
                v[tostring(Tag)]:Destroy()
                return i
            end
        end
    end
    local Database = {};
    pcall(function()
        Database = game:GetService("HttpService"):JSONDecode(readfile("H2O_Folder/AllStar_Database.json"))
    end)
    
    spawn(function()
        repeat wait() until DataFormFile.MacroMode == "Record Mode" and game.Players.LocalPlayer.PlayerGui.HUD.Wave.Visible;
        rconsoleprint("Start : Record!\n")
        Database = {}
        local LastContentForSave = {};
        local OldUntiForSave;
        local OldLevelForSave;
        local old;
        old = hookmetamethod(game:GetService("ReplicatedStorage").Remotes.Input, "__namecall", function(self, ...)
            local Args = {...};
            local Method = getnamecallmethod();
            local Type = Args[1];
            local Unit = Args[2];
            local Remote = self.Name;
            spawn(function()
                if DataFormFile.Pausing or Remote ~= "Input" then
                    return
                end
                if Method == "FireServer" then
                    repeat wait(); until #LastContentForSave == 0
                    OldUntiForSave = GetMineUnti();
                    if Type == "Summon" then
                        LastContentForSave = {"Summon", Unit["Unit"], string.format("return Vector3.new(%s, %s, %s)", Unit['cframe'].X, Unit['cframe'].Y, Unit['cframe'].Z)}
                    elseif Type == "Upgrade" then
                        local Tag = Instance.new('BoolValue', Unit); Tag.Name = "Upgrade_Tag";
                        OldLevelForSave = Unit:FindFirstChild("UpgradeTag").Value
                        LastContentForSave = {"Upgrade",  GetIndexFormTag("Upgrade_Tag")}
                    elseif Type == "Sell" then
                        local Tag = Instance.new('BoolValue', Unit); Tag.Name = "Sell_Tag";
                        LastContentForSave = {"Sell", GetIndexFormTag("Sell_Tag")}
                    elseif Type == "ChangePriority" then
                        local Tag = Instance.new('BoolValue', Unit); Tag.Name = "ChangePriority_Tag";
                        LastContentForSave = {"ChangePriority", GetIndexFormTag("ChangePriority_Tag")}
                    elseif Type == "UseSpecialMove" then
                        local Tag = Instance.new('BoolValue', Unit); Tag.Name = "UseSpecialMove_Tag";
                        LastContentForSave = {"UseSpecialMove", GetIndexFormTag("UseSpecialMove_Tag")}
                    elseif Type == "VoteGameMode" then
                        LastContentForSave = {"VoteGameMode", Unit}
                    end
                end
            end)
            return old(self, ...)
        end)
        spawn(function()
            while wait() do
                xpcall(function()
                    if #LastContentForSave ~= 0 then
                        local Type = LastContentForSave[1];
                        local Unit = GetMineUnti()[LastContentForSave[2]];
                        local SaveData = false;
                        if (Type == "Summon" or Type == "Sell") then
                            wait(0.7)
                            if OldUntiForSave == #GetMineUnti() then
                                LastContentForSave = {}
                                return print("TimeOut")
                            else
                                SaveData = true
                            end
                        elseif Type == "Upgrade" then
                            wait(0.7)
                            if OldUntiForSave == #GetMineUnti() then
                                LastContentForSave = {}
                                return print("TimeOut")
                            else
                                SaveData = true
                            end
                        elseif Type == "ChangePriority" or Type == "UseSpecialMove" or Type == "VoteGameMode" then
                            SaveData = true
                        else
                        end
                        if SaveData then
                            table.insert(Database, LastContentForSave);
                        end
                        LastContentForSave = {}
                    end
                end, function(err)
                    print(err)
                end)
            end
        end)
        spawn(function()
            repeat wait() until DataFormFile.AutoSaveWhenEnd and game.Players.LocalPlayer.PlayerGui.Notification:FindFirstChild("Notification") and game.Players.LocalPlayer.PlayerGui.Notification.Notification:FindFirstChild("NotificationTemplate") and game.Players.LocalPlayer.PlayerGui.Notification.Notification.NotificationTemplate:FindFirstChild("Label") and string.match(game.Players.LocalPlayer.PlayerGui.Notification.Notification.NotificationTemplate.Label.Text, "TIME") and string.match(game.Players.LocalPlayer.PlayerGui.Notification.Notification.NotificationTemplate.Label.Text, "seconds")
            writefile("H2O_Folder/AllStar_Database.json", game:GetService("HttpService"):JSONEncode(Database))
            rconsoleprint("Saved to file.\n")
        end)
        Console:AddInput("Save", "Save playing data.", function()
            if DataFormFile.MacroMode ~= "Record Mode" then
                return rconsoleerr("Can't save because marco mode not record mode!\n")
            end
            writefile("H2O_Folder/AllStar_Database.json", game:GetService("HttpService"):JSONEncode(Database))
            rconsoleprint("Saved to file.\n")
        end)
    end)
    
    spawn(function()
        repeat wait() until DataFormFile.MacroMode == "Play Mode" and game.Players.LocalPlayer.PlayerGui.HUD.Wave.Visible;
        wait(5)
        if #Database == 0 then
            return error("Can't Find Playing Data!", 2)
        end
        spawn(function()
            repeat wait() until DataFormFile.AutoExitWhenEnd and game.Players.LocalPlayer.PlayerGui.Notification:FindFirstChild("Notification") and game.Players.LocalPlayer.PlayerGui.Notification.Notification:FindFirstChild("NotificationTemplate") and game.Players.LocalPlayer.PlayerGui.Notification.Notification.NotificationTemplate:FindFirstChild("Label") and string.match(game.Players.LocalPlayer.PlayerGui.Notification.Notification.NotificationTemplate.Label.Text, "TIME") and string.match(game.Players.LocalPlayer.PlayerGui.Notification.Notification.NotificationTemplate.Label.Text, "seconds")
            syn.queue_on_teleport([[game:Shutdown()]])
        end)
        rconsoleprint("Start : Play!\n")
        while wait(0.5) do
            xpcall(function()
                local DataOfMarco = Database[1];
                if #Database == 0 then
                    return
                end
                local Type = tostring(DataOfMarco[1]);
                local Index = DataOfMarco[2];
                local OldUnti = #GetMineUnti()
                local Bypass = false
                local Unti
                local OldUntiLevel
                if not DataOfMarco then
                    return print("lost of data!")
                end
                repeat wait() until not DataFormFile.Pausing
                repeat
                    if Type == "Summon" then
                        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(Type, { ["cframe"] = CFrame.new(loadstring(DataOfMarco[3])(), Vector3.new(-0, -0, -1)), ["Unit"] = Index })
                    elseif Type == "VoteGameMode" then
                        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(Type, Index)
                        Bypass = true
                    elseif Type == "Upgrade" then
                        OldUntiLevel = GetMineUnti()[Index]:FindFirstChild("UpgradeTag").Value
                        Unti = GetMineUnti()[tonumber(Index)]
                        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(Type, Unti)
                    elseif Type == "Sell" then
                        Unti = GetMineUnti()[tonumber(Index)]
                        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(Type, Unti)
                    elseif Type == "ChangePriority" or Type == "UseSpecialMove" then
                        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(Type, GetMineUnti()[tonumber(Index)])
                        Bypass = true
                    else
                        return error("flie data error!", 2)
                    end
                    wait(0.5)
                until Bypass or ((Type == "Summon" or Type == "Sell") and OldUnti ~= #GetMineUnti()) or (Type == "Upgrade" and Unti:FindFirstChild("UpgradeTag") and (Unti and Unti:FindFirstChild("UpgradeTag").Value ~= OldUntiLevel or Unti:FindFirstChild("UpgradeTag").Value == Unti:FindFirstChild("MaxUpgradeTag").Value))
                table.remove(Database, 1)
            end, function(err)
                print(tostring(err))
            end)
        end
    end)
end)