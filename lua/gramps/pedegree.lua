local grps = grps or {}

local util=require("gramps.util")
local person=require("gramps.person")
local ev=require("gramps.events")
local family=require("gramps.family")
local util  =require("gramps.util")
local tprt=require("gramps.grpstex")
local query=require("gramps.queries")

local print = require("gramps.output")

grps.do_children = true
grps.do_spouse = true
grps.do_parents = true

function grps.Cfulname(idx)
    return person.fulname(kwartierstaat_index[idx])
end

function grps.Cfirstname(idx)
    return person.firstname(kwartierstaat_index[idx])
end

function grps.setdatabase(db)
    query.init(db)
end

-----------------------------------------------------------------
---    kwartierstaat
-----------------------------------------------------------------
grps.central_id =""
kwartierstaat_index={}
descendence_index={}
generation_size={}

-- Setting up ancestor numbering

local function fill_kwartierstaat_index(id,i,maxgen,gen)
    print.i("id="..id.." - "..i)

    local p=person(id)

    --io.write(p.gramps_id.." ("..i.." "..maxgen.." "..gen..")  "..person.fullname(p.handle).."\n")

    kwartierstaat_index[i]=p.gramps_id
    person[p.handle].kwartiernummer = i

    if gen<maxgen then
        local parents = person.parents(p.handle)
        for j, fid in ipairs(parents) do
            if family[fid].father_handle ~= nil then
                fill_kwartierstaat_index(family[fid].father_handle,i*2,maxgen,gen+1)
            end
            if family[fid].mother_handle ~= nil then
                fill_kwartierstaat_index(family[fid].mother_handle,i*2+1,maxgen,gen+1)
            end
        end
    end
    return p.handle
end

--- Set kekule for id
-- @param id
-- @param max_gen set kekule for max_gen
function grps.set(id,max_gen)
    kwartierstaat_index={}
    --io.write("init "..id.." "..max_gen)
    local max_gen = max_gen or 3
    grps.central_id=id
    fill_kwartierstaat_index(id,1,max_gen,1)
end

--- get gramps\_id from kwartierstaat_index by kekule
-- @param k kakule
-- @return gramps\_id
function grps.kekule_id(k) return kwartierstaat_index[k] end

--- get following kekule
function grps.next_kekule(k)
    return table.next(kwartierstaat_index,k)
end

local kwrt_tree_entrences

---
-- @param id person id
-- @param max_gen set kekule for max_gen
-- @param piece splitup ancestor tree in pieces of piece generations
-- @return array of ids that start suntrees
function grps.set_ancestor_tree(id,maxgen,piece)
    local piece = piece or 3
    kwrt_tree_entrences={}

    grps.set(id,maxgen)
    for i=1,maxgen-1,piece-1 do
        for j=2^(i-1),2^(i)-1 do
        -- io.write(piece.." "..i.. " - " ..j.."\n")
            if kwartierstaat_index[j] then
                table.insert(kwrt_tree_entrences,kwartierstaat_index[j])
            end
        end
    end
    return(kwrt_tree_entrences)
end

function _skp_parents(entries,nr,g)
    if kwartierstaat_index[nr] then table.insert(entries,nr) end
    if g>1 then
        _skp_parents(entries,nr*2,g-1)
        _skp_parents(entries,nr*2+1,g-1)
    end
    --io.write(string.format("nr %d  entries %d\n",nr,#entries))
end

function grps.set_kwartier_pieces(kwrt_entrences,piece)
    local piece = piece or 3

    local kwrt_pieces={}

    for i,id in ipairs(kwrt_entrences) do
        local kw =person(id).kwartiernummer
        kwrt_pieces[i]={}
        _skp_parents(kwrt_pieces[i],kw,piece)
        table.sort(kwrt_pieces[i])
--        for j,k in ipairs(kwrt_pieces[i]) do   io.write(string.format("%d [%d] %d\n",i,j,k)) end
    end

    return kwrt_pieces
end

----------------------------------------------------------------
---    descendence
-----------------------------------------------------------------
local function fill_descendence_index(id,op,gen)
    if  op.childless or person.has_children(id) then
        if generation_size[gen] then
            generation_size[gen] =  generation_size[gen] +1
        else
            generation_size[gen] =1
        end

        local p=person(id)

        local indexer=""
        if op.pergen then
            indexer = (gen-1)*100 + generation_size[gen]
        else
            for i=1,gen do
                if #indexer==0 then
                    indexer=""..generation_size[i]
                else
                    indexer = indexer.."."..generation_size[i]
                end
            end
        end

        table.insert(descendence_index,{indexer,p.handle,p.gramps_id})
        person[p.handle].ancestornummer = util.Roman(gen)..util.alphanumber(generation_size[gen])

        print.i("id="..id.." - ("..person[p.handle].ancestornummer..") "..indexer)

        if gen < op.maxgen then
            local spouses = person.spouses(p.handle)
            for i, fid in ipairs(spouses) do

                local children = family.get_children(fid)
                    --print(util.dump(children))
                local sorted = person.sort_person_handles(children)

                for j,ic in ipairs(sorted) do
                        fill_descendence_index(children[ic[1]],op,gen+1)
                end
            end
        end
    end
end

local function sort_func(a,b)
    local na=string.split(a[1],".")
    local nb=string.split(b[1],".")

    io.write("na ") for i,v in ipairs(na) do io.write(v..", ") end print("")
    io.write("nb ") for i,v in ipairs(nb) do io.write(v..", ") end print("")

    for i,v in ipairs(na) do
        if nb[i] then
            if v < nb[i] then return true end
        else -- a langer dan b
            return false
        end
    end
    return  (#na > #nb)
end

function grps.set_descendence(id,max_gen,pergen,childless)
    descendence_index ={}

    local include_childless = childless or false
    local pergen = (pergen==nil) or pergen --per generation (TRUE) or per branche
    local max_gen =max_gen or 3

    grps.central_id=id

    fill_descendence_index(id,{maxgen=max_gen,childless=include_childless,pergen=pergen},1)

    if pergen then
        table.sort(descendence_index,function(a,b) return a[1]<b[1] end)
    else
        --table.sort(descendence_index,sort_func)
    end
end

-- get gramps-handle from ancestor number

--function grps.get(ind)
--    local t=0
--    local i
--    for i,h in pairs(kwartierstaat_index) do
--        t=t+1
--        if i == ind then return h, (#kwartierstaat_index-t) end
--        if i > ind then return "",(#kwartierstaat_index-t+1) end
--    end
--    return "", -1
--end

function grps.get_descendent(ind)
    if descendence_index[ind] then
        local index = descendence_index[ind]

        if type(index[1])=="string" then
            gens = string.split(index[1],".")
            --print.i(index[1].." "..#gens )
            return({#gens,index[2],index[1],index[3]})
        else
            local gen = 1 + math.floor(descendence_index[ind][1]/100)
            return( {gen, index[2], person[index[2]].ancestornummer,index[3]} )
        end
    else
        return{1000,"","",""}
    end
end

--  Preparing data for Genealytree.sty

function grps.descendent_tree_data(id,maxgen,gen)

    local gen=gen or 1
    local p=person(id)
    local link=""
    local s="child{"

    if p == nil then
        s = s .. "g[]{name=UN}}"
        return s
    end
    io.write("\nHandle"..p.handle.."\n")

    if gen==1 and person.has_parents(p.handle) then
        link=",hasparents" end
    if gen==maxgen and person.has_children(p.handle) then
        link=",haschildren" end

    s=s..tprt.tree_person(p.handle,'g',link)

    --s=s..tp.tree_person(p.handle,'p')
    if gen<maxgen then
        local spouses = person.spouses(p.handle)
        for i, fid in ipairs(spouses) do
            s=s .."union"
            local children = family.get_children(fid)
            if #children > 0 then
                s=s.."{" else s=s.."[childless]{" end

            if family[fid].father_handle==p.handle then
                s=s..tprt.tree_person(family[fid].mother_handle,'p')
            else
                s=s..tprt.tree_person(family[fid].father_handle,'p')
            end

            local children = family.get_children(fid)
            --print(util.dump(children))
            local sorted = person.sort_person_handles(children)

            for j,ic in ipairs(sorted) do
                s=s..grps.descendent_tree_data(children[ic[1]],maxgen,gen+1)
            end
            s=s.."}"
        end
    end
    s=s.."}\n"
    return s
end

function grps.ancestor_tree_data(id,maxgen,gen)
    local gen=gen or 1
    local s="parent{\n"
    local p=person(id)
    local link = ""

    if p.kwartiernummer == nil or kwartierstaat_index[p.kwartiernummer] == nil then return "" end

    --io.write("kwartier nr "..maxgen.." "..gen.." " ..person.fullname(p.handle).."\n")
    if gen==maxgen then
        if (kwartierstaat_index[p.kwartiernummer*2] or kwartierstaat_index[p.kwartiernummer*2+1]) then
            --io.write(string.format(" %d %s  %s\n",  p.kwartiernummer*2,kwartierstaat_index[p.kwartiernummer*2],p.gramps_id))
                link = link..",hasparents, parenttree="..p.gramps_id
        end
    end
    if gen==1 then
        link=link ..",thistree="..p.gramps_id

        local priv    = table.priv(kwartierstaat_index,p.kwartiernummer)
        local next    = table.next(kwartierstaat_index,p.kwartiernummer)
        local act_gen = 1 + math.floor(math.log(p.kwartiernummer,2))

        if next and next < math.pow(2,act_gen) then
            link=link..",righttree="..kwartierstaat_index[next]
        end
        if priv and priv >= math.pow(2,act_gen-1) then
            link=link..",lefttree="..kwartierstaat_index[priv]
        end

        if person.has_children(p.handle)  and kwartierstaat_index[math.floor(p.kwartiernummer/2)] then
            --io.write(string.format("%d -> %d ",p.kwartiernummer,(2^(maxgen-1))))
            local pid = math.floor(p.kwartiernummer/(2^(maxgen-1)))
            childtree = kwartierstaat_index[pid]
            --io.write(string.format("pid=%d cid=%s id=%s\n",pid,childtree,p.gramps_id))
            link=link .. ",haschildren, childtree="..childtree
        end
    end
    --print("kwartierstaat name: ",person.firstname(p.handle))
    s=s..tprt.tree_person(p.handle,'g',link)

    if gen<maxgen then
        local parents = person.parents(p.handle)
        --print("kwartierstaat parents: ",util.dump(parents))
        for i, fid in ipairs(parents) do
            --print(family[fid].father_handle,family[fid].mother_handle)
            if family[fid].father_handle ~= nil then
                s=s..grps.ancestor_tree_data(family[fid].father_handle,maxgen,gen+1)
            end
            if family[fid].mother_handle ~= nil then
                s=s..grps.ancestor_tree_data(family[fid].mother_handle,maxgen,gen+1)
            end
        end
    end
    s=s.."}\n"
    return s
end

query.close()
if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    query.init('/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db')
    --grps.long_print_person = tp.long_print_person
    --pass:
    --print(print_person('I0689'))
    --print("kwartirstaat I2604:\n",grps.kwartierstaat('I2604',5))
    --grps.set('I2604',3)
    --\Kwartierstaat[gen=4,depth=3]{I0876}

    --print(grps.ancestor_tree_data('I0565',3))
    --print(grps.descendent_tree_data('I2483',3))
    --print(grps.ancestor_tree_data('I1998',3))
    --print(grps.descendent_tree_data('I1998',3))

    grps.set_descendence('I7141',10,false)
    for i=1,#descendence_index do
        v=grps.get_descendent(i)
        print.i(i,v[1],v[2],v[3],v[4])
    end
    local s1="1.1.1.1"
    local s2="1.1"
    print(s1.." - " ..s2) if(sort_func({s1},{s2})) then print("true") else print("false") end
    --d=grps.get_descendent(3)
    --print(d[1],d[2],d[3])
    --grps.set('I0876',2)
    --for i,h in pairs(kwartierstaat_index) do
    --    tp.short_print_person(h,3)
    --end
    --print(grps.ancestor_tree_data('I0689',6))
    grps.set_ancestor_tree('I2604',3,4)
    for i,h in ipairs(kwrt_tree_entrences) do
        print(string.format("%d - %s",i,person.fullname(h)))
    end
else
    return(grps)
end

