local Preview = require(script.Parent.Preview);
local Timeline = require(script.Parent.Timeline);
local Scrubber = require(script.Parent.Scrubber);
local Deserializer = require(script.Parent.Parent.data.Deserializer);

local Editor = {};
Editor.__index = Editor;

function Editor.new(dockWidgetPluginGui : DockWidgetPluginGui)
    local self = setmetatable({}, Editor);

    self.preview = Preview.new(dockWidgetPluginGui);
    self.timeline = Timeline.new(dockWidgetPluginGui);
    self.scrubber = Scrubber.new(dockWidgetPluginGui);
    self.deserializer = Deserializer.new();

    self._length = 2
    self._framerate = 30

    self:ConnectScrubberEvents();
    self:ConnectPreviewEvents();
    self:ConnectDeserializerEvents();

    return self;
end

function Editor:Update(dt, time)
    self.scrubber:SetPosition(time);
end

function Editor:UpdateProperties(config: {})
    self._length = config.length
    self._framerate = config.framerate

    self.preview:SetLength(self._length);
    self.timeline:SetLength(self._length);
    self.timeline:SetFramerate(self._framerate);
    self.scrubber:SetLength(self._length);
    self.scrubber:SetFramerate(self._framerate);
end

function Editor:ConnectScrubberEvents()
    self.scrubber.Moved:Connect(function(...) self.preview:SetTime(...) end);
end

function Editor:ConnectPreviewEvents()
    self.preview.Updated:Connect(function(...) self:Update(...) end);
end

function Editor:ConnectDeserializerEvents()
    self.deserializer.ConfigurationLoaded:Connect(function(...) self:UpdateProperties(...) end);
end

function Editor:WindowResized(windowSize: Vector2)
    self.timeline:Resize();
end

return Editor;