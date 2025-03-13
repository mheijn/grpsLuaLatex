query=require("gramps.queries")
util=require("gramps.util")
repo=require("gramps.repository")
note=require("gramps.note")

local Source = {_TYPE='module', _NAME='gramps.media' ,_VERSION='0.15.10.2024'}

local source = {}
local order = {}
local id_handle = {}

local function get(h,s)
    local index = {handle=1, gramps_id=2,title=3,author=4}
    local i = index[s]
    return source[h].blob_data[index[s]]
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

function Source:new(req)
    local handle = check_handle(req)
    if source[handle] then
        return source[handle]
    else
        r = query.get_source_from_handle(handle,true)
        if r[1] then
            r[1].repository = repo.of_source(handle)
            r[1].note = note.of_object(handle)
            source[handle]=r[1]
            id_handle[r[1].gramps_id]=handle
            r[1].get = function(s) return get(handle,s) end
            return r[1]
        else
            return(nil)
        end
    end
end

function Source.of_citation(cit_handle)
    local res={}
    
    for i,s in pairs(query.get_source_from_citation(cit_handle)) do
        if not source[s.handle] then 
            s.repository = repo.of_source(s.handle)
            s.note = note.of_object(s.handle)
            source[s.handle]=s
            s.get = function(str) return get(s.handle,str) end
            id_handle[s.gramps_id]=s.handle
        end
        table.insert(res,s.handle)
    end
    return res
end

function Source.all()
    local r = query.get_source_from_handle(nil,true)
    for i,so in ipairs(r) do
        so.repository = repo.of_source(so.handle)
        so.note = note.of_object(so.handle)
        so.get = function(str) return get(so.handle,str) end
        order[i]={so.handle,so.gramps_id}
        source[so.handle] = so
    end
    table.sort(order, function(a, b) return a[2] < b[2] end )
end

function Source.bibliography(file)
    -- Open a file in write mode ("w" = overwrite, "a" = append)
    local file = io.open(file, "w")

-- Check if the file was opened successfully
    if not file then 
        print("Error opening file!")
        return 
    end
    

    Source.all()
    for i,so in pairs(Source) do
            local s=""
            s=s.."@misc{"..so.gramps_id..",\n"
            s=s.."title={"..so.get("title").."},\n"
            s=s.."author={"..so.get("author").."},\n"
            
            if(so.note[1]) then 
                local n = note[so.note[1]]
                s=s.."titleaddon={"..n.get("text").."},\n"
            end
            if(so.repository[1]) then
                local rep=repo[so.repository[1]]
                s=s.."titleaddon={"..rep.get("name").."},\n"
                s=s.."howpublished={"..rep.get("type").."},\n"
            end
            s=s.."}\n"
            file:write(s)
    end
    file:close()  -- Close the file

end

--[[
            "type": "object",
            "title": _("Source"),
            "properties": {
                "_class": {"enum": [cls.__name__]},
               1 "handle": {"type": "string",
                           "maxLength": 50,
                           "title": _("Handle")},
               2 "gramps_id": {"type": "string",
                              "title": _("Gramps ID")},
               3 "title": {"type": "string",
                          "title": _("Title")},
               4 "author": {"type": "string",
                           "title": _("Author")},
               5 "pubinfo": {"type": "string",
                            "title": _("Publication info")},
               6 "note_list": {"type": "array",
                              "items": {"type": "string",
                                        "maxLength": 50},
                              "title": _("Notes")},
               7 "media_list": {"type": "array",
                               "items": MediaRef.get_schema(),
                               "title": _("Media")},
               8 "abbrev": {"type": "string",
                           "title": _("Abbreviation")},
               9 "change": {"type": "integer",
                           "title": _("Last changed")},
              10 "attribute_list": {"type": "array",
                                   "items": SrcAttribute.get_schema(),
                                   "title": _("Source Attributes")},
              11 "reporef_list": {"type": "array",
                                 "items": RepoRef.get_schema(),
                                 "title": _("Repositories")},
			  12	"tag_list": {"type": "array",
                             "items": {"type": "string",
                                       "maxLength": 50},
                             "title": _("Tags")},
              13 "private": {"type": "boolean",
                            "title": _("Private")}
            }
        }

]]--

-------------------------------------
-- Set the metatable to the module
---------------------            r[1].get = function(s) return get(handle,s) end
----------------
local function source_iterator(order, i)
i = i + 1
    if i <= #order then
        return i, source[order[i][1]]
    end
end

setmetatable(Source, {
    __call = function(_,handle)
        return Source:new(handle)
    end,

__index = function(_,handle)
return Source:new(handle)
end,

__newindex = function(_,handle,p)
source[handle]=p
end,

__pairs = function(_)
        return source_iterator, order, 0  -- Return the custom iterator function, table, and initial index
end
})

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

    local id = "S0301"
    local m = Source[id]
    print(util.dump(m))
    Source.bibliography("grps.bib")
    --print(m.handle)
else
    return Source
end
