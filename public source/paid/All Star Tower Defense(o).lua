repeat
    wait()
until game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Name
do
    local HashSha256 = function(InputContent)
        local MOD = 2^32
        local MODM = MOD-1
        
        local function memoize(f)
            local mt = {}
            local t = setmetatable({}, mt)
            function mt:__index(k)
                local v = f(k)
                t[k] = v
                return v
            end
            return t
        end
        
        local function make_bitop_uncached(t, m)
            local function bitop(a, b)
                local res,p = 0,1
                while a ~= 0 and b ~= 0 do
                    local am, bm = a % m, b % m
                    res = res + t[am][bm] * p
                    a = (a - am) / m
                    b = (b - bm) / m
                    p = p*m
                end
                res = res + (a + b) * p
                return res
            end
            return bitop
        end
        
        local function make_bitop(t)
            local op1 = make_bitop_uncached(t,2^1)
            local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)
            return make_bitop_uncached(op2, 2 ^ (t.n or 1))
        end
        
        local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})
        
        local function bxor(a, b, c, ...)
            local z = nil
            if b then
                a = a % MOD
                b = b % MOD
                z = bxor1(a, b)
                if c then z = bxor(z, c, ...) end
                return z
            elseif a then return a % MOD
            else return 0 end
        end
        
        local function band(a, b, c, ...)
            local z
            if b then
                a = a % MOD
                b = b % MOD
                z = ((a + b) - bxor1(a,b)) / 2
                if c then z = bit32_band(z, c, ...) end
                return z
            elseif a then return a % MOD
            else return MODM end
        end
        
        local function bnot(x) return (-1 - x) % MOD end
        
        local function rshift1(a, disp)
            if disp < 0 then return lshift(a,-disp) end
            return math.floor(a % 2 ^ 32 / 2 ^ disp)
        end
        
        local function rshift(x, disp)
            if disp > 31 or disp < -31 then return 0 end
            return rshift1(x % MOD, disp)
        end
        
        local function lshift(a, disp)
            if disp < 0 then return rshift(a,-disp) end 
            return (a * 2 ^ disp) % 2 ^ 32
        end
        
        local function rrotate(x, disp)
            x = x % MOD
            disp = disp % 32
            local low = band(x, 2 ^ disp - 1)
            return rshift(x, disp) + lshift(low, 32 - disp)
        end
        
        local k = {
            0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
            0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
            0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
            0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
            0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
            0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
            0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
            0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
            0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
            0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
            0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
            0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
            0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
            0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
            0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
            0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
        }
        
        local function str2hexa(s)
            return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
        end
        
        local function num2s(l, n)
            local s = ""
            for i = 1, n do
                local rem = l % 256
                s = string.char(rem) .. s
                l = (l - rem) / 256
            end
            return s
        end
        
        local function s232num(s, i)
            local n = 0
            for i = i, i + 3 do n = n*256 + string.byte(s, i) end
            return n
        end
        
        local function preproc(msg, len)
            local extra = 64 - ((len + 9) % 64)
            len = num2s(8 * len, 8)
            msg = msg .. "\128" .. string.rep("\0", extra) .. len
            assert(#msg % 64 == 0)
            return msg
        end
        
        local function initH256(H)
            H[1] = 0x6a09e667
            H[2] = 0xbb67ae85
            H[3] = 0x3c6ef372
            H[4] = 0xa54ff53a
            H[5] = 0x510e527f
            H[6] = 0x9b05688c
            H[7] = 0x1f83d9ab
            H[8] = 0x5be0cd19
            return H
        end
        
        local function digestblock(msg, i, H)
            local w = {}
            for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
            for j = 17, 64 do
                local v = w[j - 15]
                local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
                v = w[j - 2]
                w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
            end
        
            local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
            for i = 1, 64 do
                local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
                local maj = bxor(band(a, b), band(a, c), band(b, c))
                local t2 = s0 + maj
                local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
                local ch = bxor (band(e, f), band(bnot(e), g))
                local t1 = h + s1 + ch + k[i] + w[i]
                h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
            end
        
            H[1] = band(H[1] + a)
            H[2] = band(H[2] + b)
            H[3] = band(H[3] + c)
            H[4] = band(H[4] + d)
            H[5] = band(H[5] + e)
            H[6] = band(H[6] + f)
            H[7] = band(H[7] + g)
            H[8] = band(H[8] + h)
        end
        
        -- Made this global
        local function sha256(msg)
            msg = preproc(msg, #msg)
            local H = initH256({})
            for i = 1, #msg, 64 do digestblock(msg, i, H) end
            return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..
            num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
        end
        return sha256(InputContent)
    end
    local req = (syn and syn.request) or (http and http.request) or http_request
    local postdata = {
        [(HashSha256(HashSha256("_" .. math.floor(#game.Players.LocalPlayer.Name * math.pi) .. "HaachamaIsSoCute!")))] = getgenv().Key,
		PlayerName = game.Players.LocalPlayer.Name
    }
    local serverResponse = req({
        Url = LPH_ENCSTR("http://kangisloser.xyz/WjKT3MMce4g8QxX2LMHx6oTgK5aqp17u");
        Method = "POST";
        Headers = {
            ["Content-Type"] = "application/json";
        };
        Body = game:GetService("HttpService"):JSONEncode(postdata);
    }).Body;
    
    local GetingHwid = function()
        local WhitelistGeting
        local decoded = game:GetService('HttpService'):JSONDecode(req({Url = LPH_ENCSTR('https://httpbin.org/get'); Method = 'GET'}).Body)
        local hwid_list = {"Syn-Fingerprint", "Krnl-Hwid", "Fingerprint"};
        local Check = 0
        for i, v in next, hwid_list do
            if decoded.headers[v] ~= nil then
                Check = Check + 1
                WhitelistGeting = decoded.headers[v]
            end
            if WhitelistGeting == nil and Check == #hwid_list then
                return game.Players.LocalPlayer:Kick("Your exploit did't support!")
            end
        end
        return WhitelistGeting
    end
    if serverResponse == "Exploit Not Support." then
        return game.Players.LocalPlayer:Kick("Exploit Not Support!")
    elseif serverResponse == "Key or hwid not match!" then
        return game.Players.LocalPlayer:Kick("Key or hwid not match!")
	elseif serverResponse == "Key not found!" then
        return game.Players.LocalPlayer:Kick("Key not found!")
    elseif serverResponse == "Blacklisted" then
        return game.Players.LocalPlayer:Kick("You're is blacklisted!")
    end

    do
        local Keylength = #getgenv().Key
        local Exploit = (syn and "Synapse X") or (http and http.request and "Script-Ware") or (http_request and "Krnl")
		local SomeData = game:HttpGet("https://raw.githubusercontent.com/KangKung01/KangWinnerB/main/Somethings.lua")
		if #SomeData ~= 93604 then
			return game.Players.LocalPlayer:Kick("Somethings error!")
		end
        local EncodedKey = HashSha256("KanG." .. GetingHwid() .. "_" .. Keylength .. "_SSS>" .. Exploit .. "/La+SamaSoCute!")
        EncodedKey = HashSha256(EncodedKey .. "Darknesss")
        if serverResponse ~= EncodedKey then
			return game.Players.LocalPlayer:Kick("Nice try skid.")
        else
            local Global_V = {}
            pcall(function()
                local req = (syn and syn.request) or http_request or request
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
        end
    end    
end