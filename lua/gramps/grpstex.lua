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

OPTION = {O_CENTRAL=1,O_SPOUSE=2,O_PARENTS=3,O_CHILDREN=4,O_SPOUSE_HANDLE=5,O_LEVEL=6,
    LONG=0,LIFEEVENTS=1,VOCATIONAL=2,RESIDENCE=3,RELATIONS=4,PARENTS=5,CHILDREN=6,FULNAME=7,SPOUSEPARENTS=8,MEDIA=9}


local function set_options(a1,a2)
    local res = 0
    local op = 0
    if a2==nil then op = a1 else
        op = a2
        res = a1
    end
--print(res,util.dump(op))

    if type(op)=="table" then
        for i,v in ipairs(op) do res=res | 2^v end
    else
        res = res & 2^op
    end

    return res
end

local function remove_options(option,op)
    if type(op)=="table" then
        for i,v in ipairs(op) do option=option ~ 2^v end
    else
        option = option | 2^op
    end

    return options
end

local function bin_set(getal,bin)
--print(getal,2^bin,(getal&(2^bin) ~=0 ))
    return (getal&(2^bin) ~=0 )
end

local option_parents  = set_options({OPTION.FULNAME})
local option_children = set_options({OPTION.LIFEEVENTS,OPTION.VOCATIONAL,OPTION.RESIDENCE,OPTION.RELATIONS,OPTION.CHILDREN,OPTION.SPOUSEPARENTS})
local option_central  = set_options({OPTION.FULNAME,OPTION.LIFEEVENTS,OPTION.VOCATIONAL,OPTION.RESIDENCE,OPTION.RELATIONS,OPTION.CHILDREN,OPTION.
    SPOUSEPARENTS,OPTION.PARENTS,OPTION.MEDIA})
local option_spouse   = set_options({OPTION.FULNAME,OPTION.LIFEEVENTS,OPTION.VOCATIONAL,OPTION.RESIDENCE,OPTION.RELATIONS,OPTION.CHILDREN,OPTION.
    SPOUSEPARENTS,OPTION.PARENTS})


local option_lastchildren = set_options({})

local default_opts = {option_central,option_spouse,option_parents,option_children,0,1}


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
    local opts = opts or default_opts
    local level = level or 3
    local options = {}

    for i,v in ipairs(opts) do  if type(v)=="number" then opts[i]= v | 1 end end
    --print.i(util.dump(options))
    grps.print_person(handle,level,1,opts,OPTION.O_CENTRAL)
end

function grps.short_print_person(handle,level,opts)
    local opts = opts or default_opts
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

    print.i("print "..person.fullname(h))

    if person_type ~= OPTION.O_CENTRAL and p.ancestornummer then
        print.s("\\hyperlink{"..p.gramps_id.."}{")
    else
        print.s("\\sethypertarget{"..p.gramps_id.."}{")
    end
    if bin_set(opt,OPTION.FULNAME) then print.s(person.fullname(h)) else print.s(person.firstname(h)) end
    print.s("}")

    print.s("\\index{"..person.familyname(h).."!"..person.firstname(h)..person(h).gramps_id.."@"..person.firstname(h).."}")
    if person_type ~=OPTION.O_PARENTS then print.s(". ") end


--event.LifeEvents={event.TYPE.BIRTH, event.TYPE.BAPTISM, event.TYPE.DEATH,
--			event.TYPE.BURIAL, event.TYPE.CREMATION, event.TYPE.ADOPT}
    --print.i("Type van pe is ",type(pe))
    if pe and bin_set(opt,OPTION.LIFEEVENTS) then
        local s = get_tex_event_by_type(pe,events.TYPE.BIRTH)
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.BABTISM))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.DEATH))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.BURIAL))
        if bin_set(opt,OPTION.LONG) then
            s=util.is_empty(s,"",hijzij(p)..s..". ")
        else
            s=util.is_empty(s,"",s..". ")
        end
        if #s>0 then print(s) end
    end

    if pe and bin_set(opt,OPTION.VOCATIONAL) then
        s = get_tex_event_by_type(pe,events.TYPE.OCCUPATION)
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.RETIREMENT))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.ELECTED))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.MILITARY_SERV))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.ORDINATION))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.EDUCATION))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.DEGREE))
        s = util.comma_con(s,get_tex_event_by_type(pe,events.TYPE.GRADUATION))
        if bin_set(opt,OPTION.LONG) then
            s=util.is_empty(s,"",hijzij(p)..s..". ")
        else
            s=util.is_empty(s,"",s..". ")
        end
        if #s>0 then print(s) end
        s=util.is_empty(s,"",hijzij(p)..s..". ")
    end

    if pe and bin_set(opt,OPTION.RESIDENCE) then
        s = get_tex_event_by_type(pe,events.TYPE.RESIDENCE)
        if bin_set(opt,OPTION.LONG) then
            s=util.is_empty(s,"",hijzij(p)..s..". ")
        else
            s=util.is_empty(s,"",s..". ")
        end
        if #s>0 then print(s) end
        s=util.is_empty(s,"",hijzij(p)..s..". ")
    end

    if bin_set(opt,OPTION.PARENTS) then
        grps.print_parents(h,max_level,level,opts)
    end

    local picture_printed=false
    if bin_set(opt,OPTION.MEDIA) and p.blob_data and p.blob_data[11][1] then
        ph=p.blob_data[11][1][5]
        grps.picture(ph)
        picture_printed=true
    end
    ------ relaties --------
    local kwartier_family_handle=""
    local family_nr=0
    if bin_set(opt,OPTION.RELATIONS) then
        local fams = person.spouses(p.handle)
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
                    if not picture_printed then print("\n\n\n\\noindent") end

                    opts[OPTION.O_SPOUSE_HANDLE] = p.handle
                    if #fams > 1 then print.s("("..i..")") end
                    grps.print_relation(fh,p.gender,i,opt)
                    grps.print_person(spouse,max_level,level,opts,OPTION.O_SPOUSE)

                    --if bin_set(opt,OPTION.PARENTS) then
                    --    grps.print_parents(spouse,max_level,level,opts)
                    --end

                    if bin_set(opt,OPTION.CHILDREN) then
                        grps.print_children(fh,max_level,level,opts)
                    end
                end
            end
        end

        if  #kwartier_family_handle>1 then
            if p.gender==1 and spouse ~= "" then
                if bin_set(opt, OPTION.LONG) then
                    if family_nr > 0 then
                        print("\\item[\\gtrsymMarried$^{"..family_nr.."}$]")
                    else
                        print("\\item[\\gtrsymMarried]")
                    end
                end
                grps.print_relation(kwartier_family_handle,p.gender,family_nr,opt)
            else
                if bin_set(opt, OPTION.CHILDREN) then
                    --print("LF1\\\\")
                    if family_nr > 0 then print.s("("..family_nr..")") end
                    grps.print_children(kwartier_family_handle,max_level,level,opts)
                end
            end
        end
    end
end


function grps.print_relation(fh,man,times,opt)
    local f = family[fh]
    local fe = family.events(f.handle)
    --dprint(util.dump(f))

    local ss,s,main_handle,spouse_handle
    if man==1 then
        main_handle = f.father_handle
        spouse_handle = f.mother_handle
        ss="\\grpsTHij "
    else
        spouse_handle = f.father_handle
        main_handle = f.mother_handle
        ss="\\grpsTZij "
    end

    if fe then
        s = get_tex_event_by_type(fe,events.TYPE.ENGAGEMENT)
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.MARR_ALT))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.MARRIAGE))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.DIVORCE))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.ANNULMENT))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.MARR_SETTL))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.MARR_LIC))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.MARR_CONTR))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.MARR_BANNS))
        s = util.comma_con(s,get_tex_event_by_type(fe,events.TYPE.DIV_FILING))
    else
        s=" \\grpsTkoppelde"
    end
    
    if bin_set(opt,OPTION.LONG) then
        s=util.is_empty(s,ss..s.." \\grpsTmet ",ss..s.." \\grpsTmet ")--..person.fulname(spouse_handle)..". ")
    else
        s=util.is_empty(s,"$\\times$",s)--..person.fulname(spouse_handle)..". ")
    end
    if #s>0 then print(s) end
    
end

function grps.print_children(fh,max_level,level,options)
    --print.i("children"..util.dump(options))
    if max_level>level then
        level = level + 1
        --dprint("fhandle :" .. fh)
        local children = family.get_children(fh)
        --print(util.dump(children))
        local sorted = person.sort_person_handles(children)
        if #children > 0 then
            print("\\begin{grampslist"..util.roman(level).."}")
            for j,ic in ipairs(sorted) do
                print("\\item["..j.."]")--..person.fulname(children[ic[1]]))
                local child = children[ic[1]]
                --
                local ref_nummer = person[child].kwartiernummer  or person[child].ancestornummer
                if  ref_nummer then
                    print.s("\\hyperlink{"..person[child].gramps_id.."}{")
                    print.s(person.fullname(children[ic[1]]).." ("..ref_nummer.."$\\rightarrow$}).")
                else
                    grps.print_person(children[ic[1]],max_level,level,options,OPTION.O_CHILDREN)
                end
            end
            print("\\end{grampslist"..util.roman(level).."}")
        end
    end
end

function grps.print_parents(ph,max_level,level,options)
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
            if bin_set(options[OPTION.O_PARENTS],OPTION.LONG) then
                print(ZoonDochter(p))
            else
                print.s("(")
            end
            if  f.father_handle then grps.print_person(f.father_handle,max_level,level,options,OPTION.O_PARENTS) end
            if  f.father_handle and f.mother_handle then
                if bin_set(options[OPTION.O_PARENTS],OPTION.LONG) then print.s(" \\grpsTen ") else print.s(" $\\times$ ") end
            end
            if f.mother_handle then grps.print_person(f.mother_handle,max_level,level,options,OPTION.O_PARENTS) end

            --dprint("parents 2 ",util.dump(options))
            if bin_set(options[OPTION.O_PARENTS],OPTION.LONG) then
                print(". ")
            else
                print(") ")
            end
        end
    end
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
    s = s.."}\n"
    return s
end


function grps.picture(id)
    local m = media(id)
    local handle=m.handle
    local label=m.gramps_id
    local titel= unescape(m.desc) or ""
    local x=200
    local y=200
    local persons = media.persons(handle)

    --print(util.dump(persons))
    --print(util.dump(m))

    local filename =media.path(handle)
        if file_exists(filename) then
        local process = io.popen("identify -format '%wx%h' "..filename)
        local result = process:read("*a")
        process:close()
        local longsize = 0.9*(grps.longsize or grps.gettextwidth())
        local x,y

        --eprint("Image dimensions: " .. result.." "..longsize.."cm")  -- Example output: "800x600"

        for lx, ly in string.gmatch(result,'(%d+)x(%d+)') do  x=lx; y=ly   end
        --print.i("Image "..m.path.." "..x.."X"..y)

        if x>y then
            longsize=longsize*0.7
        end
        y=(longsize*y)/x; x=longsize

       --print.i("Image "..m.path.." "..x.."X"..y)

        print('\\begin{Figure}\\vspace{-2ex}\\begin{center}%')
        print('\\begin{tikzpicture}[x=10mm,y=10mm]')
        print('\\node[inner sep=0pt] (PIC) {\\includegraphics[width='..x..'cm,height='..y..'cm]{'..filename..'}};')
    --tannr=ord('A')

        if #persons>0 then
            print('\\begin{scope}[ocg={ref=REC'..label..', status=invisible, name=ok}]')
            for i,t in ipairs(persons) do
                local tx = (t.x1*x)/100.0
                local ty = ((100-t.y1)*y)/100.0
                local tw = (t.x2*x)/100.0
                local th = ((100-t.y2)*y)/100.0
                print('\\draw[tagbox,shift=(PIC.south west)] ('..tx..','..ty..') rectangle ('..tw..','..th..');')
                if #persons>1 then
                    print('\\node[tagnumber] at ([shift=(PIC.south west)] '..(x*t.xm/100)..','..(y*(100-t.ym)/100)..') {'..i..'};')
                end
            end
        print("\\node at (0,0) {\\switchocg{REC"..label.."}{\\raisebox{0pt}["..x.."cm][0cm]{\\makebox["..y.."cm]{}}}};")
--\draw[tagbox,shift=(PIC.south west)] (3.2303155339806,2.1) rectangle (3.5795388349515,1.59);
--\node[color=blue] at ([shift=(PIC.south west)] 1,1)  {11111};

            print('\\end{scope}')
        end
        print('\\end{tikzpicture}')
        print('\\vspace{-3.5ex}\\\\%%')
        --print('\\captionof{figure}{'..titel..'}\\label{fig:'..label..'}%')
        print('\\textbf{'..titel..'\\label{fig:'..label..'}}%')
        --print('\\vspace{-1ex}')
        if #persons>0 then
            --print(' [\\switchocg{REC'..label..'}{TAGS}]\\\\%')
            local s=""
            for i=1,#persons do

--    for i,v in ipairs(persons) do
--        print(i,util.dump(persons[i]),persons[i].handle)
            s=s.."\\hyperlink{"..person[persons[i].handle].gramps_id.."}{("..i..") "..unescape(person.fullname(persons[i].handle)).."}"
                if i < #persons  then
                    if 1 == #persons-1 then s=s.." and " else s=s..", " end
                end
            end
            print('{\\small'..s..'}')
        end
        print('\\end{center}\\end{Figure}%')
    else
        print.e("File "..m.path.." not found!")
    end

end

function hijzij(p)
    if p.gender==1 then return "\\grpsTHij "
    else return "\\grpsTZij " end
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
    grps.long_print_person('I0692')
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

