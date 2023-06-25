local Timeline = {};
Timeline.__index = Timeline;

function Timeline.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Timeline);

    self.timeline = dockWidgetPluginGui.Main:WaitForChild("Timeline");
    self.timesteps = self.timeline:WaitForChild("Timesteps");

    self._maxTimestepDivisor = 60;
    self._timeMarkerDistance = 3;
    self._framerate = 30;
    self._length = 2;
    self._scaleFactor = 0;
    self:Resize()

    self.steps = self:CreateTimesteps();

    return self;
end

function Timeline:SetFramerate(framerate : number)
    self._framerate = framerate;
end

function Timeline:SetLength(length : number)
    self._length = length;
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

function Timeline:_formatSecondsFrames(index: number): string
    local seconds = math.floor((index/self._maxTimestepDivisor)*self._length);
    local framesPerDivision = self._maxTimestepDivisor/self._length;
    local frames = string.format("%02d", (index%framesPerDivision)/framesPerDivision*self._framerate);
    return seconds..':'..frames;
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
    timestamp.Text = self:_formatSecondsFrames(index);
    timestamp.TextSize = 8;

    return timestamp;
end

function Timeline:DestroyTimesteps()
    if not self.steps then return end;
    for _,v in pairs(self.steps) do
        v:Destroy();
    end
end

function Timeline:CreateTimesteps(): {GuiObject}
    self:DestroyTimesteps();
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

function Timeline._roundToNearestPowerOfTwo(number: number)
	return math.floor(math.log(number, 2))^2
end

function Timeline:GetScaleFactor(): number
    local size = self.timesteps.AbsoluteSize;
    return Timeline._roundToNearestPowerOfTwo(size.X*0.01)
end

function Timeline:Resize()
    local scaleFactor = self:GetScaleFactor();
	if scaleFactor ~= self._scaleFactor then
        self._scaleFactor = scaleFactor;
        --needs improvement
        self._maxTimestepDivisor = ((self._framerate/9)*self._scaleFactor*self._length);
		self.steps = self:CreateTimesteps();
	end
end

return Timeline;