if gramps then return end

if not gettext then require('mh.gettext') end
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*)/") or "."
--print("Script path:", script_path)
--print("Script directory:", script_dir)
gettext.setDirectory(script_dir)

gramps6={}

gramps6.__TYPE='module'
gramps6.__NAME='gramps6'
gramps6.__VERSION='1.26.2.2026'
gramps6.__DESCRIPTION='gramps6 routines gebruikt voor LuaLaTeX'


-----------------------------------
-- database setup
-----------------------------------

local print = require("mh.print")
require("mh.table")
local TheDataBase="sqlite.db"
local json = require('cjson')
local driver = require('luasql.sqlite3')

function Queries(id)
    local env = nil
    local db = nil
    local databasename
    local tables = {I='person', C='citation', F='family', O='media', E='event',
        N='note', S='source', R='repository', P='place'}
    local self={} 
    
    function self.init(database)
        self.close()
        databasename = database or TheDataBase
        env = assert(driver.sqlite3(),"problem in sqlite3 copling")
        db = assert(env:connect(databasename),"No conection to "..databasename)
    end

    function self:close()
        if db ~= nil then
            db:close()
            env:close()
        end
        db=nil
    end

    function self.query(q)

        local data={}

        if db==nil then self.init() end

        local results,err = db:execute(q)
        if not results then
            print.e("Error:", err, '"'..q..'"'..' ('..databasename..')')
            return(data)
        end

        row = results:fetch({},"a")
        while row do
            if row['json_data'] then
                value = json.decode(row['json_data'])
                table.insert(data,  value)
            else
                --table.insert(data, table.copy( row))
                table.insert(data,  row)
            end
            row = results:fetch(row,"a")
        end
        results:close()  
        return(data)
    end

    function self.get_handle_from_id(gramps_id)
        local fc=string.sub(gramps_id,1,1)
        local table = tables[fc]
        res=self.query("SELECT handle FROM "..table.." WHERE gramps_id='"..gramps_id.."'")
        if 0==#res then 
            print.e(string.format("The id %s is not found in sql-database \"%s\"",gramps_id,databasename)) return nil
        else return res[1].handle end
    end

    function self.get_tablerow_from_handle(handle,table)
        res = self.query("SELECT * FROM "..table.." WHERE handle='"..handle.."'")
        if res[1] then return res[1] else return nil end
    end
    
    -- Metadata
    function self.get_metadata(setting)
        local res=self.query("SELECT * FROM metadata WHERE setting = '"..setting.."'")
        return res
    end


    function self.handle(id)
    
        print.d("Creating class \""..tables[id].."\"")
        obj = {}
        obj.__index = obj -- critical line

        local obj = setmetatable({}, self)
        obj.__Name = "DataContainer ("..tables[id]..")"
        obj.hash = {}
        obj.data = {}
        obj.Order = {}
        obj.tablename = tables[id]
        
        function  obj:new()
            local obj = {
                name = name,
                data = {}
                }
            return setmetatable(obj, self)
        end

        
        obj.get = function(o,string)
            local handle  = o.hash['string'] or string or ""
            if o.data[handle] then return handle end
            if 0 < #handle and #handle < 8 then handle = self.get_handle_from_id(string) end
            d = self.get_tablerow_from_handle(handle,o.tablename)
            o.data[handle] = d
            o.hash[d.gramps_id]=handle
            return handle
            end
            
        obj.tostring = function(o)
            print(json.encode(0, { indent = true }))
            end
        return setmetatable(obj, {
            __index = self,
            __call = function(self, id)
                        return self:get(id)
                    end})
    end
    return self
end


gramps6.DataSet    = require('gramps6.DataSet')
gramps6.Queries    = Queries()
require('gramps6.person')
require('gramps6.events')
require('gramps6.place')
gramps6.Family     = gramps6.DataSet('Family',gramps6.Queries)
gramps6.Citation   = gramps6.DataSet('Citation',gramps6.Queries)
gramps6.Media      = gramps6.DataSet('Media',gramps6.Queries)
--gramps6.Event      = gramps6.DataSet('Event',gramps6.Queries)
gramps6.Note       = gramps6.DataSet('Note',gramps6.Queries)
gramps6.Source     = gramps6.DataSet('Source',gramps6.Queries)
gramps6.Repository = gramps6.DataSet('Repository',gramps6.Queries)

gramps6.SetDatabase = gramps6.Queries.init
gramps6.media_path  = function() return gramps6.Queries.get_metadata('media_path')[1].value end
gramps6.researcher  = function() return gramps6.Queries.get_metadata('researcher')[1].value end
gramps6.version     = function() return gramps6.Queries.get_metadata('version')[1].value end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    --print(gramps6.Queries.get_handle_from_id('I0018'))
    --print(table.tostring(gramps6.Person))
    --print(table.tostring(gramps6.Person('I0018')))
    --print(table.tostring(gramps6.Family('c5db97e598e374cef8cb0637377')))
    
    --print(table.tostring(gramps6.Person))
    --print(table.tostring(gramps6.Family))
    
    p=gramps6.Person:get('I0018')
    p=gramps6.Person:get('I0692')
    gramps6.Person.print(p.event_ref_list[1])
    
    e=gramps6.Event:get(p.event_ref_list[1].ref)
    
    e:print()
    gramps6.Person('I0692'):print()
    print(table.tostring(gramps6.researcher()[1].value))
else
    return(gramps6)
end

