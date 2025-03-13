if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps") end
if gramps and not gramps.Metadata then
    query=require("gramps.queries")

    Metadata = {data={}}
    
    function Metadata.new(req)
        if Metadata.data[req] then
            return Metadata.data[req]
        else
            r = query.get_metadata()
            for i,md in ipairs(r) do  Metadata.data[md.setting] = md.blob_data end
            if Metadata.data[req] then
                return Metadata.data[req]
            else
                return nil
            end
        end
    end
        
    setmetatable(Metadata, {
        __call = function(_,handle)
            return Metadata:new(name)
        end,

        __index = function(_,name)
        return Metadata.new(name)
        end,
    })
    gramps.Metadata = Metadata
--[[   

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
    ]]--
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
--	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")

    query=require("gramps.queries")
    util=require("gramps.util")
    
    r = query.get_metadata()
    if r[1] then
        print(util.dump(r))
        --metadata[r[1].setting] = r[1].blob_data
        --return r[1].blob_data
    end
    print(gramps.Metadata.nmap_index)

else

end
