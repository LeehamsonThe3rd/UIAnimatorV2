local RunService = game:GetService("RunService");
local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal);

local Preview = {};
Preview.__index = Preview;

function Preview.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Preview);

    self.topbar = dockWidgetPluginGui.Main.Topbar;
    self.animation = nil;

    self._direction = 1;
    self._length = 2;
    self._framerate = 30;
    self._time = 0;
    self._loop = false;
    self._timeSettings = false;

    self.runConnection = nil;

    self.Updated = GoodSignal.new();
    self.LengthChanged = GoodSignal.new();
    self.TimeChanged = GoodSignal.new();

    self:ConnectButtons();

    return self;
end

function Preview:SetLength(length: number)
    self._length = length;
    self.topbar.Length.Text = self:_convertTime(self._length);
end

function Preview:SetFramerate(framerate: number)
    self._framerate = framerate;
end

function Preview:SetTime(time: number)
    self._timeSetting = true;
    self:Stop();
    self._time = time;
    self:UpdatePreview();
    self.Updated:Fire(0, self._time);
    self.topbar.Time.Text = self:_convertTime(self._time);
    self._timeSetting = false; --to avoid making a keyframe on the spot we preview
end

function Preview:SetAnimation(animation: ModuleScript)
    self.animation = animation
end

function Preview:IsPlaying()
    if self.runConnection or self._timeSetting then return true end;
    return false;
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
    self.topbar.Time.Text = self:_convertTime(self._time);
end

function Preview:AnimateObject(object: Folder)
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

function Preview:UpdatePreview()
    for _,v in pairs(self.animation:GetChildren()) do
        local success,error = pcall(function()
            self:AnimateObject(v);
        end);

        if not success then print(error) end;
    end
end

function Preview:Update(dt: number)
    self._time += self._direction*dt;
    self.topbar.Time.Text = self:_convertTime(self._time);
    self:UpdatePreview();
    self:_checkReset();
    self.Updated:Fire(dt, self._time);
end

function Preview:_parseTime(string: string): number
    local seconds, frames = string:match("(%d+):(%d+)");
    if seconds and frames then
        local totalSeconds = tonumber(seconds) + (tonumber(frames) / self._framerate);
        return totalSeconds;
    else
        return nil;
    end
end

function Preview:_convertTime(time: number): string
    return math.floor(time)..':'..string.format("%02d", (time%1)*self._framerate)
end

function Preview:UpdateLength()
    local parsedTime = self:_parseTime(self.topbar.Length.Text);
    if not parsedTime or (parsedTime and parsedTime < 1) then 
        parsedTime = 1
        warn("[UIAnimator V2] invalid time format ff:ss");
    end;
    self._length = parsedTime;
    self.topbar.Length.Text = self:_convertTime(self._length);
    self.LengthChanged:Fire(self._length);
end

function Preview:UpdateTime()
    self._timeSetting = true;
    local parsedTime = self:_parseTime(self.topbar.Time.Text);
    if not parsedTime then
        parsedTime = 0
        warn("[UIAnimator V2] invalid time format ff:ss");
    end;
    self._time = parsedTime;
    self.topbar.Time.Text = self:_convertTime(self._time);
    self.TimeChanged:Fire(self._time);
    self:UpdatePreview();
    self._timeSetting = false;
end

function Preview:ConnectButtons()
    self.topbar.Play.MouseButton1Click:Connect(function() self:Play() end);
    self.topbar.Reverse.MouseButton1Click:Connect(function() self:Reverse() end);
    self.topbar.Beginning.MouseButton1Click:Connect(function() self:ToBeginning() end);
    self.topbar.End.MouseButton1Click:Connect(function() self:ToEnd() end);
    self.topbar.Loop.MouseButton1Click:Connect(function() self:ToggleLooping() end);

    self.topbar.Length.FocusLost:Connect(function() self:UpdateLength() end);
    self.topbar.Time.FocusLost:Connect(function() self:UpdateTime() end);
end

return Preview;