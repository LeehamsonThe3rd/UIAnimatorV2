--[[
    
    IF YOU'VE CLONED THE PROJECT FROM GITHUB PLEASE READ THE FOLLOWING INFORMATION TO ENSURE PROPER FUNCTIONALITY
    THE FOLLOWING INFORMATION APPLIES TO ALL CLASSES IN THIS FOLDER:

    --FILE STRUCTURE INFORMATION--
    In order for this class to properly work we need to serialize data in float curves. A float curve
    may be created by calling Instance.new("FloatCurve", [parent])

    the following tree represents the structure that must exist in this class
    in order to ensure proper functionality:

    --Color3.lua [ModuleScript]
        --R [FloatCurve]
        --G [FloatCurve]
        --B [FloatCurve]

    --ADDITIONAL INFORMATION--
    This class unlike other classes doesn't have a proper ClassName, in order to make this object identifiable
    please add a ATTRIBUTE of type STRING called "Type" and set it's value to "Color3"

--]]

local Color3Curve = {};

Color3Curve.R = script.R;
Color3Curve.G = script.G;
Color3Curve.B = script.B;

function Color3Curve.GetKeyAtIndex(index: number)
    local R = Color3Curve.R:GetKeyAtIndex(index);
    local G = Color3Curve.G:GetKeyAtIndex(index);
    local B = Color3Curve.B:GetKeyAtIndex(index);

    return {R, G, B};
end

function Color3Curve.GetKeyIndicesAtTime(time: number)
    local R = Color3Curve.R:GetKeyIndicesAtTime(time);
    local G = Color3Curve.G:GetKeyIndicesAtTime(time);
    local B = Color3Curve.B:GetKeyIndicesAtTime(time);

    return {R, G, B};
end

function Color3Curve.GetKeys(index: number)
    local R = Color3Curve.R:GetKeys();
    local G = Color3Curve.G:GetKeys();
    local B = Color3Curve.B:GetKeys();

    return {R, G, B};
end

function Color3Curve.GetValueAtTime(time: number)
    local R = Color3Curve.R:GetValueAtTime(time);
    local G = Color3Curve.G:GetValueAtTime(time);
    local B = Color3Curve.B:GetValueAtTime(time);

    return Color3.new(R, G, B);
end

function Color3Curve.InsertKey(key: {FloatCurveKey}, formatted: boolean?)
    Color3Curve.R:InsertKey(key[1]);
    Color3Curve.G:InsertKey(key[2]);
    Color3Curve.B:InsertKey(key[3]);
end

function Color3Curve.RemoveKeyAtIndex(startingIndex: number, count: number)
    Color3Curve.R:RemoveKeyAtIndex(startingIndex, count);
    Color3Curve.G:RemoveKeyAtIndex(startingIndex, count);
    Color3Curve.B:RemoveKeyAtIndex(startingIndex, count);
end

function Color3Curve.SetKeys(keys: {{FloatCurveKey}})
    Color3Curve.R:SetKeys(keys[1]);
    Color3Curve.G:SetKeys(keys[2]);
    Color3Curve.B:SetKeys(keys[3]);
end

return Color3Curve;