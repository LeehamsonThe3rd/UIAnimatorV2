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

    self.runConnection = nil;

    self.Updated = GoodSignal.new()

    self:ConnectButtons();

    return self
end

function Preview:SetLength(length: number)
    self._length = length;
end

function Preview:SetTime(time: number)
    self:Stop()
    self._time = time;
end

function Preview:SetPlayButtonState(playing: boolean)
    self.topbar.Play.Image = "http://www.roblox.com/asset/?id=13835204675";
    self.topbar.Play.BackgroundTransparency = 1;
    if playing then
        self.topbar.Play.Image = "http://www.roblox.com/asset/?id=13846241842";
        self.topbar.Play.BackgroundTransparency = 0;
    end
end

function Preview:Play()
    if self._time == self._length then self._time = 0 end
    if not self.runConnection then
        self:SetPlayButtonState(true);
        self.runConnection = RunService.Heartbeat:Connect(function(...) self:Update(...) end);
    else
        self:Stop();
    end
end

function Preview:Stop()
    if not self.runConnection then return end
    self:SetPlayButtonState(false);
    self.runConnection:Disconnect();
    self.runConnection = nil;
end

function Preview:Update(dt: number)
    self._time += self._direction*dt;
    if self._time > self._length then
        self._time = self._length;
        self:Stop();
    end
    self.Updated:Fire(dt, self._time);
end

function Preview:ConnectButtons()
    self.topbar.Play.MouseButton1Click:Connect(function() self:Play() end);
end

return Preview;