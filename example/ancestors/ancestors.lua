local Anc={}

function _ancestors(ph,index,ag,g, ret)
	if not ret[ag] then ret[ag]={} end
	
	local p=gramps.Person(ph)	
	ret[ag][index] = ph
	--print(ag, index, p:fullname())
	
	if ag<g then
		for i,fh in pairs(p.parent_family_list) do
			local f=gramps.Family(fh)
			if f.father_handle  then 
				ret = _ancestors(f.father_handle,index*2,ag+1,g,ret)
			end
			if f.mother_handle  then 
				ret = _ancestors(f.mother_handle,index*2+1,ag+1,g,ret)
			end
		end
	end
	return ret
end

function Anc.ancestors(id,gen)
	local p = gramps.Person(id)
	--print(p)
	local ret = _ancestors(p.handle,1,1,gen,{})
	return ret
end


if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	loc = require("mh.local")
	loc.setlanguage('nl')

	require("gramps")

	util = require("gramps.util")

	tex={print=print}
	print = require("mh.print")
	require("person_short")
	_=require("mh.gettext")
	
	local anc = Anc

	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
	--gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
	loc.setlanguage('nl')
    print(loc.language())
	local voorouders =anc.ancestors('I2604',2)
	for i,g in pairs(voorouders) do
		--print(string.format("\\section*{%s}",_("Central Person","Generation %d",i)))
		--print("\\begin{itemize}")
		for k,h in pairs(g) do
			--print(string.format("\\item[%d]",k))
			printperson(h,voorouders)
		end
		--print("\\end{itemize}")
	end
else
	return Anc
end
