if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps") end
if gramps and not gramps.Place.all then

    local _ = require("mh.gettext")

    function gramps.Place:sort_on() return {self:fullplace_rev()} end

    function gramps.Place.all()
        local s=""
        gramps.Place()
        for i, h in pairs(gramps.Place.Order) do
            local p = gramps.Place(h[1])
            if tex then
                line=string.format("%-40s & %-10s & %-15s & %-15s \\\\",
                    _.T(p:fullplace()),
                    _.T(p.place_type.string),
                    p.long,p.lat)
            else
                line=string.format("%-40s %-10s %-15s %-15s",p:fullplace(),p.place_type.string,p.long,p.lat)
            end
            s=s.."\n"..line
        end
        return s
    end

    function gramps.Place:fullplace()
        local s = self.name.value
        for i,pr in pairs(self.placeref_list) do
            --print(pr.ref)
            local p = gramps.Place(pr.ref)
            s=s..", "..p:fullplace()
        end
        return s
    end

    function gramps.Place:fullplace_rev()
        local s = self.name.value
        for i,pr in pairs(self.placeref_list) do
           --print(pr.ref)
            local p = gramps.Place(pr.ref)
            s=p:fullplace().." "..s
        end
        return s
    end

end
if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
--	query.init("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
    --tex={}
    print(gramps.Place.all())
else
    return gramps.Place

end


