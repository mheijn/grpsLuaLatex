local grps = {}
local family = require("gramps.family")
local person = require("gramps.person")
local util   = require("gramps.util")
local events = require("gramps.events")
local place  = require("gramps.place")
local media  = require("gramps.media")
local print = require("gramps.output")

--local = require("")
--format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)"

OPTION = {O_CENTRAL=1,
    O_SPOUSE=2,
    O_CHILDREN=3,
    O_PARENTS=4,
    O_SPOUSE_HANDLE=5,
    O_LEVEL=6,
    O_MAXMEDIA=7,
    LONG=0,
    LIFEEVENTS=1,
    VOCATIONAL=2,
    RESIDENCE=3,
    RELATIONS=4,
    PARENTS=5,
    CHILDREN=6,
    FULLNAME=7,
    SPOUSEPARENTS=8,
    MEDIA=9,
    ITEMIZE=10,
    SIBLINGS=11}
grps.OPTION = OPTION
---
-- @param a1 if a2==nil a1 are/is the option(s) set else a2
-- @param a2 existing options
local function set_options(a1,a2)
    local res = 0
    local op = 0
    if a2==nil then op = a1 else
        op = a2
        res = a1
    end

    if type(op)=="table" then
        for i,v in ipairs(op) do res=res | 2^v end
    else
        res = res | 2^op
 --print.i("set_options:",res,util.dump(op))
    end

    return res
end
grps.set_options = set_options

local function remove_options(option,op)
    if type(op)=="table" then
        for i,v in ipairs(op) do option=option ~ 2^v end
    else
        option = option ~ 2^op
    end

    return option
end
grps.remove_options=remove_options

local function bin_set(getal,bin)
--print(getal,2^bin,(getal&(2^bin) ~=0 ))
    return (getal&(2^bin) ~=0 )
end

function default_options()
    local option_parents  = set_options({OPTION.FULLNAME})
    local option_children = set_options({OPTION.LIFEEVENTS,OPTION.VOCATIONAL,OPTION.RESIDENCE,OPTION.RELATIONS,OPTION.CHILDREN,OPTION.SPOUSEPARENTS})
    local option_central  = set_options({OPTION.FULLNAME,OPTION.LIFEEVENTS,OPTION.VOCATIONAL,OPTION.RESIDENCE,OPTION.RELATIONS,OPTION.CHILDREN,OPTION.
    SPOUSEPARENTS,OPTION.PARENTS,OPTION.MEDIA})
    local option_spouse   = set_options({OPTION.FULLNAME,OPTION.LIFEEVENTS,OPTION.VOCATIONAL,OPTION.RESIDENCE,OPTION.RELATIONS,OPTION.CHILDREN,OPTION.
    SPOUSEPARENTS,OPTION.PARENTS})
    local default_opts = {option_central,option_spouse,option_children,option_parents,0,1}
    return default_opts
end
grps.default_options = default_options

local option_lastchildren = set_options({})

function unescape(str)
if not tex then return str end
if type(str)=="string" then
res = string.gsub(str,"_","\\_")
res = string.gsub(res,"~","$\\sim$")
res = string.gsub(res,";",";\\-")
res = string.gsub(res,"#","\\#")
res = string.gsub(res,'"','``')
else
res = "TYPE: "..type(str)
end
return res
end

function file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

function grps.gettextwidth()
    local points = 469*65536
    if tex and tex.dimen then
        points = tex.dimen.columnwidth or tex.dimen.textwidth
    end
--local columnwidth_points = tex.dimen.columnwidth
--tex.print("Textwidth in points: " .. tostring(columnwidth_points / 65536) .. "pt")
--local textwidth_in_cm = (columnwidth_points / 65536) / 28.3464567
--tex.print(textwidth_in_cm.."cm")
    return points/1857713.386
end

function grps.long_print_person(handle,level,opts)
    local opts = opts or default_options()
    local level = level or 3
    local options = {}

    for i,v in ipairs(opts) do  if type(v)=="number" then opts[i]= v | 1 end end
    --print.i(util.dump(options))
    grps.print_person(handle,level,1,opts,OPTION.O_CENTRAL)
end

function grps.short_print_person(handle,level,opts)
    local opts = opts or default_options()
    local level = level or 3
    local options = {}

    for i,v in ipairs(opts) do if type(v)=="number" then
        opts[i]= v & ~set_options({OPTION.LONG, OPTION.VOCATIONAL, OPTION.RESIDENCE})
    end end
--    for i=1,level do
--        options[i]=table.copy(opts)
--        options[i][OPTION.O_LEVEL]=i
--    end
    --print.i(util.dump(options))
    grps.print_person(handle,level,1,opts,OPTION.O_CENTRAL)
end

function grps.print_person(h,max_level,level,opts,person_type)
    local opt = opts[person_type]
    local calling_spouse = opts[OPTION.O_SPOUSE_HANDLE]
    opts[OPTION.O_SPOUSE_HANDLE] = ""

    local p=person(h)
    local h=p.handle
    local pe = person.events(h)

    local line = string.texcommand("noindent")
    line = line..string.gdef("grpssex",p.gender)
    line = line..string.gdef("grpsItemizeActualdepth",level)

    -- Format name person with hyperlink and index
    local sp=""
    if person_type ~= OPTION.O_CENTRAL and (p.ancestornummer or p.kwartiernummer) then
        sp=sp.."\\hyperlink{"..p.gramps_id.."}{"
    else
        sp=sp.."\\sethypertarget{"..p.gramps_id.."}{"
    end

    if bin_set(opt,OPTION.FULLNAME) then
        sp=sp..person.fullname(h)
    else
        sp=sp..person.firstname(h)
    end
    sp=sp.."}"

    sp=sp.."\\index{"..person.familyname(h).."!"..person.firstname(h)..person(h).gramps_id.."@"..person.firstname(h).."}"
    if person_type ~=OPTION.O_PARENTS  and not bin_set(opt,OPTION.ITEMIZE) then sp=sp..".\n"end

    line = line .. sp

    sentence = person_type ~=OPTION.O_PARENTS
    nopoint  = person_type ==OPTION.O_PARENTS
    --------- Events --------------
    if pe and bin_set(opt,OPTION.LIFEEVENTS) then
        sl = set_events(opt,p,pe,events.LifeEvents,sentence,nopoint)
        line = line .. sl
    end

    if pe and bin_set(opt,OPTION.VOCATIONAL) then
        sl = set_events(opt,p,pe,events.Vocational,sentence,nopoint)
        line = line .. sl
    end

    if pe and bin_set(opt,OPTION.VOCATIONAL) then
        sl = set_events(opt,p,pe,events.Academic,sentence,nopoint)
        line = line .. sl
    end

    if pe and bin_set(opt,OPTION.RESIDENCE) then
        sl = set_events(opt,p,pe,events.Residence,sentence,nopoint)
        line = line .. sl
    end

    -------- Parents ------------------
    if bin_set(opt,OPTION.PARENTS) and person_type ~= OPTION.O_CHILDREN then
        line=line..grps.parents(h,max_level,level,opts)
    end

    --------- Siblings ----------------
    if bin_set(opt,OPTION.SIBLINGS)  then
        line=line..grps.siblings(h,max_level,level,opts)
    end

    ----- Pictures --------
    local spic = ""
    if bin_set(opt,OPTION.MEDIA) and p.blob_data then
        local nr_pic=1
        local ac_pic=1
        while p.blob_data[11][ac_pic] do
            if nr_pic > opts[OPTION.O_MAXMEDIA] then break end;
            local ph=p.blob_data[11][ac_pic][5]
            local pic = grps.picture(ph)
            if #pic>0 then
                nr_pic = nr_pic + 1
                spic = spic.. pic
            end
            ac_pic = ac_pic + 1
        end
    end

    if p.kwartiernummer then line=line .. spic end

    ------ relaties --------
    local rs=""
    local kwartier_family_handle=""
    local family_nr=0
    if bin_set(opt,OPTION.RELATIONS) then
        local fams = person.spouses(p.handle)
        --if #fams>0 and bin_set(opt,OPTION.ITEMIZE) then print("\\begin{itemize}\\item[]start") end
        for i,fh in ipairs(fams) do
            --dprint("\nfamily handle: "..fh)

            f=family[fh]
            if f.father_handle == p.handle then
                spouse=f.mother_handle
            else
                spouse=f.father_handle
            end

            if p.kwartiernummer and spouse == nil then
                kwartier_family_handle=fh
                family_nr=i

            elseif p.kwartiernummer and  (p.kwartiernummer+1) == person[spouse].kwartiernummer then
                kwartier_family_handle=fh
                family_nr=i

            elseif p.kwartiernummer and  (p.kwartiernummer-1) == person[spouse].kwartiernummer then
                kwartier_family_handle=fh
                family_nr=i

            else
                if calling_spouse~=spouse then
                    --print("\\\\calsp="..calling_spouse.." \\\\sp="..spouse.." \\\\h="..p.handle)
                    --if not picture_printed then print("\\\\") end
                    --if not picture_printed then print("\n\n\n\\noindent") end

                    opts[OPTION.O_SPOUSE_HANDLE] = p.handle
                    if #fams > 1 then rs=rs .."("..i..")" end
                    rs = rs .. grps.relation(fh,p,i,opt)
                    if spouse then
                        rs = rs .. grps.print_person(spouse,max_level,level+1,opts,OPTION.O_SPOUSE)
                    end

                    --if bin_set(opt,OPTION.PARENTS) then
                    --    grps.print_parents(spouse,max_level,level,opts)
                    --end

                    if bin_set(opt,OPTION.CHILDREN) then
                        rs = rs .. grps.children(fh,max_level,level,opts)
                    end
                end
            end
        end

        if  #kwartier_family_handle>1 then
            if p.gender==1 and spouse ~= "" then
                if bin_set(opt, OPTION.LONG) or bin_set(opt,OPTION.ITEMIZE) then
                    if #fams > 1 then
                        rs = rs .. "\\item[\\gtrsymMarried$^{"..family_nr.."}$]"
                    else
                        rs = rs .. "\\item[\\gtrsymMarried]"
                    end
                end
                rs = rs .. grps.relation(kwartier_family_handle,p,family_nr,opt)
            else
                if bin_set(opt, OPTION.CHILDREN) then
                    --print("LF1\\\\")
                    if #fams > 1 then rs = rs.." ("..family_nr..") " end
                    rs = rs .. grps.children(kwartier_family_handle,max_level,level,opts)
                end
            end
        end

        --if #fams>0 and bin_set(opt,OPTION.ITEMIZE) then print("\\end{compactitemize}") end
    end
    line = line ..rs

    if not p.kwartiernummer then line=line .. spic end

    --if person_type ~= OPTION.O_PARENTS then
    line = line.."\\stopitemize{"..(level).."}" --end

    if level == 1 then
        print("\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        print(line)
        --io.write(line)
        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    end
    return line
end

function grps.relation(fh,p,times,opt)
    local f = family[fh]
    local fe = family.events(f.handle)
    --dprint(util.dump(f))

    local s,main_handle,spouse_handle

    --token.set_macro("grpssex",man,"global")
    s=string.gdef("grpssex",p.gender)
    --token.set_macro("grps@itemize@actualdepth"

    if p.gender==1 then
        main_handle = f.father_handle
        spouse_handle = f.mother_handle
        --ss="\\grpsTHij "
    else
        spouse_handle = f.father_handle
        main_handle = f.mother_handle
        --ss="\\grpsTZij "
    end

    if fe then
        sfe = set_events(opt,p,fe,events.Family,true,true)
    end
    if #sfe==0 then
        if bin_set(opt,OPTION.LONG) then
            sfe=HijZij(p).."\\grpsTkoppelde"
        else
            sfe="$\\times$"
        end
    end

    if bin_set(opt,OPTION.LONG) then
        s = s..sfe .." \\grpsTmet "
    else
        s=s..sfe
    end

    return s
end

function grps.children(fh,max_level,level,options)
    local s=""
    --print.i("children"..util.dump(options))
    if max_level>level then
        level = level + 1
        --dprint("fhandle :" .. fh)
        local children = family.get_children(fh)
        --print(util.dump(children))
        local sorted = person.sort_person_handles(children)
        if #children > 0 then
            s=s.."\\begin{grampslist"..util.roman(level).."}"
            for j,ic in ipairs(sorted) do
                s=s.."\\item["..j.."]"

                local child = children[ic[1]]
                local ref_nummer = person[child].kwartiernummer  or person[child].ancestornummer

                if  ref_nummer then
                    s=s.."\\hyperlink{"..person[child].gramps_id.."}{"..
                        person.fullname(children[ic[1]]).." ("..ref_nummer.."$\\rightarrow$})."
                else
                    s=s..grps.print_person(children[ic[1]],max_level,level,options,OPTION.O_CHILDREN)
                end
            end
            s=s.."\\end{grampslist"..util.roman(level).."}"
        end
    end
    return s
end

function grps.siblings(ph,max_level,level,options)
    s=""
    local p=person[ph]
    local fam = person.parents(ph)
    for i,fh in ipairs(fam) do
        local sibls = family.get_children(fh)
        local sorted = person.sort_person_handles(sibls)
        if #sibls > 0 then
            s=s.."\\begin{grampslist"..util.roman(level).."}"
            for j,ic in ipairs(sorted) do
                s=s.."\\item["..j.."]"
                local sib = sibls[ic[1]]

                if sib == ph then
                    --
                else
                    s=s..grps.print_person(sib,max_level,level+1,options,OPTION.O_CHILDREN)
                end
            end
            s=s.."\\end{grampslist"..util.roman(level).."}"
        end
    end
    return s
end

function grps.parents(ph,max_level,level,options)
    s=""
    --print(ph,util.dump(options))
    local p=person[ph]
    --print("("..p.gramps_id..")")
    local fam = person.parents(ph)
    --dprint("in parents"..util.dump(options))
    for i,fh in ipairs(fam) do
        f=family(fh)
    --print(util.dump(f))
        if f.father_handle or f.mother_handle then
            --print(options.relation,OPTION.LONG)
            --dprint("parents 1 ",util.dump(options))
            local do_itemize  = bin_set(options[OPTION.O_CENTRAL],OPTION.ITEMIZE)
            if bin_set(options[OPTION.O_PARENTS],OPTION.LONG) then -- LONG --
                if do_itemize then s=s.."\\doitem[-]{}" end
                s=s..ZoonDochter(p)
                if  f.father_handle then
                    if do_itemize then s=s.."\\doitem[V]{}" end
                    s=s..grps.print_person(f.father_handle,max_level,level+1,options,OPTION.O_PARENTS)
                end
                if do_itemize then s=s.."\\doitem[ ]{}" end
                if  f.father_handle and f.mother_handle then s=s.." \\grpsTen " end
                if f.mother_handle then
                    if do_itemize then s=s.."\\doitem[M]{}" end
                    s=s..grps.print_person(f.mother_handle,max_level,level+1,options,OPTION.O_PARENTS)
                end
                s=s ..".\n"
            else
                if do_itemize then
                    if f.father_handle then
                        s=s.."\\doitem[V]{}"
                        s=s..grps.print_person(f.father_handle,max_level,level+1,options,OPTION.O_PARENTS)
                    end
                    if f.father_handle then
                        s=s.."\\doitem[M]{}"
                        s=s..grps.print_person(f.mother_handle,max_level,level+1,options,OPTION.O_PARENTS)
                    end
                else
                    s=s.."("
                    if f.father_handle then s=s..grps.print_person(f.father_handle,max_level,level+1,options,OPTION.O_PARENTS) end
                    if f.father_handle and f.mother_handle then s=s.." $\\times$ " end
                    if f.mother_handle then s=s..grps.print_person(f.mother_handle,max_level,level+1,options,OPTION.O_PARENTS) end
                    s=s..")"
                end
            end
        end
    end
    return s
end

function set_events(opt,p,pe,event_types,sentence,nopoint)
    if nil == sentence then sentence = true end
    if nil == nopoint then nopoint =  false end
    e ={}
    for _,t in ipairs(event_types) do
        table.insert(e,get_tex_event_by_type(pe,t))
    end
    if bin_set(opt,OPTION.ITEMIZE) then
        s=table.join(e," ")
    else
        s=table.join(e,", ")
        if #s>0 then
            if bin_set(opt,OPTION.LONG) then
                if sentence then s = HijZij(p)..s
                else s = ", "..hijzij(p)..s
                end
            end
            if not nopoint then s=s..". " end
        end
    end
    return s
end

function get_tex_event_by_type(evs,ev_type)
    local s_ret=""
    local s=""
--print.i("evs = ",util.dump(evs))
for i,eh in ipairs(evs) do
        local ev   = events[eh]
local blob = ev.blob_data
        --dprint(i,eh,blob[3][1],ev_type)
--io.write(util.dump(ev))
        if ev_type == blob[3][1] then
s="\\grpsEvent{"..ev_type.."}"

if blob[4] and blob[4][4] then
s=s.."{"..blob[4][1].."}"
s=s.."{"..blob[4][2].."}"
s=s.."{"..blob[4][3].."}"
s=s.."{"..blob[4][4][3]..
util.is_zero(blob[4][4][2],"","-"..blob[4][4][2])..
util.is_zero(blob[4][4][1],"","-"..blob[4][4][1]).."}"
else
s=s.."{0}{0}{0}{}"
--io.write(util.dump(blob))
end
s=s.."{"..place.name(ev.place).."}"
if blob[4] and blob[4][4] and blob[4][4][5] and blob[4][2]>3 then
s=s.."{"..blob[4][4][7]..
util.is_zero(blob[4][4][6],"","-"..blob[4][4][6])..
util.is_zero(blob[4][4][5],"","-"..blob[4][4][5]).."}"
else
s=s.."{}"
end
s=s.."{}{"..unescape(ev.description).."}"
        else
            s=""
        end
        s_ret = util.comma_con(s_ret,s)
end
return s_ret
end

local function get_textree_event_by_type(h,ev_type)
    evs = person.events(h)
    local s=""
    local plus =""
if evs then for i,eh in ipairs(evs) do
        local ev   = events[eh]
local blob = ev.blob_data
        if ev_type == blob[3][1] then
            if blob[4] and blob[4][4] then
            --print(util.dump(blob[4][4]))
                s = s.."{"..blob[4][4][3]..
util.is_zero(blob[4][4][2],"","-"..blob[4][4][2])..
util.is_zero(blob[4][4][1],"","-"..blob[4][4][1]).."}"
            else
                s=s.."{}"
            end
            local placename = place.name(ev.place)
            if placename=="" then plus="-" else s = s.."{"..placename.."}" end
        end
    end end
    return s,plus
end

function grps.tree_person(id,fun,link)
    local link = link or ""
    local fun = fun or 'g'
    local s=""

    local p=person(id)
    local h=p.handle
    s = fun.."[id="..p.gramps_id..link..']{\n'
    --print(util.dump(p))
    if p.gender==1 then s=s.."male,\n" else s=s.."female,\n" end
    s=s.."name = {\\pref{"..person.firstname(h).."} \\surn{"..person.familyname(h).."}},\n"
    datum,plus = get_textree_event_by_type(p.handle,events.TYPE.BIRTH)
    if datum ~= "" then s=s.."birth"..plus.." = "..datum..",\n" end
    -- baptism
    datum,plus = get_textree_event_by_type(p.handle,events.TYPE.BABTISM)
    if datum ~= "" then s=s.."baptism"..plus.." = "..datum..",\n" end
    -- birth
    datum,plus = get_textree_event_by_type(p.handle,events.TYPE.DEATH)
    if datum ~= "" then s=s.."death"..plus.." = "..datum..",\n" end
    -- birth
    datum,plus = get_textree_event_by_type(p.handle,events.TYPE.BURIAL)
    if datum ~= "" then s=s.."burial"..plus.." = "..datum..",\n" end
    -- kwartier nummer
    if p.kwartiernummer then s=s.."kekule = "..p.kwartiernummer..",\n" end
    s = s.."}\n"
    return s
end

function datum(blob_datum)
    local d=""
    if blob_datum[4] then
        d = util.is_zero(blob_datum[4][1],"",blob_datum[4][1].."-")..
            util.is_zero(blob_datum[4][2],"",blob_datum[4][2].."-")..
            util.is_zero(blob_datum[4][3],"",blob_datum[4][3])
    end
    return d
end

picture_published = {}

function grps.picture(id)
    local m = media(id)
    local handle=m.handle
    local label=m.gramps_id
    local titel= unescape(m.desc) or ""
    local datum = datum(m.blob_data[11]) or ""
    local x=200
    local y=200
    local persons = media.persons(handle)
    local s=""

    --io.write(util.dump(m))

    --s=s..util.dump(m)
    local fig_nr
    for fig_nr,id in ipairs(picture_published) do
        if id == label then return "" end
    end
    table.insert( picture_published,label)
    fig_nr = #picture_published
    if #datum > 0 then titel = titel .."("..datum..")" end
    caption = "Fig. "..fig_nr..".\\label{fig:"..label..'} '..titel
    --s=s .. "\\addcontentsline{lof}{figure}{Figure "..fig_nr..".  "..titel.."}"

    local filename =media.path(handle)
    if file_exists(filename) then

        local process = io.popen("identify -format '%wx%h' "..filename)
        local result = process:read("*a")
        process:close()
        local longsize = 0.9*(grps.longsize or grps.gettextwidth())
        local x,y
        for lx, ly in string.gmatch(result,'(%d+)x(%d+)') do  x=lx; y=ly   end

        if x>y then
            longsize=longsize*0.7
        end
        y=(longsize*y)/x; x=longsize

        s =s..'\\begin{Figure}\\vspace{-2ex}\\begin{center}'..
            '\\begin{tikzpicture}[x=10mm,y=10mm]'..
            "\\addcontentsline{lof}{figure}{Figure "..fig_nr..".  "..titel.."}"..
            '\\node[inner sep=0pt] (PIC) {\\includegraphics[width='..
            x..'cm,height='..y..'cm]{'..filename..'}};'

        if #persons>0 then
            s=s..'\\begin{scope}[ocg={ref=REC'..label..', status=invisible, name=ok}]'
            for i,t in ipairs(persons) do
                local tx = (t.x1*x)/100.0
                local ty = ((100-t.y1)*y)/100.0
                local tw = (t.x2*x)/100.0
                local th = ((100-t.y2)*y)/100.0
                s=s..'\\draw[tagbox,shift=(PIC.south west)] ('..tx..','..ty..') rectangle ('..tw..','..th..');'
                if #persons>1 then
                    s=s..'\\node[tagnumber] at ([shift=(PIC.south west)] '..(x*t.xm/100)..','..(y*(100-t.ym)/100)..') {'..i..'};'
                end
            end
            s=s.."\\node at (0,0) {\\switchocg{REC"..label.."}{\\raisebox{0pt}["..x.."cm][0cm]{\\makebox["..y.."cm]{}}}};"..
                '\\end{scope}'
        end
        s=s.."\\node (T) at (0,"..(y*0.5 - 1)..") {};"
        if #titel > 0 then
            s=s..'\\node[above=of T, align=center, text width='..0.9*grps.gettextwidth()..'cm]  {'..caption..'};'
        end
        s=s.."\\node (B) at (0,"..(-y*0.5 + 1)..") {};"
        s=s.."\\node[below=of B, align=center, text width="..0.9*grps.gettextwidth().."cm]  {"
            --"This is a node with text that will automatically break into multiple lines based"..
            --"on the specified text width};"

        --print('\\vspace{-1ex}')

        if #persons>0 then
            --print(' [\\switchocg{REC'..label..'}{TAGS}]\\\\%')
            local sp=""
            for i=1,#persons do

--    for i,v in ipairs(persons) do
--        print(i,util.dump(persons[i]),persons[i].handle)
            sp=sp.."\\hyperlink{"..person[persons[i].handle].gramps_id.."}{("..i..")\\ "..unescape(person.fullname(persons[i].handle)).."}"
                if i < #persons  then
                    if 1 == #persons-1 then sp=sp.." and " else sp=sp..", " end
                end
            end
            s=s..'{\\small'..sp..'}};'
        end
        s=s..'\\end{tikzpicture}'
        s=s..'\\end{center}\\end{Figure}'
    else
        print.e("File "..m.path.." not found!")
    end
    --io.write(s)
    return s

end

function HijZij(p)
    --if p==nil then return "" end
    if p.gender==1 then return "\\grpsTHij "
    else return "\\grpsTZij " end
end

function hijzij(p)
    --if p==nil then return "" end
    if p.gender==1 then return "\\grpsThij "
    else return "\\grpsTzij " end
end

function ZijnHaar(p)
    if p.gender==1 then return "\\grpsTZijn "
    else return "\\grpsTHaar " end
end

function ZoonDochter(p)
    if p.gender==1 then return "\\grpsTZoon "
    else return "\\grpsTDochter " end
end

function grps.test()
    print.i("Dit is een test naar log")
    print("Dit is een test naar tekst")

    local info = debug.getinfo(2, "nSl")
    print(util.dump(info))
    --print( info.source, info.currentline)
end
function hallo()
grps.test()
end

function grps.allmedia()
    media.all()
    local i=0
    for h,m in pairs(media) do
        print("\\subsection{"..unescape(m.path).." ("..m.gramps_id..")}")
        i=i+1
        if i>20 then break end
        grps.picture(m.handle)
    end
end

function grps.allperson()
    person.all()
    return person
end

--local textwidth_in_points = tex.dimen.textwidth
--  tex.print("Textwidth in points: " .. tostring(textwidth_in_points / 65536) .. "pt")
-- local textwidth_in_cm = (textwidth_in_points / 65536) / 28.3464567
query.close()

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    --local fh="c5db97ee058b578e47c10737e0f"
    --fh='F0001'
    --grps.print_relation(fh,1,default_options)
    --grps.print_children(fh,default_options)
    grps.long_print_person('I0018')
--    grps.short_print_person('I0018')
    --grps.short_print_person('I0018')
    --grps.short_print_person('I0692')
    --grps.test()
    --hallo()
    --grps.picture("O0710")
    --grps.allmedia()
    --grps.print_person('I0692',{person=2^OPTION.LIFEEVENTS+2^OPTION.RELATIONS+2^OPTION.FULNAME,levl=1,relation=0})
    --print(grps.tree_person('I0692'))
    --print(grps.tree_person('I0565'))
    --grps.allperson()
    --I2483
else
    return(grps)
end

