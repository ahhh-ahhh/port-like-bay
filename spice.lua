assert(not SWM, "Server already listening!");
local hookEnabled;
local socket = WebSocket.connect("ws://localhost:8291")
local id = nil;

local function hookedPrint(...)
    
    if(id == nil) then 
        return; 
    end

    local printResult = " "..os.date("*t")["hour"]..":"..os.date("*t")["min"]..":"..os.date("*t")["sec"].." -- ";
    for i,v in ipairs({...}) do
        printResult ..= tostring(v).."	"
    end
    
    printResult ..= "@@reset@@"

    socket:Send("c_out "..printResult);
end

local function hookedWarn(...)

    if(id == nil) then 
        return; 
    end
	
    local printResult = "@@yellow@@ ";
    printResult ..= os.date("*t")["hour"]..":"..os.date("*t")["min"]..":"..os.date("*t")["sec"].." -- ";
    for i,v in ipairs({...}) do
    	printResult ..= tostring(v).."	"
    end
    
    printResult ..= "@@reset@@"

    socket:Send("c_out "..printResult);
end


getgenv().SWM = {};
getgenv().SWM.Backup = {};

getgenv().SWM.Clear = function()
	if(hookEnabled and id ~= nil) then
		socket:Send("c_cls()");
	end
end

getgenv().cls = getgenv().SWM.Clear;
getgenv().clear =getgenv().SWM.Clear;
	
getgenv().SWM.print = hookedPrint;
getgenv().SWM.warn = hookedWarn;

getgenv().SWM.Backup.print = hookfunction(print,SWM.print);
getgenv().SWM.Backup.warn = hookfunction(warn,SWM.warn);

socket.OnMessage:Connect(function(msg)
  print(msg);
  if(string.split(msg, ' ')[1] == "uuid") then
    id = string.split(msg, ' ')[2];
    socket:Send("got "..id);
  else
    loadstring(msg)();
  end;
end);

getgenv().SWM.HookOutput = function()
	hookEnabled = true;
	hookfunction(print,SWM.print);
	hookfunction(warn,SWM.warn);
end

getgenv().SWM.DisableHook = function()
	hookEnabled = false;
	hookfunction(print,SWM.Backup.print);
	hookfunction(warn,SWM.Backup.warn);
end

getgenv().SWM.Backup.print([[
    Script-Ware M has loaded! Ported by AHHH.
    Currently, every call to print and warn will redirect to the Build-In Console.
    To disable this, use SWM.DisableHook(). If you're missing your logs being baked into Script-Ware, run SWM.HookOutput().


    This does not redirect the rconsole library, feel free to add it yourself.
	
    To clear the console, write cls() or clear()
]]);

setreadonly(getgenv().SWM,true);
