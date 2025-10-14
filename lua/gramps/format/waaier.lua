local wi = {}
local grps = gramps or require("gramps")
_ = _ or require("mh.gettext")

function gramps.Event:treedate()
    s=""
    if type(self.date) == "table" and self.date.dateval  then
        if self.date.modifier> 2 or self.date.quality>0 then
            s="(caAD)"
        end
        if self.date.dateval[3] > 0 then s=s..self.date.dateval[3] end
        if self.date.dateval[2] > 0 then s=s.."-"..string.format("%02d",self.date.dateval[2]) end
        if self.date.dateval[1] > 0 then s=s.."-"..string.format("%02d",self.date.dateval[1]) end

        if self.date.modifier == 1 then s="/"..s end
        if self.date.modifier == 2 then s=s.."/" end
    end
    return s
end

function wi.set_voorouder_trees(voorouders,generations,tree_size)
    local trees={{0,0,0,0}}
    for g=1,generations,tree_size-1 do
        local notfirst=false
        if voorouders[g] then for k= 2^(g-1),2^(g)-1 do
            local h = voorouders[g][k]
            if h then
                trees[#trees][1]=k
                trees[#trees][2]=h
                if notfirst then
                    trees[#trees-1][4]=k
                else
                    trees[#trees][3]=0
                end
                notfirst=true
                table.insert(trees,{0,0,k,0})
            end
        end end
        --for i,v in ipairs(trees) do
        --    if v[2] ~= 0 then
        --        tree(v[2],treesize,p.gramps_id,v[1],v[3],v[4])
        --    end
        --end
    end
    return trees
end

local function tree_person(h,fun,kekule)
    local fun = fun or 'g'
    local s=""
    local p=gramps.Person(h)

    s = fun.."[id="..p.gramps_id..']{\n'
    if p.gender==1 then s=s.."male,\n" else s=s.."female,\n" end
--    s=s.."name = {\\hyperlink{p.gramps_id}{\\pref{"..p:firstname().."} \\surn{"..p:surname().."}}},\n"
    s=s.."name = {\\pref{"..p:firstname().."} \\surn{"..p:surname().."}},\n"

    local bi,ba,de,bu
    --bi,ba,de,bu = p:Life()

    if bi then s=s.. "birth = "  .."{"..bi:treedate().."}{".._.T(bi:plaats()).."},\n" end
    if ba then s=s.. "baptism = ".."{"..ba:treedate().."}{".._.T(ba:plaats()).."},\n" end
    if de then s=s.. "death = "  .."{"..de:treedate().."}{".._.T(de:plaats()).."},\n" end
    if bu then s=s.. "burial = " .."{"..bu:treedate().."}{".._.T(bu:plaats()).."},\n" end

    s=s..string.format("kekule = %d,\n",kekule)
    s = s.."}\n"
    return s
end

local function ancestor_tree_data(h,maxgen,keku,gen,kekule,links)
    local kekule = kekule or keku
    local gen=gen or 1
    local links = links or {}
    local s="parent{\n"
    local p=gramps.Person(h)

    if gen==1 then if p:hasChildren()  then table.insert(links,{gramps.Person(h).gramps_id,math.floor(keku/(2^(maxgen-1)))})
        else table.insert(links,{"",0}) end end
    if gen==maxgen and p:hasParents()  then table.insert(links,{p.gramps_id,kekule}) end

    s=s..tree_person(p.handle,'g',kekule)

    if gen<maxgen then
        for i,fh in pairs(p.parent_family_list) do
			local f=gramps.Family(fh)
			if f.father_handle  then
				s = s .. ancestor_tree_data(f.father_handle,maxgen,keku, gen+1,kekule*2,links)
			end
			if f.mother_handle  then
				s = s .. ancestor_tree_data(f.mother_handle,maxgen,keku, gen+1,kekule*2+1,links)
			end
		end
    end
    s=s.."}"
    return s
end


function wi.tree(ph,depth,treebase,keku,left_id,right_id)
    if ph==0 then return end
    p=gramps.Person(ph)
    if treebase == nil then treebase = p.gramps_id end
    if keku == nil then keku = 1 end
    if left_id == nil then left_id=0 end 
    if right_id == nil then right_id=0 end 
    

    --/gtr/name font = {\gtrifmale{\selectfont\color{blue!50!black}}{\selectfont\color{red!50!black}}},
    print("\\begin{center}")
    --print("\\makeatletter \\def\\gtrkv@treeprefix{}\\def\\gtrkv@treesuffix{}")
    --print("\\tikzset{")
	--print("/gtr/id/.code={"..
	--	"\\xdef\\GtrGkvIdLink{#1}"..
    --    "\\xdef\\gtr@gkv@id{\\expandonce\\gtrkv@idprefix\\unexpanded{#1}\\expandonce\\gtrkv@idsuffix}},")
    --print("/gtr/name code = {\\hyperlink{\\GtrGkvIdLink}{\\gtrPrintName@full (\\gtrDBkekule)}}, ")
    --print("/gtr/name code = {\\GtrGkvIdLink}{\\gtrPrintName@full (\\gtrDBkekule)}, ")
    --print("}")
    --print("\\makeatother")

    print(string.format("\\hypertarget{TREE%d%s}{}\\begin{tikzpicture}",keku,treebase))
    --print(string.format("\\begin{tikzpicture}"))
    print("\\makeatletter \\def\\gtrkv@treeprefix{}\\def\\gtrkv@treesuffix{}")
    print("\\tikzset{")
	print("/gtr/id/.code={"..
		"\\xdef\\GtrGkvIdLink{#1}"..
        "\\xdef\\gtr@gkv@id{\\expandonce\\gtrkv@idprefix\\unexpanded{#1}\\expandonce\\gtrkv@idsuffix}},")
    print("/gtr/name code = {\\hyperlink{\\GtrGkvIdLink}{\\gtrPrintName@full (\\gtrDBkekule)}}, ")
    print("}")
    print("\\makeatother")

    print(string.format("\\node[] (TREEBASE"..p.gramps_id..") at (0,0) {};"))-- {\\hypertarget{TREE%d%s}{  }};",keku,treebase))
    --print(string.format("\\node[]  at (-4,0) {\\hypertarget{LTREE%d%s}{ TREE%d%s }};",keku,treebase,keku,treebase))

    print(string.format(
        "\\genealogytree[ "..
        "template = database traditional, "..
        "set position = %s%s at TREEBASE%s, "..
        "id prefix = %s, "..
        "date format=yyyy, "..
        "list separators={\\par}{ }{}{}, "..
        "level size=1.2cm, "..
        "node size= 1.8cm, "..
        "name font= \\gtrifmale{\\selectfont\\color{blue!50!black}}{\\selectfont\\color{red!50!black}}, "..
        --"name code  = {\\hyperlink{\\GtrGkvIdLink}{\\gtrPrintName@full (\\gtrDBkekule)}}, "..
       "] { "
        ,p.gramps_id, p.gramps_id, treebase, p.gramps_id
        ))

    local links = {}
    print(ancestor_tree_data(ph,depth,keku,1,keku,links))
    print("}")
    if 0<left_id then
            print(string.format("\\node [] (a) at (%s%s.west) {\\hyperlink{TREE%d%s}{$\\leftarrow$}};",
                p.gramps_id,p.gramps_id,left_id,treebase,left_id))
    end
    if 0<right_id then
            print(string.format("\\node [] (b) at (%s%s.east) {\\hyperlink{TREE%d%s}{$\\rightarrow$}};",
                p.gramps_id,p.gramps_id,right_id,treebase,right_id))
    end
    for i,l in ipairs(links) do
        if i==1 then if 0<l[2] then
            print(string.format("\\node [] (c) at (%s%s.south) {\\hyperlink{TREE%d%s}{$\\downarrow$}};",
                p.gramps_id,p.gramps_id   ,l[2],treebase,l[2]))
            end
        else
            print(string.format("\\node [] (c%d) at (%s%s.north) {\\hyperlink{TREE%d%s}{$\\uparrow$}};",
                i,p.gramps_id,l[1],l[2],treebase,l[2]))
        end
    end
    print("\\end{tikzpicture}")
    print("\\end{center}")
    --for i,h in ipairs(links) do print(i,h) end
end

local basepunt_stop=90
local basepunt_start=-90

local function make_punt(gen,pl,p)
--if gen>6 then return end
    local total_pl = 2^(gen-1)
    local place = pl-total_pl

    local basepunt = basepunt_stop-basepunt_start
    local arc_step=basepunt/total_pl
    local ang1=-basepunt_start+place*arc_step
    local ang2=ang1+arc_step
    local angc=0.5*(ang1+ang2)
    local angt=angc-90

    local r={10,10}
    local rt =20

    if gen > 2 then  for i=3,gen do
        local pow =rt*math.pi/(2^(i-1))
        --print(pow)
        if pow > 10 then
            r[i]=r[i-1]*0.7
        else
            r[i]=pow*2.0
        end
        rt=rt+r[i]
    end end

--for i=1,gen do print(r[i]) end

    local r1=0; for i=2,gen do r1=r1+r[i-1] end
    local r2=r1+r[gen]

    local rc = 0.5*(r1+r2)
    local lc = math.pi*rc*arc_step/180

    local fontsize=lc/12
    if fontsize <0.1 then fontsize=0.1 end

    local color
    if (pl & 1)==1 then color="red" else color="blue" end
    color=color.."!"..(100-2*gen).."!green!"..math.ceil((30*(place+1)/total_pl))

    --local txt = string.format("\\hyperlink{%s}{\\parbox{%.2f mm}{\\centering %s}}",p.gramps_id,lc,p:fullname())
    local txt = string.format("\\centering\\hyperlink{%s}{%s}",p.gramps_id,p:fullname())

	print(string.format("\\filldraw[fill=%s] (%.2f:%.2fmm) arc (%.2f:%.2f:%.2fmm) -- (%.2f:%.2fmm) arc (%.2f:%.2f:%.2fmm) --cycle;",
            color,ang1,r1,ang1,ang2,r1,ang2,r2,ang2,ang1,r2))

    if rc*math.pi*arc_step/180 > (r2-r1) then
        print(string.format("\\node[] at (%f: %fmm) {\\rotatebox{%f}{"..
            "\\fontsize{%.2fmm}{%.2fmm}\\selectfont"..
            "\\parbox{%f mm}{%s}}};",
            angc,rc,angt,fontsize,fontsize*1.1,lc,txt))
    else
        angt=angc
        fontsize = (r2-r1)/10; if fontsize<0.1 then fontsize=0.1 end
        scale = (r2-r1)/40
        --print(string.format("\\node[] at (%f: %fmm) {\\rotatebox{%f}{"..
        --    "\\fontsize{%.2fmm}{%.2fmm}\\selectfont"..
        --    "\\parbox{%f mm}{%s}}};",
        --    rc,angt,fontsize,fontsize*1.1,lc,txt))
        print(string.format("\\node[] at (%f: %fmm) {\\rotatebox{%f}{"..
            "\\parbox{%f mm}{\\scalebox{%f}{\\parbox{%f mm}{%s}}}}};",
            angc,rc,angt,lc,scale,(lc/scale),txt))
    end

end
--\node at (244.687500:48.788721mm) {\rotatebox{244.687500}{\parbox{4.789821mm}{\scalebox{0.4}{Dina Siemons}}}};

function wi.waaier(generations)
    print("\\begin{tikzpicture}[scale=2, transform shape]")

    for i, gen in ipairs(generations) do
        for k, h in pairs(gen) do
            local gn = 2^(i-1)
            local an = 180/gn
            local co = "blue"
            if (k & 1)== 1 then co="red" end
            local tr = 30-2*i
            p=gramps.Person(h)

            make_punt(i,k,p)
            --print(string.format("\\punt{%d}{%d}{%f}{%f}{%s!%d}{%s}{%s};",
            --    (i-1)*10,i*10, (k-gn)*an ,(k-gn+1)*an, co,tr,name,id))
        end
    end
    print("\\end{tikzpicture}")
end



if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	loc = require("mh.local")
	loc.setlanguage('nl')

	require("gramps")

	--util = require("gramps.util")
	--tex={print=print}
	local print = require("mh.print")
	anc = require("ancestors")
	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
	--gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
	loc.setlanguage('nl')
    print(loc.language())
	--local voorouders =anc.ancestors('I2604',5)
    --waaier(voorouders)
    --print(tree_person('I2604',nil,1))
    --print(ancestor_tree_data('I2604',3,1,1,1,{}))

    --local p=gramps.Person('I1119')

    tree('I1119',3,gramps.Person('I1119').gramps_id,1)
else
    return wi
end
