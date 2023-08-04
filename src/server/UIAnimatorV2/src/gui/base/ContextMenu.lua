local ContextMenu = {};
ContextMenu.__index = ContextMenu

local instance;

function ContextMenu:_checkInstances()
    if instance then instance:Destroy() end
    instance = self;
end

function ContextMenu.new(dockWidgetPluginGui: DockWidgetPluginGui, contextButtons: {})
    local self = setmetatable({}, ContextMenu);

    self.parent = dockWidgetPluginGui;
    self.frame = self:CreateMenu(dockWidgetPluginGui:GetRelativeMousePosition(), #contextButtons);
    self.contextButtonConnections = {};
    self.contextButtons = self:CreateButtons(contextButtons);
    self.focusButton = self:CreateFocusButton()

    self:_checkInstances();
    return self;
end

local function Vector2Clamp(v : Vector2, n : number, m : number)
	return Vector2.new(math.clamp(v.X,n,m),math.clamp(v.Y,n,m))
end

function ContextMenu:CreateMenu(mousePosition: Vector2, buttons: number)
    local frame = Instance.new("Frame");
    frame.Parent = self.parent;
    frame.Name = "ctxmenu";
    frame.Size = UDim2.fromOffset(150,25*buttons);
    frame.ZIndex = 20;
    frame.BackgroundColor3 = Color3.fromHex("#2e2e2e");
    frame.BorderSizePixel = 1;
    frame.BorderColor3 = Color3.fromHex("#000000");

    local offset = Vector2Clamp(self.parent.AbsoluteSize-(mousePosition+frame.AbsoluteSize), -math.huge, 0);
    frame.Position = UDim2.fromOffset(mousePosition.X+offset.X, mousePosition.Y+offset.Y);

    return frame
end

function ContextMenu:CreateButtons(contextButtons: {})
    for i,v in pairs(contextButtons) do
        v:SetParent(self.frame);
        v:SetOffset(i-1);
        table.insert(self.contextButtonConnections, v.Clicked:Connect(function() self:Destroy() end));
    end

    return contextButtons;
end

function ContextMenu:CreateFocusButton()
    local focusButton = Instance.new("TextButton");
    focusButton.Parent = self.parent;
    focusButton.Name = "focusframe";
    focusButton.Size = UDim2.fromScale(1,1);
    focusButton.BackgroundTransparency = 1;
    focusButton.TextTransparency = 1;
    focusButton.ZIndex = 8;

    self.unfocus = focusButton.MouseButton1Click:Connect(function() self:Destroy() end);

    return focusButton;
end

function ContextMenu:DestroyButtons()
    for _,v in pairs(self.contextButtons) do
        v:Destroy();
    end

    for _,v in pairs(self.contextButtonConnections) do
        v:Disconnect();
    end
end

function ContextMenu:Destroy()
    self.frame:Destroy();
    self.focusButton:Destroy()
    self:DestroyButtons();

    self.unfocus:Disconnect();
end

return ContextMenu;