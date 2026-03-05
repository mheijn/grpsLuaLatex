require('mh.table')
local Date = {}
Date.__index = Date

local _ = require("mh.gettext")
local print = require("mh.print")
local locality =  require("mh.local")
local util= require("gramps6.util")
DEBUG=4

function Date.new(datum)
	local  self = setmetatable({},Date)
	self.day = 0; self.month = 0; self.year = 0
	self.day2 = 0; self.month2 = 0; self.year2 = 0

	if (type(datum) =="table") then
		if (datum.dateval) then 
			self.day   = datum.dateval[1]
			self.month = datum.dateval[2]
			self.year  = datum.dateval[3]
			self.modifier = datum.modifier
			self.quality = datum.quality
			if (self.modifier==Date.Modifier.RANGE or self.modifier==Date.Modifier.SPAN) then
				self.day2   = datum.dateval[5]
				self.month2 = datum.dateval[6]
				self.year2  = datum.dateval[7]
			end
				
		elseif(type(datum[4]) ==  'table') then
			self.day      = datum[4][1]
			self.month    = datum[4][2]
			self.year     = datum[4][3]
			self.modifier = datum[2]
			self.quality  = datum[3]
			if (self.modifier == Date.Modifier.RANGE or self.modifier == Date.Modifier.SPAN) then
				self.day2   = datum[4][5]
				self.month2 = datum[4][6]
				self.year2  = datum[4][7]
			end
		end
	else
		self.date = datum
	end
	return self
end

---
-- @table Calendar
Date.Calendar={
	Gregorian        = 0, 
	Julian           = 1, 
	Hebrew           = 2, 
	FrenchRepublican = 3, 
	Persian          = 4, 
	Islamic          = 5, 
	Swedish          = 6 
	}
---
-- @table Modifier
Date.Modifier={
	NONE     = 0,
	BEFORE   = 1,
	AFTER    = 2,
	ABOUT    = 3,
	RANGE    = 4,
	SPAN     = 5,
	TEXTONLY = 6,
	}

---
-- @table Quality
Date.Quality={
	NONE        = 0,      
	ESTIMATED   = 1 ,
	CALCULATED  = 2, 
	INTERPRETED = 4 
	}


local days = { _("Sunday"), _("Monday"), _("Tuesday"), _("Wednesday"), _("Thursday"), _("Friday"), _("Saturday") }
local months={_("January"),_("Februari"),_("March"),_("April"),_("May"),_("June"),
      _("Jyly"),_("August"),_("September"),_("October"),_("Noveber"),_("December")}
local modifier={_("on "),_("before "),_("after "),_("about "),_("range "),_("between "),(""),(""),(""),("")}
local quality={"",_("estimate as "),_("calculated as "),_("calclated and estimate as ")}
local short_modifier={"",_("<"),_(">"),_("~"),(""),_("<>"),(""),(""),(""),("")}
local short_quality={"",_("~"),_("+/-"),_("~+/-")}

function Date:weekday(second)
	local d
	if second then
		local a = math.floor((14 - self.month2) / 12)
		local y = self.year2 - a
		local m = self.month2 + 12 * a - 2
		d = (self.day2 + y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + math.floor(31 * m / 12)) % 7
	else
		local a = math.floor((14 - self.month) / 12)
		local y = self.year - a
		local m = self.month + 12 * a - 2
		d = (self.day + y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + math.floor(31 * m / 12)) % 7
	end
	return d + 1  -- Adjust index (Lua is 1-based)
end

function Date:MakeDate(l,weekday,second)
	local s =""
	if weekday and self:realdate() then s=s.. days[self:weekday(second)].." " end
	if second then d=self.day2;m=self.month2;y=self.year2; 
	else d=self.day;m=self.month;y=self.year end

	if l=="nl"then
		if d>0 then s=s..string.format("%d", d) end
		if m>0 then s=s..util.is_empty(s,""," ")..months[m] end
		if y>0 then s=s..util.is_empty(s,""," ")..string.format("%d", y) end
	else --default en
		if m>0 then s=s..months[m] end
		if d>0 then s=s..util.is_empty(s,""," ")..string.format("%d", d) end
		if y>0 then s=s..util.is_empty(s,"",", ")..string.format("%d", y) end
	end
	return s
end

function Date:MDate(l,second)
	local s =""
	if second then d=self.day2;m=self.month2;y=self.year2 
	else d=self.day;m=self.month;y=self.year end
	
	if l=="nl"then
		if d>0 then s=s..string.format("%02d", d) end
		if m>0 then s=s..util.is_empty(s,"","-")..string.format("02%d", m) end
		if y>0 then s=s..util.is_empty(s,"","-")..string.format("04%d", y) end
	else --default en
		if m>0 then s=s..string.format("02%d", m) end
		if d>0 then s=s..util.is_empty(s,"","-")..string.format("02%d", d) end
		if y>0 then s=s..util.is_empty(s,"","-")..string.format("04%d", y) end
	end
	return s
end

function Date:long(weekday)
	--for k,v in pairs(self) do print(k,v) end
	local s=""

	lan = locality.language()
	if self.modifier < Date.Modifier.RANGE then
		s = s .. modifier[self.modifier+1] .. quality[self.quality+1]..self:MakeDate(lan,weekday)
	elseif self.modifier < Date.Modifier.TEXTONLY then
		s = s .. modifier[self.modifier+1].. quality[self.quality+1] ..
			self:MakeDate(lan,weekday)..
			((self.modifier == Date.Modifier.RANGE) and _(" till ") or _(" and ")) ..
			self:MakeDate(lan,weekday,true)
	else
		s = s ..  self.text
	end
	return s
end

  -- Function to calculate the number of days in a year
local function days_in_year(year)
	if is_leap_year(year) then
		return 366
	else
		return 365
	end
end

local function days_in_years(years)
	local total_days = 511340 --de dagen van de eerste 1400 jaar
	-- Sum the days for all complete years from 0 to (year - 1)
	for y = 1400, years - 1 do
		total_days = total_days + days_in_year(y)
	end
	return total_days
end

function Date.from_days_to_years(days)
	local corr = days - 511340
	local year = 1400
	while corr>0 do
	corr = corr - days_in_year(year)
	year = year+1
	end
	return year-1
end

local function is_leap_year(year)
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
function Date:is_leap_year() return is_leap_year(self.year) end

function Date:substract(s)
    local d,m,y
    local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	
	m=self.month
	y=self.year
    if self.day>=s.day then 
		d=self.day-s.day 
	else
		if self.month==0 then d=0 else
			if is_leap_year(self.year) then  days_in_month[2] = 29 end
			d = days_in_month[m] + self.day -s.day
			if m==1 then m=12; y=y-1 else  m=m-1 end 
        end
	end
	if m>=s.month then 
		m=m-s.month;y=y-s.year 
	else
		m=12+m-s.month; y=y-s.year-1 
    end
    if y<0 then return nil end -- geschat verschil kleiner dan jaar
    return y,m,d
  end

---
-- Checks is date is not estimated or relative
-- @param d @{Gramps_date}
-- @return boolean (true if real)
function Date:realdate()
	return (self.modifier and self.modifier == Date.Modifier.NONE and 
			self.day>0 and self.month>0 and self.year>0)
end
---
-- Checks is date has year and is at least about
-- @param d @{Gramps_date}
-- @return boolean (true if real)
function Date:aboutdate()
	return(self.modifier and (self.modifier==gramps6.Date.Modifier.NONE or self.modifier==gramps6.Date.Modifier.ABOUT)  and self.year>0)
end
  

function Date:age(stop)
	return (self:realdate() and stop:realdate()),
          stop:substract(self)
end

function Date:days_from_year_0()-- Moet veranderd	
	local total_days = days_in_years(self.year)
	-- Days in the current year
	local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	-- If it's a leap year, February has 29 days
	if is_leap_year(year) then
		days_in_month[2] = 29
	end
	-- Sum the days for the complete months in the current year
	for m = 1, self.month - 1 do
		total_days = total_days + days_in_month[m]
	end
	-- Add the days for the current month
	total_days = total_days + self.day
	return total_days
end

setmetatable(Date, {
    __call = function(cls,...)
        return cls.new(...)
    end,
})

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	datum1={0,4,0,{1,2,2025,0,2,3,2025}}
	datum2={modifier = 5,quality = 0,calendar=0,dateval={3,3,2026,0,2,3,2025}}
	
	d1 = Date(datum1)
	print(table.tostring(d1))
	d2 = Date(datum2)
	print(table.tostring(d2))
	
	print(d1:long(true))
	print(d2:long(true))
	
	if Date.realdate(d1) then print("okay") end
	if d1:realdate() then print("okay") end
	print(d1:age(d2))
else 
	return Date
end
