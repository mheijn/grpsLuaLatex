query=require("gramps.queries")
util=require("gramps.util")

local Note = {_TYPE='module', _NAME='gramps.note' ,_VERSION='0.15.10.2024'}

local notes = {}
local order = {}
local id_handle = {}

local function _(str) return str end
local Type={
    UNKNOWN = -1,
    CUSTOM = 0,
    GENERAL = 1,
    RESEARCH = 2,
    TRANSCRIPT = 3,
    --per object with notes a Type to distinguish the notes
    PERSON = 4,
    ATTRIBUTE = 5,
    ADDRESS = 6,
    ASSOCIATION = 7,
    LDS = 8,
    FAMILY = 9,
    EVENT = 10,
    EVENTREF = 11,
    SOURCE = 12,
    SOURCEREF = 13,
    PLACE = 14,
    REPO = 15,
    REPOREF = 16,
    MEDIA = 17,
    MEDIAREF = 18,
    CHILDREF = 19,
    PERSONNAME = 20,
    -- other common types
    SOURCE_TEXT = 21,    -- this is used for verbatim source text in SourceRef
    CITATION = 22,
    REPORT_TEXT = 23,    -- this is used for notes used for reports
    -- indicate a note is html code
    HTML_CODE = 24,
    TODO = 25,
    -- indicate a note used as link in another note
    LINK = 26,
    }
Type._CUSTOM = Type.CUSTOM
Type._DEFAULT = Type.GENERAL
    
local test={[1]=" "}

local Types = {
    [Type.UNKNOWN] = {_("Unknown"), "Unknown"},
    [Type.CUSTOM] = {_("Custom"), "Custom"},
    [Type.GENERAL] = {_("General"), "General"},
    [Type.RESEARCH] = {_("Research"), "Research"},
    [Type.TRANSCRIPT] = {_("Transcript"), "Transcript"},
    [Type.SOURCE_TEXT] = {_("Source text"), "Source text"},
    [Type.CITATION] = {_('Citation'), "Citation"},
    [Type.REPORT_TEXT] = {_("Report"), "Report"},
    [Type.HTML_CODE] = {_("Html code"), "Html code"},
    [Type.TODO] = {_("notetype|To Do"), "To Do"},
    [Type.LINK] = {_("notetype|Link"), "Link"},
    --_DATAMAPIGNORE
    [Type.PERSON] = {_("Person Note"), "Person Note"},
    [Type.PERSONNAME] = {_("Name Note"), "Name Note"},
    [Type.ATTRIBUTE] = {_("Attribute Note"), "Attribute Note"},
    [Type.ADDRESS] = {_("Address Note"), "Address Note"},
    [Type.ASSOCIATION] = {_("Association Note"), "Association Note"},
    [Type.LDS] = {_("LDS Note"), "LDS Note"},
    [Type.FAMILY] = {_("Family Note"), "Family Note"},
    [Type.EVENT] = {_("Event Note"), "Event Note"},
    [Type.EVENTREF] = {_("Event Reference Note"), "Event Reference Note"},
    [Type.SOURCE] = {_("Source Note"), "Source Note"},
    [Type.SOURCEREF] = {_("Source Reference Note"), "Source Reference Note"},
    [Type.PLACE] = {_("Place Note"), "Place Note"},
    [Type.REPO] = {_("Repository Note"), "Repository Note"},
    [Type.REPOREF] = {_("Repository Reference Note"), "Repository Reference Note"},
    [Type.MEDIA] = {_("Media Note"), "Media Note"},
    [Type.MEDIAREF] = {_("Media Reference Note"), "Media Reference Note"},
    [Type.CHILDREF] = {_("Child Reference Note"), "Child Reference Note"}
    }

local function get(h,s)
    local index = {handle=1, gramps_id=2,text=3,format=4,type=5}
    local i = index[s]
    if i==5 then 
        local t = notes[h].blob_data[5][1]
        --return t
        return Types[t][1], t 
    end
    if i==3 then return notes[h].blob_data[3][1] end
    return notes[h].blob_data[i]
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

function Note:new(req)
    local handle = check_handle(req)
    if notes[handle] then
        return notes[handle]
    else
        r = query.get_note_from_handle(handle,true)
        if r[1] then
            notes[handle]=r[1]
            id_handle[r[1].gramps_id]=handle
            r[1].get = function(s) return get(handle,s) end
            return r[1]
        else
            return(nil)
        end
    end
end

function Note.of_object(handle)
    res={}
    for i,r in pairs(query.get_note_from_object(handle)) do
        if not notes[r.handle] then 
            notes[r.handle]=r
            id_handle[r.gramps_id]=r.handle
            r.get = function(str) return get(r.handle,str) end           
        end
        table.insert(res,r.handle)
    end
    return res
end


function Note.all()
    local r = query.get_note_from_handle(nil,true)
    for i,n in ipairs(r) do
        order[i]={n.handle,n.gramps_id}
        n.get = function(str) return get(n.handle,str) end           
        notes[n.handle] = n
    end
    table.sort(order, function(a, b) return a[2] < b[2] end )
end

-------------------------------------
-- Set the metatable to the module
-------------------------------------
local function note_pairs(t)
    local function iterator(tbl, key)
        key = key + 1
        if key <= #order then
            --print(key)
            return key, notes[order[key][1]]
        end
    end
    return iterator, t,1
end

setmetatable(Note, {
    __call = function(_,handle)
        return Note:new(handle)
    end,

    __index = function(_,handle)
        return Note:new(handle)
    end,

    __newindex = function(_,handle,p)
        notes[handle]=p
    end,

    __pairs = note_pairs

})

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

    
    Note.all()
    
    local s=""
    for i,h in pairs(Note) do
        print(h.get("gramps_id"), h.get("format"),h.get("type"))
        print(h.get("text")) 
    end

    local id = "N1148"
    local n = Note[id]
    print(util.dump(n))
    print(n.get("gramps_id"), n.get("format"),n.get("type"))
else
    return Note
end
--[[
                1"handle": {"type": "string",
                           "maxLength": 50,
                           "title": _("Handle")},
                2"gramps_id": {"type": "string",
                              "title": _("Gramps ID")},
                3"text": StyledText.get_schema(),
                4"format": {"type": "integer",
                           "title": _("Format")},
                5"type": NoteType.get_schema(),
                6"change": {"type": "integer",
                           "title": _("Last changed")},
                7"tag_list": {"type": "array",
                             "items": {"type": "string",
                                       "maxLength": 50},
                             "title": _("Tags")},
                8"private": {"type": "boolean",
                            "title": _("Private")}
]]--
