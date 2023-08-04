local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal);

local Creator = {};
Creator.__index = Creator;

function Creator.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Creator);

    self._dockWidgetPluginGui = dockWidgetPluginGui;
    self._creationWindow = dockWidgetPluginGui:WaitForChild("CreationWindow");

    self.Creating = GoodSignal.new()

    self:_connectEvents();

    return self;
end

function Creator:Prompt()
    self._creationWindow.Visible = true;
end

function Creator:_close()
    self._creationWindow.Visible = false;
end

function Creator:_connectEvents()
    self._createConnection = self._creationWindow.Frame.Create.MouseButton1Click:Connect(function()
        local fileName = self._creationWindow.Frame.AnimationName.Text;
        self.Creating:Fire(fileName);
        self:_close();
    end)

    self._cancelConnection = self._creationWindow.Frame.Cancel.MouseButton1Click:Connect(function()
        self:_close()
    end)
end

function Creator:Destroy()
    self._createConnection:Disconnect();
    self._cancelConnection:Disconnect();
end

return Creator;