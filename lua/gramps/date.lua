---@module date
local Date = {_TYPE='module', _NAME='gramps.date', __index = Date ,_VERSION='0.9.10.2024'}
util=require("gramps.util")

--local gettext = require("gettext")
--local _ = gettext.gettext
local function translate(s)
return(s)
end
local _=translate

---
-- @table Gramps_date
-- @field 1 calendar integer @{Calendar}
-- @field 2 modifier integer @{Modifier}
-- @field 3 quality integer @{Quality}
-- @field 4 data table @{Dates}
-- @field 5 text
 --

---
-- @table Dates
-- @field 1 DAY_1
-- @field 2 MONTH_1
-- @field 3 YEAR_1
-- @field 5 DAY_2
-- @field 6 MONTH_2
-- @field 7 YEAR_2
 --

---
-- @table Calendar
Date.Calendar={
  Gregorian = 0, --0
  Julian = 1, --1
  Hebrew = 2, --2
  FrenchRepublican = 3, --3
  Persian = 4, --4
  Islamic = 5, --5
  Swedish = 6 --6
  }

---
-- @table Modifier
Date.Modifier={
  NONE = 0,-- 0
  BEFORE = 1,-- 1
  AFTER = 2,-- 2
  ABOUT = 3,-- 3
  RANGE = 4,-- 4
  SPAN = 5,-- 5
  TEXTONLY = 6,-- 6
  }

---
-- @table Quality
Date.Quality={
  NONE = 0,      -- 0
  ESTIMATED = 1 ,-- 1
  CALCULATED = 2,  -- 2
  INTERPRETED = 4 -- 4
  }

--print(_("Hello, world!"))  -- This will print the translated version of "Hello, world!"
--os.setlocale("es_ES")  -- Change locale to Spanish (Spain)

local moths={_("January"),_("Februari"),_("March"),_("April"),_("June"),_("Jyly"),_("August"),_("September"),_("October"),_("Noveber"),_("December")}
local modifier={_("before"),_("after"),_("about"),_("range"),_("between"),_(""),_(""),_(""),_("")}
local quality={_("estimate"),_("calculated"),_("calclated estimate")}

local function is_empty(s,a,b)
if #s>0 then return(b) else return(a) end end
---
-- @param d @{Gramps_date}
-- @return text date
function Date.date(d)
--print(util.dump(d))
s=""
d1=""
d2=""

--os.setlocale="nl_NL.UTF-8"
if d[4][1]>0 then d1=tostring(d[4][1]) end
if d[4][2]>0 then d1=d1..is_empty(d1,""," ")..moths[d[4][2]] end
if d[4][3]>0 then d1=d1..is_empty(d1,""," ")..d[4][3] end

if d[2]>3 then
if d[4][5]>0 then d2=tostring(d[4][5]) end
if d[4][6]>0 then d2=d2..is_empty(d2,""," ")..moths[d[4][6]] end
if d[4][7]>0 then d2=d2..is_empty(d2,""," ")..d[4][7] end
end

if d[3]>0 then s=quality[d[3]] end
if d[2]>0 then s=modifier[d[2]] end
s=s..is_empty(s,""," ")..d1

if d[2]>3 then
s = s.." - "..d2
end
return s
end

---
-- @param d @{Gramps_date}
-- @return d1-m1-y1/d2-m2-y2
function Date.tex(d)
local s=""
local d1=""
local d2=""

--os.setlocale="nl_NL.UTF-8"
if d[4][3]>0 then d1=tostring(d[4][3]) end
if d[4][2]>0 then d1=d1..is_empty(d1,"","-")..d[4][2] end
if d[4][1]>0 then d1=d1..is_empty(d1,"","-")..d[4][1] end

if d[2]>3 then
if d[4][7]>0 then d2=tostring(d[4][7]) end
if d[4][6]>0 then d2=d2..is_empty(d2,"","-")..d[4][6] end
if d[4][5]>0 then d2=d2..is_empty(d2,"","-")..d[4][5] end
end
if d[2]>3 then s = d1.."/"..d2
    elseif d[2]==1 then s="/"..d1
    elseif d[2]==2 then s=d1.."/"
    else s=d1 end

    if d[3]>0 then
        s= "(ca)"..s
    end

    --print("date.tex",s,d1,d2)
return s
end

---
-- Checks is date is not estimated or relative
-- @param d @{Gramps_date}
-- @return boolean (true if real)
function Date.realdate(d)
    if d then
        return (d[2]==MOD_NONE and d[4][1]>0 and d[4][2]>0 and d[4][3]>0)
    else return false end
end

---
-- Checks is date has year and is at least about
-- @param d @{Gramps_date}
-- @return boolean (true if real)
function Date.aboutdate(d)
    --print(util.dump(d))
    return((d[2]==MOD_NONE or d[2]==MOD_ABOUT)  and d[4][3]>0)
end

-- Function to check if a year is a leap year
function is_leap_year(year)
  if year % 4 == 0 then
    if year % 100 == 0 then
      if year % 400 == 0 then
        return true
      else
        return false
      end
    else
      return true
    end
  else
    return false
  end
end

-- Function to calculate the number of days in a year
function days_in_year(year)
  if is_leap_year(year) then
    return 366
  else
    return 365
  end
end

function days_in_years(years)
  local total_days = 511340 --de dagen van de eerste 1400 jaar
  -- Sum the days for all complete years from 0 to (year - 1)
  for y = 1400, years - 1 do
    total_days = total_days + days_in_year(y)
  end
  return total_days
end

---
--  calculate total number of days from year 0 to a given year
function Date.days_from_year_0(year, month, day)

    local total_days = days_in_years(year)

    -- Days in the current year
    local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

    -- If it's a leap year, February has 29 days
    if is_leap_year(year) then
        days_in_month[2] = 29
    end

    -- Sum the days for the complete months in the current year
    for m = 1, month - 1 do
        total_days = total_days + days_in_month[m]
    end

    -- Add the days for the current month
    total_days = total_days + day

    return total_days
end

---
-- @param year
-- @return month, day, day_of_year, days_from_year0
function Date.calculateEasterDay(year)
    -- Meeus/Jones/Butcher algorithm to calculate the month and day of Easter
    local a = year % 19
    local b = math.floor(year / 100)
    local c = year % 100
    local d = math.floor(b / 4)
    local e = b % 4
    local f = math.floor((b + 8) / 25)
    local g = math.floor((b - f + 1) / 3)
    local h = (19 * a + b - d - g + 15) % 30
    local i = math.floor(c / 4)
    local k = c % 4
    local l = (32 + 2 * e + 2 * i - h - k) % 7
    local m = math.floor((a + 11 * h + 22 * l) / 451)

    local month = math.floor((h + l - 7 * m + 114) / 31)  -- Month of Easter (3 = March, 4 = April)
    local day = ((h + l - 7 * m + 114) % 31) + 1          -- Day of Easter

    -- Calculate the day of the year for Easter
    local daysInMarch = 59  -- Day number for March 1st (common year)
    if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
        daysInMarch = 60   -- Leap year adjustment
    end
    local dayOfYear = (month == 3 and daysInMarch + day - 1) or (daysInMarch + 31 + day - 1)

    return month, day, dayOfYear, (days_in_years(year) + dayOfYear)
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    local days=Date.days_from_year_0(2000,0,0)
    print("days/year",days/2000)
else
    return Date
end
