---@module date
DEBUG =4
local TDate = {_TYPE='module', _NAME='gramps.date', _VERSION='0.28.2.2025'}

TDate.__index =Date

local container = require("gramps.datacontainer")
local util   = require("gramps.util")
local _      = require("mh.gettext")
local locality = require("mh.local")
local C = require("gramps.containers")

local function printfun(f,n)
	print("\n"..n.."=")
	if f then
        if type(f) == "table" then
            for k,v in pairs(f) do print("data ",k,type(v)) end
            local m = getmetatable(f)
            if m then
                for k,v in pairs(m) do print("metadata ",k,type(v)) end
            end
        else
            print(f.." is not a table")
        end
	end
end




local days = { _("Sunday"), _("Monday"), _("Tuesday"), _("Wednesday"), _("Thursday"), _("Friday"), _("Saturday") }
local months={_("January"),_("Februari"),_("March"),_("April"),_("May"),_("June"),
    _("Jyly"),_("August"),_("September"),_("October"),_("Noveber"),_("December")}
local modifier={"",_("before "),_("after "),_("about "),_("range "),_("between "),(""),(""),(""),("")}
local quality={"",_("estimate as "),_("calculated as "),_("calclated and estimate as ")}
local short_modifier={"",_("<"),_(">"),_("~"),(""),_("<>"),(""),(""),(""),("")}
local short_quality={"",_("~"),_("+/-"),_("~+/-")}


--Date.Date = scheme(Date.Scheme)

--function Date.new(d)
--  local self = setmetatable({},{__index = function(cls,d) return cls:get(d) end})
--  for k,v in pairs(Date.Date(d)) do self[k]=v end
--  for k,v in pairs(Date) do self[k] = v; end
--  print("self in return new datum:");for k,v in pairs(self) do print(k,v) end; print("")
--  return self
--end

function C.Date.MakeDate(d,m,y,l,weekday)
  local s =""
  if weekday and d>0 and m>0 and y>0 then s=s.. days[C.Date.weekday(d,m,y)].." " end
  if l=="nl"then
    if d>0 then s=s..tostring(d) end
    if m>0 then s=s..util.is_empty(s,""," ")..months[m] end
    if y>0 then s=s..util.is_empty(s,""," ")..y end
  else --default en
    if m>0 then s=s..months[m] end
    if d>0 then s=s..util.is_empty(s,""," ")..tostring(d) end
    if y>0 then s=s..util.is_empty(s,"",", ")..y end
  end
  return s
end

function C.Date.MDate(d,m,y,l)
  local s =""
  if l=="nl"then
    if d>0 then s=s..tostring(d) end
    if m>0 then s=s..util.is_empty(s,"","-")..tostring(m) end
    if y>0 then s=s..util.is_empty(s,"","-")..y end
  else --default en
    if m>0 then s=s..tostring(m) end
    if d>0 then s=s..util.is_empty(s,"","-")..tostring(d) end
    if y>0 then s=s..util.is_empty(s,"","-")..y end
  end
  return s
end

function C.Date:long(weekday)
  --for k,v in pairs(self) do print(k,v) end
  local s=""

  local d =self.dateval
  if type(d) ~= "table" then return "" end
  lan = locality.language()
  if self.modifier < C.Date.Modifier.RANGE then
    s = s .. _("on ")..quality[self.quality+1].. modifier[self.modifier+1]..C.Date.MakeDate(d[1],d[2],d[3],lan,weekday)
  elseif self.modifier < C.Date.Modifier.TEXTONLY then
    s = s .. quality[self.quality+1].. modifier[self.modifier+1]..C.Date.MakeDate(d[1],d[2],d[3],lan,weekday)..
           _(" and ") ..C.Date.MakeDate(d[5],d[6],d[7],lan,weekday)
  else
    s = s ..  self.text
  end
   return s-- .." ("..lan..")"
end

function C.Date:short()
  local d =self.dateval
  if type(d) ~= "table" then return "" end
  print(type(d))
  lan = locality.language()
  local s=""
  if self.modifier < C.Date.Modifier.RANGE then
    s = s .. short_quality[self.quality+1].. short_modifier[self.modifier+1]..C.Date.MDate(d[1],d[2],d[3],lan)
  elseif self.modifier < C.Date.Modifier.TEXTONLY then
    s = s .. short_quality[self.quality+1].. short_modifier[self.modifier+1]..C.Date.MDate(d[1],d[2],d[3],lan)..
          " - "..C.Date.MakeDate(d[5],d[6],d[7],lan,weekday)
  end
  return s
end

--setmetatable(Date,{	__call = function(_,d) print("in __call",d[5])return Date.new(d) end})

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
TDate.Calendar={
  Gregorian = 0, --0
  Julian    = 1, --1
  Hebrew    = 2, --2
  FrenchRepublican = 3, --3
  Persian    = 4, --4
  Islamic    = 5, --5
  Swedish    = 6 --6
  }

---
-- @table Modifier
C.Date.Modifier={
  NONE   = 0,-- 0
  BEFORE = 1,-- 1
  AFTER  = 2,-- 2
  ABOUT  = 3,-- 3
  RANGE  = 4,-- 4
  SPAN   = 5,-- 5
  TEXTONLY = 6,-- 6
  }

---
-- @table Quality
C.Date.Quality={
  NONE      = 0,      -- 0
  ESTIMATED = 1 ,-- 1
  CALCULATED = 2,  -- 2
  INTERPRETED = 4 -- 4
  }


local function is_empty(s,a,b)-- Moet weg
if #s>0 then return(b) else return(a) end end


---
-- @param d @{Gramps_date}
-- @return text date
function C.Date.date(d) -- Moet weg
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
function C.Date.tex(d)-- Moet weg
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

function C.Date.weekday(day, month, year)
    local a = math.floor((14 - month) / 12)
    local y = year - a
    local m = month + 12 * a - 2
    local d = (day + y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + math.floor(31 * m / 12)) % 7

    return d + 1  -- Adjust index (Lua is 1-based)
end




---
-- Checks is date is not estimated or relative
-- @param d @{Gramps_date}
-- @return boolean (true if real)
function TDate.realdate(d)-- Moet veranderd
    if d then
        return (d[2]==C.Date.Modifier.NONE and d[4][1]>0 and d[4][2]>0 and d[4][3]>0)
    else return false end
end

---
-- Checks is date has year and is at least about
-- @param d @{Gramps_date}
-- @return boolean (true if real)
function TDate.aboutdate(d)-- Moet veranderd
    --print(util.dump(d))
    return((d[2]==C.Date.Modifier.NONE or d[2]==C.Date.Modifier.ABOUT)  and d[4][3]>0)
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
function TDate.days_from_year_0(year, month, day)-- Moet veranderd

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
function TDate.calculateEasterDay(year)-- Moet veranderd
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
    --local days=Date.days_from_year_0(2000,0,0)
    --print("days/year",days/2000)
    printfun(C.Date,"Ndate")
    local d1=C.Date({0,0,0,{1,2,2025,0,2,3,2025},"datum 1",0,0})
    local d2=C.Date({0,0,0,{1,2,2023,0,2,3,2023},"datum 2",0,0})
    printfun(d2,"datum d2")
    local d3=C.Date({0,0,0,{1,2,2023,0,2,3,1962},"datum 3",0,0})

    print(d2:get('text'))
    --printfun(d2,"d2:")
    --print(d1.text)
    --print(d2:get('text'))
    --print(d2['text'])
    --print(d2.text)
    --print(d3.text)


 --   d1:long()
    print(d2:long())
    locality.setlanguage('nl')
    print(d2:long(true))
    print(d2:short())
    --print(days[Date.weekday(1,3,2025)])

else
    return C.Date
end
