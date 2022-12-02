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
    local req = (syn and syn.request) or request
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
            wait(tonumber(Settings.Delay))
            spawn(function()
                local Old = os.time()
                repeat
                    wait()
                until Settings.EmergencyReJoin and Settings.EmergencyReJoinTime and not Settings.FoundWillStop and (os.time() - Old) > tonumber(Settings.EmergencyReJoinTime)
                game.StarterGui:SetCore('SendNotification', {
                    Title = "Emergency ReJoin Working",
                    Text = "Something Went Wrong \n Please Check Your Settings \n Or Call Kang <3",
                    Icon = "rbxassetid://4918719521",
                    Duration = 5,
                })
                wait(3)
                game:GetService('TeleportService'):Teleport(game.PlaceId)
            end)
            
            repeat
                wait()
            until game.Players and (game.Workspace:FindFirstChild('Trees') and game.Workspace.Trees:FindFirstChild('Tree') and  game.Workspace.Trees.Tree:FindFirstChild('Model')) and (game.Workspace:FindFirstChild('Island14') and game.Workspace.Island14:FindFirstChild('PedestalSpots'))
            
            spawn(function()
                repeat
                    wait()
                until not game.Workspace:FindFirstChild('Trees')
                wait(10)
                game:GetService('TeleportService'):Teleport(game.PlaceId)
            end)
            
            if Settings.It_Is_Latest_Version and not Settings.NotSameServerListMax then
                game.StarterGui:SetCore('SendNotification', {
                    Title = "README UWU",
                    Text = "Your script is't not last version \n you can got it on hunter v1 or ctrl + v on browser.",
                    Icon = "rbxassetid://4918719521",
                    Duration = 30,
                })
                setclipboard('https://cdn.discordapp.com/attachments/658642551804395541/786851251014991902/OPL_sub_Hunter.lua')
                return
            end
            
            
            
            local RATE_Fruit = loadstring(game:HttpGet'https://raw.githubusercontent.com/KangKung01/KangWinnerB/main/OPL/DevilFurit_Name.lua')()
            local RATE_BOX = loadstring(game:HttpGet'https://raw.githubusercontent.com/KangKung01/KangWinnerB/main/OPL/Box_Name.lua')()
            local STATS_STOP
            
            local Firewebhook = function(Type, Owner, Name, Stats, Where)
                local Request = (syn and syn.request) or request
                Request({
                    Url = tostring(Settings.WebHook),
                    Method = 'POST',
                    Headers = {['Content-Type'] = 'application/json'},
                    Body = game:GetService('HttpService'):JSONEncode({
                        embeds = {{
                            title = tostring(Settings.Title),
                            fields = {
                                {
                                    name = 'Type :',
                                    value = tostring(Type),
                                    inline = false
                                },
                                {
                                    name = 'Owner :',
                                    value = tostring(Owner),
                                    inline = false
                                },
                                {
                                    name = 'Name :',
                                    value = tostring(Name),
                                    inline = false
                                },
                                {
                                    name = 'Stats :',
                                    value = tostring((Stats == '' and 'None') or Stats),
                                    inline = false
                                },
                                {
                                    name = 'Where :',
                                    value = tostring(Where),
                                    inline = false
                                },
                                {
                                    name = 'Server :',
                                    value = tostring(game.JobId),
                                    inline = false
                                }
                            },
                            color = tonumber(Settings.Color)
                        }}
                    })
                })
                if Settings.FoundWillStop then
                    STATS_STOP = true
                end
            end
            local Stats_Check
            
            
            pcall(function()
                if Settings.RareFurits then
                    for _, Players in pairs(game.Players:GetChildren()) do
                        for _, Fruit in pairs(Players.Backpack:GetChildren()) do
                            if table.find(RATE_Fruit, Fruit.Name) then
                                Firewebhook('Fruit', Players.Name, Fruit.Name, Fruit.ToolTip, 'Backpack')
                            end
                        end
                    end
            
                    for _, Players in pairs(game.Players:GetChildren()) do
                        for _, Fruit in pairs(Players.Character:GetChildren()) do
                            if Fruit.ClassName == 'Tool' and table.find(RATE_Fruit, Fruit.Name) then
                                Firewebhook('Fruit', Players.Name, Fruit.Name, Fruit.ToolTip, 'Hand')
                            end
                        end
                    end
            
                    for _, Fruit in pairs(game.Workspace.Trees.Tree.Model:GetChildren()) do
                        if table.find(RATE_Fruit, Fruit.Name) then
                            Firewebhook('Fruit', 'None', Fruit.Name, Fruit.ToolTip, 'Ground')
                        end
                    end
            
                    for _, Path in pairs(game.Workspace.Island14.PedestalSpots:GetChildren()) do
                        for _, Fruit in pairs(Path:GetChildren()) do
                            if table.find(RATE_Fruit, Fruit.Name) then
                                Firewebhook('Fruit', 'None', Fruit.Name, Fruit.ToolTip, 'Nomal Pedestal')
                            end
                        end
                    end
            
                    for _, Fruit in pairs(game.Workspace.Altar.FruitReceptical:GetChildren()) do
                        if table.find(RATE_Fruit, Fruit.Name) then
                            Firewebhook('Fruit', 'None', Fruit.Name, Fruit.ToolTip, 'Rebirth Pedestal')
                        end
                    end
                end
            
                if Settings.RareBox then
                    for _, Players in pairs(game.Players:GetChildren()) do
                        for _, Fruit in pairs(Players.Backpack:GetChildren()) do
                            if table.find(RATE_BOX, Fruit.Name) then
                                Firewebhook('Box', Players.Name, Fruit.Name, Fruit.ToolTip, 'Backpack')
                            end
                        end
                    end
            
                    for _, Players in pairs(game.Players:GetChildren()) do
                        for _, Fruit in pairs(Players.Character:GetChildren()) do
                            if Fruit.ClassName == 'Tool' and table.find(RATE_BOX, Fruit.Name) then
                                Firewebhook('Box', Players.Name, Fruit.Name, Fruit.ToolTip, 'Hand')
                            end
                        end
                    end
            
                    for _, Fruit in pairs(game.Workspace.Trees.Tree.Model:GetChildren()) do
                        if table.find(RATE_BOX, Fruit.Name) then
                            Firewebhook('Box', 'None', Fruit.Name, Fruit.ToolTip, 'Ground')
                        end
                    end
            
                    for _, Path in pairs(game.Workspace.Island14.PedestalSpots:GetChildren()) do
                        for _, Fruit in pairs(Path:GetChildren()) do
                            if table.find(RATE_BOX, Fruit.Name) then
                                Firewebhook('Box', 'None', Fruit.Name, Fruit.ToolTip, 'Nomal Pedestal')
                            end
                        end
                    end
            
                    for _, Fruit in pairs(game.Workspace.Altar.FruitReceptical:GetChildren()) do
                        if table.find(RATE_BOX, Fruit.Name) then
                            Firewebhook('Box', 'None', Fruit.Name, Fruit.ToolTip, 'Rebirth Pedestal')
                        end
                    end
                end
            
                if Settings.AuraFurits then
                    for _, Players in pairs(game.Players:GetChildren()) do
                        for _, Fruit in pairs(Players.Backpack:GetChildren()) do
                            if Fruit.ClassName == 'Tool' and Fruit:FindFirstChild('Main') and Fruit.Main:FindFirstChild('AuraAttachment') then
                                Firewebhook('Fruit [Arua]', Players.Name, Fruit.Name, Fruit.ToolTip, 'Backpack')
                            end
                        end
                    end
            
                    for _, Players in pairs(game.Players:GetChildren()) do
                        for _, Fruit in pairs(Players.Character:GetChildren()) do
                            if Fruit.ClassName == 'Tool' and Fruit:FindFirstChild('Main') and Fruit.Main:FindFirstChild('AuraAttachment') then
                                Firewebhook('Fruit [Arua]', Players.Name, Fruit.Name, Fruit.ToolTip, 'Hand')
                            end
                        end
                    end
            
                    for _, Fruit in pairs(game.Workspace.Trees.Tree.Model:GetChildren()) do
                        if Fruit.ClassName == 'Tool' and Fruit:FindFirstChild('Main') and Fruit.Main:FindFirstChild('AuraAttachment') then
                            Firewebhook('Fruit [Arua]', 'None', Fruit.Name, Fruit.ToolTip, 'Ground')
                        end
                    end
            
                    for _, Path in pairs(game.Workspace.Island14.PedestalSpots:GetChildren()) do
                        for _, Fruit in pairs(Path:GetChildren()) do
                            if Fruit.ClassName == 'Tool' and Fruit:FindFirstChild('Main') and Fruit.Main:FindFirstChild('AuraAttachment') then
                                Firewebhook('Fruit [Arua]', 'None', Fruit.Name, Fruit.ToolTip, 'Nomal Pedestal')
                            end
                        end
                    end
            
                    for _, Fruit in pairs(game.Workspace.Altar.FruitReceptical:GetChildren()) do
                        if Fruit.ClassName == 'Tool' and Fruit:FindFirstChild('Main') and Fruit.Main:FindFirstChild('AuraAttachment') then
                            Firewebhook('Fruit [Arua]', 'None', Fruit.Name, Fruit.ToolTip, 'Rebirth Pedestal')
                        end
                    end
                end
                Stats_Check = true
            end)
            
            repeat
                wait()
            until Stats_Check and Settings.ServerHoping and not STATS_STOP
            
            
            
            local NotSameServer
            xpcall(function()
                NotSameServer = game:GetService('HttpService'):JSONDecode(readfile('NotSameServer.json'))
                if #NotSameServer >= tonumber(Settings.NotSameServerListMax) then
                    NotSameServer = {}
                end
                writefile('NotSameServer.json', game:GetService('HttpService'):JSONEncode(NotSameServer))
            end, function()
                NotSameServer = {}
                writefile('NotSameServer.json', game:GetService('HttpService'):JSONEncode(NotSameServer))
            end)
            
            local ServerList, Server = {}
            pcall(function()
                Server = game:GetService('HttpService'):JSONDecode(game:HttpGet(string.format('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100', game.PlaceId)))
            end)
            
            
            pcall(function()
                for _, v in pairs(Server.data) do
                    if not table.find(NotSameServer, v.id) and v.maxPlayers ~= v.playing then
                        table.insert(ServerList, v.id)
                    end
                end
            end)
            
            if #ServerList == 0 then
                game:GetService('TeleportService'):Teleport(game.PlaceId)
            end
            
            repeat
                game.StarterGui:SetCore('SendNotification', {
                    Title = "README UWU",
                    Text = "Rejoining!",
                    Icon = "rbxassetid://4918719521",
                    Duration = 5,
                })
                local ServerID = ServerList[math.random(1, #ServerList)]
                table.insert(NotSameServer, ServerID)
                writefile('NotSameServer.json', game:GetService('HttpService'):JSONEncode(NotSameServer))
                wait(3)
                game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, ServerID)
                wait(10)
            until not game.Players
            
        end
    end    
end