setfflag("HumanoidParallelRemoveNoPhysics", "False")
setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
setfflag("CrashPadUploadToBacktraceToBacktraceBaseUrl", "")
setfflag("CrashUploadToBacktracePercentage", "0")
setfflag("CrashUploadToBacktraceBlackholeToken", "")
setfflag("CrashUploadToBacktraceWindowsPlayerToken", "")


game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait()
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
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

}

local Flux = loadstring(game:HttpGet"https://raw.githubusercontent.com/KangKung02/H2O/main/Flux_Ui.lua")();
local win = Flux:Window("Krypton Premium", "                  version : "..Global_V.Version_script, Color3.fromRGB(33, 30, 207), Enum.KeyCode.RightControl)

Ui_Tab["Main"] = win:Tab("Main", "http://www.roblox.com/asset/?id=6756586445")
