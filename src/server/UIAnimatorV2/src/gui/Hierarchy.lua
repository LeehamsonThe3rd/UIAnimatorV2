local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal)
local Selection = game:GetService("Selection")
local ListItem = require(script.Parent.base.ListItem)

local Hierarchy = {};
Hierarchy.__index = Hierarchy;

function Hierarchy.new(dockWidgetPluginGui: DockWidgetPluginGui)
    local self = setmetatable({}, Hierarchy);

    self.hierarchy = dockWidgetPluginGui.Main:WaitForChild("Hierarchy");

    self._animation = nil;
    self.root = nil;
    self.rootFrame = nil;
    self._expandedItems = {}
    self.children = {};
    self.changedConnections = {};

    self.ChildChanged = GoodSignal.new();
    self.Redrawing = GoodSignal.new();

    return self;
end

function Hierarchy:SetAnimation(animation: ModuleScript)
    self._animation = animation;
end

function Hierarchy:GetChildren()
    return self.children;
end

function Hierarchy:SetRoot(root: Frame): Frame
    if self.root then
        self.root = nil;
        self.rootFrame:Destroy();
    end

    self.root = root;
    self.rootFrame = ListItem.new(self.hierarchy, root.Name.." (root)", 0);
    return self.rootFrame;
end

function Hierarchy:Select(object: any)
    Selection:Set({object});
end

function Hierarchy:SetSelected(selection: {})
    self:DeselectAll()
    for _,v in pairs(selection) do
        if not v:IsA("GuiObject") then continue end;

        local item = self:GetItem(v)
        if item then item:Highlight() end;
    end
end

function Hierarchy:DeselectAll()
    for _,v in pairs(self.children) do
        v:Deselect();
    end
end

function Hierarchy:AddChild(index: number, child: GuiObject, expanded: boolean)
    local childItem = ListItem.new(self.hierarchy, child.Name, index, expanded, function()
        self:DeselectAll();
        self:Select(child);
    end);
    childItem.AssociatedGui = child;

    table.insert(self.changedConnections, childItem.Expanding:Connect(function(expanded: boolean)
        if not expanded then
            self._expandedItems[child] = true;
        else
            self._expandedItems[child] = false;
        end
        self.Redrawing:Fire();
    end));
    table.insert(self.children, childItem);
    table.insert(self.changedConnections, child.Changed:Connect(function(...) self.ChildChanged:Fire(child, ...) end));
    return childItem;
end

function Hierarchy:AddChildProperties(child: GuiObject, indexOffset: number)
    local animationData = self:_getDataFromAnimation(child);
    local offset = 0
    if not animationData then return offset end;
    for _,v in pairs(animationData:GetChildren()) do
        if not v:IsA("ModuleScript") then continue end;
        offset += 1;
        local child = self:AddChild(offset+indexOffset,v,false)
        child:SetHorizontalOffset(10);
        child:SetExpansionEnabled(false);
    end
    return offset;
end

function Hierarchy:_getDataFromAnimation(child: GuiObject)
    for _,v in pairs(self._animation:GetChildren()) do
        local gui = v:FindFirstChild("AssociatedGui")
        if gui and gui.Value == child then return v end
    end
end

function Hierarchy:ClearAllChildren()
    for _,v in pairs(self.children) do
        for _,folder in pairs(self._animation:GetChildren()) do --annoying nested loop because of the weird storage method (there is probably a better way to do this)
            if not folder:IsA("Folder") then continue end
            if v.AssociatedGui == folder.AssociatedGui.Value and v.AssociatedGui.Parent == nil then folder:Destroy() end
        end
        v:Destroy();
    end;
    for _,v in pairs(self.changedConnections) do v:Disconnect() end;
    self.children = {};
end

function Hierarchy:Draw()
    self:ClearAllChildren();
    if not self.root then return end;
    local i = 1
    for _,v in pairs(self.root:GetDescendants()) do
        if v:IsA("GuiObject") then
            local expanded = self._expandedItems[v];
            if not expanded then
                self:AddChild(i,v,false);
                i += 1;
                continue;
            else
                self:AddChild(i,v,true);
                if self._expandedItems[v] then i += self:AddChildProperties(v,i) end;
                i += 1;
                continue;
            end
        end
    end
end

function Hierarchy:GetItem(child: GuiObject): {}
    for _,v in pairs(self.children) do
        if v.AssociatedGui == child then return v end;
    end
    return nil;
end

return Hierarchy;