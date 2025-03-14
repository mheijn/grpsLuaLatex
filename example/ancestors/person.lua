pic=require("pictures")
max_depth = 3
imaesPerPerson = 2

util=require("gramps.util")
local function IsIfThenElse(t,a,b) if t  then return a else return b end end
local function StrIfThenElse(t,a,b) print("test ",#t) ;if 0 < #t  then return a else return b end end

local function make_sentence(s)
    fl, rs = s:match("%s*(.)(.-)[%.,]*%s*$")
    if fl then return string.upper(fl)..rs..". "  else return s end
end
local function un_sentence(s)
    fl, rs = s:match("%s*(.)(.-)%.*%s*$");
    if fl then return string.lower(fl)..rs else return s end
end


local function make_part(s) local rs = s:match("^%s*(.*)%s*$"); return rs end


local function make_space(s) local r =make_part(s); 
    if 0<#r then return r.." " else return r end end

local function HeShe(p) 
    if p.gramps_id:match("^F.*") then return _("zij ") 
    elseif 0<p.gender then return _("he ") else return _("she ") end 
end 

local function HisHer(p) if 0<p.gender then return _("zijn ") else return _("haar ") end end 

local function leeftijd(p) 
    local s=""
    y,m,d = p:age()
    if y  then  
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
    if 0<#s then print(make_sentence(HeShe(p).._("werd ")..s.._("oud"))) end
end

local function index(p)
    if tex then 
        print("\\index{"..p:surname().."!"..p.primary_name.first_name..p.gramps_id.."@"..p.primary_name.first_name.."}")
    end
end
local function link(val,key)
    if tex then 
        print("\\hyperlink{"..key.."}{"..val.."}")
    else
        print(val)
    end
end        


local importants
local events,event,citations--,printperson

local function in_importants(handle)
    for i,g in pairs(importants) do
        for j,h in pairs(g) do
            --print(i,j,#importants,#g,h,handle)
            if h == handle then return j end
        end 
    end 
end

local function citations(comp)
    local s=""
    for i,cr in ipairs(comp.citation_list) do
        local cit = gramps.Citation(cr)
        --local sh = cit.source_handle
        --print(sh)
        local ref = gramps.Source(cit.source_handle).gramps_id
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
        if f.father_handle then  parents = parents..gramps.Person(f.father_handle):firstname() end
        if f.mother_handle then  
            if 0<#parents then parents =parents .._(" and ") end 
            parents = parents..gramps.Person(f.mother_handle):firstname() end
        print(_("Kind van ","Kinderen van ",amount)..parents.._(":is","  zijn:",amount))

        --print(#f.child_ref_list)
        
        print("\\begin{enumerate}")
        for i,cr in ipairs(f.child_ref_list) do
            child = gramps.Person(cr.ref)
            print("\\item ")
            if in_importants(cr.ref) then
                link(child:firstname(),child.gramps_id)
            else
                print("\\textbf{"..child:firstname().."}")
                printperson(cr.ref,importants,depth+1)
            end
        end
        print("\\end{enumerate}")
    end
end

local function relatiegegevens(p, ph,f)
    if ph then
        local s = make_sentence(HeShe(p).._("had een relatie met ").. 
            "\\textbf{"..gramps.Person(ph):fullname().."} "..citations(f))
        print(s)
        index(gramps.Person(ph))
        print(events(f,2))
    end
end
----------------------------------------------------------
function relaties(p,depth)
    local main_rela 

    for fi,fh in ipairs(p.family_list) do
        --print(fh)
     
        f = gramps.Family(fh)
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
        f = gramps.Family(fh)
        local s=""
        if 0<#f.father_handle then 
            local pf = gramps.Person(f.father_handle)
            s=make_part(HisHer(p) .._("vader is ")..pf:fullname())..", "
            if not in_importants(f.father_handle) then  s=s .. un_sentence(events(pf,3)) end
            if #s>60 then print(make_sentence(s)); s="" end
        end
        if 0<#f.mother_handle then 
            local pm = gramps.Person(f.mother_handle)
            if 0<#s then s=s.._(" and ")  end
            s=s..make_part(HisHer(p) .._("moeder is ")..pm:fullname())..", "
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
        note = gramps.Note(nh)
        print(note.gramps_id .." \\emph{"..note.text.string.."}")
    end
end

----------------------------------------------------------


local function type_event(evs,t)
    ret={}
	for i,ev in pairs(evs) do if ev.type.number == t then table.insert(ret,ev) end end
	return ret
end

local last_place=""
local function long_event(ev)
    local line = ""
    local pl
    if ev then
		local dat = IsIfThenElse(ev.date, ev.date:long(true).." ", "")
		local des = make_space(_.T(ev.description))
		
		if 0< #ev.place then
            if ev.place == last_place then pl = _("ald.") else
            place=gramps.Place(ev.place);pl=  _("te " )..place:fullplace()..citations(place) end
        else pl="" end
        last_place = ev.place

        line = _("Custom ","Event %d ",ev.type.number)..des..dat..pl..citations(ev)
		--print(line)
	end
	return line
end

function events(p,ty)

	local s=""
	--print(p,ty)
	local events = p:events()
    local event_groups ={
            {gramps.Event.LifeEvents,
            gramps.Event.Religious,
            gramps.Event.Vocational,
            gramps.Event.Academic,
            gramps.Event.Travel,
            gramps.Event.Legal,
            gramps.Event.Residence},
            {gramps.Event.Family},
            {gramps.Event.LifeEvents}
            }
	for k,group in ipairs(event_groups[ty]) do
        local lines={}
        for i,en in ipairs(group) do
            for ie, ev in ipairs(type_event(events,en)) do
                l=long_event(ev)
                if 0<#l then table.insert(lines,make_part(l)) end
            end
        end
        local sg = table.concat(lines,", ")
        if 0<#sg then s = s.. make_sentence(HeShe(p)..sg) end
	end
	return s
end

local function images(p)
    if 0<#p.media_list then
        local ip=0
        print("")
        --print("\\showthe\\leftmargin")
        print("\\begin{Figure}\\vspace{0ex}"..
            "\\noindent\\hspace*{\\linewidth}\\hspace*{-\\textwidth}"..
            "\\begin{minipage}{\\textwidth}\\begin{center}")
        for i,ml in ipairs(p.media_list) do
            --print("\\typeout{"..ml.ref.."}")
            
            local s, nr  = pic.image(ml.ref,false)
            if 0<#s then ip=ip+1;print(s) end
            if ip>=imaesPerPerson then break end
        end 
        print('\\end{center}\\end{minipage}\\end{Figure}')
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

	p=gramps.Person(h)

	if depth ==0 then 
        target(p:fullname(),p.gramps_id); 
    end
    index(p) 
    
    printNotEmpty(citations(p))
	
	leeftijd(p)
	
	if depth ==0 then  printNotEmpty( events(p,1))
    else printNotEmpty (events(p,3)) end
    
    images(p)
    
	if depth==0 then parents(p) end

	notes(p)
	
	relaties(p,depth)
end


