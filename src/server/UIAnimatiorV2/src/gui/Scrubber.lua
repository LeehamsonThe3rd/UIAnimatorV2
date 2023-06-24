local DraggableFrame = require(script.Parent.base.DraggableFrame)

local Scrubber = setmetatable({}, DraggableFrame);
Scrubber.__index = Scrubber;

function Scrubber.new(dockWidgetPluginGui : DockWidgetPluginGui)
    local self = setmetatable({}, Scrubber);

    self.dockWidgetPluginGui = dockWidgetPluginGui
    self.timeline = dockWidgetPluginGui.Main:WaitForChild("Timeline");
    self.timesteps = self.timeline:WaitForChild("Timesteps");
    self.scrubberArea = self.timeline:WaitForChild("ScrubberArea");

    self.scrubber = self:CreateScrubber();

    return self;
end

function Scrubber:CreateScrubber() : Frame
    local scrubber = Instance.new("Frame");
    scrubber.Name = "scrubber"
    scrubber.Parent = self.timesteps;
    scrubber.Position = UDim2.new(0,0,0,0);
    scrubber.Size = UDim2.new(0,1,1,0);
    scrubber.BorderSizePixel = 0;
    scrubber.BackgroundColor3 = Color3.fromHex("#00a2ff");
    scrubber.ZIndex = 3;

    local scrubberTop = Instance.new("Frame");
    scrubberTop.Name = "top";
    scrubberTop.Parent = scrubber;
    scrubberTop.Position = UDim2.new(0.5,0,0,0);
    scrubberTop.Size = UDim2.new(0,5,0,5)
    scrubberTop.BorderSizePixel = 0;
    scrubberTop.BackgroundColor3 = Color3.fromHex("#00a2ff");
    scrubberTop.ZIndex = 3;
    scrubberTop.AnchorPoint = Vector2.new(0.5,0)

    self:ConnectDragging();

    return scrubber;
end

function Scrubber:ConnectDragging()
    self.dragBegin = self.scrubberArea.InputBegan:Connect(function(...) self:Hold(...) end);
    self.dragEnd = self.scrubberArea.InputEnded:Connect(function(...) self:Release(...) end);
end

function Scrubber._snapScrubber(position : Vector3) : number
    --both clamps the position and rounds it for fixed timestep positions
    local frames = (_G.animation.length*_G.animation.framerate)
    return math.clamp(math.floor(position.X*frames)/frames,0,1)
end

function Scrubber:Drag(inputObject : InputObject)
   local mousePosition = self.dockWidgetPluginGui:GetRelativeMousePosition();
   local absPosition = self.scrubberArea.AbsolutePosition
   local absSize = self.scrubberArea.AbsoluteSize
   --accounts offset and converts to scale
   local adjustedPosition = (mousePosition-absPosition) / absSize;

   self.scrubber.Position = UDim2.fromScale(Scrubber._snapScrubber(adjustedPosition),0);
end

function Scrubber:Destroy()
    self.scrubber:Destroy();
    self:DisconnectDragging();
end

return Scrubber;