if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps6") end
if gramps6 and not gramps6.Placel then
    gramps6.Place      = gramps6.DataSet('Place',gramps6.Queries)
    gramps6.Place.__file = debug.getinfo(1, "S").source:sub(2)


    local _ = require("mh.gettext")

    function gramps6.Place:sort_on() return {self:fullplace_rev()} end

    function gramps6.Place.all()
        local s=""
        gramps6.Place()
        for i, h in pairs(gramps6.Place.Order) do
            local p = gramps6.Place(h[1])
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

    function gramps6.Place:fullplace()
        local s = self.name.value
        for i,pr in pairs(self.placeref_list) do
            --print(pr.ref)
            local p = gramps6.Place(pr.ref)
            s=s..", "..p:fullplace()
        end
        return s
    end

    function gramps6.Place:fullplace_rev()
        local s = self.name.value
        for i,pr in pairs(self.placeref_list) do
           --print(pr.ref)
            local p = gramps6.Place(pr.ref)
            s=p:fullplace().." "..s
        end
        return s
    end

end
if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
--	query.init("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
    --tex={}
    print(gramps6.Place.all())
else
    return gramps6.Place

end


