assert(not SWM, "Server already listening!");
local hookEnabled;
local socket = WebSocket.connect("ws://localhost:8291")
local id = nil;


--prapin/LuaBrainFuck
getgenv().SWM.bfuck = function(s)
  local subst = {["+"]="v=v+1 ", ["-"]="v=v-1 ", [">"]="i=i+1 ", ["<"]="i=i-1 ",
    ["."] = "w(v)", [","]="v=r()", ["["]="while v~=0 do ", ["]"]="end "}
  local env = setmetatable({ i=0, t=setmetatable({},{__index=function() return 0 end}),
    r=function() return io.read(1):byte() end, w=function(c) io.write(string.char(c)) end }, 
    {__index=function(t,k) return t.t[t.i] end, __newindex=function(t,k,v) t.t[t.i]=v end })
  load(s:gsub("[^%+%-<>%.,%[%]]+",""):gsub(".", subst), "brainfuck", "t", env)()
end;

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
	
getgenv().SWM.print = hookedPrint;
getgenv().SWM.warn = hookedWarn;

getgenv().SWM.Backup.print = hookfunction(print,SWM.print);
getgenv().SWM.Backup.warn = hookfunction(warn,SWM.warn);

socket.OnMessage:Connect(function(msg)
		
    if(msg == "bad_handshake") then
	    socket:Close();
	    return; 
    end;
    if(string.split(msg, ' ')[1] == "uuid") then
        id = string.split(msg, ' ')[2];
        socket:Send("got "..id);
        return;
    end

    local success, err = pcall(function()
	    return loadstring(tostring(msg))()
    end)

    if not success then
        warn(err);
    end
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

setreadonly(getgenv().SWM,true);
