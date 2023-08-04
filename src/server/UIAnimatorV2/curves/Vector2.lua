--[[
    
    IF YOU'VE CLONED THE PROJECT FROM GITHUB PLEASE READ THE FOLLOWING INFORMATION TO ENSURE PROPER FUNCTIONALITY
    THE FOLLOWING INFORMATION APPLIES TO ALL CLASSES IN THIS FOLDER:

    --FILE STRUCTURE INFORMATION--
    In order for this class to properly work we need to serialize data in float curves. A float curve
    may be created by calling Instance.new("FloatCurve", [parent])

    the following tree represents the structure that must exist in this class
    in order to ensure proper functionality:

    --Vector2.lua [ModuleScript]
        --X [FloatCurve]
        --Y [FloatCurve]

    --ADDITIONAL INFORMATION--
    This class unlike other classes doesn't have a proper ClassName, in order to make this object identifiable
    please add a ATTRIBUTE of type STRING called "Type" and set it's value to "Vector2"

--]]

local Vector2Curve = {};

Vector2Curve.X = script.X;
Vector2Curve.Y = script.Y;

function Vector2Curve.GetKeyAtIndex(index: number)
    local X = Vector2Curve.X:GetKeyAtIndex(index);
    local Y = Vector2Curve.Y:GetKeyAtIndex(index);

    return {X, Y};
end

function Vector2Curve.GetKeyIndicesAtTime(time: number)
    local X = Vector2Curve.X:GetKeyIndicesAtTime(time);
    local Y = Vector2Curve.Y:GetKeyIndicesAtTime(time);

    return {X, Y};
end

function Vector2Curve.GetKeys(index: number)
    local X = Vector2Curve.X:GetKeys();
    local Y = Vector2Curve.Y:GetKeys();

    return {X, Y};
end

function Vector2Curve.GetValueAtTime(time: number)
    local X = Vector2Curve.X:GetValueAtTime(time);
    local Y = Vector2Curve.Y:GetValueAtTime(time);

    return Vector2.new(X, Y);
end

function Vector2Curve.InsertKey(key: {FloatCurveKey}, formatted: boolean?)
    Vector2Curve.X:InsertKey(key[1]);
    Vector2Curve.Y:InsertKey(key[2]);
end

function Vector2Curve.RemoveKeyAtIndex(startingIndex: number, count: number)
    Vector2Curve.X:RemoveKeyAtIndex(startingIndex, count);
    Vector2Curve.Y:RemoveKeyAtIndex(startingIndex, count);
end

function Vector2Curve.SetKeys(keys: {{FloatCurveKey}})
    Vector2Curve.X:SetKeys(keys[1]);
    Vector2Curve.Y:SetKeys(keys[2]);
end

return Vector2Curve;