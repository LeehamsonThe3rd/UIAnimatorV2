local Timeline = require(script.Parent.Timeline);
local Scrubber = require(script.Parent.Scrubber);

local Editor = {};
Editor.__index = Editor;

function Editor.new(dockWidgetPluginGui : DockWidgetPluginGui)
    local self = setmetatable({}, Editor);

    self.timeline = Timeline.new(dockWidgetPluginGui);
    self.scrubber = Scrubber.new(dockWidgetPluginGui);

    return self;
end

return Editor;