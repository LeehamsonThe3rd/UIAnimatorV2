local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal);
local Keyframe = require(script.Parent.base.Keyframe);

local Timeline = {};
Timeline.__index = Timeline;

function Timeline.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Timeline);

    self.dockWidgetPluginGui = dockWidgetPluginGui;
    self.timeline = dockWidgetPluginGui.Main:WaitForChild("Timeline");
    self.timesteps = self.timeline:WaitForChild("Timesteps");
    self.keyframes = {}
    self.keyframeConnections = {};

    self._maxTimestepDivisor = 60;
    self._timeMarkerDistance = 3;
    self._framerate = 30;
    self._length = 2;
    self._scaleFactor = 0;

    self.Resized = GoodSignal.new();
    self.KeyframeMoved = GoodSignal.new();
    self.KeyframeDestroying = GoodSignal.new();
    self.KeyframeInterpolationModeChanged = GoodSignal.new();

    self.steps = self:CreateTimesteps();

    return self;
end

function Timeline:SetFramerate(framerate : number)
    self._framerate = framerate;
    self:Draw();
end

function Timeline:SetLength(length : number)
    self._length = length;
    self:Draw();
end

function Timeline:CreateMarker(index: number, offset: number) : Frame
    local marker = Instance.new("Frame");
    marker.Name = "marker-"..tostring(index);
    marker.Parent = self.timesteps;
    marker.Position = UDim2.new(index/self._maxTimestepDivisor,0,0,offset);
    marker.Size = UDim2.new(0,1,1,-offset);
    marker.BorderSizePixel = 0;
    marker.BackgroundColor3 = Color3.fromHex("#999999");
    marker.ZIndex = 8;

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
    timestamp.ZIndex = 8;
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
        if i%(self._timeMarkerDistance+1) == 0 then
            markerOffset = 10;
            table.insert(timesteps, self:CreateTimestamp(i));
        end
        table.insert(timesteps, self:CreateMarker(i, markerOffset));
    end

    return timesteps;
end

function Timeline._roundToNearestPowerOfTwo(number: number): number
	return math.floor(math.log(number, 2));
end

function Timeline._roundToEven(number: number): number
    return math.floor(number - number%2)
end

function Timeline:GetScaleFactor(): number
    local size = self.timesteps.AbsoluteSize;
    return Timeline._roundToNearestPowerOfTwo(size.X*0.01)
end

function Timeline:Draw()
    local scaleFactor = self:GetScaleFactor();
    self._scaleFactor = scaleFactor;
    --isn't exact but it's pretty close to the original (also a bit buggy with bigger numbers)
    local subdivisions = Timeline._roundToNearestPowerOfTwo(math.max(self._length,2))*(4-self._scaleFactor);
    local scale = math.max(Timeline._roundToEven(math.floor(math.exp(subdivisions-1))),1);
    self._maxTimestepDivisor = (self._framerate/scale*self._length);
    self._timeMarkerDistance = math.min((subdivisions*2),4);
    self.steps = self:CreateTimesteps();
end

function Timeline:Resize()
    self:Draw();
    self.Resized:Fire();
end

function Timeline._toValue(key: {}, index: number, type: string)
    if type == "UDim2" then return UDim2.new(key[1][index].Value, key[2][index].Value, key[3][index].Value, key[4][index].Value) end;
    if type == "Color3" then return Color3.new(key[1][index].Value, key[2][index].Value, key[3][index].Value) end;
    if type == "Vector2" then return Vector2.new(key[1][index].Value, key[2][index].Value) end;
    if type == "number" then return key[1][index].Value end;
    return key[index].Value;
end

function Timeline:DrawPropertyKeys(child: Folder, property: ModuleScript, keys : {}, position: UDim2)
    local iterableKeys = keys;
    if typeof(keys[1]) == "table" then iterableKeys = keys[1] end;

    for i,v in pairs(iterableKeys) do
        local position = UDim2.new(v.Time/self._length,0,0,position.Height.Offset);
        local keyframe = Keyframe.new(self.timeline.Keyframes, position, self._length, self._framerate, self.dockWidgetPluginGui);
        
        if property:GetAttribute("Type") == "boolean" then keyframe:SetInterpolationOptionsEnabled(false) end;

        table.insert(self.keyframeConnections, keyframe.Moved:Connect(function(time)
            self.KeyframeMoved:Fire(child.AssociatedGui.Value, property.Name, time*self._length, Timeline._toValue(keys, i, property:GetAttribute("Type")), i)
         end));
        
        table.insert(self.keyframeConnections, keyframe.Destroying:Connect(function()
            self.KeyframeDestroying:Fire(child.AssociatedGui.Value, property.Name, i);
        end));

        table.insert(self.keyframeConnections, keyframe.InterpolationModeChanged:Connect(function(mode)
            self.KeyframeInterpolationModeChanged:Fire(child.AssociatedGui.Value, property.Name, i, mode);
        end));

        table.insert(self.keyframes, keyframe);
    end
end

function Timeline:GetChildProperties(child: Folder, position: UDim2, expanded: boolean)
    local offset = 0
    for i,v in pairs(child:GetChildren()) do
        if v:IsA("ObjectValue") then continue end;
        self:DrawPropertyKeys(child, v, require(v).GetKeys(), position);
        if expanded then self:DrawPropertyKeys(child, v, require(v).GetKeys(), position+UDim2.fromOffset(0,(25*i)-25)) end;
        offset += 1;
    end
end

function Timeline:ClearKeys()
    for _,v in pairs(self.keyframes) do
        v:Destroy();
    end

    for _,v in pairs(self.keyframeConnections) do
        v:Disconnect();
    end
end

function Timeline:DrawKeys(animation: ModuleScript, hierarchy: {})
    self:ClearKeys();
    if #hierarchy.children < 1 or not animation then return end;
    for _,v in pairs(animation:GetChildren()) do
        if not v:FindFirstChild("AssociatedGui") then continue end;
        local item = hierarchy:GetItem(v.AssociatedGui.Value)
        self:GetChildProperties(v, item.item.Position, item:GetExpanded());
    end
end

return Timeline;