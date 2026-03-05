-----------------------------------
-- DataSet
-----------------------------------
local Date = require('gramps6.Date')

function DataSet(thetable,q)
    local Set = {}
    Set.hash = {}
    Set.data = {}
    Set.__index = Set   -- critical line
    Set.tablename = thetable

    function Set:new(name)
        local obj = {
            name = name,
            data = {}
        }
        return setmetatable(obj, self)
    end
    
    function Set:print()
        --print(table.tostring(self))
        print(Set.tostring(self))
    end
    
    function Set.tostring(t, tab)
        tab = tab or ""
        s=""
        --print(table.tostring(t))
        
        for i,v in pairs(t) do
            s = s.."\n"..tab..i.." = "
            if type(v)=="table" then 
                if table.size(v)==0 then 
                    s= s.."{}"
                else 
                    s= s.."{"
                    s = s.. Set.tostring(v,tab.."   ")
                end
            else
                if type(v)=="boolean" then
                    if v then s = s.."TRUE" else s = s.."FALSE" end
                else
                    s = s..table.tostring(v)
                end
            end
        end
        return s
    end

    function Set:get(h)
        -- If present and gramps_id then give handle
        local handle  = Set.hash[h] or h or ""
        -- If present give Data
        if self.data[handle] then 
            return setmetatable(Set.data[handle],self) 
        end
        -- If granps_id search handle    
        if 0 < #handle and #handle < 8 then 
            handle = q.get_handle_from_id(handle) 
        end
        -- get Data
        local d = q.get_tablerow_from_handle(handle,self.tablename)
        if(d.date) then d.date = Date(d.date) end 
        self.data[handle] = d
        self.hash[d.gramps_id]=handle
        return setmetatable(Set.data[handle], self)
    end
    
    function Set:events(key)
        local evs={}
        for i,ref in pairs(self.event_ref_list) do
            local ev = gramps6.Event(ref.ref)
            if(not key or ev.type.value == key) then
                table.insert(evs,ev) 
            end
        end
        return evs
    end

    
    return setmetatable(Set,{
        __call = function(self,id) return self:get(id) end
    })
end

return DataSet
