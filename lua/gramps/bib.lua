if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps") end
if gramps and not gramps.Source.all then

    local _ = require("mh.gettext")

    local print = require("mh.print")
    local util =require("gramps.util")
    DEBUG=4
    
    function gramps.Source:sort_on() return {self.gramps_id} end
    function gramps.Repository:sort_on() return {self.gramps_id} end

    function gramps.Source.all()
        local s=""
        gramps.Source()
        for i, h in pairs(gramps.Source.Order) do
            local r = gramps.Source(h[1])
            local line
            if tex then 
                line="@source{"..r.gramps_id..",\n"
                line=line.."title={".._.T(r.title).."},\n"
                line=line.."author={".._.T(r.author).."},\n"
                if r.reporef_list[1] then 
                    local repo = gramps.Repository(r.reporef_list[1].ref)
                    line=line.."crossref={"..repo.gramps_id.."},\n"
                end
                line=line.."}\n"
                --print(line)
            else
                line=string.format("%-40s %s",r.author,r.title)
            end
            s=s.."\n"..line
        end
        return s
    end

    local function bib_url(urls)
        for i,u in pairs(urls) do
            if u.type.number ==1 then
                return "email={"..u.path.."},\n"
            elseif u.type.number ==2 or u.type.number ==3 then
                return "web={"..u.path.."},\n"
            elseif u.type.number == 4  then
                return "ftp={"..u.path.."},\n"
            end
        end
        return ""
    end

    function gramps.Repository.all()
        local s=""
        gramps.Repository()
        for i, h in pairs(gramps.Repository.Order) do
            local r = gramps.Repository(h[1])
            local line
            --print(util.dump(r.data))
            --print(r)
            if tex then
                line = "@repository{"..r.gramps_id..",\n"
                line=line.."title={".._.T(r.name).."},\n"
                line=line.."type={".._.T(r.type.string).."},\n"
                line=line..bib_url(r.urls)
                if 0<#r.address_list then line=line.."address={".._.T(r.address_list[1].location:string()).."}\n" end
                line = line.."}\n"
            else
                local ex =bib_url(r.urls)

                if 0<#r.address_list then
                    print(r.address_list[1])
                    ex = ex .. r.address_list[1].location:string() end
                line=string.format("%-40s %-10s %s",r.name,r.type.string,ex)
            end
            s=s.."\n"..line
        end
        return s
    end

    function gramps.Location:string()
        local loc =require("mh.local")
        lan = loc.language()

        if lan == 'nl' then --NL
            local s = self.street
            if 0<#self.postal then s=s..", "..self.postal end
            if 0<#self.locality then s=s.." "..self.locality end
            if 0<#self.city then s=s.." "..self.city end
            if 0<#self.county then s=s..", "..self.county end
            if 0<#self.state then s=s..", "..self.state end
            if 0<#self.country then s=s..", "..self.country end
            if 0<#self.phone then s=s.." ("..self.phone..")" end
            return s
        else
            local s = self.street
            if 0<#self.locality then s=s..", "..self.locality end
            if 0<#self.city then s=s..", "..self.city end
            if 0<#self.county then s=s.." "..self.county end
            if 0<#self.state then s=s..", "..self.state end
            if 0<#self.country then s=s..", "..self.country end
            if 0<#self.postal then s=s.." "..self.postal end
            if 0<#self.phone then s=s.." ("..self.phone..")" end
            return s
        end
    end


end
----------------------------------------

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
--	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
    tex={}
    print(gramps.Source.all())
    print(gramps.Repository.all())
else
    return(Source)
end
