if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps") end
if gramps and not gramps.Media.all then

    local _ = require("mh.gettext")

    local print = require("mh.print")
    local util =require("gramps.util")
    DEBUG=4
    
    --local mediapath = gramps.Metadata.media_path

    function gramps.Media:sort_on() return {self.gramps_id} end

    function gramps.Media:getPath()
        local mediapath = gramps.Metadata['media-path']
        return mediapath.."/"..self.path
    end
    
    function gramps.Media.all()
        s=""
        gramps.Media()
        for i, h in pairs(gramps.Media.Order) do
            local m = gramps.Media(h[1])
            local line = string.format("%-10s%-20s%s",m.gramps_id,m.path,m.desc)
            print(line)
            s=s.."\n"..line
        end
        return s
    end
    
    local function imageplace(m,ph)
        local obj={}
        local p=gramps.Person(ph)
        for i,im in ipairs(p.media_list) do
            if im.ref==m.handle then
                local rec =im.rect
                if rec==nil then rec={0,0,100,100} end
                obj = {handle=ph,x1=rec[1],y1=rec[2],x2=rec[3],y2=rec[4],
                            xm=0.5*(rec[1]+rec[3]),ym=0.5*(rec[2]+rec[4]),
                            order=0}
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
    
    function gramps.Media:persons()
        if self.data.person_list == nil then
            local pers = {}
            local pers_handles = query.get_person_from_media(self.handle)
            for i,ph in ipairs(pers_handles) do
                --print(ph)
                local obj=imageplace(self,ph)
                table.insert(pers,obj)
            end
            
            self.data.person_list = sort_person_handles(pers)
        end
        return self.data.person_list
    end

end
----------------------------------------

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
--	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
    local id = "O0710"
    local m = gramps.Media(id)
    print(m)
    for k,v in pairs(m)do print(k,v) end
    --m:getPath()
    print((m:persons()[1]))
    --local ps = Media.persons( m.handle )
    --print(util.dump(m))
    --gramps.Media.all()
else
    return(gramps.Media)
end


