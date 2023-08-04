local GoodSignal = require(script.Parent.Parent.Parent.dependencies.GoodSignal);

local ContextButton = {}
ContextButton.__index = ContextButton

function ContextButton.new(description: string, buttonFunction: any)
    local self = setmetatable({}, ContextButton)

    self.description = description;
    self.buttonFunction = buttonFunction;

    self.buttonConnection = nil;
    self.button = self:CreateButton();
    if typeof(self.buttonFunction) == "table" then
        self:ConnectHoverEvents();
        self.subContextMenuButtonConnection = self.buttonFunction.ButtonClicked:Connect(function()
            self.Clicked:Fire();
        end)
    end

    self.Clicked = GoodSignal.new();

    return self
end

function ContextButton:SetParent(parent: GuiObject)
    self.button.Parent = parent;
end

function ContextButton:SetOffset(offset: number)
    self.button.Position = UDim2.fromOffset(0,25*offset);
    if typeof(self.buttonFunction) == "table" then self.buttonFunction:SetOffset(self.button.AbsolutePosition) end;
end

function ContextButton:CreateButton()
    local button = Instance.new("TextButton");
    button.Text = "   "..self.description;
    button.TextXAlignment = Enum.TextXAlignment.Left;
    button.Size = UDim2.fromOffset(150,25);
    button.Position = UDim2.fromOffset(0,0);
    button.Parent = self.frame;
    button.ZIndex = 21;
    button.BackgroundTransparency = 1;
    button.TextColor3 = Color3.fromHex("#FFFFFF");
    button.BorderSizePixel = 0;

    self.clickConnection = button.MouseButton1Click:Connect(function()
        if typeof(self.buttonFunction) ~= "table" then self.buttonFunction() end;
        self.Clicked:Fire();
    end);

    return button;
end

function ContextButton:ConnectHoverEvents()
    self.enterConnection = self.button.MouseEnter:Connect(function() self.buttonFunction:SetEnabled(true) end);
    self.leaveConnection = self.button.MouseLeave:Connect(function() self.buttonFunction:SetEnabled(false) end);
end

function ContextButton:DisconnectHoverEvents()
    if not self.enterConnection then return end;
    self.enterConnection:Disconnect()
    self.leaveConnection:Disconnect()
end

function ContextButton:Destroy()
    if typeof(self.buttonFunction) == "table" then self.buttonFunction:Destroy() end;

    self.button:Destroy();
    self.clickConnection:Disconnect();

    if self.subContextMenuButtonConnection then self.subContextMenuButtonConnection:Disconnect() end;
    self:DisconnectHoverEvents();
end

return ContextButton