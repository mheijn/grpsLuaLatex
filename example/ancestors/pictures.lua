local Picture = {}
local print = require("mh.print")
local _ = require("mh.gettext")


local fig_nr=0
local figures_shown ={}

function gettextwidth()
    local points = 469*65536
    if tex and tex.dimen then
        points = tex.dimen.columnwidth or tex.dimen.textwidth
    end
    return points/1857713.386
end

local function rectangles(m,x,y)
    local s = ""
    local med_pers = m:persons()
    
    if 0==#med_pers then return s end 
    
    s=s..'\\begin{scope}[ocg={ref=REC'..m.gramps_id..', status=invisible, name=ok}]'
    for i,t in ipairs(med_pers) do
        local tx = (t.x1*x)/100.0
        local ty = ((100-t.y1)*y)/100.0
        local tw = (t.x2*x)/100.0
        local th = ((100-t.y2)*y)/100.0
        s=s..'\\draw[tagbox,shift=(PIC.south west)] ('..tx..','..ty..') rectangle ('..tw..','..th..');'
        if #med_pers > 1 then
            s=s..'\\node[tagnumber] at ([shift=(PIC.south west)] '..(x*t.xm/100)..','..(y*(100-t.ym)/100)..') {'..i..'};'
        end
    end
    s=s.."\\node at (0,0) {\\switchocg{REC"..m.gramps_id.."}{\\raisebox{0pt}["..x.."mm][0mm]{\\makebox["..y.."mm]{}}}};"..
                '\\end{scope}'

    return s
end


local function legenda(m)
    local s = ""
    local med_pers = m:persons()
    for i,pers_ref in ipairs(med_pers) do
        local pers = gramps.Person(pers_ref.handle)
        
        local sp="\\hyperlink{"..pers.gramps_id.."}{("..i..")\\ "..pers:fullname().."}"
        if i < #med_pers  then
            if i == #med_pers-1 then sp=sp.._(" and ") else sp=sp..", " end
        end
        s=s..'{\\small'..sp..'}'
    end
    return s
end

function Picture.image(h,embed)
    
    embed = (embed==nil) or embed
    
    for  i,ph in ipairs(figures_shown) do if ph==h then return "",i end end 
    table.insert(figures_shown,h)
    
	local x,y, longsize
	local textwidth = 10*gettextwidth()
	if textwidth > 100 then 
        longsize = 0.45*textwidth else  longsize = 0.9*textwidth end
        
	media = gramps.Media(h)
	
	fig_nr=fig_nr+1

	local label=media.gramps_id
    local titel= _.T(media.desc) or ""
    local datum = media.date:long()
	if 0<#datum then titel = titel .." ("..datum..")" end
	local caption = "Fig. "..fig_nr..".\\label{fig:"..label..'} '..titel

	local filename = media:getPath()

	local file = io.open(filename, "r")
    if file then file:close()
    else print.e(string.format("Media file (%s) could not be found",filename)) return end

	local process = io.popen("identify -format '%wx%h' "..filename)
	local result = process:read("*a")
	process:close()
    
    --local longsize = 0.9*(grps.longsize or grps.gettextwidth())
    
	--for lx, ly in string.gmatch(result,'(%d+)x(%d+)') do  x=lx; y=ly   end
	x, y  = result:match('(%d+)x(%d+)')
	--print(x,y)

	if x<y then y=longsize*y/x; x=longsize
	else x=longsize*x/y;y=longsize end
	
	local s=""
	if embed then 
        s ='\\begin{Figure}\\vspace{-2ex}\\begin{center}\n'
    end
    s=s..'\\begin{tikzpicture}[x=1mm,y=1mm]\n'..
        "\\addcontentsline{lof}{figure}{Figure "..fig_nr..".  "..titel.."}\n"..
		'\\node[inner sep=0pt] (PIC) {\\includegraphics[width='..
            x..'mm,height='..y..'mm]{'..filename..'}};\n'
	
	s=s.."\\node (T) at (0,"..(y*0.5-12)..") {};\n"
	s=s..'\\node[above=of T, align=center, text width='..longsize..'mm]  {'..caption..'};\n'
	
    s=s.."\\node (B) at (0,"..(-y*0.5 +11)..") {};"
    s=s.."\\node[below=of B, align=center, text width="..longsize.."mm]  {"
--0.9*grps.gettextwidth()
	s=s..legenda(media)
	s=s.."};\n" 
	
	s=s..rectangles(media,x,y)
	
	s=s..'\\end{tikzpicture}\n'
	if embed then
        s=s..'\\end{center}\\end{Figure}'
	end
	return s,fig_nr
end


if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	require("gramps")
	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
--	gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/67460b08/sqlite.db")
    local id = "O0710"
	print(Picture.image(id))
else
	return Picture
end



