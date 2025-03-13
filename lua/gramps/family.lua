if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps") end
if gramps and not gramps.Family.all then

    local _ = require("mh.gettext")
    local print = require("mh.print")
    local util =require("gramps.util")
    DEBUG=4

    function gramps.Family:sort_on() return {self:get_family_date()} end

    function gramps.Family.all()
        local name1,name2,year
        local s=""
        
        gramps.Family()
        for i, h in pairs(gramps.Family.Order) do
            --print(i,"handle",h[1])
            
            local f = gramps.Family(h[1])
            --print(util.dump(h))
            --print(f)
            if f.father_handle then
                local p1 = gramps.Person(f.father_handle)
                name1 =p1:fullname()
            else name1="" end
            if f.mother_handle then
                local p2 = gramps.Person(f.mother_handle)
                name2 =p2:fullname()
            else name2="" end
            
            if h[2][1] > 0 then
                year = tostring(gramps.Date.from_days_to_years(h[2][1]))
            else 
                year = ""
            end
		
            local line = string.format("%-7s%-25s%-25s %s",
                f.gramps_id,name1,name2,year)
            print(line)
            --s=s.."\n"..line
        end
        return s
    end


--    local event_types = {event.TYPE.ENGAGEMENT, event.TYPE.MARRIAGE, event.TYPE.DIVORCE, event.TYPE.ANNULMENT, event.TYPE.MARR_SETTL, event.TYPE.MARR_LIC,
--                event.TYPE.MARR_CONTR, event.TYPE.MARR_BANNS, event.TYPE.DIV_FILING, event.TYPE.MARR_ALT}

    function gramps.Family:get_family_date()
        
        local ret=0
        local t=0
        for i,er in pairs(self.event_ref_list) do
            local e = gramps.Event(er.ref)
            if e.date then 
                local v=e.date:days_from_year_0()
                if v>0 then ret=ret+v;t=t+1; end
            end
        end
        return math.floor(ret/t)
    end

    function gramps.Family:has_children()
        return 0 < #self.child_ref_list
    end

    function gramps.Family:events()
        local evs={}
        for i,ref in pairs(self.event_ref_list) do
            local ev = gramps.Event(ref.ref)
            table.insert(evs,ev) 
        end
        return evs
    end

    
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    local util =require("gramps.util")
--	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")

    local f=gramps.Family('F0001')
    local f2=gramps.Family('F0014')
    print(f)
    for i,ev in pairs(f:events()) do print(ev) end
    --print(f:get_family_date())
    
    --print(gramps.Family.all())
else
    return gramps.Family
end
