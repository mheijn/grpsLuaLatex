local u=require('gramps6.util')

local multicolumnset = false
function u.multicolumn(c)
	if c  and not multicolumnset then multicolumnset = true;print("\\begin{multicols}{"..c.."}")
	elseif not c and multicolumnset then multicolumnset = false;print("\\end{multicols}")
	end
end
local itemizeset = false
function u.itemize(b)
    if b  and not itemizeset then itemizeset = true;print("\\begin{itemize}")
	elseif not b and itemizeset then itemizeset = false;print("\\end{itemize}")
	end
end



local function _stamhouder(h)
	local p = gramps6.Person(h)
	if p:hasFather() then return _stamhouder(p:getFather()) end 
	return h
end

local function check_father(ph,fn)
	local p = gramps6.Person(ph)
	if not p:hasFather() then
			--print("Has No father ",p:fullname())
			return ph
	else
			pf = gramps6.Person(p:getFather())
			if pf:surname() ~= fn then 
				--print("dif familie ",fn,pf:surname())
				--print(pf:surname(),pf.gramps_id) 
				return _stamhouder(pf.handle)
			end
	end
end

local function _nakom(h,withchild,depth)
	if withchild == nil then withchild={} end
	if depth == nil then depth=0 end
	
	local p = gramps6.Person(h)
	local gen=0
	for fi,fh in ipairs(p.family_list) do
		f = gramps6.Family(fh)
		for i,cr in ipairs(f.child_ref_list) do
			local g, withchild  = _nakom(cr.ref,withchild,depth+1)
			if gen<g then gen=g end
		end
	end 
	if gen>0 then 
		if withchild[depth] == nil then withchild[depth]={} end
		table.insert(withchild[depth],h) 
	end
	return gen +1, withchild
end
				



function u.stamhouders(familyname)
		local familyname = familyname or "Heijn"
        local shs={}
        
        local persons = gramps6.query.get_persons_from_familyname(familyname)
        for i, ph in ipairs(persons) do
			local h = check_father(ph.handle,familyname)
			if  nil ~= h then
				--print(h);print((gramps.Person(h)):fullname())
				local present= false
				for i,th in ipairs(shs) do
					if th.handle == h then present=true; break end 
				end
				if not present then 
					gen, withchild = _nakom(h)
					table.insert(shs,{handle = h, generations = gen,important = withchild}) 
				end
			end
		end
		table.sort(shs, function(a, b)  return a.generations > b.generations end)
		return shs
end

-- ###################### Voorouders #########################
function u.in_array(tbl, val)
	for i = 1, #tbl do
		if tbl[i] == val then return true end
	end
	return false
end

function _ancestors(ph,index,ag,g, ret)
	if not ret[ag] then ret[ag]={} end
	
	local p=gramps6.Person(ph)	
	ret[ag][index] = ph
	--print(ag, index, p:fullname())
	
	if ag<g then
		for i,fh in pairs(p.parent_family_list) do
			local f=gramps6.Family(fh)
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

function u.ancestors(id,gen)
	local p = gramps6.Person(id)
	--print(p)
	local ret = _ancestors(p.handle,1,1,gen,{})
	return ret
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	loc = require("mh.local")
	loc.setlanguage('nl')
	require("gramps6")
	local print = require("mh.print")
	gramps6.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

	local an = u.ancestors('I14180',40)
	for i,g in pairs(an) do
		for k,h in pairs(g) do
			print(h)
		end
	end

	local shs = u.stamhouders("Heijn")
	--local shs = u.stamhouders("Schouten")
	for i, sh in ipairs(shs) do 
		if sh.generations >0 then
			local p =gramps6.Person(sh.handle)
			print(sh.generations,p.gramps_id,p:fullname()) 
			if p:hasFather() then print("Has father") end
		end
		--for j = 0,sh.generations-2 do
		--	for k,h in ipairs(sh.important[j]) do 
		--		print(j,(gramps6.Person(h)):fullname())
		--	end
		--end
	end
else
	return u
end
