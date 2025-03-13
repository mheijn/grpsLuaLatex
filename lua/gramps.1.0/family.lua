local query=require("gramps.queries")
local util=require("gramps.util")
local event=require("gramps.events")
local date=require("gramps.date")

local Family = {_TYPE='module', _NAME='gramps.family' ,_VERSION='0.9.10.2024'}

local family_meta = {}

local families = {}
local order = {}
local id_handle = {}

local function check_handle(req)
if type(req)=="string" then
if #req >6 then
handle=req
else
handle  = id_handle[req] or query.get_family_handle_from_id(req)
end
end
return handle
end

function Family:new(req)
    --print("Family:new",handle)
    --print("Family:new",print(util.dump(families)))
    local handle = check_handle(req)

    if families[handle] then
return families[handle]
else
r = query.get_family_from_handle(handle)
if r[1] then
families[handle]=r[1]
id_handle[r[1].gramps_id]=handle
return r[1]
else
return(nil)
end
end
end

local function check(handle)
f=Family(handle)
--print("check_handle",p.handle)
return f.handle
end

function Family.all()
local rf, rl = query.get_family_from_handle(nil,false)
for i,rf in ipairs(r) do
order[i]=f.handle
families[p.handle] = f
end
end

function Family.events(handle)
if Family[handle].events == nil then
        Family[handle].events = event.events(handle)
--Family[handle].events = query.get_events_from_handle(handle)
end
return Family[handle].events
end

local event_types = {event.TYPE.ENGAGEMENT, event.TYPE.MARRIAGE, event.TYPE.DIVORCE, event.TYPE.ANNULMENT, event.TYPE.MARR_SETTL, event.TYPE.MARR_LIC,
               event.TYPE.MARR_CONTR, event.TYPE.MARR_BANNS, event.TYPE.DIV_FILING, event.TYPE.MARR_ALT}

function get_family_date(handle)
    local ret=0
    local evs=Family.events(handle)
    --print(util.dump(evs))
    if evs then for i, evh in ipairs(evs) do
        local blob=event[evh].blob_data
        --print(util.dump(blob))
        if blob[4] and blob[4][4] then
            ret = date.days_from_year_0(blob[4][4][3],blob[4][4][2],blob[4][4][1])
            if ret>0 then break end
        end
    end end
    return ret
end

function Family.get_person_family(handle)
    local parents = {}
    local child = {}
    local r = query.get_person_family(handle)

    for i,f in ipairs(r) do
        if families[f.handle]==nil then
            families[f.handle]=f
        end
        if handle==f.father_handle or handle==f.mother_handle then
            Family[f.handle].date = get_family_date(f.handle)
            table.insert(child,f.handle)
        else
            table.insert(parents,f.handle)
            --print("parents of",handle==father_handle)
        end
    end
    table.sort(child, function(a, b) 
            if Family[a].date  and Family[b].date then 
                return Family[a].date <Family[b].date 
            else
                return false;
            end
            end )

    return child, parents
end

function Family.has_children(fhandle)
     if #Family.get_children(fhandle) > 0 then
        return true
    else
        return false
    end
end

function Family.get_children(fhandle)
    local f=Family[fhandle]
    if f.children == nil then
        f.children = {}
        local cs = query.get_persons_from_family(f.handle)
        for i,h in ipairs(cs) do
            if h~=f.father_handle and h~=f.mother_handle then
                table.insert(Family[fhandle].children,h)
            end
         end
    end
    return Family[fhandle].children
end

-------------------------------------
-- Set the metatable to the module
-------------------------------------
local function family_iterator(order, i)
--print(order,key)
i = i + 1
    if i <= #order then
--print(i,order[i])
        return i, families[order[i]]
    end
end

setmetatable(Family, {
    __call = function(_,handle)
        return Family:new(handle)
    end,

__index = function(_,handle)
return Family(handle)
end,

__newindex = function(_,handle,p)
families[handle]=p
end,

__pairs = function(_)
        return family_iterator, order, 0  -- Return the custom iterator function, table, and initial index
end
})

return Family
--[[
       return {
            "type": "object",
            "title": _("Family"),
            "properties": {
                "_class": {"enum": [cls.__name__]},
                "handle": {"type": "string",
                           "maxLength": 50,
                           "title": _("Handle")},
                "gramps_id": {"type": "string",
                              "title": _("Gramps ID")},
                "father_handle": {"type": ["string", "null"],
                                  "maxLength": 50,
                                  "title": _("Father")},
                "mother_handle": {"type": ["string", "null"],
                                  "maxLength": 50,
                                  "title": _("Mother")},
                "child_ref_list": {"type": "array",
                                   "items": ChildRef.get_schema(),
                                   "title": _("Children")},
                "type": FamilyRelType.get_schema(),
                "event_ref_list": {"type": "array",
                                   "items": EventRef.get_schema(),
                                   "title": _("Events")},
                "media_list": {"type": "array",
                               "items": MediaRef.get_schema(),
                               "title": _("Media")},
                "attribute_list": {"type": "array",
                                   "items": Attribute.get_schema(),
                                   "title": _("Attributes")},
                "lds_ord_list": {"type": "array",
                                 "items": LdsOrd.get_schema(),
                                 "title": _("LDS ordinances")},
                "citation_list": {"type": "array",
                                  "items": {"type": "string",
                                            "maxLength": 50},
                                  "title": _("Citations")},
                "note_list": {"type": "array",
                              "items": {"type": "string",
                                        "maxLength": 50},
                              "title": _("Notes")},
                "change": {"type": "integer",
                           "title": _("Last changed")},
                "tag_list": {"type": "array",
                             "items": {"type": "string",
                                       "maxLength": 50},
                             "title": _("Tags")},
                "private": {"type": "boolean",
                            "title": _("Private")}
]]--
