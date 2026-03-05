if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps6") end
    
--print(table.tostring(gramps6.Person,2))

if gramps6 and not gramps6.Person then
    gramps6.Person     = gramps6.DataSet('Person',gramps6.Queries)
    gramps6.Person.__file = debug.getinfo(1, "S").source:sub(2)

    local _ = require("mh.gettext")
    local print = require("mh.print")
    local util =require("gramps6.util")
    DEBUG=4

    local function _surname(n)
        s=""
        if 0<#n.prefix then s=s..n.prefix.." " end
        if 0<#n.surname then s=s..n.surname end
        return s
    end
    local function surname(name)
        s=""
        for i,n in pairs(name.surname_list) do
            if i==2 then s=s.." (" end
            if i>3 then s=s..", " end
            if i>2 then s=s..string.format("[%d]",i) end
            s=s.._surname(n)
            if i>1 and i==#name.surname_list then s=s..")" end
        end
        return s
    end

    function gramps6.Person:fullname()
        s=""
        local name = self.primary_name
        local nn=name.nick
        s=surname(name)..util.is_empty(nn,""," (")..nn..util.is_empty(nn,"",")")
        s=name.first_name..util.is_empty(s,""," ")..s
        return s
    end
    function gramps6.Person:surname() return surname(self.primary_name) end
    function gramps6.Person:firstname()	return self.primary_name.first_name end
--[[
    function get_event(p)
        local s
        for i,ref in pairs(p.event_ref_list) do
            print(ref.ref)
            local e = gramps6.Event(ref.ref)
            s = e:long()
        end
        return s
    end
]]--
    function gramps6.Person:birth() end
    function gramps6.Person.death() end
    function gramps6.Person:sort_on() return {self:surname(), self:firstname()} end
    
    function gramps6.Person:hasChildren()
        for fi,fh in ipairs(self.family_list) do
            f = gramps6.Family(fh)
            if #f.child_ref_list > 0 then return true; end
        end
        return false
    end
    function gramps6.Person:hasParents()
        ret = 0
        for fi,fh in ipairs(self.parent_family_list) do
            f = gramps6.Family(fh)
            if f.father_handle then ret = ret | 1 end
            if f.mother_handle then ret = ret | 2 end
        end
        return ret
    end
    function gramps6.Person:hasFather() return (1 & self:hasParents())>0 end
    function gramps6.Person:hasMother() return (2 & self:hasParents())>0 end
    function gramps6.Person:getFather() 
        for fi,fh in ipairs(self.parent_family_list) do
            local f = gramps6.Family(fh)
            return f.father_handle 
        end
    end
    function gramps6.Person:getMother() 
        for fi,fh in ipairs(self.parent_family_list) do
            local f = gramps6.Family(fh)
            return f.mother_handle 
        end
    end

    function gramps6.Person.all()
        local s="";local sb="";local sd=""
        local pt = {}
        gramps6.Person()
        for i, h in pairs(gramps6.Person.Order) do
            local p = gramps6.Person(h[1])
		
            bi,ba,de,bu = p:Life()
            --print("gg")
            sb=""
            sd=""
            if bi then sb = bi:datum()
            elseif ba then sb = ba:datum() end
            if de then sd = de:datum()
            elseif bu then  sd = bu:datum() end
            --print("ff")
            local line = string.format("%-7s%-15s%-15s %11s %11s",
                p.gramps_id,p:surname(),p:firstname(),sb,sd)
            --print(line)
            table.insert(pt,{
                id = p.gramps_id,
                surname = p:surname(),
                firstname = p:firstname(),
                birth = sb,
                death = sd
                })

            s=s.."\n"..line
        end
        return pt
    end

    function gramps6.Person:Life()
        local birth,bapt,death,buri

        for i,ref in pairs(self.event_ref_list) do
            local ev = gramps6.Event(ref.ref)
            --print("event"); ev:print()
            if ev.type.value  == gramps6.Event.Type.BIRTH then
                birth=ev
            elseif ev.type.value  == gramps6.Event.Type.BABTISM then
                bapt=ev
            elseif ev.type.value  == gramps6.Event.Type.DEATH then
                death=ev
            elseif ev.type.value  == gramps6.Event.Type.BURIAL then
                buri=ev
            end
            --print(ev.type.value)
        end
        return  birth,bapt,death,buri
    end
    
    function gramps6.Person:age()
        local b,d
    
        bi,ba,de,bu = self:Life()
    
        if bi then b = bi.date
        elseif ba then b = ba.date end
    
        if de then d = de.date
        elseif bu then d = bu.date end
        
        --print(b,d)
        if b and d then return b:age(d) end
        return nil
    end
--[[    
    function gramps6.Person:event(key)
        evs={}
        for i,ref in pairs(self.event_ref_list) do
            local ev = gramps6.Event(ref.ref)
            local s=ev:long(key)
            if 0<#s then table.insert(evs,s) end
        end
        return evs
    end
    function gramps6.Person:events()
        local evs={}
        for i,ref in pairs(self.event_ref_list) do
            local ev = gramps6.Event(ref.ref)
            table.insert(evs,ev) 
        end
        return evs
    end
]]--
end
----------------------------------------

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
--	query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
	--gramps6.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
	--p1=gramps6.Person('I0565')
	p2=gramps6.Person('I0010')
    --p2:print()
	print(p2:age())
	p3=gramps6.Person('I0683')
    --p3:print()
	print(p3:age())
	--print(gramps6.Person.all())
	--print(util.dump(p1.data))
	--for k,v in pairs(gramps6.Person) do print(k,type(v),v) end
	--print(p1.naam)
	--print(p1:fullname())
	--print(p1.birth_ref_index,p1.death_ref_index)
	--print(p1)
	--p1:events()
	--print(p2)
	--p3:Date()

else
    return(Person)
end

