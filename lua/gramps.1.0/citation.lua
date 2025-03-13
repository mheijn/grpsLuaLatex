local query=require("gramps.queries")
local util=require("gramps.util")
local src = require("gramps.source")
local repo = require("gramps.repository")

local Citation = {_TYPE='module', _NAME='gramps.citation' ,_VERSION='0.15.10.2024'}

local citation = {}
local order = {}
local id_handle = {}

local function get(h,s)
    local index = {handle=1, gramps_id=2,page=3}
    local i= index[s]
    return citation[h].blob_data[index[s]]
end

local function check_handle(req)
    if type(req)=="string" then
        if #req >6 then
            handle=req
        else
            handle  = id_handle[req] or query.get_handle_from_id(req)
        end
    end
    return handle
end

function Citation:new(req)
    local handle = check_handle(req)
    if citation[handle] then
        return citation[handle]
    else
        local r = query.get_citation_from_handle(handle,true)
        if r[1] then
            local cit =r[1]
            citation[handle]=cit
            id_handle[cit.gramps_id]=handle
            cit.source = src.of_citation(handle)
            cit.get = function(s) return get(handle,s) end
            return cit
        else
            return(nil)
        end
    end
end

function Citation.of_object(obj_handle)
    local res={}
    
    for i,s in pairs(query.get_citation_from_object(obj_handle)) do
        if not citation[s.handle] then 
            s.source = src.of_citation(s.handle)
            citation[s.handle]=s
            s.get = function(str) return get(s.handle, str) end
            id_handle[s.gramps_id]=s.handle
        end
        table.insert(res,s.handle)
    end
    return res
end


function Citation.all()
    local r = query.get_citation_from_handle(nil,true)
    for i,m in ipairs(r) do
        m.source = src.of_citation(m.handle)
        order[i]={m.handle,m.gramps_id}
        m.get = function(str) return get(m.handle, str) end
        citation[m.handle] = m
    end
    table.sort(order, function(a, b) return a[2] < b[2] end )
end

--[[
            "type": "object",
            "title": _("Citation"),
            "properties": {
                "_class": {"enum": [cls.__name__]},
                1"handle": {"type": "string",
                           "maxLength": 50,
                           "title": _("Handle")},
                2"gramps_id": {"type": "string",
                              "title": _("Gramps ID")},
                ?"date": {"oneOf": [{"type": "null"}, Date.get_schema()],
                         "title": _("Date")},
                3"page": {"type": "string",
                         "title": _("Page")},
                4"confidence": {"type": "integer",
                               "minimum": 0,
                               "maximum": 4,
                               "title": _("Confidence")},
                5"source_handle": {"type": "string",
                                  "maxLength": 50,
                                  "title": _("Source")},
                6"note_list": {"type": "array",
                              "items": {"type": "string",
                                        "maxLength": 50},
                              "title": _("Notes")},
                7"media_list": {"type": "array",
                               "items": MediaRef.get_schema(),
                               "title": _("Media")},
                8"attribute_list": {"type": "array",
                                   "items": SrcAttribute.get_schema(),
                                   "title": _("Source Attributes")},
                9"change": {"type": "integer",
                           "title": _("Last changed")},
                10"tag_list": {"type": "array",
                             "items": {"type": "string",
                                       "maxLength": 50},
                             "title": _("Tags")},
                11"private": {"type": "boolean",
                            "title": _("Private")}

]]--

-------------------------------------
-- Set the metatable to the module
-------------------------------------
local function citation_pairs(t)
    local function iterator(tbl, key)
        key = key + 1
        if key <= #order then
            --print(key)
            return key, citation[order[key][1]]
        end
    end
    return iterator, t,1
end


setmetatable(Citation, {
    __call = function(_,handle)
        return Citation:new(handle)
    end,

__index = function(_,handle)
return Citation:new(handle)
end,

__newindex = function(_,handle,p)
citation[handle]=p
end,

__pairs = citation_pairs
})

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

    local id = "C0435"
    local m = Citation[id]
    print(util.dump(m))
    
    print ( m.get("gramps_id"),m.get("page"))
    if(m.source[1]) then print(src(m.source[1]).get("title"),src(m.source[1]).get(author))
        if(src(m.source[1]).repository[1]) then 
            print(repo(src(m.source[1]).repository[1]).get("type"),
                  repo(src(m.source[1]).repository[1]).get("name"))
        end
    end
    
    --print(m.handle)
else 
    return Citation
end
