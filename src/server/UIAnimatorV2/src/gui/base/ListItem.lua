local GoodSignal = require(script.Parent.Parent.Parent.dependencies.GoodSignal)

local ListItem = {};
ListItem.__index = ListItem;

function ListItem.new(parent: any, name: string, id: number, expanded: boolean, selectFunction: ()->()?)
    local self = setmetatable({}, ListItem);

    self._parent = parent
    self._name = name;
    self._id = id;
    self._expanded = expanded;
    self.selectFunction = selectFunction;
    self.item = self:CreateButton();
    self.selection = nil;
    self.selectConnection = nil

    self.Expanding = GoodSignal.new()

    return self;
end

function ListItem:GetExpanded()
    return self._expanded
end

function ListItem:GetId()
    return self._id;
end

function ListItem:Deselect()
    if self.selection then self.selection:Destroy() end
end

function ListItem:Highlight()
    local selection = Instance.new("Frame")
    selection.Parent = self._parent
    selection.Position = UDim2.fromOffset(0,25*self._id);
    selection.Size = UDim2.new(1,0,0,25);
    selection.ZIndex = 5;
    selection.BackgroundColor3 = Color3.fromHex("#00a2ff");
    selection.BorderSizePixel = 0;
    self.selection = selection
end

function ListItem:Select()
    if not self.selectFunction then return end;

    self:Deselect();
    self:Highlight();
    self.selectFunction();
end

function ListItem:CreateButton(): ImageButton
    local label = Instance.new("Frame");
    label.Parent = self._parent;
    label.Name = "label";
    label.Position = UDim2.fromOffset(0,25*self._id);
    label.BackgroundColor3 = Color3.fromHex("#FFFFFF");
    label.BackgroundTransparency = 0.95;
    label.Size = UDim2.new(10,0,0,25);
    label.BorderSizePixel = 0;
    label.ZIndex = 5;

    if self._id%2 == 0 then
        label.BackgroundTransparency = 1
    end

    local button = Instance.new("TextButton")
    button.Parent = label
    button.Name = "button"
    button.Size = UDim2.fromScale(0.1,1);
    button.Position = UDim2.fromOffset(5,1);
    button.BackgroundTransparency = 1;
    button.TextColor3 = Color3.fromHex("#FFFFFF");
    button.TextXAlignment = Enum.TextXAlignment.Left;
    button.Text = ' '..self._name;
    button.ZIndex = 6;
    button.AutoButtonColor = false;

    self.selectConnection = button.MouseButton1Click:Connect(function() self:Select() end)

    local expandButton = Instance.new("TextButton");
    expandButton.Parent = label;
    expandButton.Name = "expand";
    expandButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    expandButton.Size = UDim2.new(0,25,1,0);
    expandButton.Position = UDim2.fromScale(0.09,0);
    expandButton.BackgroundTransparency = 1;
    expandButton.TextColor3 = Color3.fromHex("#FFFFFF");
    expandButton.Text = "^";
    expandButton.ZIndex = 7;
    expandButton.Rotation = 0;
    if not self._expanded then expandButton.Rotation = 180 end;

    self.expandConnection = expandButton.MouseButton1Click:Connect(function() self.Expanding:Fire(self._expanded) end)

    return label;
end

function ListItem:SetHorizontalOffset(offset: number)
    self.item.button.Position += UDim2.fromOffset(offset,0);
end

function ListItem:SetExpansionEnabled(enabled: boolean)
    self.item.expand.Visible = enabled;
end

function ListItem:Destroy()
    self.item:Destroy();
    self:Deselect();
    if self.selectConnection then self.selectConnection:Disconnect() end;
    if self.expandConnection then self.expandConnection:Disconnect() end;
end

return ListItem;