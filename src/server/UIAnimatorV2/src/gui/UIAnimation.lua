--[[
    --INFORMATION-- (if you downloaded from the github repo)

    This script requires GoodSignal as a dependency for script signals, so in order for this class to
    properly work please add GoodSignal from the dependency folder to this script!
]]--

local RunService = game:GetService("RunService");
local GoodSignal = require(script:WaitForChild("GoodSignal"));

local Player = {};
Player.__index = Player;

function Player.new()
    local self = setmetatable({}, Player);

    self:_updateProperties();
    self._time = 0;

    self.Finished = GoodSignal.new();
    self.Looped = GoodSignal.new();

    self._runConnection = nil;

    return self;
end

function Player:_updateProperties()
    self._loop = script:GetAttribute("loop");
    self._length = script:GetAttribute("length");
    self._speed = script:GetAttribute("speed");
end

function Player:Play()
    self:_updateProperties();
    self._runConnection = RunService.Heartbeat:Connect(function(...) self:Update(...) end);
end

function Player:AnimateObject(object: Folder)
    local gui = object:FindFirstChild("AssociatedGui").Value;
    for _,v in pairs(object:GetChildren()) do
		if v:IsA("ObjectValue") then continue end;
		local value = require(v).GetValueAtTime(self._time);
        if v:GetAttribute("Type") == "boolean" then
            if value == 1 then value = true end; --this is for booleans only (type casting)
            if value == 0  then value = false end;
        end
        gui[v.Name] = value;
    end
end

function Player:UpdatePreview()
    for _,v in pairs(script:GetChildren()) do
        if not v:IsA("Folder") then continue end;
        local success,error = pcall(function()
            self:AnimateObject(v);
        end);

        if not success then print(error) end;
    end
end

function Player:_checkReset()
    if self._time > self._length then
        self._time = 0;
        if not self._loop then self:Stop() else self.Looped:Fire() end;
    end
end

function Player:Update(dt)
    self._time += dt*self._speed;
    self:UpdatePreview();
    self:_checkReset();
end

function Player:Stop()
    if not self._runConnection then return end
    self.Finished:Fire()
    self._runConnection:Disconnect();
    self._runConnection = nil;
end

function Player:SetLooping(loop: boolean)
    script:SetAttribute("loop", loop);
end

function Player:SetSpeed(speed: number)
    script:SetAttribute("speed", speed);
end

function Player:SetLength(length: number)
    script:SetAttribute("speed", length);
end

function Player:SetTime(time: number)
    self._time = time;
end

function Player:Destroy()
    if self._runConnection then self._runConnection:Disconnect() end
end

return Player;