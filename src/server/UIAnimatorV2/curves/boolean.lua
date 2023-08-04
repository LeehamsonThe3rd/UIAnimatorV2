--[[

    IF YOU'VE CLONED THE PROJECT FROM GITHUB PLEASE READ THE FOLLOWING INFORMATION TO ENSURE PROPER FUNCTIONALITY
    THE FOLLOWING INFORMATION APPLIES TO ALL CLASSES IN THIS FOLDER:

    --FILE STRUCTURE INFORMATION--
    In order for this class to properly work we need to serialize data in float curves. A float curve
    may be created by calling Instance.new("FloatCurve", [parent])

    the following tree represents the structure that must exist in this class
    in order to ensure proper functionality:

    --boolean.lua [ModuleScript]
        --X [FloatCurve]

    --ADDITIONAL INFORMATION--
    This class unlike other classes doesn't have a proper ClassName, in order to make this object identifiable
    please add a ATTRIBUTE of type STRING called "Type" and set it's value to "boolean"

--]]

local BooleanCurve = {}; --yes I know it makes no sense

BooleanCurve.X = script.X;

function BooleanCurve.GetKeyAtIndex(index: number)
    local X = BooleanCurve.X:GetKeyAtIndex(index);

    return {X}
end

function BooleanCurve.GetKeyIndicesAtTime(time: number)
    local X = BooleanCurve.X:GetKeyIndicesAtTime(time);

    return {X};
end

function BooleanCurve.GetKeys(index: number)
    local X = BooleanCurve.X:GetKeys();

    return {X};
end

function BooleanCurve.GetValueAtTime(time: number)
    local X = BooleanCurve.X:GetValueAtTime(time);

    return X;
end

function BooleanCurve.InsertKey(key: {FloatCurveKey}, formatted: boolean?)
    BooleanCurve.X:InsertKey(key[1]);
end

function BooleanCurve.RemoveKeyAtIndex(startingIndex: number, count: number)
    BooleanCurve.X:RemoveKeyAtIndex(startingIndex, count);
end

function BooleanCurve.SetKeys(keys: {{FloatCurveKey}})
    BooleanCurve.X:SetKeys(keys[1]);
end

return BooleanCurve;