local RunService = game:GetService("RunService")

local DraggableFrame = {};
DraggableFrame.__index = DraggableFrame;

function DraggableFrame.new(frame : Frame?)
    local self = setmetatable({}, DraggableFrame);

    self.frame = frame

    self.dragBegin = nil
    self.dragEnd = nil
    self.dragUpdate = nil;

    return self;
end

function DraggableFrame:Hold(inputObject : InputObject)
    if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end;
    self.dragUpdate = RunService.Heartbeat:Connect(function() self:Drag() end);
end

function DraggableFrame:Drag(inputObject : InputObject)
    --drag code
end

function DraggableFrame:Release(inputObject : InputObject)
    if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end;
    if self.dragUpdate then self.dragUpdate:Disconnect(); end
end

function DraggableFrame:ConnectDragging()
    self.dragBegin = self.frame.InputBegan:Connect(function(...) self:Hold(...) end);
    self.dragEnd = self.frame.InputEnded:Connect(function(...) self:Release(...) end);
end

function DraggableFrame:DisconnectDragging()
    self.dragBegin:Disconnect();
    self.dragEnd:Disconnect();
    if self.dragUpdate then self.dragUpdate:Disconnect() end;
end

function DraggableFrame:Destroy()
    self.frame:Destroy();
    self:DisconnectDragging();
end

return DraggableFrame