----------------------------------
-- ETK Helper Classes           --
-- make stuff more easy         --
--                              --
-- (C) 2015 Jim Bauwens         --
-- Licensed under the GNU GPLv3 --
----------------------------------
-- BetterLuaAPI for the TI-Nspire
-- Version 3.5 (March 17th 2014)
-- Adriweb 2013
-- http://tiplanet.org - http://inspired-lua.org
-- Contributions by LDStudios
-- Put all this or some of this (be careful, though, some functions use each other) in your code and thank me ;)
----------------------
------ Utilities -----
----------------------
-- Thanks John Powers (TI) !
-- Needed if OS < 3.2
if not platform.withGC then
    function platform.withGC(f)
        local gc = platform.gc()
        gc:begin()
        local result = {f(gc)}
        gc:finish()
        return unpack(result)
    end
end

-- Credits to Jim Bauwens :)
-- See http://inspired-lua.org/index.php/2013/05/how-to-add-your-own-functions-to-gc/
-- Needed.
function AddToGC(key, func)
    local gcMetatable = platform.withGC(getmetatable)
    gcMetatable[key] = func
end

----------------------
----- New Things -----
----------------------

device = {api, hasColor, isCalc, theType, lang}
device.api = platform.apilevel
device.hasColor = platform.isColorDisplay()
device.lang = locale.name()

function on.resize(w, h)
    device.isCalc = platform.window:width() < 320
    device.theType = platform.isTabletModeRendering and
                         (platform.isTabletModeRendering() and "tablet" or
                             "software") or
                         (platform.isDeviceModeRendering() and "handheld" or
                             "software")

    -- put the rest of your resize code here
end

Color = {
    ["black"] = {0, 0, 0},
    ["red"] = {255, 0, 0},
    ["green"] = {0, 255, 0},
    ["blue "] = {0, 0, 255},
    ["white"] = {255, 255, 255},
    ["brown"] = {165, 42, 42},
    ["cyan"] = {0, 255, 255},
    ["darkblue"] = {0, 0, 139},
    ["darkred"] = {139, 0, 0},
    ["fuchsia"] = {255, 0, 255},
    ["gold"] = {255, 215, 0},
    ["gray"] = {127, 127, 127},
    ["grey"] = {127, 127, 127},
    ["lightblue"] = {173, 216, 230},
    ["lightgreen"] = {144, 238, 144},
    ["magenta"] = {255, 0, 255},
    ["maroon"] = {128, 0, 0},
    ["navyblue"] = {159, 175, 223},
    ["orange"] = {255, 165, 0},
    ["palegreen"] = {152, 251, 152},
    ["pink"] = {255, 192, 203},
    ["purple"] = {128, 0, 128},
    ["royalblue"] = {65, 105, 225},
    ["salmon"] = {250, 128, 114},
    ["seagreen"] = {46, 139, 87},
    ["silver"] = {192, 192, 192},
    ["turquoise"] = {64, 224, 208},
    ["violet"] = {238, 130, 238},
    ["yellow"] = {255, 255, 0}
}
Color.mt = {__index = function() return {0, 0, 0} end}
setmetatable(Color, Color.mt)

local function copyTable(t)
    local t2 = {}
    for k, v in pairs(t) do t2[k] = v end
    return t2
end

-- This function recursively copies a table's contents, and ensures that metatables are preserved.
-- That is, it will correctly clone a pure Lua object.
-- Taken from http://snippets.luacode.org/snippets/Deep_copy_of_a_Lua_Table_2
local function deepcopy(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then v = deepcopy(v) end
        res[k] = v
    end
    setmetatable(res, mt)
    return res
end

local function test(arg) return arg and 1 or 0 end

local function uCol(col) return col[1], col[2], col[3] end

local function screenRefresh() return platform.window:invalidate() end
local function pww() return platform.window:width() end
local function pwh() return platform.window:height() end

local function drawPoint(gc, x, y) gc:fillRect(x, y, 1, 1) end

local function drawCircle(gc, x, y, r)
    gc:drawArc(x - r, y - r, 2 * r, 2 * r, 0, 360)
end

local function fillCircle(gc, x, y, r)
    gc:fillArc(x - r, y - r, 2 * r, 2 * r, 0, 360)
end

local function fillGradientRect(gc, x, y, w, h, color1, color2, d)
    local l = {w, x}
    if d == 2 then l = {h, y} end
    for i = l[2], l[1] + l[2] do
        gc:setColorRGB(color1[1], color1[2], color1[3])
        if d == 1 then
            gc:fillRect(i, y, 1, h)
        else
            gc:fillRect(x, i, w, 1)
        end
        color1 = {
            color1[1] + (color1[1] - color2[1]) / (i - l[1] - l[2]),
            color1[2] + (color1[2] - color2[2]) / (i - l[1] - l[2]),
            color1[3] + (color1[3] - color2[3]) / (i - l[1] - l[2])
        }
    end
end

local function fillGradientCircle(gc, x, y, r, color1, color2)
    for i = 0, r do
        gc:setColorRGB(color1[1], color1[2], color1[3])
        gc:setPen("thick")
        drawCircle(gc, x, y, i)
        color1 = {
            color1[1] + (color2[1] - color1[1]) / (r - i),
            color1[2] + (color2[2] - color1[2]) / (r - i),
            color1[3] + (color2[3] - color1[3]) / (r - i)
        }
    end
end

local function drawThickCircle(gc, x, y, r, r2)
    gc:setPen("thick")
    for i = r, r2 do drawCircle(gc, x, y, i) end
end

local function drawCenteredString(gc, str)
    gc:drawString(str, (platform.window:width() - gc:getStringWidth(str)) / 2,
                  platform.window:height() / 2, "middle")
end

local function drawXCenteredString(gc, str, y)
    gc:drawString(str, (platform.window:width() - gc:getStringWidth(str)) / 2,
                  y, "top")
end

local function setColor(gc, theColor)
    if type(theColor) == "string" then
        theColor = theColor:lower()
        if type(Color[theColor]) == "table" then
            gc:setColorRGB(uCol(Color[theColor]))
        end
    elseif type(theColor) == "table" then
        gc:setColorRGB(uCol(theColor))
    end
end

local function verticalBar(gc, x) gc:fillRect(x, 0, 1, platform.window:height()) end

local function horizontalBar(gc, y) gc:fillRect(0, y, platform.window:width(), 1) end

local function drawSquare(gc, x, y, l)
    gc:drawPolyLine({
        (x - l / 2), (y - l / 2), (x + l / 2), (y - l / 2), (x + l / 2),
        (y + l / 2), (x - l / 2), (y + l / 2), (x - l / 2), (y - l / 2)
    })
end

local function drawRoundRect(gc, x, y, wd, ht, rd) -- wd = width, ht = height, rd = radius of the rounded corner
    if rd > ht / 2 then rd = ht / 2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max rd)
    gc:drawLine(x + rd, y, x + wd - (rd), y)
    gc:drawArc(x + wd - (rd * 2), y + ht - (rd * 2), rd * 2, rd * 2, 270, 90)
    gc:drawLine(x + wd, y + rd, x + wd, y + ht - (rd))
    gc:drawArc(x + wd - (rd * 2), y, rd * 2, rd * 2, 0, 90)
    gc:drawLine(x + wd - (rd), y + ht, x + rd, y + ht)
    gc:drawArc(x, y, rd * 2, rd * 2, 90, 90)
    gc:drawLine(x, y + ht - (rd), x, y + rd)
    gc:drawArc(x, y + ht - (rd * 2), rd * 2, rd * 2, 180, 90)
end

local function fillRoundRect(gc, x, y, wd, ht, radius) -- wd = width and ht = height -- renders badly when transparency (alpha) is not at maximum >< will re-code later
    if radius > ht / 2 then radius = ht / 2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max radius)
    local ox = x
    local oy = y
    x = x + wd / 2
    y = y + ht / 2
    gc:fillPolygon({
        (x - wd / 2), (y - ht / 2 + radius), (x + wd / 2),
        (y - ht / 2 + radius), (x + wd / 2), (y + ht / 2 - radius),
        (x - wd / 2), (y + ht / 2 - radius), (x - wd / 2), (y - ht / 2 + radius)
    })
    gc:fillPolygon({
        (x - wd / 2 - radius + 1), (y - ht / 2), (x + wd / 2 - radius + 1),
        (y - ht / 2), (x + wd / 2 - radius + 1), (y + ht / 2),
        (x - wd / 2 + radius), (y + ht / 2), (x - wd / 2 + radius), (y - ht / 2)
    })
    x = ox
    y = oy
    gc:fillArc(x + wd - (radius * 2), y + ht - (radius * 2), radius * 2,
               radius * 2, 1, -91)
    gc:fillArc(x + wd - (radius * 2), y, radius * 2, radius * 2, -2, 91)
    gc:fillArc(x, y, radius * 2, radius * 2, 85, 95)
    gc:fillArc(x, y + ht - (radius * 2), radius * 2, radius * 2, 180, 95)
end

local function clearWindow(gc, theColor)
    gc:setColor(theColor) -- will handle both strings like "red" and direct colors like {255,0,0}
    gc:fillRect(0, 0, platform.window:width(), platform.window:height())
end

-----------------------------------------
------ Adding the functions to gc -------
-----------------------------------------
AddToGC("setColor", setColor)
AddToGC("drawPoint", drawPoint)
AddToGC("drawCircle", drawCircle)
AddToGC("fillCircle", fillCircle)
AddToGC("drawThickCircle", drawThickCircle)
AddToGC("fillGradientCircle", fillGradientCircle)
AddToGC("drawGradientRect", drawGradientRect)
AddToGC("drawSquare", drawSquare)
AddToGC("drawRoundRect", drawRoundRect)
AddToGC("fillRoundRect", fillRoundRect)
AddToGC("verticalBar", verticalBar)
AddToGC("horizontalBar", horizontalBar)
AddToGC("drawCenteredString", drawCenteredString)
AddToGC("drawXCenteredString", drawXCenteredString)
AddToGC("clearWindow", clearWindow)
------------------
-- Enumerations --
------------------

Enum = function(enumTable)
    for k, v in ipairs(enumTable) do enumTable[v] = k end

    return enumTable
end

-------------
-- Logging --
-------------

do
    Logger = {}
    Logger.Log = function(message, ...) print(message:format(...)) end

    Logger.Warn = function(message, ...)
        Logger.Log("Warning: " .. message, ...)
    end
end

-----------------------------------------------
-- Handle different types of user unit input --
-----------------------------------------------

do
    UnitCalculator = {}
    UnitCalculator.GetAbsoluteValue = function(value, referenceValue)
        local numberValue, unit = string.match(tostring(value), "([-%d.]+)(.*)")

        local number = tonumber(numberValue)

        if not number then
            Logger.Warn(
                "UnitCalculator.GetAbsoluteValue - Invalid number value, returning 0")
            return 0
        end

        local isPercent = unit == "%"

        if number < 0 then
            print(number, "from")
            number = (isPercent and 100 or referenceValue) + number
            print(number, "to")
        end

        if isPercent then
            return referenceValue / 100 * number
        else
            return number
        end
    end
end

-------------------------------------------------
-- Keep dimensions in a nice to handle wrapper --
-------------------------------------------------

do
    Dimension = class()
    function Dimension:init(width, height)
        self.width = width
        self.height = height
    end

    function Dimension:get(parentWidth, parentHeight, dirty)
        if self.width then
            if dirty or not self.cachedWidth then
                self.cachedWidth = UnitCalculator.GetAbsoluteValue(self.width,
                                                                   parentWidth)
                self.cachedHeight = UnitCalculator.GetAbsoluteValue(self.height,
                                                                    parentHeight)
            end

            return self.cachedWidth, self.cachedHeight
        else
            self.cachedWidth = parentWidth
            self.cachedHeight = parentHeight

            return parentWidth, parentHeight
        end
    end

    function Dimension:getCachedDimension()
        return self.cachedWidth or 0, self.cachedHeight or 0
    end

    function Dimension:invalidate()
        self.cachedWidth = nil
        self.cachedHeight = nil
    end
end

do
    Position = class()
    Position.Type = Enum {"Absolute", "Relative"}
    Position.Sides = Enum {"Left", "Right", "Top", "Bottom"}

    function Position:init(arg)
        arg = arg or {}

        self.left = arg.left
        self.top = arg.top
        self.bottom = arg.bottom
        self.right = arg.right

        self.alignment = arg.alignment or {}

        if not (self.left or self.right) then self.left = 0 end

        if not (self.top or self.bottom) then self.top = 0 end
    end

    function Position:get(parentX, parentY, parentWidth, parentHeight, width,
                          height, dirty)
        if dirty or not self.cachedX then
            local x, y
            local originX = parentX
            local originY = parentY

            if self.right then originX = originX + parentWidth end

            if self.bottom then originY = originY + parentHeight end

            for _, alignment in ipairs(self.alignment) do
                local side = alignment.side
                local ref = alignment.ref
                local refWidth, refHeight = ref:getDimension()
                local refX, refY = ref:getPosition()

                if side == Position.Sides.Left then
                    originX = refX
                elseif side == Position.Sides.Right then
                    originX = refX + refWidth
                elseif side == Position.Sides.Top then
                    originY = refY
                elseif side == Position.Sides.Bottom then
                    originY = refY + refHeight
                else
                    Logger.Warn("Invalid side specified")
                end
            end

            if self.left then
                x = originX +
                        UnitCalculator.GetAbsoluteValue(self.left, parentWidth)
            elseif self.right then
                x = originX -
                        UnitCalculator.GetAbsoluteValue(self.right, parentWidth) -
                        width
            end

            if self.top then
                y = originY +
                        UnitCalculator.GetAbsoluteValue(self.top, parentHeight)
            elseif self.bottom then
                y = originY -
                        UnitCalculator.GetAbsoluteValue(self.bottom,
                                                        parentHeight) - height
            end

            self.cachedX = x
            self.cachedY = y
        end

        return self.cachedX, self.cachedY
    end

    function Position:invalidate()
        self.cachedX = nil
        self.cachedY = nil
    end

    function Position:getCachedPosition()
        return self.cachedX or 0, self.cachedY or 0
    end

end

-----------
-- Color --
-----------

local function unpackColor(col) return col[1] or 0, col[2] or 0, col[3] or 0 end

-------------------
-- Event calling --
-------------------

local CallEvent = function(object, event, ...)
    local handler = object[event]

    if handler then return handler, handler(object, ...) end
end
