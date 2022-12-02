setfflag("HumanoidParallelRemoveNoPhysics", "False")
setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
setfflag("CrashPadUploadToBacktraceToBacktraceBaseUrl", "")
setfflag("CrashUploadToBacktracePercentage", "0")
setfflag("CrashUploadToBacktraceBlackholeToken", "")
setfflag("CrashUploadToBacktraceWindowsPlayerToken", "")

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait();
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

if getgenv().IsKangDev == "Haachamaissocute!" then
    Global_V = {
        Version_script = "0.0.0.0";
        Script_enabled = true;
    }
end
if not Global_V.Script_enabled then
    return game.Players.LocalPlayer:Kick("Script was disabled.")
end
local UITab = {};
local Cache = { DevConfig = {} };

Cache.DevConfig["FolderSettingPath"] = "KryptonHub";
Cache.DevConfig["FileSettingPath"] = "Settings";

local CheckPath = function(Path, ...)
    local Args = {...};
    for _, v in pairs(Args) do
        if Path:FindFirstChild(v) then
            Path = Path[v]
        else
            return false;
        end
    end
    return true;
end

local MyFile = {};
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/KangKung02/LinoriaLib/main/addons/SaveManager.lua"))();
SaveManager:SetFolder(Cache.DevConfig["FolderSettingPath"]);
SaveManager:SetFile("Settings");
SaveManager:IgnoreThemeSettings()
function MyFile:Load()
    SaveManager:Load();
    if not self.IsLoaded then
        self.IsLoaded = true
    end
end

local MethodsAutoTableUI = {
    __index = function(self, key)
        if not rawget(self, key) then
            rawset(self, key, {})
        end
        return rawget(self, key)
    end,
    __newindex = function(self, key, value)
        if #rawget(self, key) == 0 then
            rawset(self, "Main", value)
        end
        return rawset(self, key, value)
    end
}
setmetatable(UITab, MethodsAutoTableUI);

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KangKung02/LinoriaLib/main/Library.lua"))();


local Windows = Library:CreateWindow(string.format("Krypton %s - %s", "Premium", Global_V.Version_script));





































UITab["Settings-Credits"]["Main"] = Windows:AddTab("Settings - Credits");
UITab["Settings-Credits"]["Left"] = UITab["Settings-Credits"]["Main"]:AddLeftTabbox("Settings");
UITab["Settings-Credits"]["Right"] = UITab["Settings-Credits"]["Main"]:AddRightTabbox("Credits")

UITab["Settings-Credits"]["Left"]["Theme"] = UITab["Settings-Credits"]["Left"]:AddTab("Theme");
UITab["Settings-Credits"]["Left"]["FileManager"] = UITab["Settings-Credits"]["Left"]:AddTab("File Manager");

local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/KangKung02/LinoriaLib/main/addons/ThemeManager.lua"))();
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder(Cache.DevConfig["FolderSettingPath"])
ThemeManager:ApplyToGroupbox(UITab["Settings-Credits"]["Left"]["Theme"])

local MyFileManager = {};

function MyFileManager:Save()
    local folder = SaveManager.Folder .. '/settings/';
    if not isfolder(folder) then
        makefolder(folder);
    end
    local List = {
        AutoSave = (Toggles["AutoSave"] and Toggles["AutoSave"].Value) or false;
        AutoLoad = (Toggles["AutoLoad"] and Toggles["AutoLoad"].Value) or false;
    }
    writefile(folder .. "AutoSave.json", game:GetService("HttpService"):JSONEncode(List));
end

function MyFileManager:Load()
    local file = SaveManager.Folder .. '/settings/AutoSave.json';
    if not isfile(file) then return end;
    local List = {"AutoSave", "AutoLoad"};
    local decoded = game:GetService("HttpService"):JSONDecode(readfile(file));
    for _, index in next, List do
        spawn(function()
            repeat wait() until Toggles[index];
            if Toggles[index].SetValue and decoded[index] then
                Toggles[index]:SetValue(decoded[index]);
            end
        end)
    end
end

MyFileManager:Load();

UITab["Settings-Credits"]["Left"]["FileManager"]:AddToggle("AutoSave", { Text = "Auto Save"} ):OnChanged(function()
    MyFileManager:Save();
end);
UITab["Settings-Credits"]["Left"]["FileManager"]:AddToggle("AutoLoad", { Text = "Auto Load"} ):OnChanged(function()
    MyFileManager:Save();
end);
UITab["Settings-Credits"]["Left"]["FileManager"]:AddButton("Save", function()
    MyFileManager:Save();
    SaveManager:Save();
end);
UITab["Settings-Credits"]["Left"]["FileManager"]:AddButton("Load", function()
    SaveManager:Load();
end);
UITab["Settings-Credits"]["Left"]["FileManager"]:AddButton("Reset Settings", function()
    local file = SaveManager.Folder .. '/settings/' .. SaveManager.File .. '.json';
    if isfile(file) then
        delfile(file)
        Library:Notify("Deleted File, Please ReJoin!");
    end
end);
UITab["Settings-Credits"]["Right"]["Credits"] = UITab["Settings-Credits"]["Right"]:AddTab("Credits");
UITab["Settings-Credits"]["Right"]["Credits"]:AddLabel("Made By : 「 Kang Kung#7271 」");
UITab["Settings-Credits"]["Right"]["Credits"]:AddLabel("Discord : \nhttps://discord.gg/B659FscCBz");
UITab["Settings-Credits"]["Right"]["Credits"]:AddBlank(5);
UITab["Settings-Credits"]["Right"]["Credits"]:AddButton("Copy Link", function()
    local Http_Request = (syn and syn.request) or request
    Http_Request({
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
end)


Library:Notify("Loaded Krypton Hub Press Right Control For Show, Hide UI");

SaveManager:SetIgnoreIndexes({"AutoSave", "AutoLoad"});

spawn(function()
    repeat wait() until Toggles["AutoLoad"];
    if Toggles["AutoLoad"].Value then
        MyFile:Load();
    end
end)
spawn(function()
    repeat wait() until Toggles["AutoSave"] and Toggles["AutoLoad"].Value;
    SaveManager:AutoSave();
end)
