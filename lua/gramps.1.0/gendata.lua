--package.path = "../?.lua;../gramps/?.lua;"..package.path
--print (package.path)

local util=require("gramps.util")
local date=require("gramps.date")
local events=require("gramps.events")

local event_personen = {}
local event_families = {}
local gendata={}

local function get_date(ev)
    if ev then
        --print("get_date",ev,util.dump(events[ev]))
        blob=events[ev].blob_data
        --print("get_date",util.dump(blob))
        if blob[4] and date.aboutdate(blob[4]) then return blob[4] end
    end
end

local function get_start(ph)
    evs = events.events(ph)
    local d = get_date(events.get_event_by_type(evs,events.TYPE.BIRTH)[1])
    --print("DATE",util.dump(d,0,false))
    if d then return d end
    d = get_date(events.get_event_by_type(evs,events.TYPE.BAPTISM)[1])
    return d
end

local function get_stop(ph)
    evs = events.events(ph)
    local d = get_date(events.get_event_by_type(evs,events.TYPE.DEATH)[1])
    if d then return d end
    d = get_date(events.get_event_by_type(evs,events.TYPE.BURIAL)[1])
    return d
end

local function get_marriage(ph)
    local d,start
    if event_personen[ph].children then
        local f = event_personen[ph].children
        local fam = event_families[f]
        if  fam.events then
        --print(util.dump(event_families[f].events))
        --print(util.dump(Event[event_families[f].events[1]]))
            d = get_date(events.get_event_by_type(fam.events,events.TYPE.MARRIAGE)[1])

            if fam.father_handle == ph then sph =fam.mother_handle else sph=fam.father_handle end
            if  sph and #sph>0 then  start = get_start(sph) end
            return d,start
        end
    end
end

local function get_generation(ph,gen)
    local f,fam,d,fd,md,d2, ffd, fmd,d3, mfd, mmd
    local gen = gen or 1
    if event_personen[ph].parents then
        f = event_personen[ph].parents
        fam = event_families[f]
        if  fam.events then
            d = get_date(events.get_event_by_type(fam.events,events.TYPE.MARRIAGE)[1])
        end
        --print(util.dump(fam))
        if fam.father_handle and #fam.father_handle>6 then fd = get_start(fam.father_handle) end
        if fam.mother_handle and #fam.mother_handle>6 then md = get_start(fam.mother_handle) end
        if gen<2 then
            if fam.father_handle and #fam.father_handle>6 then d2, ffd, fmd = get_generation(fam.father_handle,gen+1) end
            if fam.mother_handle and #fam.mother_handle>6 then d3, mfd, mmd = get_generation(fam.mother_handle,gen+1) end
        end
    end
    return d, fd, md, ffd, fmd, mfd, mmd
end

local function sprint(...)
    local args = {...}  -- Collect all arguments in a table
    for i, v in ipairs(args) do
        if type(v)~="string" then v=tostring(v) end
        file_out:write(string.format("%10s",v)) end
end

local function days_from_date(d)
    --print(d[4][3], d[4][2], d[4][1])
    if d ==nil or d[4][3]<1200 then return -1 end
    return date.days_from_year_0(d[4][3], d[4][2], d[4][1])
--    return math.floor(util.days_from_year_0(d[4][3], d[4][2], d[4][1])/365.2425)
end

local function get_all_person()
	local r = query.get_person_from_handle(nil,false)
	for i,p in ipairs(r) do
		event_personen[p.handle] = p
	end
end

local function get_all_family()
    local r,rl = query.get_family_from_handle()
    for i, f in ipairs(r) do
        event_families[f.handle] =f
        event_families[f.handle].children ={}
        event_families[f.handle].events ={}
    end
    for i,ref in ipairs(rl) do
        if ref.ref_class=='Person' then
            if event_families[ref.obj_handle].father_handle==ref.ref_handle or event_families[ref.obj_handle].mother_handle==ref.ref_handle then
                event_personen[ref.ref_handle].children=ref.obj_handle
            else
                table.insert(event_families[ref.obj_handle].children,ref.ref_handle)
                event_personen[ref.ref_handle].parents=ref.obj_handle
            end
        elseif ref.ref_class=='Event' then
            table.insert(event_families[ref.obj_handle].events,ref.ref_handle)
        end
    end

end


function create_table()
    local ages = {}

    i=0
    for oh, p in pairs(event_personen) do
        --print(oh,util.dump(events.events(oh)))

    --i=i+1
    --if i>200 then break end

        --print("start",util.dump(start))
        if events.events(oh) then
            local start = get_start(oh)
            if start then

                local stop = get_stop(oh)
                local marriage, sstart = get_marriage(oh)
                local parents, father, mother, f_grandfather, f_grandmother,
                    m_grandfather, m_grandmother = get_generation(oh)

                sprint(event_personen[oh].gramps_id)
                sprint(event_personen[oh].gender)
                local days = days_from_date(start)
                sprint(days)
                if date.realdate(start) then sprint(1) else sprint(0) end
                if stop then sprint(days_from_date(stop)-days) else sprint(-1)  end
                if marriage then sprint(days-days_from_date(marriage)-days) else sprint(-1)  end
                if sstart then sprint(days -days_from_date(sstart)) else sprint(-1)  end

                if parents then sprint(days-days_from_date(parents))  else sprint(-1)  end
                if date.realdate(parents) and date.realdate(start) then
                    sprint(days-days_from_date(parents))  else sprint(-1)  end

                if father then sprint(days-days_from_date(father)) else sprint(-1)  end
                if mother then sprint(days-days_from_date(mother)) else sprint(-1)  end
                if f_grandfather then sprint(days-days_from_date(f_grandfather)) else sprint(-1)  end
                if f_grandmother then sprint(days-days_from_date(f_grandmother)) else sprint(-1)  end
                if m_grandfather then sprint(days-days_from_date(m_grandfather)) else sprint(-1)  end
                if m_grandmother then sprint(days-days_from_date(m_grandmother)) else sprint(-1)  end
                sprint("\n")
            end
        end
    end
end

function create_table_par()
    local ages = {}

    i=0
    for oh, p in pairs(event_personen) do
        --print(oh,util.dump(events.events(oh)))

    --i=i+1
    --if i>200 then break end

        --print("start",util.dump(start))
        if events.events(oh) then
            local start = get_start(oh)
            if start and date.realdate(start) then

                local stop = get_stop(oh)
                local parents = get_generation(oh)
                if date.realdate(parents) then
                    sprint(event_personen[oh].gramps_id)
                    sprint(event_personen[oh].gender)

                    local days = days_from_date(start)
                    sprint(days)
                    sprint(days-date.days_from_year_0(start[4][3], 0, 0))

                    local y1=math.floor((days-266)/365.2425)
                    local m,d, ed, ted = date.calculateEasterDay(y1)
                    if days-ted > 400 then
                        m,d, ed, ted = date.calculateEasterDay(y1+1)
                    end
                    sprint(days-ted)

                    if date.realdate(stop) then sprint(days_from_date(stop)-days) else sprint(-1)  end

                    sprint(days-days_from_date(parents))

                    sprint("\n")
                end
            end
        end
    end
end

function gendata.gendata(filename)
    if filename==nil then filename = "grps" end

    print("Writing to "..filename..".pers.plt")
    file_out = io.open(filename..".pers.plt", "w")
    if file_out then
        events.events()
        get_all_person()
        get_all_family()
        sprint("id","gender","born","real","age","mariiage","spouse","parents","realpar","father","mother","fgrandf","fgrandm","mgrandf","mgrandm","\n")
        create_table()
        file_out:close()
    else
        print("Failed to open file for writing.")
    end

    print("Writing to "..filename..".pare.plt")
    file_out = io.open(filename..".pare.plt", "w")
    if file_out then
        sprint("id","gender","born","inyear","ineaster","age","parents","\n")
        create_table_par()
        file_out:close()
    else
        print("Failed to open file for writing.")
    end
end
----------------------------------------

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
    --query.init("../../example/sqlite.db")

    gendata.gendata()
else
    return(gendata)
end

