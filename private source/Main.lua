local LoadFreeScript = function()
    local Value, Err = pcall(function()
        loadstring(game:HttpGet(string.format("http://kangisloser.xyz/public/free/%s.lua", game.PlaceId)))();
    end)
    if not Value then
        return Err
    end
    return true
end

local LoadPaidScript = function()
    local Value, Err = pcall(function()
        loadstring(game:HttpGet(string.format("http://kangisloser.xyz/public/paid/%s.lua", game.PlaceId)))();
    end)
    print(Value, Err)
    if not Value then
        return Err
    end
    return true
end

local RunFreeScript = function()
    local OldTimer = os.clock();
    game.StarterGui:SetCore("SendNotification", {
        Title = "Krypton Notification",
        Text = "I'm Loading Free Script!",
        Icon = "rbxassetid://6756586445",
        Duration = 3,
    })
    local Response = LoadFreeScript();
    if Response ~= true then
        if string.match(Response, "UNAVAILABLE") then
            return game.Players.LocalPlayer:Kick("Server is down!")
        elseif string.match(tostring(Response), "NOT FOUND") then
            wait(3)
            return game.Players.LocalPlayer:Kick("Game not support!")
        else
            return print("Error : \n"..Response)
        end
    end
    game.StarterGui:SetCore("SendNotification", {
        Title = "Krypton Notification",
        Text = string.format("Load Succeed!\nTime Spent : %.3fs", os.clock() - OldTimer),
        Icon = "rbxassetid://6756586445",
        Duration = 3,
    })
end

local RunPaidScript = function()
    local OldTimer = os.clock();
    game.StarterGui:SetCore("SendNotification", {
        Title = "Krypton Notification",
        Text = "I'm Loading Paid Script!",
        Icon = "rbxassetid://6756586445",
        Duration = 3,
    })
    local Response = LoadPaidScript();
    print('1')
    print(Response)
    if Response ~= true then
        if string.match(Response, "UNAVAILABLE") then
            return game.Players.LocalPlayer:Kick("Server is down!")
        elseif string.match(Response, "NOT FOUND") then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Krypton Notification",
                Text = "Fail! I Can't Find This Game In Paid Script!",
                Icon = "rbxassetid://6756586445",
                Duration = 3,
            })
            return RunFreeScript()
        else
            return print("Error : \n" .. Response)
        end
    end
    game.StarterGui:SetCore("SendNotification", {
        Title = "Krypton Notification",
        Text = string.format("Load Succeed!\nTime Spent : %.3fs", os.clock() - OldTimer),
        Icon = "rbxassetid://6756586445",
        Duration = 5,
    })
end

if getgenv().Key == "Free-User" then
    RunFreeScript()
else
    RunPaidScript()
end
