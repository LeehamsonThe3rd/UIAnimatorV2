local ContextMenu = require(script.Parent.ContextMenu)
local GoodSignal = require(script.Parent.Parent.Parent.dependencies.GoodSignal)

local SubContextMenu = setmetatable({}, ContextMenu);
SubContextMenu.__index = SubContextMenu;

function SubContextMenu.new(dockWidgetPluginGui: DockWidgetPluginGui, contextButtons: {})
    local self = setmetatable({}, SubContextMenu);

    self.parent = dockWidgetPluginGui;
    self.frame = self:CreateMenu(dockWidgetPluginGui:GetRelativeMousePosition(), #contextButtons);
    self.contextButtonConnections = {};
    self.contextButtons = self:CreateButtons(contextButtons);

    self.frame.ZIndex = 30; --for making it go on top

    self._buttonHeld = false;
    self._menuHover = false;
    self:UpdateVisibility();

    self.ButtonClicked = GoodSignal.new();

    self:ConnectHoverEvents();

    return self;
end

function SubContextMenu:CreateButtons(contextButtons: {})
    for i,v in pairs(contextButtons) do
        v:SetParent(self.frame);
        v:SetOffset(i-1);
        v.button.ZIndex = 31;
        table.insert(self.contextButtonConnections, v.Clicked:Connect(function() self.ButtonClicked:Fire() end));
    end

    return contextButtons;
end

function SubContextMenu:UpdateVisibility()
    self.frame.Visible = true;
    if not self._buttonHeld and not self._menuHover then
        self.frame.Visible = false;
    end
end

function SubContextMenu:SetEnabled(enabled: boolean)
    self._buttonHeld = enabled;
    self:UpdateVisibility();
end

function SubContextMenu:SetOffset(offset: Vector2)
    local XOffset = offset.X+self.frame.AbsoluteSize.X;
    if XOffset+self.frame.AbsoluteSize.X > self.parent.AbsoluteSize.X then --flips side if offscreen
        XOffset = offset.X-self.frame.AbsoluteSize.X;
    end

    local newPosition = UDim2.fromOffset(XOffset, math.clamp(offset.Y, 0, self.parent.AbsoluteSize.Y-self.frame.AbsoluteSize.Y)); --moves frame if offscreen
    self.frame.Position = newPosition
end

function SubContextMenu:ConnectHoverEvents()
    self.enterConnection = self.frame.MouseEnter:Connect(function()
        self._menuHover = true;
        self:UpdateVisibility();
     end);
    self.leaveConnection = self.frame.MouseLeave:Connect(function()
        self._menuHover = false;
        self:UpdateVisibility();
    end);
end

function SubContextMenu:DisconnectHoverEvents()
    self.enterConnection:Disconnect()
    self.leaveConnection:Disconnect()
end

function SubContextMenu:Destroy()
    self.frame:Destroy();
    self:DestroyButtons();

    self:DisconnectHoverEvents();
end

return SubContextMenu;