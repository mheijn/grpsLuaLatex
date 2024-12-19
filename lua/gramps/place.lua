query=require("gramps.queries")

local Place = {_TYPE='module', _NAME='gramps.place' ,_VERSION='0.9.10.2024'}

local place_meta = {}

local places = {}
local order = {}

function Place:new(handle)

    if places[handle] then
		return places[handle]
	else
		r = query.get_place_from_handle(handle)
		if r[1] then
			places[handle]=r[1]
			if r[1].enclosed_by ~= "" then
                Place:new(r[1].enclosed_by)
            end
			return r[1]
		else
			return(nil)
		end
	end
end

local function check_place(handle)
	p=Place(handle)
	--print("check_handle",p.handle)
	return p.handle
end

function Place:all()
	local r = query.get_place_from_handle(nil,false)
	for i,p in ipairs(r) do
		order[i]=p.handle
		places[p.handle] = p
	end
end

---------------UTIL----------------------
local function is_empty(s,a,b)
	if #s>0 then return(b) else return(a) end end
----------------NAME----------------------
function Place.fulname(handle)
	local p=Place(handle)
	local s=p.title
	if p.enclosed_by ~= ""  then
        local s = s..", "..Place.fulname(p.enclosed_by)
    end
    return s
end

function Place.name(handle)
	local p=Place(handle)
	if p==nil then return "" end
	return p.title
end

-------------------------------------
-- Set the metatable to the module
-------------------------------------
local function place_iterator(order, i)
	--print(order,key)
	i = i + 1
    if i <= #order then
		--print(i,order[i])
        return i, places[order[i]]
    end
end

setmetatable(Place, {
    __call = function(_,handle)
        --print(handle)
        return Place:new(handle)
    end,

	__index = function(_,handle)
		--print("index: ",handle,#personen,Pers(handle))
		--p=Pers(handle)
		--print(p,p.surname)
		return Place(handle)
	end,

	__newindex = function(_,handle,p)
		places[handle]=p
	end,

	__pairs = function(_)
		--print("iterator",t,personen,i)
        return place_iterator, order, 0  -- Return the custom iterator function, table, and initial index
	end
})

return Place
