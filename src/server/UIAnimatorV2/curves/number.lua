--[[
    
    IF YOU'VE CLONED THE PROJECT FROM GITHUB PLEASE READ THE FOLLOWING INFORMATION TO ENSURE PROPER FUNCTIONALITY
    THE FOLLOWING INFORMATION APPLIES TO ALL CLASSES IN THIS FOLDER:

    --FILE STRUCTURE INFORMATION--
    In order for this class to properly work we need to serialize data in float curves. A float curve
    may be created by calling Instance.new("FloatCurve", [parent])

    the following tree represents the structure that must exist in this class
    in order to ensure proper functionality:

    --number.lua [ModuleScript]
        --X [FloatCurve]

    --ADDITIONAL INFORMATION--
    This class unlike other classes doesn't have a proper ClassName, in order to make this object identifiable
    please add a ATTRIBUTE of type STRING called "Type" and set it's value to "number"

--]]

local NumberCurve = {};

NumberCurve.X = script.X;

function NumberCurve.GetKeyAtIndex(index: number)
    local X = NumberCurve.X:GetKeyAtIndex(index);

    return {X}
end

function NumberCurve.GetKeyIndicesAtTime(time: number)
    local X = NumberCurve.X:GetKeyIndicesAtTime(time);

    return {X};
end

function NumberCurve.GetKeys(index: number)
    local X = NumberCurve.X:GetKeys();

    return {X};
end

function NumberCurve.GetValueAtTime(time: number)
    local X = NumberCurve.X:GetValueAtTime(time);

    return X;
end

function NumberCurve.InsertKey(key: {FloatCurveKey}, formatted: boolean?)
    NumberCurve.X:InsertKey(key[1]);
end

function NumberCurve.RemoveKeyAtIndex(startingIndex: number, count: number)
    NumberCurve.X:RemoveKeyAtIndex(startingIndex, count);
end

function NumberCurve.SetKeys(keys: {{FloatCurveKey}})
    NumberCurve.X:SetKeys(keys[1]);
end

return NumberCurve;