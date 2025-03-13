query=require("gramps.queries")
util=require("gramps.util")

local Meta = {_TYPE='module', _NAME='gramps.metadata' ,_VERSION='0.16.10.2024'}

local metadata = {}

function Meta.new(req)
    if metadata[req] then
        return metadata[req]
    else
        r = query.get_metadata(req)
        if r[1] then
            --print(util.dump(r[1]))
            metadata[r[1].setting] = r[1].blob_data
            return r[1].blob_data
        else
            return(nil)
        end
    end
end

function Meta:all()
    local r = query.get_metadata(nil)
    for i,md in ipairs(r) do
        --print(i,md,md.setting,util.dump(md.blob_data))
        metadata[md.setting] = md.blob_data
    end
end

function Meta.media_path()
    return Meta.new("media-path")
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

Meta.all()
    --print(Meta.media_path())
    print(util.dump(metadata,1))
else
    return Meta
end
