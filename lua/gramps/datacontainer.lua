DEBUG = 4
local print = require("mh.print")
--require("mh.table")
local _ = require("mh.gettext")
local util=require("gramps.util")
local query=require("gramps.queries")


local DataContainer = { Container = {}, Hash={}, Order={} }
DataContainer.__index = DataContainer

local function array_to_string(items,a,del,tab)
    s="{"
    --print("Data:",util.dump(a))
    --print("Items",util.dump(items))
    for i,v in ipairs(a) do
        if items.class then
            --print(util.dump(v))
            local cl = items.class(v);
            s=s.. cl:tostring(tab,i)
        else
            s=s..tostring(v)
            if i<#s then s=s..del end
        end
    end
    return s.."}"
end
local function prints_entry(entry, data, tab)
--print(entry.title, util.dump(data),util.dump(entry.type))
    if entry.type == "string" then
            return string.format("\n%s%-20s %s",tab,entry.title,data)
    elseif entry.type == "null" then
            return string.format("\n%s%-20s nil",tab,entry.title)
    elseif entry.type == "integer" then
            return string.format("\n%s%-20s %d",tab,entry.title,data)
    elseif entry.type == "boolean" then
            return string.format("\n%s%-20s %s",tab,entry.title,tostring(data))
    elseif entry.type == "array" then
            return string.format("\n%s%-20s %s",tab,entry.title, array_to_string(entry.items,data, ", ",tab))
    elseif type(entry.type) == "table" then 
        for it,tt in pairs(entry.type) do
            if tt == type(data) then return string.format("\n%s%-20s %s",tab,entry.title,tostring(data)) end
            if tt=="null" and not data then return string.format("\n%s%-20s nil",tab,entry.title) end
        end 
    elseif entry.map then 
            --print(data,util.dump(entry.map))
            return string.format("%s",entry.map[data][1])
    elseif entry.class then
            return  entry.class(data):tostring(tab);
    elseif entry.oneOf then
        for _,subentry in ipairs(entry.oneOf) do
            if entry.title then subentry.title = entry.title end --put title also in subentries 
            if type(data) == "table" and subentry.class then
                return  subentry.class(data):tostring(tab);
            elseif not data and subentry.type == "null" then
                return prints_entry(subentry,nil,tab)
            elseif (subentry.type=="string" and type(data)== string) or
                    (subentry.type=="boolean" and type(data)== boolean) or
                    (subentry.type=="integer" and type(data)== number) then
                return prints_entry(subentry,data,tab)
            end
            --if subentry.class then                return subentry.class(data):tostring(tab)end
        end
    end
    return ""
end

function DataContainer:tostring(tab,key)
    tab = tab or ""
    s=""
    if #self.scheme>2 then --Only string modules have 2
        s=s.."\n"..tab.."Data of "..self.scheme.scheme_type['title']
        if self.scheme.scheme_type.table then s=s.." from table ",self.scheme.scheme_type['table'] end
    else -- give string with  module name
        s=s..string.format("\n%s%-21s",tab,self.scheme.scheme_type['title'])
    end 
    
    if key then tab = string.format("%s[%s] ",tab,tostring(key))
    else  tab=tab.."   " end

    for i,n in pairs(self.scheme_index) do
        s=s..prints_entry(self.scheme[n],self.data[i],tab)
    end

    return s
end

function DataContainer:get(name)
    --print(name)
    --printfun(self,"self in get")
--if self.__Name == "DataContainer (Event Type)" then
--for k,v in pairs(self.scheme) do print(k,v) end
--for k,v in pairs(self.data) do print(k,v) end
--end
    if #self.scheme_index == 1 then --Only one index = must be string
        if self.scheme.string and self.scheme.string.map then
            local nr = self.data[1]
            if "text"==name then return self.scheme.string.map[nr][1] 
            elseif "string"==name then return self.scheme.string.map[nr][2] 
            else return nr end
        end
    end
	local entry=self.scheme[name]
	local index=self.scheme_index
	if entry then

        i=entry.index
		if entry.type == "string" then  return self.data[i], entry.title end
		if entry.type == "integer" then  return tonumber(self.data[i]), entry.title end
		if entry.type == "array" then  
            if entry.items.class then
                local class_array ={}
                for i,v in pairs(self.data[i]) do table.insert(class_array,entry.items.class(v)) end 
                return class_array
            end
            return self.data[i], entry.title 
        end
        if type(entry.type)=="table" then
            for it,tt in pairs(entry.type) do
                if tt== type(self.data[i]) then return self.data[i], entry.title end
                if tt=="null" and not self.data[i] then return nil, entry.title end
            end 
        end
		if entry.class then
			return entry.class(self.data[i])
		end
		if entry.oneOf then
			for _,subentry in ipairs(entry.oneOf) do
				if self.data[i] == nil and subentry.type == "null" then return nil end
				if subentry.class then return subentry.class(self.data[i]) end
				if type(self.data[i]) == "table" and subentry.type=="array" then  return self.data[i], entry.title end
			end
		end
	end
	local error = string.format(_("%s not in scheme of %s"),name,self.scheme.scheme_type.title)
	if DEBUG and DEBUG>3 then
        print.D(error.." Valide entries are:")
        for i,k in pairs(self.scheme_index) do print.D(i,k) end 
    end
	return  nil, error
end


function DataContainer:VerifyData(data)
    --print("DATA",util.dump(data))
    --print("SCHEME",util.dump(self.scheme))

	local correct = true
	self.error = string.format("Error in %s:",self.scheme.scheme_type.title)
	for i,n in ipairs(self.scheme_index) do
		local v=self.scheme[n]
		local error = false
		if  v.type then
			--if i == 9 then print(v.type,type(data[i])) end
			if v.type=="integer" and type(data[i])~="number" then error=true;correct=false
			elseif v.type=="string" and type(data[i])~="string" then
                if data[i]==nil then
                    data[i]=""; error=true;print.e(string.format("\nEntry %d named %s is nil and changes to \"\"",i,n))
                else
                    error=true;correct=false; print("fout")
                end
			elseif v.type=="array" and type(data[i])~="table" then error=true;correct=false
			end
			if error then
				self.error = self.error .. string.format("\nEntry %d named %s in must be %s and is %s",
                            i,n,v.type,type(data[i]))
			end
		end
	end
	if not correct then print.e(self.error) end
	return correct
end

function DataContainer:CreateClass(scheme)
    print.d("Creating class \""..scheme.scheme_type.title.."\"")
    local obj = setmetatable({}, self)
    obj.scheme = scheme
    obj.__Name = "DataContainer ("..scheme.scheme_type.title..")"
    obj.scheme_index={}
    obj.Container = {}
    obj.Order = {}
    for k,v in pairs(scheme) do if v.index  then obj.scheme_index[v.index]=k end end
    obj.get = self.get
    --return obj
    return setmetatable(obj, {
        __index = self,
        __call = self.__call,
--[[        __pairs = function(cls)
            local i=0
            --print(i,#obj.Order,obj.scheme.scheme_type.title)
            --for k,v in pairs(obj) do print(k,v) end

            return  function()
                i=i+1
                --print(i)
                --for k,v in pairs(obj) do print(k,v) end
                if i<=#obj.Order then
                    local h = obj.Order[i][1]
                    local d = obj.Container[h]
                    --DataContainer.InputData(obj,d)

                    return h, d
                end
              end
            end]]--
        })
end






function DataContainer:InputData(data)
        if self:VerifyData(data) then
            local obj = setmetatable({}, self)
            for k,v in pairs(self) do obj[k]=v end
            obj.data = data
            obj.tostring = DataContainer.tostring
            --return  obj  -- Set metatable again to allow obj1(s) to work
            return setmetatable(obj, {
                __index = function(cls,n) return cls:get(n) end,
                __tostring = DataContainer.tostring,
                __call = self.__call })

        else
            return nil, self.error
        end
end

function DataContainer:GetData(string)

    local handle  = self.Hash['string'] or string or ""
    --print("GET","|"..handle.."|")
    if self.Container[handle] then return DataContainer.InputData(self,self.Container[handle]) end
    
    if 0 < #handle and #handle < 8 then handle = query.get_handle_from_id(string) end
    
    for i,v in pairs(query.get_from_handle(self.scheme.scheme_type.table,handle)) do -- get from sql-database
    
        if self.scheme.scheme_type.hash then -- Save handle in hash table
            self.Hash[v[self.scheme.scheme_type.hash]]=v.handle 
        end
        
        self.Container[v.handle] = v.blob_data
        local so = {""}
        if self.scheme.scheme_type.sort then 
            so = DataContainer.InputData(self,v.blob_data):sort_on()
        end
        self.Order[#self.Order+1]={v.handle,so}
    end
    table.sort(self.Order, function(a, b)
        if a[2][1] == b[2][1] and a[2][2] then return a[2][2] < b[2][2] end
        return a[2][1] < b[2][1]  
        end)


    if self.Container[handle] then return DataContainer.InputData(self,self.Container[handle]) end
    return nil
    --return DataContainer.InputData(self,self.Container[handle])
end

function DataContainer:new(data)
    --printfun(self,"self in __call")
    --print(type(data))
    --printfun(data,"DATA")
    
    if self.scheme then -- schemea exists
        if type(data) == "table" then --input data
            return self:InputData(data) -- gives obj or nil
        elseif type(data) == "string" then
            return self:GetData(data) 
        elseif type(data) == "nil" then 
            return self:GetData("") 
        end
    else -- No scheme, input scheme
        if type(data) == "table" then
            if data.scheme_type then return self:CreateClass(data) end
        end
    end
    return self
end

function DataContainer:__call(data)
    return self:new(data)  -- Create a new instance when called
end

-- Set metatable so that DataContainer itself is callable
--setmetatable(DataContainer, DataContainer)
--setmetatable(DataContainer, { __call = DataContainer.__call })
setmetatable(DataContainer, { __call = function(cls, s) return cls:new(s) end })



if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then

    local Scheme={
		calendar = {index=1 ,type= "integer", title= _("Calendar")},
		modifier = {index=2 ,type= "integer", title= _("Modifier")},
		quality =  {index=3 ,type= "integer",  title= _("Quality")},
		dateval =  {index=4 ,type= "array", title= _("Values"), items= {type= {"integer", "boolean"}}},
		text =     {index=5 ,type= "string", title= _("Text")},
		sortval =  {index=6 ,type= "integer", title= _("Sort value")},
		newyear =  {index=7 ,type= "integer", title= _("New year begins")},
		scheme_type = {class="Date", title="Date"}
		}

    local Date = DataContainer(Scheme)
    function Date:long()
        --print("long");
        --printfun(self,"self in Data:long");

        local d,es = self:get('dateval')
        if d==nil then print(es) end

        --printfun(self,"self in Data:long");

        --local t,es = self:get('text')
        --if t==nil then print(es) end

        s=d[1].."-"..d[2].."-"..d[3].."("..self:get('text')..")"
        print(s)
    end

    printfun(Date,"Date")

    local datum1 = Date({0,0,0,{1,2,2025,0,2,3,2025},"datum 1",0,0})

    local datum2, str = Date({0,0,0,{1,2,2025,0,2,3,2025},"datum 2",0,0})
    if not datum2 then print(Date.error,str) end

    printfun(datum2,"datum 2")
    print("datum2:get('text'):",datum2:get('text'))
    print("datum2['text']:",datum2['text'])
    print("datum2.text:",datum2.text)

    --printfun(datum1,"datum 1")
    datum1:long()

-- Example usage
--local d = { { index = 1 }, { index = 2 } }
--local s = { { index = 3 }, { index = 4 } }

--local obj1 = DataContainer(d)  -- Calls DataContainer:new(d)
--local obj2 = obj1(s)  -- Calls obj1:__call(s), which creates obj2

--print(obj1.scheme_index[1])  -- Output: 1
--print(obj2.scheme_index[3])  -- Output: 3
else
    return DataContainer
end
