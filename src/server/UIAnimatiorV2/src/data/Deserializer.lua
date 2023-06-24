local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal);

local Deserializer = {};
Deserializer.__index = Deserializer;

local instance = nil;

function Deserializer:_checkExists()
    if not instance then return end;
    instance:Destroy();
    instance = self;
end

function Deserializer.new()
    local self = setmetatable({}, Deserializer);

    self.ConfigurationLoaded = GoodSignal.new();

    self:_checkExists();

    return self;
end

function Deserializer:LoadAnimation(animation: {})
    self.ConfigurationLoaded:Fire(animation.config);
end

return Deserializer;