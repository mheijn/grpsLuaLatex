local pickle=require('gramps.pickle')
local util=require("gramps.util")
DEBUG = 3
local print=require("mh.print")
local q={}

local TheDataBase="sqlite.db"

-----------------------------------
-- database setup
-----------------------------------
local driver = require('luasql.sqlite3')
local env = nil
local db = nil

function q.init(database)
    q.close()
    q.database = database or TheDataBase

    --print("\ndatabase: ",q.database,db)

    env = assert(driver.sqlite3(),"problem in sqlite3 copling")
    db = assert(env:connect(q.database),"No conection to "..q.database)

    --[[print(type(db))
    local r= q.get_person_from_id("I0018")
    print(r[1].given_name)
    local r= q.get_person_from_id("I7141")
    if r[1] then print(r[1].given_name) end
    ]]--
end

function q:close()
    if db ~= nil then
        db:close()
        env:close()
    end
    db=nil
end

-----------------------------------
--
-----------------------------------

local index_person_handle_ref = {
    events=8,
    child_family=9,
    parent_family=10,
    media=11}

-----------------------------------
--
-----------------------------------

local function Where(column,handles)
    local where = ""

    if handles ~= nil and #handles > 0 then
        if #where>0 then where=where.." AND " end
        where = column.." IN ("
        if type(handles)=='table' then
        --print("query ",util.dump(handles))
            for n,i in ipairs(handles) do
                if n>1 then where=where.."," end
                where = where ..'"'..i..'"'
            end
        else
            where = where..'"'..handles..'"'
        end
        where=where..")"
    end
    if #where>0 then where = " WHERE "..where end
    return where
end

local function proces_query(query,blob)

    local data={}
    local chunk = 100
    --print(query)

    if db==nil then q.init() end

    for offset = 0,20099,chunk do
        local limit=" LIMIT "..tostring(chunk).." OFFSET "..tostring(offset)
        print.d(query..limit)

        local results,err = db:execute(query..limit)
        if not results then
            print.e("Error:", err, '"'..query..'"')
            return(data)
        end

        local blobs={}
        row = results:fetch({},"a")
        local tel=0
        while row do
            tel=tel+1
            -- save blob_data
            if blob and row['blob_data'] then
            ----------
                row['blob_data']=pickle.depickle(row['blob_data'])
            ----------
                --print(row['blob_data'])
                --table.insert(blobs,row['blob_data'])
            else
                row['blob_data']=nil
            end
            table.insert(data, table.copy( row))
            --table.insert(data,  row)
            row = results:fetch(row,"a")
        end
        results:close()
--[[
        if blob then -- depicle blob_data
            for i,b in ipairs(blobdepicle(blobs))do
                --print(offset+i)
                --print(util.dump(b))

                data[offset+i]['blob_data']=b
            end
        end
]]--
        if tel<chunk then break end
    end -- of LIMIT a OFFSET b
    return(data)
end

q.ORDER_BY_NAME = true

local function Order(tab)
    local order=""
    if q.ORDER_BY_NAME then
        if tab=="person" then order=" ORDER BY person.surname ASC, person.given_name ASC" end
    end
    return order
end

function q.get_person_from_id(gramps_id,blob)
    if blob==nil then blob=true end
    return(proces_query("SELECT * FROM person"..Where("gramps_id",gramps_id)..Order("person"),blob))
end

function q.get_person_from_handle(handle,blob)
    if blob==nil then blob=true end
    return(proces_query("SELECT * FROM person"..Where("handle",handle),blob))
end

function q.get_from_handle(table,handle,blob)
    if blob==nil then blob=true end
    return proces_query("SELECT * FROM "..table..Where("handle",handle),blob)
end

function q.get_events_from_handle(handle,blob)
    if blob==nil then blob=true end
    local q="SELECT event.*, reference.obj_handle AS obj_handle FROM event LEFT JOIN reference ON reference.ref_handle=event.handle"
    if handle then q=q.." WHERE reference.obj_handle='"..handle.."'" end
    return(proces_query(q,blob))
end

function q.get_person_handle_from_id(gramps_id)
    res=proces_query("SELECT handle FROM person WHERE gramps_id='"..gramps_id.."'")
    if res[1] then return res[1].handle else return nil end
end

function q.get_handle_from_id(gramps_id)
    local fc=string.sub(gramps_id,1,1)
    local table
    if fc=='I' then table='person'
    elseif fc=='C' then table='citation'
    elseif fc=='F' then table='family'
    elseif fc=='O' then table='media'
    elseif fc=='E' then table='event'
    elseif fc=='N' then table='note'
    elseif fc=='S' then table='source'
    elseif fc=='R' then table='repository'
    elseif fc=='P' then table='place'
    end
    res=proces_query("SELECT handle FROM "..table.." WHERE gramps_id='"..gramps_id.."'")
    if 0==#res then 
        print.e(string.format("The id %s is not found in sql-database \"%s\"",gramps_id,q.database)) return nil
    else return res[1].handle end
end

function q.get_events_from_persons(blob)
    if blob==nil then blob=true end
    return(proces_query("SELECT event.*,reference.obj_handle AS person_handle FROM event LEFT JOIN reference ON reference.ref_handle=event.handle WHERE reference.obj_class='Person' AND reference.ref_class='Event'",blob))
end

function q.get_family_handle_from_id(gramps_id)
    res=proces_query("SELECT handle FROM family WHERE gramps_id='"..gramps_id.."'")
    return res[1].handle
end

function q.get_place_from_handle(handle)
    local res=proces_query("SELECT title, enclosed_by FROM place "..Where('handle',handle))
    return res
end

function q.get_family_from_handle(handle)
    local res=proces_query("SELECT * FROM family "..Where('handle',handle))
    local link
    if handle==nil then
        link =proces_query("SELECT * FROM reference WHERE obj_class='Family'")
    end
    return res ,link
end

function q.get_person_family(handle)
    local res=proces_query("SELECT family.* FROM family LEFT JOIN reference ON family.handle=reference.ref_handle "..
            "WHERE reference.obj_handle='"..handle.."' and reference.ref_class='Family'")
    return res
end

function q.get_persons_from_family(fhandle)
    local children={}
    local res=proces_query("SELECT person.handle FROM person LEFT JOIN reference ON person.handle=reference.obj_handle "..
            "WHERE reference.ref_handle = '"..fhandle.."' and reference.ref_class='Family'")

    for i,p in ipairs(res) do
        table.insert(children,p.handle)
    end
    return children
end

-- Media
function q.get_media_handle_from_id(gramps_id)
    res=proces_query("SELECT handle FROM media WHERE gramps_id='"..gramps_id.."'")
    return res[1].handle
end

function q.get_media_from_handle(handle,blob)
    local res=proces_query("SELECT * FROM media "..Where('handle',handle),blob)
    return res
end

function q.get_person_from_media(handle)
    local ret={}
    local refs = proces_query("SELECT obj_handle FROM reference WHERE ref_handle='"..handle.."' AND obj_class = 'Person'")
    for i,ref in ipairs(refs) do table.insert(ret,ref.obj_handle) end
    return ret
end

-- Source
function q.get_source_from_citation(handle,blob)
    if blob==nil then blob=true end
    return(proces_query("SELECT * FROM source "..
        "LEFT JOIN reference ON 'Source' = reference.ref_class AND source.handle = reference.ref_handle "..
        "WHERE reference.obj_handle ='"..handle.."'",blob))
end

function q.get_source_handle_from_id(gramps_id)
    return q.get_handle_from_id(gramps_id)
end
function q.get_source_from_handle(handle,blob)
    local res=proces_query("SELECT * FROM source "..Where('handle',handle),blob)
    return res
end

-- Repositories
function q.get_repository_from_source(handle,blob)
    if blob==nil then blob=true end
    return(proces_query("SELECT * FROM repository "..
        "LEFT JOIN reference ON 'Repository' = reference.ref_class AND repository.handle = reference.ref_handle "..
        "WHERE reference.obj_handle ='"..handle.."'",blob))
end

function q.get_repository_handle_from_id(gramps_id)
    return q.get_handle_from_id(gramps_id)
end
function q.get_repository_from_handle(handle,blob)
    local res=proces_query("SELECT * FROM repository "..Where('handle',handle),blob)
    return res
end

-- Citation
function q.get_citation_from_object(handle,blob)
    if blob==nil then blob=true end
    return(proces_query("SELECT * FROM citation "..
        "LEFT JOIN reference ON 'Citation' = reference.ref_class AND  citation.handle = reference.ref_handle "..
        "WHERE reference.obj_handle ='"..handle.."'",blob))
end
function q.get_citation_handle_from_id(gramps_id)
    return q.get_handle_from_id(gramps_id)
end
function q.get_citation_from_handle(handle,blob)
    local res=proces_query("SELECT * FROM citation "..
    --"LEFT JOIN reference ON obj_handle=citation.handle "..
    Where('handle',handle),blob)
    return res
end

--Note
function q.get_note_handle_from_id(gramps_id)
    return q.get_handle_from_id(gramps_id)
end
function q.get_note_from_handle(handle,blob)
    return proces_query("SELECT * FROM note "..Where('handle',handle),blob)
end
function q.get_note_from_object(handle,blob)
    if blob==nil then blob=true end
    return(proces_query("SELECT * FROM note "..
        "LEFT JOIN reference ON 'Note' = reference.ref_class AND  note.handle = reference.ref_handle "..
        "WHERE reference.obj_handle ='"..handle.."'",blob))
end

-- Metadata
function q.get_metadata(setting)
    local res=proces_query("SELECT setting as setting, value as blob_data FROM metadata "..Where('setting',setting),true)
    return res
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    --print(Where({'1','2','3'}))
    --print(Where(nil,{'1','2','3'}))

    print(q.get_handle_from_id('I0018'))

    --p=q.get_person_from_id('I2604')
    --f=q.get_person_family(p[1].handle)
    --if f then print("FATHER",f[1].father_handle) end

    p=q.get_person_from_id('I0018')
    f=q.get_person_family(p[1].handle)
    if f then print("FATHER",f[1].father_handle) end

    --f=q.get_parent_family('c5db97fcf0c2c7f7442c525591b')
    --if f then print("FATHER",f.father_handle) end

    if db ~= nill then q.close() end
else
    return(q)
end
