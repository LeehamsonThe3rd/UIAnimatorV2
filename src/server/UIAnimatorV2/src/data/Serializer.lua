local GoodSignal = require(script.Parent.Parent.dependencies.GoodSignal);

local Serializer = {};
Serializer.__index = Serializer;

local instance = nil;

function Serializer:_checkExists()
    if not instance then return end;
    instance:Destroy();
    instance = self;
end

function Serializer.new()
    local self = setmetatable({}, Serializer);

    self:_checkExists();

    return self;
end

function Serializer:CreateChild(animation: ModuleScript, child: Folder)
    local folder = Instance.new("Folder");
    folder.Parent = animation;
    folder.Name = child.Name;

    local association = Instance.new("ObjectValue");
    association.Parent = folder;
    association.Name = "AssociatedGui";
    association.Value = child

    return folder;
end

function Serializer._createKey(curveType: string, time: number, value: any): any
    if curveType == "UDim2" then
        return {
            FloatCurveKey.new(time, value.X.Offset, Enum.KeyInterpolationMode.Linear),
            FloatCurveKey.new(time, value.Y.Offset, Enum.KeyInterpolationMode.Linear),
            FloatCurveKey.new(time, value.X.Scale, Enum.KeyInterpolationMode.Linear),
            FloatCurveKey.new(time, value.Y.Scale, Enum.KeyInterpolationMode.Linear),
        };
    elseif curveType == "Color3" then
        return {
            FloatCurveKey.new(time, value.R, Enum.KeyInterpolationMode.Linear),
            FloatCurveKey.new(time, value.G, Enum.KeyInterpolationMode.Linear),
            FloatCurveKey.new(time, value.B, Enum.KeyInterpolationMode.Linear),
        };
    elseif curveType == "Vector2" then
        return {
            FloatCurveKey.new(time, value.X, Enum.KeyInterpolationMode.Linear),
            FloatCurveKey.new(time, value.Y, Enum.KeyInterpolationMode.Linear),
        };
    elseif curveType == "number" then
        return {
            FloatCurveKey.new(time, value, Enum.KeyInterpolationMode.Linear),
        };
    elseif curveType == "boolean" then
        if value == true then value = 1 end; --this is for booleans only (type casting)
        if value == false then value = 0 end;
        return {
            FloatCurveKey.new(time, value, Enum.KeyInterpolationMode.Constant),
        };
    end
end

function Serializer:CreateProperty(animationChild: Folder, property: string, value: any)
    local curveType = typeof(value);
    local curve = script.Parent.Parent.Parent.curves:FindFirstChild(curveType);
    if curve then
        local propertyCurve = curve:Clone();
        propertyCurve.Parent = animationChild;
        propertyCurve.Name = property;
        return propertyCurve;
    end
    return nil;
end

function Serializer:SetProperty(propertyCurve: any, time: number, value: any)
    local curveType = typeof(value);
    local key = Serializer._createKey(curveType, time, value);
	
	propertyCurve = require(propertyCurve);
	propertyCurve.InsertKey(key);
end

function Serializer:_getChild(animation: GuiObject, child: GuiObject)
    for _,v in pairs(animation:GetChildren()) do
        if not v:FindFirstChild("AssociatedGui") then continue end;
        if v.AssociatedGui.Value == child then return v end;
    end
    return nil;
end

function Serializer:SaveProperty(animation: ModuleScript, child: Folder, property: string, time: number, value: any)
    local animationChild = Serializer:_getChild(animation, child);
    if not animationChild then animationChild = self:CreateChild(animation, child) end;

    if string.find(property, "Color") and not string.find(property, "Color3") then
        property = property.."3"; --ROBLOX DOESNT ADD 3 TO COLOR3!?!?
    end

    local propertyCurve = animationChild:FindFirstChild(property);
    if not propertyCurve then propertyCurve = self:CreateProperty(animationChild, property, value) end;
    self:SetProperty(propertyCurve, time, value);
end

function Serializer:RemoveKeyFromProperty(animation: ModuleScript, child: Folder, property: string, index: number)
    local animationChild = Serializer:_getChild(animation, child);
    if not animationChild then return end;

    local propertyCurve = animationChild:FindFirstChild(property);
    if not propertyCurve then return end;

    if propertyCurve:IsA("FloatCurve") then
        propertyCurve:RemoveKeyAtIndex(index);
        return;
    end
    propertyCurve = require(propertyCurve);
    propertyCurve.RemoveKeyAtIndex(index);
end

function Serializer:SetPropertyKeyInterpolationMode(animation: ModuleScript, child: Folder, property: string, index: number, mode: Enum.KeyInterpolationMode)
    local animationChild = Serializer:_getChild(animation, child);
    if not animationChild then return end;

    local propertyCurve = animationChild:FindFirstChild(property);
    if not propertyCurve then return end;

    local key;
    propertyCurve = require(propertyCurve);
    key = propertyCurve.GetKeyAtIndex(index);
    for _,v in pairs(key) do
        v.Interpolation = mode;
    end
    self:RemoveKeyFromProperty(animation, child, property, index);
    propertyCurve.InsertKey(key, true);
end

return Serializer;