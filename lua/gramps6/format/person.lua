--pic=require("gramps6.format.pictures")
max_depth = 3
imagesPerPerson = 2
labeltype = 1
multicolumn  = true

require('gramps6')
util=require("gramps6.util")
_=require("mh.gettext")

local function IsIfThenElse(t,a,b) if t  then return a else return b end end
local function StrIfThenElse(t,a,b) print("test ",#t) ;if 0 < #t  then return a else return b end end

--First capital and end point
local function make_sentence(s)
    fl, rs = s:match("%s*(.)(.-)[%.,]*%s*$")
    if fl then return string.upper(fl)..rs..". "  else return s end
end

local function un_sentence(s)
    fl, rs = s:match("%s*(.)(.-)%.*%s*$");
    if fl then return string.lower(fl)..rs else return s end
end

--trim left and right
local function make_part(s) local rs = s:match("^%s*(.*)%s*$"); return rs end

--add space at end
local function make_space(s) local r =make_part(s); 
    if 0<#r then return r.." " else return r end end

local function HeShe(p) 
    if p.gramps_id:match("^F.*") then return _("zij ") 
    elseif 0<p.gender then return _("he ") else return _("she ") end 
end 

local function HisHer(p) if 0<p.gender then return _("zijn ") else return _("haar ") end end 

local function leeftijd(p) 
    local s   = ""
    local mod = ""
    local r,y,m,d = p:age()
    if y ~= nil then
        if y==0 then
            if m==0 then 
                s = _("%d dag ","%d dagen ",d)
            else
                s = _("%d maand ","%d maanden ",m)
            end
        else
            s = _("%d jaar ","%d jaren ",y)
        end
    end    
    if not r then 
        mod = _("about ")
    end
    if 0<#s then print(make_sentence(HeShe(p).._("werd ")..mod..s.._("oud") )) end
end

local function index(p)
    if tex then 
        print("\\index{"..p:surname().."@".._.T(p:surname()).."!"..
            p.primary_name.first_name..p.gramps_id.."@".. _.T(p.primary_name.first_name) .."}")
    end
end
local function link(val,key)
    if tex then 
        print("\\hyperlink{"..key.."}{"..val.."}")
    else
        print(val)
    end
end        
local function index_str(p)
    if tex then 
        return("\\index{"..p:surname().."@".._.T(p:surname()).."!"..
            p.primary_name.first_name..p.gramps_id.."@".. _.T(p.primary_name.first_name) .."}")
    else   
        return("")
    end
end
local function link_str(val,key)
    if tex then 
        return("\\hyperlink{"..key.."}{"..val.."}")
    else
        return(val)
    end
end        

local function itemlabel(gen,num)
    if labeltype==1 then 
        return num 
    elseif labeltype==2 then 
        return util.Roman(k).."\\textsubscript{"..util.alphanumber(j).."}" 
    else return gen.."-"..num
    end
end

local importants = {}
local events,event,citations--,printperson

local function in_importants(handle)
    for i,g in pairs(importants) do
        for j,h in pairs(g) do
            --print(i,j,#importants,#g,h,handle)
            if h == handle then return j,i end
        end 
    end 
end

local function citations(comp)
    local s=""
    for i,cr in ipairs(comp.citation_list) do
        local cit = gramps6.Citation(cr)
        --local sh = cit.source_handle
        --print(sh)
        local ref = gramps6.Source(cit.source_handle).gramps_id
        --local page =""
        s=s.."\\cite"
        if 0<#cit.page then s=s.."["..cit.page.."]" end
        --if 0<#page then s=s.."["..page.."]" end
        s=s.."{"..ref.."}"
    end 
    return s
end

local function children(f,depth)
    local amount = #f.child_ref_list
    if 0<amount and depth <= max_depth then
    
        local parents=""
        if f.father_handle then  parents = parents..gramps6.Person(f.father_handle):firstname() end
        if f.mother_handle then  
            if 0<#parents then parents =parents .._(" and ") end 
            parents = parents..gramps6.Person(f.mother_handle):firstname() end
        print(_("Kind van ","Kinderen van ",amount)..parents.._("is:","  zijn:",amount))

        --print(#f.child_ref_list)
        
        print("\\begin{itemize}")
        for i,cr in ipairs(f.child_ref_list) do
            child = gramps6.Person(cr.ref)
            
            if depth==1 then print("\\item["..util.alphanumber(i).."] ")
            elseif depth==2 then print("\\item["..util.roman(i).."] ")
            else print("\\item["..i.."] ")
            end
            
            n,g = in_importants(cr.ref)
            if n then
                link(child:firstname().." ("..itemlabel(g,n)..")",child.gramps_id)
            else
                print("\\textbf{"..child:firstname().."}")
                printperson(cr.ref,importants,depth+1)
            end
        end
        print("\\end{itemize}")
    end
end

local function relatiegegevens(p, ph,f)
    if ph then
        local s = make_sentence(HeShe(p).._("had een relatie met ").. 
            "\\textbf{"..gramps6.Person(ph):fullname().."} "..citations(f))
        print(s)
        index(gramps6.Person(ph))
        print(events(f,2))
    end
end
----------------------------------------------------------
function relaties(p,depth)
    local main_rela 

    for fi,fh in ipairs(p.family_list) do
        --print(fh)
     
        f = gramps6.Family(fh)
        if p.gender==1 then 
        --print(f)
        --print(util.dump(f.data))
            part_han = f.mother_handle 
        else
            part_han = f.father_handle
        end
        
        --print(in_importants(part_han))
        if in_importants(part_han) and p.gender then
            main_rela =f
        else
            relatiegegevens(p,part_han,f)
            children(f,depth+1)
        end
    end
    
    if main_rela then
        if p.gender == 1 then -- man 
            --print("|"..main_rela.mother_handle.."|")
            relatiegegevens(p,main_rela.mother_handle,main_rela)
            if not main_rela.mother_handle then --relatie gegevens
                print("geen moeder")
                children(main_rela,depth+1)
            end
        else -- vrouw
            --print("|"..main_rela.father_handle.."|")
            if not main_rela.father_handle then --relatie gegevens
            relatiegegevens(p,main_rela)
            end  
            children(main_rela,depth+1)
        end
    end
end

local function parents(p)
    local main_rela
    
    for fi,fh in ipairs(p.parent_family_list) do
        f = gramps6.Family(fh)
        local s=""
        if f.father_handle then
            local pf = gramps6.Person(f.father_handle)
            s=HisHer(p) .._("vader is ")
            n,g = in_importants(f.father_handle)
            if n  then
                s=s..link_str(pf:fullname().." ("..itemlabel(g,n)..")",pf.gramps_id)..
                    index_str(pf)
            else
                s=s..pf:fullname()
            end
            s = make_part(s)..", "
            if not in_importants(f.father_handle) then  s=s .. un_sentence(events(pf,3)) end
            if #s>60 then print(make_sentence(s)); s="" end
        end
        if f.mother_handle then
            local pm = gramps6.Person(f.mother_handle)
            if 0<#s then s=s.._(" and ")  end
            
            s=s..HisHer(p) .._("moeder is ")
            n,g = in_importants(f.mother_handle)
            if n  then
                s=s..link_str(pm:fullname().." ("..itemlabel(g,n)..")",pm.gramps_id)..
                    index_str(pm)
            else
                s=s..pm:fullname()
            end
            s = make_part(s)..", "
            if not in_importants(f.mother_handle) then  s=s .. un_sentence(events(pm,3)) end
        end
        print(make_sentence(s))
        if not in_importants(f.mother_handle) and not in_importants(f.father_handle) then
            print(events(f,2))
        end
    end 
end

local function notes(p)
    for i,nh in ipairs(p.note_list) do
        note = gramps6.Note(nh)
        print(note.gramps_id .." \\emph{"..note.text.string.."}")
    end
end

----------------------------------------------------------


local function type_event(evs,t)
    ret={}
	for i,ev in pairs(evs) do if ev.type.value == t then 
        table.insert(ret,ev) end end
	return ret
end

local last_place=""
local function long_event(ev)
    local line = ""
    local pl
    if ev then
		local dat = IsIfThenElse(ev.date, ev.date.long(ev.date,true).." ", "")
        if ev.description=='civil' then ev.description='' end
		local des = make_space(_.T(ev.description))
		
		if 0< #ev.place then
            if ev.place == last_place then pl = _("ald.") else
            place=gramps6.Place(ev.place);pl=  _("te " )..place:fullplace()..citations(place) end
        else pl="" end
        last_place = ev.place

        line = _("Custom ","Event %d ",ev.type.value)..des..dat..pl..citations(ev)
		--print(line)
	end
	return line
end

function events(p,ty)

	local s=""
	local hijzijn=""
	--print(p,ty)
	local events = p:events()
    local event_groups ={--{group,true:Hij/Zij false:Zijn/Haar}
            {
            {gramps6.Event.LifeEvents,true},
            {gramps6.Event.Religious,false},
            {gramps6.Event.Vocational,true},
            {gramps6.Event.Academic,true},
            {gramps6.Event.Travel,true},
            {gramps6.Event.Legal,true},
            {gramps6.Event.Residence,true}
            },
            {{gramps6.Event.Family,true}},
            {{gramps6.Event.LifeEvents,true}}
            }
	for k,group in ipairs(event_groups[ty]) do
        local lines={}
        for i,en in ipairs(group[1]) do
            for ie, ev in ipairs(type_event(events,en)) do
                l=long_event(ev)
                if 0<#l then table.insert(lines,make_part(l)) end
            end
        end
        
        local sg = table.concat(lines,", ")
        if group[2] then hijzijn = HeShe(p) else hijzijn=HisHer(p) end
        if 0<#sg then s = s.. make_sentence(hijzijn..sg) end
        
	end
	return s
end

local function images(p)
    if 0<#p.media_list then
        local ip=0
        print("")
        if not multicolumn then 
            print("\\the\\linewidth, \\the\\textwidth")
            print("\\begin{Figure}\\vspace{0ex}"..
                "\\noindent\\hspace*{\\linewidth}\\hspace*{-\\textwidth}"..
                "\\begin{minipage}{\\textwidth}")
        end
        print("\\begin{center}")
        for i,ml in ipairs(p.media_list) do
            
            local s, nr  = pic.image(ml.ref,false)
            
            if 0<#s then ip=ip+1;
                if multicolumn then 
                    print("\\hspace*{\\linewidth}\\hspace*{-\\columnwidth}"..
                        "\\parbox{\\columnwidth}{"..s.."}")
                else 
                    print(s)
                end
            end
            
            if ip>=imagesPerPerson then break end
        end 
        print('\\end{center}')
        if not multicolumn then
            print('\\end{minipage}\\end{Figure}')
        end
    end

end


local function target(s,ref)
    if tex then 
--        print("\\hypertarget{"..ref.."}{\\textcolor{blue!70!black}{"..s.."}}")
        print("\\hypertarget{"..ref.."}{\\textbf{"..s.."}}")
    else
        print(s)
    end 
end

function printNotEmpty(s) if 0<#s then print(s) end end

function printperson(h,imp,d)
    local depth = d or 0
    importants = imp

	p=gramps6.Person(h)

	if depth ==0 then 
        target(p:fullname(),p.gramps_id); 
    end
    index(p) 
    
    printNotEmpty(citations(p))
	
	leeftijd(p)
	
	if depth ==0 then  printNotEmpty( events(p,1))
    else printNotEmpty (events(p,3)) end


    
    --if imagesPerPerson > 0 then  images(p) end
    
	if depth==0 then parents(p) end

	notes(p)
	
	relaties(p,depth)
end

function printpersondone(h)
	p=gramps6.Person(h)
    link(p:fullname(),p.gramps_id) 
    index(p) 
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	loc = require("mh.local")
	loc.setlanguage('nl')

	tex={print=print,console=print}
	print = require("mh.print")
	
	require("person")
	_=require("mh.gettext")
    gramps6.Queries.init('../sqlite.db')
	printperson('I0683',{})

	--gramps6.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
	--gramps6.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
    --print( _("Custom ","Event %d ",12))
end
