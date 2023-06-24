local Timeline = {};
Timeline.__index = Timeline;

function Timeline.new(dockWidgetPluginGui : DockWidgetPluginGui)
    local self = setmetatable({}, Timeline);

    self.maxTimestepDivisor = 60;
    self.timeMarkerDistance = 3;

    self.timeline = dockWidgetPluginGui.Main:WaitForChild("Timeline");
    self.timesteps = self.timeline:WaitForChild("Timesteps");

    self.steps = self:CreateTimesteps();

    return self;
end

function Timeline:CreateMarker(index : number, height : number) : Frame
    local marker = Instance.new("Frame");
    marker.Name = "marker-"..tostring(index);
    marker.Parent = self.timesteps;
    marker.Position = UDim2.new(index/self.maxTimestepDivisor,0,1-height,0);
    marker.Size = UDim2.new(0,1,height,0);
    marker.BorderSizePixel = 0;
    marker.BackgroundColor3 = Color3.fromHex("#999999");
    marker.ZIndex = 2;

    return marker;
end

function Timeline._formatSecondsFrames(index : number, framerate : number) : string
    return math.floor(index/framerate)..':'..string.format("%02d", index%framerate);
end

function Timeline:CreateTimestamp(index : number) : TextLabel
    local timestamp = Instance.new("TextLabel");
    timestamp.Name = "timestamp-"..tostring(index);
    timestamp.Parent = self.timesteps;
    timestamp.Position = UDim2.new(index/self.maxTimestepDivisor,5,0,0);
    timestamp.Size = UDim2.new(0,40,0,20);
    timestamp.ZIndex = 2;
    timestamp.TextXAlignment = Enum.TextXAlignment.Left;
    timestamp.BackgroundTransparency = 1;
    timestamp.TextColor3 = Color3.fromHex("#999999");
    timestamp.Text = Timeline._formatSecondsFrames(index, _G.animation.framerate);

    return timestamp;
end

function Timeline:CreateTimesteps() : {GuiObject}
    local timesteps = {};

    for i : number = 0,self.maxTimestepDivisor do
        local markerHeight: number = 0.91;
        if i%self.timeMarkerDistance == 0 then
            markerHeight = 0.95;
            table.insert(timesteps, self:CreateTimestamp(i));
        end

        table.insert(timesteps, self:CreateMarker(i, markerHeight));
    end

    return timesteps;
end

return Timeline;