local RunService = game:GetService("RunService")
local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal)
local DraggableFrame = require(script.Parent.base.DraggableFrame);

local Scrubber = setmetatable({}, DraggableFrame);
Scrubber.__index = Scrubber;

function Scrubber.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Scrubber);

    self._framerate = 30
    self._length = 2

    self.dockWidgetPluginGui = dockWidgetPluginGui
    self.timeline = dockWidgetPluginGui.Main:WaitForChild("Timeline");
    self.timesteps = self.timeline:WaitForChild("Timesteps");
    self.scrubberArea = self.timeline:WaitForChild("ScrubberArea");

    self.Moved = GoodSignal.new()

    self.scrubber = self:CreateScrubber();

    return self;
end

function Scrubber:SetFramerate(framerate : number)
    self._framerate = framerate;
end

function Scrubber:SetLength(length : number)
    self._length = length;
end

function Scrubber:CreateScrubber(): Frame
    local scrubber = Instance.new("Frame");
    scrubber.Name = "scrubber";
    scrubber.Parent = self.timesteps;
    scrubber.Position = UDim2.new(0,0,0,0);
    scrubber.Size = UDim2.new(0,1,1,0);
    scrubber.BorderSizePixel = 0;
    scrubber.BackgroundColor3 = Color3.fromHex("#00a2ff");
    scrubber.ZIndex = 10;

    local scrubberTop = Instance.new("Frame");
    scrubberTop.Name = "top";
    scrubberTop.Parent = scrubber;
    scrubberTop.Position = UDim2.new(0.5,0,0,0);
    scrubberTop.Size = UDim2.new(0,5,0,5)
    scrubberTop.BorderSizePixel = 0;
    scrubberTop.BackgroundColor3 = Color3.fromHex("#00a2ff");
    scrubberTop.ZIndex = 10;
    scrubberTop.AnchorPoint = Vector2.new(0.5,0)

    self:ConnectDragging();

    return scrubber;
end

function Scrubber:ConnectDragging()
    self.dragBegin = self.scrubberArea.InputBegan:Connect(function(...) self:Hold(...) end);
    self.dragEnd = self.scrubberArea.InputEnded:Connect(function(...) self:Release(...) end);
end

function Scrubber._snapScrubber(percent: number, length: number, framerate: number): number
    --both clamps the position and rounds it for fixed timestep positions
    local frames = (length*framerate);
    return math.clamp(math.floor(percent*frames)/frames,0,1);
end

function Scrubber:Hold(inputObject: InputObject)
    if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end;
    self.dragUpdate = RunService.Heartbeat:Connect(function() self:Drag() end);
    self.Moved:Fire(self.scrubber.Position.X.Scale)
    self:Drag()
end

function Scrubber:Drag()
   local mousePosition = self.dockWidgetPluginGui:GetRelativeMousePosition();
   local absPosition = self.scrubberArea.AbsolutePosition;
   local absSize = self.scrubberArea.AbsoluteSize;
   --accounts offset and converts to scale
   local adjustedPosition = (mousePosition-absPosition) / absSize;

   self.Moved:Fire(self.scrubber.Position.X.Scale*self._length)
   self:SetPosition(Scrubber._snapScrubber(adjustedPosition.X, self._length, self._framerate));
end

function Scrubber:Release(inputObject: InputObject)
    if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end;
    if self.dragUpdate then
        self.Moved:Fire(self.scrubber.Position.X.Scale*self._length)
        self.dragUpdate:Disconnect();
    end;
end

function Scrubber:SetPosition(percent: number)
    self.scrubber.Position = UDim2.fromScale(percent,0);
end

function Scrubber:GetTime()
    return self.scrubber.Position.X.Scale*self._length;
end

function Scrubber:Destroy()
    self.scrubber:Destroy();
    self:DisconnectDragging();
end

return Scrubber;