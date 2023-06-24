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

    self:ConnectScrubberEvents();
    self:ConnectPreviewEvents();
    self:ConnectDeserializerEvents();

    return self;
end

function Editor:Update(dt, time)
    self.scrubber:SetPosition(time);
end

function Editor:UpdateProperties(config: {})
    self.preview:SetLength(config.length);
    self.timeline:SetFramerate(config.framerate);
    self.scrubber:SetLength(config.length);
    self.scrubber:SetFramerate(config.framerate);
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

return Editor;