local event=require("gramps.events")
local query=require("gramps.queries")
local family=require("gramps.family")
local util=require("gramps.util")

local Pers = {_TYPE='module', _NAME='grps_persoon' ,_VERSION='0.2.10.2024'}
local pers_meta = {}


local personen = {}
local order = {}
local id_handle = {}

--function Pers(req) Pers:new(req) end
local function check_handle(req)
	local handle
	if type(req)=="string" then
		if #req >6 then
			handle=req
		else
			handle  = id_handle[req] or query.get_person_handle_from_id(req)
		end
	elseif type(req)=="table" then
		handle = {}
		for i,h in ipairs(req) do
			if #req >6 then
				table.insert(handle,h)
			else
				table.insert(handle, id_handle[req] or query.get_person_handle_from_id(h))
			end
		end
	end
	return handle
end

function Pers:new(req)
	handle = check_handle(req)

	--print("handle = ",req,util.dump(handle))
	local res={}
	local request={}
	local length=0

	if type(handle)=="table" then
		for i,h in ipairs(handle) do
			if personen[h] then
				res[h]=personen[h]
				length=length+1
			else
				table.insert(request,h)
			end
		end
	else
		if personen[handle] then
			return personen[handle]
		else
			request[1]=handle
		end
	end

	if #request>0 then
		r = query.get_person_from_handle(request,true)
		for i, p in ipairs(r) do
			personen[p.handle]=p
			id_handle[p.gramps_id] = p.handle
			res[p.handle]=p
			length=length+1
		end
	end
	--print("res = ", length )


	if length==0 then return nil end
	if length==1 then for k,v in pairs(res) do return v end end
	return res
end

local function check_person(req)
	p=Pers(req)
	--print("check_handle",p.handle)
	return p.handle
end

function Pers:all()

	local r = query.get_person_from_handle(nil,false)
	for i,p in ipairs(r) do
		order[i]=p.handle
		id_handle[p.gramps_id]=p.handle
		--print(i,p.handle,p)
		personen[p.handle] = p
	end
	table.sort(order, function(a,b)
		if personen[a].surname==personen[b].surname then
			return personen[a].given_name<personen[b].given_name
		else
			return personen[a].surname<personen[b].surname
		end
	end)

	--print("getting events")
	evs = query.get_events_from_persons()
	local i=0
	for i,e in ipairs(evs) do
		event[e.handle]=e

		if Pers[e.person_handle].events == nil then Pers[e.person_handle].events={} end
        table.insert(Pers[e.person_handle].events,e.handle)
	end
	print("Getting birth and baptism dates")
	for h,p in pairs(Pers) do
		if p.events then
			Pers.birth(p.handle)
			Pers.baptism(p.handle)
			Pers.death(p.handle)
			Pers.burial(p.handle)
		--print(util.dump(Pers[p.handle].birth))
		end
	end
end

function Pers.events(handle)
	--print("handle in person event ",handle)
	if Pers[handle].events == nil then
		--print("Getting events...")
        Pers[handle].events = event.events(handle)
	end
	return Pers[handle].events
end

----------------NAME----------------------
function Pers.fullname(handle)
	local p=Pers(handle)
	if p then
		return p.given_name..util.is_empty(p.given_name,""," ")..p.surname
	else return "NF" end
end
function Pers.firstname(handle)
	local p=Pers(handle)
	if p then
		return util.is_empty(p.given_name,"",p.given_name)
	else return "NF" end
end
function Pers.familyname(handle)
	local p=Pers(handle)
	if p then
		return util.is_empty(p.surname,"",p.surname)
	else return "NF" end
end
----------------------------------------------

function Pers.dateindication(handle)
	local ret = 0
	local pevs = Pers.events(handle)

	local evs = event.get_event_by_type(pevs,event.TYPE.BIRTH)
	if evs[1] then
		local ev=event[evs[1]]
		if blob and blob[4] ~= nil then
			ret = util.days_from_year_0(ev.blob_data[4][4][3],ev.blob_data[4][4][2],ev.blob_data[4][4][1])
		end
	else
		evs = event.get_event_by_type(pevs,event.TYPE.BAPTISM)
		if evs[1] then
			local ev=event[evs[1]]
			if blob and blob[4] ~= nil then
				ret = util.days_from_year_0(ev.blob_data[4][4][3],ev.blob_data[4][4][2],ev.blob_data[4][4][1])
			end
		end
	end
	return ret
end

function Pers.birth(handle)
	if Pers[handle].birth then return Pers[handle].birth end
	Pers[handle].birth={}
	local pevs = Pers.events(handle)
	local evs = event.get_event_by_type(pevs,event.TYPE.BIRTH)
	if evs[1] then
		local blob=event[evs[1]].blob_data
		--print(handle,evs[1],util.dump(blob))
		if blob and blob[4] ~= nil then
			Pers[handle].birth=blob[4][4]
		end
	end
	return Pers[handle].birth
end
function Pers.baptism(handle)
	if Pers[handle].baptism then return Pers[handle].baptism end
	Pers[handle].baptism={}
	local pevs = Pers.events(handle)
	local evs = event.get_event_by_type(pevs,event.TYPE.BAPTISM)
	if evs[1] then
		local ev=event[evs[1]]
		if blob and blob[4] ~= nil then
			Pers[handle].baptsm=ev.blob_data[4][4]
		end
	end
	return Pers[handle].baptism
end
function Pers.death(handle)
	if Pers[handle].death then return Pers[handle].death end
	Pers[handle].death={}
	local pevs = Pers.events(handle)
	local evs = event.get_event_by_type(pevs,event.TYPE.DEATH)
	if evs[1] then
		local blob=event[evs[1]].blob_data
		--print(handle,evs[1],util.dump(blob))
		if blob and blob[4] ~= nil then
			Pers[handle].death=blob[4][4]
		end
	end
	return Pers[handle].death
end
function Pers.burial(handle)
	if Pers[handle].burial then return Pers[handle].burial end
	Pers[handle].burial={}
	local pevs = Pers.events(handle)
	local evs = event.get_event_by_type(pevs,event.TYPE.BURIAL)
	if evs[1] then
		local ev=event[evs[1]]
		if blob and blob[4] ~= nil then
			Pers[handle].burial=ev.blob_data[4][4]
		end
	end
	return Pers[handle].burial
end

---**********************************
function Pers.make_birth_death()
	print("get all events")
	event.events()

	local r = query.get_person_from_handle(nil,false)
	for i,p in ipairs(r) do
		order[i]=p.handle
		id_handle[p.gramps_id]=p.handle
		p.events = event.events(p.handle)
		--print(i,p.handle,p)
		personen[p.handle] = p
	end
	table.sort(order, function(a,b)
			if personen[a].surname==personen[b].surname then
				return personen[a].given_name<personen[b].given_name
			else
				return personen[a].surname<personen[b].surname
			end
		end)


end
-----------------------------------------------------

function Pers.sort_person_handles(handles)
   local s={}
   for i,h in ipairs(handles) do
      s[i]={i,Pers.dateindication(h)}
   end
   table.sort( s, function(a, b) return a[2] < b[2] end )
   return s
end

function Pers.family(handle)
	local p=Pers(handle)
	--print(handle,util.dump(p))
	local handle = p.handle
	--print("person family: ",handle)

	if Pers[handle].parents == nil then
		Pers[handle].spouses, Pers[handle].parents = family.get_person_family(handle)
	--print(util.dump(Pers[handle]))
	end
	--print(util.dump(Pers[handle]))
	return Pers[handle]
end

function Pers.parents(handle)
	--print("person parent: ",handle)
	local p=Pers.family(handle)
	return p.parents
end

function Pers.has_parents(handle)
	local parents=Pers.parents(handle)
	return (parents ~= nil)
end

function Pers.spouses(handle)
	local p=Pers.family(handle)
	return p.spouses
end

function Pers.has_children(handle)
	for i,fh in ipairs(Pers.spouses(handle)) do
        local children = family.get_children(fh)
        if #children > 0 then return true end
	end
	return false
end
-------------------------------------
-- Set the metatable to the module
-------------------------------------
local function pers_iterator(order, i)
	--print(order,key)
	i = i + 1
    if i <= #order then
		--print(i,order[i])
        return i, personen[order[i]]
    end
end

setmetatable(Pers, {
    __call = function(_,handle)
        return Pers:new(handle)
    end,

	__index = function(_,handle)
		return Pers(handle)
	end,

	__newindex = function(_,handle,p)
		personen[handle]=p
	end,

	__pairs = function(_)
        return pers_iterator, order, 0  -- Return the custom iterator function, table, and initial index
	end
})



if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    --pass
    print(Pers.fulname('I0692'))
    print(Pers.fulname('I999009'))
 --   local p = Pers('I0692')
--    local p = Pers({'I2604','I0692'})
--    local p = Pers('I2604')
--    print("final result",util.dump(p))
    --print(Pers['I0692'].surname)
--[[	Pers:all()
	i=0
	for k,p in pairs(order) do
		i=i+1
		print(i,k,p)--.given_name,p.surname)
		if i>10 then break end
	end
	i=0
	for k,p in pairs(Pers) do
		i=i+1
		print(i,k,p.handle,p.given_name,p.surname)
		if i>10 then break end
	end
    --    Pers:events(p1)
--    p1 =pers:new(query.get_handle_from_id('I0692'))
--	pers.LifeEvents(p1)
--	pers.Residence(p1)
	--print(Pers.fulbirth('I0692'))
	--print(Pers.fulLifeEvents('I0692'))
	--print(Pers.fulLifeEvents('I0689'))
	f=Pers.parents('I0689')
	print(util.dump(f))
]]--
	print(check_person('I0565'))

else
    return(Pers)
end

--[[
        return {
            "type": "object",
            "title": _("Person"),
            "properties": {
                "_class": {"enum": [cls.__name__]},
                1 "handle": {"type": "string",
                           "maxLength": 50,
                           "title": _("Handle")},
                2 "gramps_id": {"type": "string",
                              "title": _("Gramps ID")},
                3 "gender": {"type": "integer",
                           "minimum": 0,
                           "maximum": 2,
                           "title": _("Gender")},
                4 "primary_name": Name.get_schema(),
                5"alternate_names": {"type": "array",
                                    "items": Name.get_schema(),
                                    "title": _("Alternate names")},
                6 "death_ref_index": {"type": "integer",
                                    "title": _("Death reference index")},
                7 "birth_ref_index": {"type": "integer",
                                    "title": _("Birth reference index")},
                8 "event_ref_list": {"type": "array",
                                   "items": EventRef.get_schema(),
                                   "title": _("Event references")},
                9 "family_list": {"type": "array",
                                "items": {"type": "string",
                                          "maxLength": 50},
                                "title": _("Families")},
                10 "parent_family_list": {"type": "array",
                                       "items": {"type": "string",
                                                 "maxLength": 50},
                                       "title": _("Parent families")},
                11 "media_list": {"type": "array",
                               "items": MediaRef.get_schema(),
                               "title": _("Media")},
                12 "address_list": {"type": "array",
                                 "items": Address.get_schema(),
                                 "title": _("Addresses")},
                13 "attribute_list": {"type": "array",
                                   "items": Attribute.get_schema(),
                                   "title": _("Attributes")},
                14 "urls": {"type": "array",
                         "items": Url.get_schema(),
                         "title": _("Urls")},
                15 "lds_ord_list": {"type": "array",
                                 "items": LdsOrd.get_schema(),
                                 "title": _("LDS ordinances")},
                16 "citation_list": {"type": "array",
                                  "items": {"type": "string",
                                            "maxLength": 50},
                                  "title": _("Citations")},
                17 "note_list": {"type": "array",
                              "items": {"type": "string",
                                        "maxLength": 50},
                              "title": _("Notes")},
                18 "change": {"type": "integer",
                           "title": _("Last changed")},
                19 "tag_list": {"type": "array",
                             "items": {"type": "string",
                                       "maxLength": 50},
                             "title": _("Tags")},
                20 "private": {"type": "boolean",
                            "title": _("Private")},
                21 "person_ref_list": {"type": "array",
                                    "items": PersonRef.get_schema(),
                                    "title": _("Person references")}
]]--
