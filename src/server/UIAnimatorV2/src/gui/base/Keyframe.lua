local DraggableFrame = require(script.Parent.DraggableFrame);
local ContextMenu = require(script.Parent.ContextMenu);
local SubContextMenu = require(script.Parent.SubContextMenu);
local ContextButton = require(script.Parent.ContextButton);
local GoodSignal = require(script.Parent.Parent.Parent.dependencies.GoodSignal);

local Keyframe = setmetatable({}, DraggableFrame);
Keyframe.__index = Keyframe;

function Keyframe.new(parent: GuiObject, position: UDim2, length: number, framerate: number, dockWidgetPluginGui: DockWidgetPluginGuiInfo)
    local self = setmetatable({}, Keyframe);

    self.dockWidgetPluginGui = dockWidgetPluginGui;
    self.parent = parent;
    self.frame = self:CreateButton(position);

    self._length = length;
    self._framerate = framerate;
    self._interpolationOptionsEnabled = true;

    self.dragBegin = nil;
    self.dragEnd = nil;
    self.dragUpdate = nil;
    self.rightClick = nil;

    self.Moved = GoodSignal.new();
    self.Destroying = GoodSignal.new();
    self.InterpolationModeChanged = GoodSignal.new();

    self:ConnectRightClick();
    self:ConnectDragging();

    return self;
end

function Keyframe:CreateButton(position: UDim2)
    local keyframe = Instance.new("ImageButton");
    keyframe.Name = "keyframe";
    keyframe.Parent = self.parent;
    keyframe.Position = UDim2.new(position.X.Scale,0,0,position.Y.Offset+37);
    keyframe.Size = UDim2.fromOffset(14,14);
    keyframe.BackgroundTransparency = 1;
    keyframe.Image = "http://www.roblox.com/asset/?id=12146009347";
    keyframe.ZIndex = 9;
    keyframe.AnchorPoint = Vector2.new(0.5,0.5);

    return keyframe;
end

function Keyframe._snapKeyframe(percent: number, length: number, framerate: number): number
    --both clamps the position and rounds it for fixed timestep positions
    local frames = (length*framerate);
    return math.clamp(math.floor(percent*frames)/frames,0,1);
end

function Keyframe:Drag(inputObject: InputObject)
    local mousePosition = self.dockWidgetPluginGui:GetRelativeMousePosition();
    local absPosition = self.parent.AbsolutePosition;
    local absSize = self.parent.AbsoluteSize;
    --accounts offset and converts to scale
    local adjustedPosition = (mousePosition-absPosition) / absSize;
    local newPosition = UDim2.new(Keyframe._snapKeyframe(adjustedPosition.X,self._length,self._framerate),0,0,self.frame.Position.Y.Offset);

    self.frame.Position = newPosition
end

function DraggableFrame:Release(inputObject: InputObject)
    if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end;
    if self.dragUpdate then self.dragUpdate:Disconnect(); end;

    self.Moved:Fire(self.frame.Position.X.Scale);
end

function Keyframe:SetInterpolationOptionsEnabled(enabled: boolean)
    self._interpolationOptionsEnabled = enabled;
end

function Keyframe:OpenContextMenu()
    local contextButtons = {
        ContextButton.new("Delete", function()
            self:Destroy()
            self.Destroying:Fire();
         end),
        ContextButton.new("Interpolation Mode", SubContextMenu.new(self.dockWidgetPluginGui, {
            ContextButton.new("Linear", function()
                self.InterpolationModeChanged:Fire(Enum.KeyInterpolationMode.Linear);
            end),
            ContextButton.new("Cubic", function()
                self.InterpolationModeChanged:Fire(Enum.KeyInterpolationMode.Cubic);
            end),
            ContextButton.new("Constant", function()
                self.InterpolationModeChanged:Fire(Enum.KeyInterpolationMode.Constant);
            end),
        })),
    }
    if not self._interpolationOptionsEnabled then table.remove(contextButtons, 2) end;

    ContextMenu.new(self.dockWidgetPluginGui, contextButtons);
end

function Keyframe:ConnectRightClick()
    self.rightClick = self.frame.MouseButton2Click:Connect(function() self:OpenContextMenu() end)
end

function Keyframe:DisconnectRightClick()
    self.rightClick:Disconnect();
end

function Keyframe:Destroy()
    self.frame:Destroy();
    self:DisconnectDragging();
    self:DisconnectRightClick();
end

return Keyframe;