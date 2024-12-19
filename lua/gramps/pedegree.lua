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
--
-- Setting up ancestor numbering

local function fill_kwartierstaat_index(id,i,maxgen,gen)
    print.i("id="..id.." - "..i)

    local p=person(id)

    --io.write(p.gramps_id.." "..person.fulname(p.handle).."\n")

    kwartierstaat_index[i]=p.handle
    person[p.handle].kwartiernummer = i

    if gen<=maxgen then
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

function grps.set(id,max_gen)
    kwartierstaat_index={}
    --io.write("init "..id.." "..max_gen)
    local max_gen = max_gen or 3
    grps.central_id=id
    fill_kwartierstaat_index(id,1,max_gen,1)
end

if not string.split then
function string:split(delimiter)
    if not delimiter or delimiter == "" then
        return {self} -- If no delimiter is given, return the whole string
    end
    local result = {}

    for match in (self .. delimiter):gmatch("([^..delimiter..*])" .. delimiter) do
        table.insert(result, match)
    end
    return result
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

function grps.get(ind)
    local t=0
    local i
    for i,h in pairs(kwartierstaat_index) do
        t=t+1
        if i == ind then return h, (#kwartierstaat_index-t) end 
        if i > ind then return "",(#kwartierstaat_index-t+1) end
    end
    return "", -1
end

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
    --print("kwartierstaat name: ",person.firstname(p.handle))
    s=s..tprt.tree_person(p.handle)

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
else
    grps.long_print_person = tprt.long_print_person
    grps.short_print_person = tprt.short_print_person
    return(grps)
end

