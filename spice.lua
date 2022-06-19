assert(not SWM, "Server already listening!");
local hookEnabled;
local socket = WebSocket.connect("ws://localhost:8291")

local function hookedPrint(...)

	local printResult = " "..os.date("*t")["hour"]..":"..os.date("*t")["min"]..":"..os.date("*t")["sec"].." -- ";
    for i,v in ipairs({...}) do
        printResult ..= tostring(v) .. "	"
    end
    
    printResult ..= "@@reset@@"

    socket:Send("c_out "..printResult);
end

local function hookedWarn(...)

	local printResult = "@@yellow@@ ";
    printResult ..= os.date("*t")["hour"]..":"..os.date("*t")["min"]..":"..os.date("*t")["sec"].." -- ";
    for i,v in ipairs({...}) do
        printResult ..= tostring(v) .. "	"
    end
    
    printResult ..= "@@reset@@"

    socket:Send("c_out "..printResult);
end

getgenv().SWM = {};

SWM.Backup = {};

SWM.Clear = function()
	if(hookEnabled) then
		socket:Send("c_cls()");
	end
end

getgenv().cls = SWM.Clear();
getgenv().clear = SWM.Clear();
	
SWM.print = hookedPrint;
SWM.warn = hookedWarn;

SWM.Backup.print = hookfunction(print,SWM.print);
SWM.Backup.warn = hookfunction(warn,SWM.warn);

socket.OnMessage:Connect(function(msg)
  loadstring(msg)();
end);

SWM.HookOutput = function()
	hookEnabled = true;
	hookfunction(print,SWM.print);
	hookfunction(warn,SWM.warn);
end

SWM.DisableHook = function()
	hookEnabled = false;
	hookfunction(print,SWM.Backup.print);
	hookfunction(warn,SWM.Backup.warn);
end

SWM.Backup.print("Script-Ware M has loaded! Ported by AHHH.");
SWM.Backup.warn("Currently, every call to print and warn will redirect to the Built-In Console.");
SWM.Backup.print("To disable this, run SWM.DisableHook(). If you're missing your logs being baked into Script-Ware, run SWM.HookOutput().");
SWM.Backup.print("\n\n\n");
SWM.Backup.print("This does not redirect the rconsole library, feel free to add it yourself.");
