local Selection = game:GetService("Selection");
local Editor = require(script.Parent.gui.Editor);
local Creator = require(script.Parent.gui.Creator);

local ContextMenu = require(script.Parent.gui.base.ContextMenu);
local ContextButton = require(script.Parent.gui.base.ContextButton);
local SubContextMenu = require(script.Parent.gui.base.SubContextMenu);

local PluginManager = {};
PluginManager.__index = PluginManager;

function PluginManager.new(plugin : Plugin)
    local self = setmetatable({}, PluginManager);

    self.plugin = plugin;
    self.editing = nil;

    self.dockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        true,
        false,
        1200,
        200,
        800,
        200
    );
    self:CreateWindow();
    self:CreateToolbar();
    self:CreateToolbarButtons();
    self:ConnectEvents();
    self:ConnectFileContextMenuEvents();

    return self;
end

function PluginManager:CreateWindow()
    self.dockWidgetPluginGui = self.plugin:CreateDockWidgetPluginGui("UIAnimator V2", self.dockWidgetPluginGuiInfo);
    self.dockWidgetPluginGui.Title = "UIAnimator V2";
    script.Parent.Parent.gui.Main:Clone().Parent = self.dockWidgetPluginGui;
    script.Parent.Parent.gui.CreationWindow:Clone().Parent = self.dockWidgetPluginGui;

    self.editor = Editor.new(self.dockWidgetPluginGui);
    self.creator = Creator.new(self.dockWidgetPluginGui);
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
    return nil;
end

function PluginManager:CreateFile(fileName: string)
    local cachedSelection = Selection:Get();
    if #cachedSelection ~= 1 then
        warn("[UIAnimator V2] please have the PARENT selected")
        return;
    end;

    local newFile = script.Parent.gui.UIAnimation:Clone()
    newFile.Name = fileName;
    newFile.Parent = cachedSelection[1];
end

function PluginManager:OpenFile(file: ModuleScript?)
    local animation = file;
    if not file then
        local cachedSelection = Selection:Get();
        if self.editing ~= nil then self.editor:SelectionChanged(cachedSelection) end;
        if #cachedSelection > 1 then return end;

        local select = cachedSelection[1];
        if not select or select == self.editing then return end;
        if not select:IsA("ScreenGui") then return end;

        animation = PluginManager._getAnimation(select);
        if not animation then
            self.creator:Prompt();
            return;
        end

        self.editing = select;
    end

    self.dockWidgetPluginGui.Title = "UIAnimator V2 - "..self.editing.Name;
    self.editor:SetAnimation(animation);
    self.editor:SetParentFrame(self.editing);
end

function PluginManager:CloseFile()
    self.dockWidgetPluginGui.Title = "UIAnimator V2"
    self.editor:Reset();
end

function PluginManager:WindowResized(property: string)
    if not property == "AbsoluteSize" then return end;
    self.editor:WindowResized();
end

function PluginManager:ConnectEvents()
    Selection.SelectionChanged:Connect(function() self:OpenFile() end);
    self.dockWidgetPluginGui.Changed:Connect(function(...) self:WindowResized(...) end);
    self.creator.Creating:Connect(function(...) self:CreateFile(...) end)
    self.editor.FileCreationRequesting:Connect(function()
        self.creator:Prompt();
    end)
end

function PluginManager:_getAnimationsAsButtons()
    if not self.editing then return end;
    local buttons = {}
    for _,v in pairs(self.editing:GetChildren()) do
        if not v:GetAttribute("CLASS_UI_ANIMATION") then continue end;
        table.insert(buttons, ContextButton.new(v.Name, function()
            self:OpenFile(v);
        end))
    end
    return buttons;
end

function PluginManager:ConnectFileContextMenuEvents()
    self.dockWidgetPluginGui.Main.Topbar.More.MouseButton1Click:Connect(function()
        local animationButtons = self:_getAnimationsAsButtons();
        local animationSubContextMenu;
        if animationButtons then
            animationSubContextMenu = SubContextMenu.new(self.dockWidgetPluginGui, animationButtons)
        end

        ContextMenu.new(self.dockWidgetPluginGui, {
            ContextButton.new("New Animation", function()
                self.creator:Prompt();
            end),
            ContextButton.new("Load Animation", animationSubContextMenu);
            ContextButton.new("Exit", function()
                self:CloseFile();
            end),
        })
    end)
end

return PluginManager;