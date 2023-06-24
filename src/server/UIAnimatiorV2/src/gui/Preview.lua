local RunService = game:GetService("RunService");
local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal);

local Preview = {};
Preview.__index = Preview;

function Preview.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Preview);

    self.topbar = dockWidgetPluginGui.Main.Topbar;

    self._direction = 1;
    self._length = 1;
    self._time = 0;
    self._loop = false;

    self.runConnection = nil;

    self.Updated = GoodSignal.new()

    self:ConnectButtons();

    return self;
end

function Preview:SetLength(length: number)
    self._length = length;
end

function Preview:SetTime(time: number)
    self:Stop();
    self._time = time;
    self.Updated:Fire(0, self._time);
end

function Preview:SetPlayButtonState(playing: boolean)
    self.topbar.Play.Image = "http://www.roblox.com/asset/?id=13835204675";
    self.topbar.Play.BackgroundTransparency = 1;
    if playing then
        self.topbar.Play.Image = "http://www.roblox.com/asset/?id=13846241842";
        self.topbar.Play.BackgroundTransparency = 0;
    end
end

function Preview:SetReverseButtonState(playing: boolean)
    self.topbar.Reverse.Image = "http://www.roblox.com/asset/?id=13835205401";
    self.topbar.Reverse.BackgroundTransparency = 1;
    if playing then
        self.topbar.Reverse.Image = "http://www.roblox.com/asset/?id=13846241842";
        self.topbar.Reverse.BackgroundTransparency = 0;
    end
end

function Preview:SetLoopButtonState(looping: boolean)
    self.topbar.Loop.BackgroundTransparency = 1;
    if looping then
        self.topbar.Loop.BackgroundTransparency = 0;
    end
end

function Preview:_reset()
    if self._time == self._length and self._direction == 1 then self._time = 0 end;
    if self._time == 0 and self._direction == -1 then self._time = self._length end;
end

function Preview:Start(oldDirection : number)
    self:_reset();
    if not self.runConnection then
        self.runConnection = RunService.Heartbeat:Connect(function(...) self:Update(...) end);
    elseif oldDirection == self._direction then
        self:Stop();
    end
end

function Preview:Play()
    local oldDirection = self._direction;
    self._direction = 1;
    self:SetReverseButtonState(false);
    self:SetPlayButtonState(true);
    self:Start(oldDirection);
end

function Preview:Reverse()
    local oldDirection = self._direction;
    self._direction = -1;
    self:SetReverseButtonState(true);
    self:SetPlayButtonState(false);
    self:Start(oldDirection);
end

function Preview:ToBeginning()
    self:SetTime(0);
end

function Preview:ToEnd()
    self:SetTime(self._length);
end

function Preview:ToggleLooping()
    self._loop = not self._loop;
    self:SetLoopButtonState(self._loop);
end

function Preview:Stop()
    if not self.runConnection then return end
    self:SetPlayButtonState(false);
    self:SetReverseButtonState(false);
    self.runConnection:Disconnect();
    self.runConnection = nil;
end

function Preview:_checkReset()
    local inverse = 0;
    if self._loop then inverse = self._length end;

    if self._time > self._length then
        self._time = math.abs(inverse-self._length);
        if not self._loop then self:Stop() end;
    elseif self._time < 0 then
        self._time = math.abs(inverse-0);
        if not self._loop then self:Stop() end;
    end
end

function Preview:Update(dt: number)
    self._time += self._direction*dt;
    self:_checkReset();
    self.Updated:Fire(dt, self._time);
end

function Preview:ConnectButtons()
    self.topbar.Play.MouseButton1Click:Connect(function() self:Play() end);
    self.topbar.Reverse.MouseButton1Click:Connect(function() self:Reverse() end);
    self.topbar.Beginning.MouseButton1Click:Connect(function() self:ToBeginning() end);
    self.topbar.End.MouseButton1Click:Connect(function() self:ToEnd() end);
    self.topbar.Loop.MouseButton1Click:Connect(function() self:ToggleLooping() end);
end

return Preview;