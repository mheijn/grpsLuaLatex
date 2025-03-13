require("gramps.date")
local event=require("gramps.events")
local query=require("gramps.queries")
local family=require("gramps.family")
local util=require("gramps.util")
local citation=require("gramps.citation")

local _ = require("mh.gettext")
local container = require("gramps.datacontainer")
local C = require("gramps.containers")
local print = require("mh.print")
DEBUG=4

local function _surname(n)
	s=""
	if 0<#n.prefix then s=s..n.prefix.." " end
	if 0<#n.surname then s=s..n.surname end
	return s
end
local function surname(name)
	s=""
	for i,n in pairs(name.surname_list) do
		if i==2 then s=s.." (" end
		if i>3 then s=s..", " end
		if i>2 then s=s..string.format("[%d]",i) end
		s=s.._surname(n)
		if i>1 and i==#name.surname_list then s=s..")" end
	end
	return s
end
function C.Person:fullname()
	s=""
	--print(util.dump(self.data))
	--print(self.primary_name)
	--print("Nummer",self.scheme_index['primary_name'])
	local name = self.primary_name
	local nn=name.nick
	s=surname(name)..util.is_empty(nn,""," (")..nn..util.is_empty(nn,"",")")
	s=name.first_name..util.is_empty(s,""," ")..s
	return s
end
function C.Person:surname() return surname(self.primary_name) end
function C.Person:firstname()	return self.primary_name.first_name end

function get_event(p)
	local s
	for i,ref in pairs(p.event_ref_list) do
		print(ref.ref)
		local e = C.Event(ref.ref)
		s = e:long()
	end
	return s
end

function C.Person:birth() end
function C.Person.death() end
function C.Person:sort_on() return {self:surname(), self:firstname()} end

function C.Person.all()
	local s="";local sb="";local sd=""
	C.Person()
	for i, h in pairs(C.Person.Order) do
		local p = C.Person(h[1])
		
		bi,ba,de,bu = p:Life()
		print("gg")
		if bi then sb = bi:datum()
		elseif ba then sb = ba:datum() end
		if de then sd = de:datum()
		elseif bu then sb = bu.datum() end
		print("ff")
		local line = string.format("%-7s%-15s%-15s %11s %11s",
			p.gramps_id,p:surname(),p:firstname(),sb,sd)
		s=s.."\n"..line
	end
	return s
end

function C.Person:Life()
	local birth,bapt,death,buri
	
	for i,ref in pairs(self.event_ref_list) do
		local ev = C.Event(ref.ref)
		if ev.type.number  == C.Event.Type.BIRTH then
			birth=ev
		elseif ev.type.number  == C.Event.Type.BABTISM then
			bapt=ev
		elseif ev.type.number  == C.Event.Type.DEATH then
			death=ev
		elseif ev.type.number  == C.Event.Type.BURIAL then
			buri=ev
		end
	end
	return  birth,bapt,death,buri
end

function C.Person:events(key)
	evs={}
	for i,ref in pairs(self.event_ref_list) do
		local ev = C.Event(ref.ref)
		local s=ev:long(key)
		if 0<#s then table.insert(evs,s) end
	end
	return evs
end
----------------------------------------

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
--	query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
	query.init("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
	--p1=C.Person('I0565')
	p2=C.Person('I0001')
	print(C.Person.all())
	--print(util.dump(p1.data))
	--for k,v in pairs(C.Person) do print(k,type(v),v) end
	--print(p1.naam)
	--print(p1:fullname())
	--print(p1.birth_ref_index,p1.death_ref_index)
	--print(p1)
	--p1:events()
	--print(p2)

else
    return(Person)
end

