--[[
    
    IF YOU'VE CLONED THE PROJECT FROM GITHUB PLEASE READ THE FOLLOWING INFORMATION TO ENSURE PROPER FUNCTIONALITY
    THE FOLLOWING INFORMATION APPLIES TO ALL CLASSES IN THIS FOLDER:

    --FILE STRUCTURE INFORMATION--
    In order for this class to properly work we need to serialize data in float curves. A float curve
    may be created by calling Instance.new("FloatCurve", [parent])

    the following tree represents the structure that must exist in this class
    in order to ensure proper functionality:

    --UDim2.lua [ModuleScript]
        --X [Folder]
            --Offset [FloatCurve]
            --Scale [FloatCurve]
        --Y [Folder]
            --Offset [FloatCurve]
            --Scale [FloatCurve]

    --ADDITIONAL INFORMATION--
    This class unlike other classes doesn't have a proper ClassName, in order to make this object identifiable
    please add a ATTRIBUTE of type STRING called "Type" and set it's value to "UDim2"

--]]

local UDim2Curve = {};

UDim2Curve.X = {};
UDim2Curve.X.Offset = script.X.Offset;
UDim2Curve.X.Scale = script.X.Scale;

UDim2Curve.Y = {};
UDim2Curve.Y.Offset = script.Y.Offset;
UDim2Curve.Y.Scale = script.Y.Scale;

function UDim2Curve.GetKeyAtIndex(index: number)
    local XOffset = UDim2Curve.X.Offset:GetKeyAtIndex(index);
    local YOffset = UDim2Curve.Y.Offset:GetKeyAtIndex(index);
    local XScale = UDim2Curve.X.Scale:GetKeyAtIndex(index);
    local YScale = UDim2Curve.Y.Scale:GetKeyAtIndex(index);

    return {XScale, XOffset, YScale, YOffset};
end

function UDim2Curve.GetKeyIndicesAtTime(time: number)
    local XOffset = UDim2Curve.X.Offset:GetKeyIndicesAtTime(time);
    local YOffset = UDim2Curve.Y.Offset:GetKeyIndicesAtTime(time);
    local XScale = UDim2Curve.X.Scale:GetKeyIndicesAtTime(time);
    local YScale = UDim2Curve.Y.Scale:GetKeyIndicesAtTime(time);

    return {XScale, XOffset, YScale, YOffset};
end

function UDim2Curve.GetKeys()
    local XOffset = UDim2Curve.X.Offset:GetKeys();
    local YOffset = UDim2Curve.Y.Offset:GetKeys();
    local XScale = UDim2Curve.X.Scale:GetKeys();
    local YScale = UDim2Curve.Y.Scale:GetKeys();

    return {XScale, XOffset, YScale, YOffset};
end

function UDim2Curve.GetValueAtTime(time: number)
    local XOffset = UDim2Curve.X.Offset:GetValueAtTime(time);
    local YOffset = UDim2Curve.Y.Offset:GetValueAtTime(time);
    local XScale = UDim2Curve.X.Scale:GetValueAtTime(time);
    local YScale = UDim2Curve.Y.Scale:GetValueAtTime(time);

    return UDim2.new(XScale, XOffset, YScale, YOffset);
end

function UDim2Curve.InsertKey(key: {FloatCurveKey}, formatted: boolean?)
    if not formatted then
        UDim2Curve.X.Offset:InsertKey(key[1]);
        UDim2Curve.Y.Offset:InsertKey(key[2]);
        UDim2Curve.X.Scale:InsertKey(key[3]);
        UDim2Curve.Y.Scale:InsertKey(key[4]);
    else
        UDim2Curve.X.Offset:InsertKey(key[2]);
        UDim2Curve.Y.Offset:InsertKey(key[4]);
        UDim2Curve.X.Scale:InsertKey(key[1]);
        UDim2Curve.Y.Scale:InsertKey(key[3]);
    end
end

function UDim2Curve.RemoveKeyAtIndex(startingIndex: number, count: number)
    UDim2Curve.X.Offset:RemoveKeyAtIndex(startingIndex, count);
    UDim2Curve.Y.Offset:RemoveKeyAtIndex(startingIndex, count);
    UDim2Curve.X.Scale:RemoveKeyAtIndex(startingIndex, count);
    UDim2Curve.Y.Scale:RemoveKeyAtIndex(startingIndex, count);
end

function UDim2Curve.SetKeys(keys: {{FloatCurveKey}})
    UDim2Curve.X.Offset:SetKeys(keys[1]);
    UDim2Curve.Y.Offset:SetKeys(keys[2]);
    UDim2Curve.X.Scale:SetKeys(keys[3]);
    UDim2Curve.Y.Scale:SetKeys(keys[4]);
end

return UDim2Curve;