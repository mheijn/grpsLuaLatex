query=require("gramps.queries")
event=require("gramps.events")
person=require("gramps.person")
util=require("gramps.util")
metadata =require("gramps.metadata")
local mediapath = metadata.media_path()

local Media = {_TYPE='module', _NAME='gramps.media' ,_VERSION='0.15.10.2024'}

local media = {}
local order = {}
local id_handle = {}

local function check_handle(req)
	if type(req)=="string" then
		if #req >6 then
			handle=req
		else
			handle  = id_handle[req] or query.get_media_handle_from_id(req)
		end
	end
	return handle
end


function Media:new(req)
    local handle = check_handle(req)
    if media[handle] then
		return media[handle]
	else
		r = query.get_media_from_handle(handle,false)
		if r[1] then
			media[handle]=r[1]
			id_handle[r[1].gramps_id]=handle
			return r[1]
		else
			return(nil)
		end
	end
end

function Media.all()
	local r = query.get_media_from_handle(nil,false)
	for i,m in ipairs(r) do
		order[i]={m.handle,m.path}
		media[m.handle] = m
	end
    table.sort(order, function(a, b) return a[2] < b[2] end )
end

local function imageplace(ih,ph)
    local obj={}
    p=person(ph)

    obj.handle=ph
    --print(ih,util.dump(p.blob_data[11]))
    for i,im in ipairs(p.blob_data[11]) do
        if im[5]==ih then
            local rec =im[6]
            if rec==nil then rec={0,0,100,100} end
            obj = {handle=ph,x1=rec[1],y1=rec[2],x2=rec[3],y2=rec[4],xm=0.5*(rec[1]+rec[3]),ym=0.5*(rec[2]+rec[4]),order=0}
            --print(ih,ph,util.dump(obj))
        end
    end
    return obj
end

function sort_person_handles(objs)
    local tag_height= 0
    for i,obj in ipairs(objs) do
        tag_height = tag_height + obj.y2 - obj.y1
    end
    tag_height = tag_height/#objs

    for i,obj in ipairs(objs) do
        obj.order = 100*math.floor(0.5+obj.ym/tag_height)+obj.xm
    end
    table.sort( objs, function(a, b) return a.order < b.order end )
    return objs
end

function Media.persons(handle)
	if Media[handle].persons == nil then
        local pers = {}
        local phs = query.get_person_from_media(handle)
        for i,ph in ipairs(phs) do
            local obj=imageplace(handle,ph.obj_handle)
            table.insert(pers,obj)
            --print(util.dump(obj))
        end

        Media[handle].persons = pers
        --person(pers)
	end
	return sort_person_handles(Media[handle].persons)
end

function Media.path(handle)
    m=Media(handle)
    local mediapath = metadata.media_path()
    return mediapath.."/"..m.path
end


-----------------------------------------------------

----------------NAME----------------------
function Media.fulname(handle)
	local m=Media(handle)
	local s=m.title
    return s
end

function Media.name(handle)
	local m=Media(handle)
	if m==nil then return "" end
	return m.desc
end

-------------------------------------
-- Set the metatable to the module
-------------------------------------
local function media_iterator(order, i)
	i = i + 1
    if i <= #order then
        return i, media[order[i][1]]
    end
end

setmetatable(Media, {
    __call = function(_,handle)
        return Media:new(handle)
    end,

	__index = function(_,handle)
		return Media:new(handle)
	end,

	__newindex = function(_,handle,p)
		media[handle]=p
	end,

	__pairs = function(_)
        return media_iterator, order, 0  -- Return the custom iterator function, table, and initial index
	end
})



if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    --id = "O0710"
    --local m = Media[id]
    --print(m.handle)
    --local ps = Media.persons( m.handle )
    --print(util.dump(m))
    --print(m.handle,#ps,util.dump(ps))
    Media.all()
    --for i,o in ipairs(order) do
    --    print(i,Media[o[1]].path)
    --end
    for i,m in pairs(Media) do
     print (i,m.path)
     end
else
    return Media
end


--[[
..[11] = {
......[1] = {
.........[1] = false,
.........[2] = {},
.........[3] = {},
.........[4] = {},
.........[5] = df476fbdc167dd2ccbd20453761,
.........[6] = {
............[1] = 79,
............[2] = 33,
............[3] = 85,
............[4] = 45,},},
.
return {
            "type": "object",
            "title": _("Media"),
            "properties": {
                "_class": {"enum": [cls.__name__]},
                "handle": {"type": "string",
                           "maxLength": 50,
                           "title": _("Handle")},
                "gramps_id": {"type": "string",
                              "title": _("Gramps ID")},
                "path": {"type": "string",
                         "title": _("Path")},
                "mime": {"type": "string",
                         "title": _("MIME")},
                "desc": {"type": "string",
                         "title": _("Description")},
                "checksum": {"type": "string",
                             "title": _("Checksum")},
                "attribute_list": {"type": "array",
                                   "items": Attribute.get_schema(),
                                   "title": _("Attributes")},
                "citation_list": {"type": "array",
                                  "items": {"type": "string",
                                            "maxLength": 50},
                                  "title": _("Citations")},
                "note_list": {"type": "array",
                              "items": {"type": "string"},
                              "title": _("Notes")},
                "change": {"type": "integer",
                           "title": _("Last changed")},
                "date": {"oneOf": [{"type": "null"}, Date.get_schema()],
                         "title": _("Date")},
                "tag_list": {"type": "array",
                             "items": {"type": "string",
                                       "maxLength": 50},
                             "title": _("Tags")},
                "private": {"type": "boolean",
                            "title": _("Private")}
            }
        }
]]--
