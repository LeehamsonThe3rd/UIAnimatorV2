local Editor = require(script.Parent.gui.Editor)

local PluginManager = {};
PluginManager.__index = PluginManager;

function PluginManager.new(plugin : Plugin)
    local self = setmetatable({}, PluginManager);

    self.plugin = plugin

    self.dockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        true,
        false,
        600,
        400
    );
    self:CreateWindow();
    self:CreateToolbar();
    self:CreateToolbarButtons();

    return self;
end

function PluginManager:CreateWindow()
    self.dockWidgetPluginGui = self.plugin:CreateDockWidgetPluginGui("UIAnimator V2", self.dockWidgetPluginGuiInfo);
    self.dockWidgetPluginGui.Title = "UIAnimator V2";
    script.Parent.Parent.gui.Main:Clone().Parent = self.dockWidgetPluginGui

    Editor.new()
end

function PluginManager:CreateToolbar()
    self.pluginToolbar = self.plugin:CreateToolbar("UIAnimator V2");
end

function PluginManager:CreateToolbarButtons()
    self.pluginButton = self.pluginToolbar:CreateButton("UIAnimator V2", "", "rbxassetid://13773600899");
    self.pluginButton.Click:Connect(function() self.dockWidgetPluginGui.Enabled = true end);
end

return PluginManager;