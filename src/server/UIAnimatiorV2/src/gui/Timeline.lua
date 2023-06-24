local Timeline = {};
Timeline.__index = Timeline;

function Timeline.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Timeline);

    self._maxTimestepDivisor = 60;
    self._timeMarkerDistance = 3;
    self._framerate = 30;

    self.timeline = dockWidgetPluginGui.Main:WaitForChild("Timeline");
    self.timesteps = self.timeline:WaitForChild("Timesteps");

    self.steps = self:CreateTimesteps();

    return self;
end

function Timeline:SetFramerate(framerate : number)
    self._framerate = framerate
end

function Timeline:CreateMarker(index: number, offset: number) : Frame
    local marker = Instance.new("Frame");
    marker.Name = "marker-"..tostring(index);
    marker.Parent = self.timesteps;
    marker.Position = UDim2.new(index/self._maxTimestepDivisor,0,0,offset);
    marker.Size = UDim2.new(0,1,1,-offset);
    marker.BorderSizePixel = 0;
    marker.BackgroundColor3 = Color3.fromHex("#999999");
    marker.ZIndex = 2;

    return marker;
end

function Timeline._formatSecondsFrames(index: number, framerate: number): string
    return math.floor(index/framerate)..':'..string.format("%02d", index%framerate);
end

function Timeline:CreateTimestamp(index: number): TextLabel
    local timestamp = Instance.new("TextLabel");
    timestamp.Name = "timestamp-"..tostring(index);
    timestamp.Parent = self.timesteps;
    timestamp.Position = UDim2.new(index/self._maxTimestepDivisor,5,0,0);
    timestamp.Size = UDim2.new(0,40,0,20);
    timestamp.ZIndex = 2;
    timestamp.TextXAlignment = Enum.TextXAlignment.Left;
    timestamp.BackgroundTransparency = 1;
    timestamp.TextColor3 = Color3.fromHex("#999999");
    timestamp.Text = Timeline._formatSecondsFrames(index, self._framerate);
    timestamp.TextSize = 8;

    return timestamp;
end

function Timeline:CreateTimesteps(): {GuiObject}
    local timesteps = {};

    for i : number = 0,self._maxTimestepDivisor do
        local markerOffset: number = 18;
        if i%self._timeMarkerDistance == 0 then
            markerOffset = 10;
            table.insert(timesteps, self:CreateTimestamp(i));
        end

        table.insert(timesteps, self:CreateMarker(i, markerOffset));
    end

    return timesteps;
end

return Timeline;