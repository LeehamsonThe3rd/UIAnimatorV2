local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal);

local Preview = require(script.Parent.Preview);
local Timeline = require(script.Parent.Timeline);
local Scrubber = require(script.Parent.Scrubber);
local Hierarchy = require(script.Parent.Hierarchy)
local Deserializer = require(script.Parent.Parent.data.Deserializer);
local Serializer = require(script.Parent.Parent.data.Serializer);

local Editor = {};
Editor.__index = Editor;

local illegalProperties = {
    "AbsolutePosition",
    "AbsoluteSize",
    "AbsoluteRotation",
    "ContentText",
    "TextBounds",
    "TextFits",
    "AbsoluteCanvasSize",
    "AbsoluteWindowSize",
    "Parent",
    "Name",
    "IsNotOccluded",
}

function Editor.new(dockWidgetPluginGui : DockWidgetPluginGui)
    local self = setmetatable({}, Editor);

    self._dockWidgetPluginGui = dockWidgetPluginGui;
    self.preview = Preview.new(dockWidgetPluginGui);
    self.timeline = Timeline.new(dockWidgetPluginGui);
    self.scrubber = Scrubber.new(dockWidgetPluginGui);
    self.hierarchy = Hierarchy.new(dockWidgetPluginGui);
    self.deserializer = Deserializer.new();
    self.serializer = Serializer.new();

    self.FileCreationRequesting = GoodSignal.new();

    self.animation = nil;

    self._length = 2
    self._framerate = 30

    self:ConnectScrubberEvents();
    self:ConnectPreviewEvents();
    self:ConnectHierarchyEvents();
    self:ConnectDeserializerEvents();
    self:ConnectTimelineEvents();

    return self;
end

function Editor:Refresh()
    self.hierarchy:Draw();
    self.timeline:DrawKeys(self.animation, self.hierarchy);
end

function Editor:SetParentFrame(parent: Frame)
    self.hierarchy:SetRoot(parent);
    self:Refresh();
    parent.ChildAdded:Connect(function() self:Refresh() end);
    parent.ChildRemoved:Connect(function() self:Refresh() end);
end

function Editor:Update(dt, time)
    self.scrubber:SetPosition(time/self._length);
end

function Editor._addThreeDots(string: string)
    if #string > 20 then
        string = string.sub(string, 1, 20) .. "..."
    end
    return string
end

function Editor:SetAnimation(animation: ModuleScript)
    self.animation = animation;
    self.deserializer:LoadAnimation(animation);
    self.preview:SetAnimation(self.animation);
    self.hierarchy:SetAnimation(self.animation);
    self._dockWidgetPluginGui.Main.Topbar.AnimationName.Text = Editor._addThreeDots(animation.Name);
end

function Editor:SetLength(length: number)
    self._length = length;
    self.animation:SetAttribute("length", length);
    self:SetProperties();
end

function Editor:Reset()
    self.hierarchy:ClearAllChildren(self.animation);
    self.timeline:ClearKeys();
    self.preview:SetAnimation(nil);
    self.hierarchy:SetAnimation(nil);
    self.animation = nil;
    self.FileCreationRequesting:Fire();
end

function Editor:UpdateProperties(config: {})
    self._length = config.length;
    self._framerate = config.framerate;
    self:SetProperties();
end

function Editor:SetProperties()
    self.preview:SetLength(self._length);
    self.preview:SetFramerate(self._framerate);
    self.timeline:SetLength(self._length);
    self.timeline:SetFramerate(self._framerate);
    self.scrubber:SetLength(self._length);
    self.scrubber:SetFramerate(self._framerate);
end

function Editor._isIllegalProperty(property: string)
    for _,v in pairs(illegalProperties) do
        if v == property then return true end;
    end
    return false;
end

function Editor:UpdateChild(child: Folder, property: string, time: number?, value: any?, index: number?)
    if not time then time = self.scrubber:GetTime() end;
    if not value then
        if string.find(property, "Color") and not string.find(property, "Color3") then
            property = property.."3"; --ROBLOX DOESNT ADD 3 TO COLOR3!?!?
        end

        if Editor._isIllegalProperty(property) then return end;
        local success, error = pcall(function()
            value = child[property];
        end)
        if not success then warn(error) return end;
    end;

    if property == "Name" then self:Refresh() end;
    if Editor._isIllegalProperty(property) or self.preview:IsPlaying() then return end;

    if index then
        self.serializer:RemoveKeyFromProperty(self.animation, child, property, index)
    end

    self.serializer:SaveProperty(self.animation, child, property, time, value);
    self:Refresh();
end

function Editor:RemoveChildKeyframe(child: Folder, property: string, index: number?)
    self.serializer:RemoveKeyFromProperty(self.animation, child, property, index);
end

function Editor:SetChildKeyframeInterpolationMode(child: Folder, property: string, index: number?, mode: Enum.KeyInterpolationMode)
    self.serializer:SetPropertyKeyInterpolationMode(self.animation, child, property, index, mode);
end

function Editor:ConnectScrubberEvents()
    self.scrubber.Moved:Connect(function(...) self.preview:SetTime(...) end);
end

function Editor:ConnectPreviewEvents()
    self.preview.Updated:Connect(function(...) self:Update(...) end);
    self.preview.LengthChanged:Connect(function(...) self:SetLength(...) end);
    self.preview.TimeChanged:Connect(function(t) self.scrubber:SetPosition(t/self._length); end);
end

function Editor:ConnectTimelineEvents()
    self.timeline.Resized:Connect(function() self.timeline:DrawKeys(self.animation, self.hierarchy); end);
    self.timeline.KeyframeMoved:Connect(function(...) self:UpdateChild(...) end);
    self.timeline.KeyframeDestroying:Connect(function(...) self:RemoveChildKeyframe(...) end);
    self.timeline.KeyframeInterpolationModeChanged:Connect(function(...) self:SetChildKeyframeInterpolationMode(...) end);
    self.timeline.timeline.Keyframes.Changed:Connect(function(p)
        if p == "CanvasPosition" then
            self.hierarchy.hierarchy.CanvasPosition = self.timeline.timeline.Keyframes.CanvasPosition;
        end
    end);
end

function Editor:ConnectHierarchyEvents()
    self.hierarchy.ChildChanged:Connect(function(...) self:UpdateChild(...) end);
    self.hierarchy.Redrawing:Connect(function() self:Refresh() end)
    self.hierarchy.hierarchy.Changed:Connect(function(p)
        if p == "CanvasPosition" then --auto resizing but they didn't really need their own functions
            self.timeline.timeline.Keyframes.CanvasPosition = self.hierarchy.hierarchy.CanvasPosition;
        elseif p == "AbsoluteCanvasSize" then
            local size = self.hierarchy.hierarchy.AbsoluteCanvasSize;
            self.timeline.timeline.Keyframes.CanvasSize = UDim2.new(0.95, 0, 0, size.Y+25);
        end
    end)
end

function Editor:ConnectDeserializerEvents()
    self.deserializer.ConfigurationLoaded:Connect(function(...) self:UpdateProperties(...) end);
end

function Editor:SelectionChanged(selection: {})
    self.hierarchy:SetSelected(selection);
end

function Editor:WindowResized()
    self.timeline:Resize();
end

return Editor;