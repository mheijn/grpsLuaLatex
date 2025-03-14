if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps") end
if gramps and not gramps.Date.MakeDate then

    local _ = require("mh.gettext")
    local print = require("mh.print")
    local locality =  require("mh.local")
    local util= require("gramps.util")
    DEBUG=4




  local days = { _("Sunday"), _("Monday"), _("Tuesday"), _("Wednesday"), _("Thursday"), _("Friday"), _("Saturday") }
  local months={_("January"),_("Februari"),_("March"),_("April"),_("May"),_("June"),
      _("Jyly"),_("August"),_("September"),_("October"),_("Noveber"),_("December")}
  local modifier={"",_("before "),_("after "),_("about "),_("range "),_("between "),(""),(""),(""),("")}
  local quality={"",_("estimate as "),_("calculated as "),_("calclated and estimate as ")}
  local short_modifier={"",_("<"),_(">"),_("~"),(""),_("<>"),(""),(""),(""),("")}
  local short_quality={"",_("~"),_("+/-"),_("~+/-")}

  function gramps.Date.MakeDate(d,m,y,l,weekday)
    local s =""
    if weekday and d>0 and m>0 and y>0 then s=s.. days[gramps.Date.weekday(d,m,y)].." " end
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

  function gramps.Date.MDate(d,m,y,l)
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

  function gramps.Date:long(weekday)
    --for k,v in pairs(self) do print(k,v) end
    local s=""

    local d =self.dateval
    if type(d) ~= "table" then return "" end
    lan = locality.language()
    if self.modifier < gramps.Date.Modifier.RANGE then
      s = s .. _("on ")..quality[self.quality+1].. modifier[self.modifier+1]..gramps.Date.MakeDate(d[1],d[2],d[3],lan,weekday)
    elseif self.modifier < gramps.Date.Modifier.TEXTONLY then
      s = s .. quality[self.quality+1].. modifier[self.modifier+1]..gramps.Date.MakeDate(d[1],d[2],d[3],lan,weekday)..
            _(" and ") ..gramps.Date.MakeDate(d[5],d[6],d[7],lan,weekday)
    else
      s = s ..  self.text
    end
    return s-- .." ("..lan..")"
  end

  function gramps.Date:short()
    local d =self.dateval
    if type(d) ~= "table" then return "" end
    print(type(d))
    lan = locality.language()
    local s=""
    if self.modifier < gramps.Date.Modifier.RANGE then
      s = s .. short_quality[self.quality+1].. short_modifier[self.modifier+1]..gramps.Date.MDate(d[1],d[2],d[3],lan)
    elseif self.modifier < gramps.Date.Modifier.TEXTONLY then
      s = s .. short_quality[self.quality+1].. short_modifier[self.modifier+1]..gramps.Date.MDate(d[1],d[2],d[3],lan)..
            " - "..gramps.Date.MakeDate(d[5],d[6],d[7],lan,weekday)
    end
    return s
  end

  ---
  -- @table Calendar
  gramps.Date.Calendar={
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
  gramps.Date.Modifier={
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
  gramps.Date.Quality={
    NONE      = 0,      -- 0
    ESTIMATED = 1 ,-- 1
    CALCULATED = 2,  -- 2
    INTERPRETED = 4 -- 4
    }

  function gramps.Date.weekday(day, month, year)
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
  function gramps.Date:realdate()
      local d =self.dateval
      if d then
          return (d[2]==gramps.Date.Modifier.NONE and d[4][1]>0 and d[4][2]>0 and d[4][3]>0)
      else return false end
  end

  ---
  -- Checks is date has year and is at least about
  -- @param d @{Gramps_date}
  -- @return boolean (true if real)
  function gramps.Date:aboutdate()
      local d =self.dateval
      
      return d and ((d[2]==gramps.Date.Modifier.NONE or d[2]==gramps.Date.Modifier.ABOUT)  and d[4][3]>0)
  end

  local function substract( d1, m1, y1, d2, m2, y2)
    local d,m,y
    local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    
    if m1==0 then m1=6 end; if m2==0 then m2=6 end --for estimates in year take half way
    
    if d1>=d2 then d=d1-d2 else
        if is_leap_year(y1) then  days_in_month[2] = 29 end
        d = days_in_month[m1] + d1 -d2
        if m1==1 then m1=12; y1=y1-1 else  m1=m1-1 end 
    end
    if m1>=m2 then m=m1-m2;y=y1-y2 else
      m=12+m1-m2; y=y1-y2-1 
    end
    --print(d1,m1,y1,d2,m2,y2,y,m,d)
    return y,m,d
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

  function gramps.Date.from_days_to_years(days)
      local corr = days - 511340
      local year = 1400
      while corr>0 do
        corr = corr - days_in_year(year)
        year = year+1
      end
      return year-1
    end
  ---
  --  calculate total number of days from year 0 to a given year
  function gramps.Date:days_from_year_0()-- Moet veranderd
      local d =self.dateval
      
      if d then 
        local year, month, day
        year=d[3]; month=d[2]; day=d[1]
        
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
      else 
        return 0
      end
  end
  
  function gramps.Date:age(stop)
    local sa=self.dateval
    local ss=stop.dateval
    
    if sa and ss then
      return substract(tonumber(ss[1]), tonumber(ss[2]),tonumber(ss[3]),tonumber(sa[1]),tonumber(sa[2]),tonumber(sa[3]))
    end
    return  nil
  end
  ---
  -- @param year
  -- @return month, day, day_of_year, days_from_year0
  function calculateEasterDay(year)-- Moet veranderd
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

end
if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    local util =require("gramps.util")
    local locality =  require("mh.local")
    
    --local days=Date.days_from_year_0(2000,0,0)
    --print("days/year",days/2000)
    util.printfun(gramps.Date,"Ndate")
    local da1=gramps.Date({0,0,0,{1,2,2025,0,2,3,2025},"datum 1",0,0})
    local da2=gramps.Date({0,0,0,{1,2,2023,0,2,3,2023},"datum 2",0,0})
    util.printfun(da2,"datum d2")
    local da3=gramps.Date({0,0,0,{1,2,2023,0,2,3,1962},"datum 3",0,0})

    print("age ",da3:age(da1))
    print(da2:get('text'))
    --printfun(da2,"d2:")
    --print(da1.text)
    --print(da2:get('text'))
    --print(da2['text'])
    --print(da2.text)
    --print(da3.text)


 --   da1:long()
    print(da2:long())
    locality.setlanguage('nl')
    print(da2:long(true))
    print(da2:short())
    print(da2:days_from_year_0())
    --print(days[Date.weekday(1,3,2025)])
    print(gramps.Date.from_days_to_years(738920))

else
    return gramps.Date
end
