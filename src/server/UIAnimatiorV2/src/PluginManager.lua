local Selection = game:GetService("Selection")
local Editor = require(script.Parent.gui.Editor);

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
    self:ConnectEvents();

    return self;
end

function PluginManager:CreateWindow()
    self.dockWidgetPluginGui = self.plugin:CreateDockWidgetPluginGui("UIAnimator V2", self.dockWidgetPluginGuiInfo);
    self.dockWidgetPluginGui.Title = "UIAnimator V2";
    script.Parent.Parent.gui.Main:Clone().Parent = self.dockWidgetPluginGui;

    self.editor = Editor.new(self.dockWidgetPluginGui);
end

function PluginManager:CreateToolbar()
    self.pluginToolbar = self.plugin:CreateToolbar("UIAnimator V2");
end

function PluginManager:CreateToolbarButtons()
    self.pluginButton = self.pluginToolbar:CreateButton("UIAnimator V2", "", "rbxassetid://13773600899");
    self.pluginButton.Click:Connect(function() self.dockWidgetPluginGui.Enabled = true end);
end

function PluginManager._getAnimation(parent : Frame) : ModuleScript
    for _,v in pairs(parent:GetChildren()) do
        if v:GetAttribute("CLASS_UI_ANIMATION") then return v end;
    end
    return nil
end

function PluginManager:OpenFile()
    local cachedSelection = Selection:Get();
    if cachedSelection:Get() > 1 then return end;
    
    local select = cachedSelection[1];
    if not select:IsA("Frame") then return end;

    local animation = PluginManager._getAnimation(select)
    if not animation then
        warn("TODO: prompt user to create animation")
        return
    end

    _G.animation = require(animation)
end

function PluginManager:ConnectEvents()
    Selection.SelectionChanged:Connect(function() self:OpenFile() end);
end

return PluginManager;