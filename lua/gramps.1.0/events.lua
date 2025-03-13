local place=require("gramps.place")
local util=require("gramps.util")
local date=require("gramps.date")
local _ = require("mh.gettext")
local container = require("gramps.datacontainer")
local C = require("gramps.containers")
local Event = {_TYPE='module', _NAME='gramps.place' ,_VERSION='0.9.10.2024'}

--local function translate(s) return(s) end
--local _=translate

----------------------------
--[[
local EventType = container({
    type       ={index=1, type='integer',title=_('EventTypeNumber')},
    name       ={index=2, type='string',title=_('EventTypeName')},
    scheme_type={title='Event Type'}
    })

local Attribute = container({
	private       ={index = 1,type = "boolean", title = _("Private")},
	citation_list ={index = 2,type = "array",title = _("Citations"),
                        items ={type = "string",	maxLength = 50}},
	note_list     ={index = 3,type = "array",title = _("Notes"),
                        items ={type = "string", maxLength = 50}},
	type          = {index=4, class=AttributeType},
	value         ={index =5, type="string", title= _("Value")},
    scheme_type={title='Attribute'}
    })
local MediaRef = container({

	private        ={index= 1,type = "boolean",title = _("Private")},
	citation_list  ={index =2,type = "array", title = _("Citations"),
                        items ={type = "string", maxLength = 50}},
	note_list      ={index =3 ,type = "array",title = _("Notes"),
                        items ={type = "string",maxLength = 50}},
	attribute_list ={index =4 ,type = "array", title = _("Attributes"),
                        items = {class =Attribute}},
    ref            ={index =5 ,type = "string",title = _("Handle"),maxLength = 50},
	rect           ={index =6 ,title = _("Region"), oneOf = {
                            {type = "null"},
                            {type = "array",items ={type = "integer"},minItems = 4,maxItems = 4}
                        }},
    scheme_type={title='Media Ref'}
    })
]]--
TYPE = {
    UNKNOWN = -1,
    CUSTOM = 0,
    MARRIAGE = 1,
    MARR_SETTL = 2,
    MARR_LIC = 3,
    MARR_CONTR = 4,
    MARR_BANNS = 5,
    ENGAGEMENT = 6,
    DIVORCE = 7,
    DIV_FILING = 8,
    ANNULMENT = 9,
    MARR_ALT = 10,
    ADOPT = 11,
    BIRTH = 12,
    DEATH = 13,
    ADULT_CHRISTEN = 14,
    BAPTISM = 15,
    BAR_MITZVAH = 16,
    BAS_MITZVAH = 17,
    BLESS = 18,
    BURIAL = 19,
    CAUSE_DEATH = 20,
    CENSUS = 21,
    CHRISTEN = 22,
    CONFIRMATION = 23,
    CREMATION = 24,
    DEGREE = 25,
    EDUCATION = 26,
    ELECTED = 27,
    EMIGRATION = 28,
    FIRST_COMMUN = 29,
    IMMIGRATION = 30,
    GRADUATION = 31,
    MED_INFO = 32,
    MILITARY_SERV = 33,
    NATURALIZATION = 34,
    NOB_TITLE = 35,
    NUM_MARRIAGES = 36,
    OCCUPATION = 37,
    ORDINATION = 38,
    PROBATE = 39,
    PROPERTY = 40,
    RELIGION = 41,
    RESIDENCE = 42,
    RETIREMENT = 43,
    WILL = 44}
C.Event.Type = TYPE
Event.TYPE = TYPE

MAP = {
        [TYPE.UNKNOWN] =  _("Unknown"),
        [TYPE.CUSTOM] = _("Custom"),
        [TYPE.ADOPT] = _("Adopted"),
        [TYPE.BIRTH] = _("Birth"),
        [TYPE.DEATH] = _("Death"),
        [TYPE.ADULT_CHRISTEN] = _("Adult Christening"),
        [TYPE.BAPTISM] = _("Baptism"),
        [TYPE.BAR_MITZVAH] = _("Bar Mitzvah"),
        [TYPE.BAS_MITZVAH] = _("Bat Mitzvah"),
        [TYPE.BLESS] = _("Blessing"),
        [TYPE.BURIAL] = _("Burial"),
        [TYPE.CAUSE_DEATH] = _("Cause Of Death"),
        [TYPE.CENSUS] = _("Census"),
        [TYPE.CHRISTEN] = _("Christening"),
        [TYPE.CONFIRMATION] = _("Confirmation"),
        [TYPE.CREMATION] = _("Cremation"),
        [TYPE.DEGREE] = _("Degree"),
        [TYPE.EDUCATION] = _("Education"),
        [TYPE.ELECTED] = _("Elected"),
        [TYPE.EMIGRATION] = _("Emigration"),
        [TYPE.FIRST_COMMUN] = _("First Communion"),
        [TYPE.IMMIGRATION] = _("Immigration"),
        [TYPE.GRADUATION] = _("Graduation"),
        [TYPE.MED_INFO] = _("Medical Information"),
        [TYPE.MILITARY_SERV] = _("Military Service"),
        [TYPE.NATURALIZATION] = _("Naturalization"),
        [TYPE.NOB_TITLE] = _("Nobility Title"),
        [TYPE.NUM_MARRIAGES] = _("Number of Marriages"),
        [TYPE.OCCUPATION] = _("Occupation"),
        [TYPE.ORDINATION] = _("Ordination"),
        [TYPE.PROBATE] = _("Probate"),
        [TYPE.PROPERTY] = _("Property"),
        [TYPE.RELIGION] = _("Religion"),
        [TYPE.RESIDENCE] = _("Residence"),
        [TYPE.RETIREMENT] = _("Retirement"),
        [TYPE.WILL] = _("Will"),
        [TYPE.MARRIAGE] = _("Marriage"),
        [TYPE.MARR_SETTL] = _("Marriage Settlement"),
        [TYPE.MARR_LIC] = _("Marriage License"),
        [TYPE.MARR_CONTR] = _("Marriage Contract"),
        [TYPE.MARR_BANNS] = _("Marriage Banns"),
        [TYPE.ENGAGEMENT] = _("Engagement"),
        [TYPE.DIVORCE] = _("Divorce"),
        [TYPE.DIV_FILING] = _("Divorce Filing"),
        [TYPE.ANNULMENT] = _("Annulment"),
        [TYPE.MARR_ALT] = _("Alternate Marriage")
        }
C.Event.Map = MAP

Event.LifeEvents={TYPE.BIRTH, TYPE.BAPTISM, TYPE.DEATH,
TYPE.BURIAL, TYPE.CREMATION, TYPE.ADOPT}

Event.Family =
              {TYPE.ENGAGEMENT, TYPE.MARRIAGE, TYPE.DIVORCE,
              TYPE.ANNULMENT, TYPE.MARR_SETTL, TYPE.MARR_LIC,
               TYPE.MARR_CONTR, TYPE.MARR_BANNS, TYPE.DIV_FILING,
               TYPE.MARR_ALT}
Event.Religious =
              {TYPE.CHRISTEN, TYPE.ADULT_CHRISTEN, TYPE.CONFIRMATION,
              TYPE.FIRST_COMMUN, TYPE.BLESS, TYPE.BAR_MITZVAH,
              TYPE.BAS_MITZVAH, TYPE.RELIGION}
Event.Vocational={
              TYPE.OCCUPATION, TYPE.RETIREMENT, TYPE.ELECTED,
              TYPE.MILITARY_SERV, TYPE.ORDINATION}
Event.Academic = {
              TYPE.EDUCATION, TYPE.DEGREE, TYPE.GRADUATION}
Event.Travel = {
              TYPE.EMIGRATION, TYPE.IMMIGRATION, TYPE.NATURALIZATION}
Event.Legal = { TYPE.PROBATE, TYPE.WILL}
Event.Residence = {TYPE.RESIDENCE, TYPE.CENSUS, TYPE.PROPERTY}
--[[             [_T_('Other'),
              [CAUSE_DEATH, MED_INFO, NOB_TITLE, NUM_MARRIAGES]
]]--

function C.Event:datum()
    return self.date:short()
end

function C.Event:short(type)
    if type and self.type.number ~= type then return "" end
    local s=string.format(_.T("EventType %d"),self.type.number)
    s=util.is_empty(s,"",s.." ") ..self.date:short()
    return s
end

function C.Event:long(weekday,type)
    if type and self.type.number ~= type then return "" end

    local s=""
    --print(self)
    local date  = self.date:long(weekday)
    
    local t = MAP[self.type.number]

    if 0 < #date then 
        s=s..t.." "..date
    else
        s=s..t
    end
    return s
end
    
local Event_meta = {}
local events = {}
local order = {}
local obj_events = {}

function Event:new(handle)
--print("new",handle,events[handle])
    if events[handle] then
        return events[handle]
    else
        r = query.get_event_from_handle(handle)
        if r[1] then
            events[handle]=r[1]
            return r[1]
        else
            return(nil)
        end
    end
end

function Event.events(handle)
    if handle and obj_events[handle] then return obj_events[handle] end

    local evs = query.get_events_from_handle(handle)
    --print("events",util.dump(evs))
    for i,ev in ipairs(evs) do
        events[ev.handle]=ev
        if ev.obj_handle then
            if obj_events[ev.obj_handle] == nil then obj_events[ev.obj_handle]={} end
            table.insert(obj_events[ev.obj_handle],ev.handle)
--        else
--            print(util.dump(ev))
        end
    end
    --print("ecevt handles ",util.dump(ehs))
    if handle then   return obj_events[handle] end
end

function Event.get_event_by_type(evs,t)
--print("get_event_by_type",util.dump(evs),t)
res={}
if evs then
        for i,ev in ipairs(evs) do
            if events[ev] and events[ev].blob_data[3][1]==t then
                table.insert(res,ev)
                --print(util.dump(Event[ev].blob_data))
            end
        end
    end
return res
end

-------------------------------------
-- Set the metatable to the module
-------------------------------------

setmetatable(Event, {
    __call = function(_,handle)
        return Event:new(handle)
    end,

__index = function(_,handle)
return Event(handle)
end,

__newindex = function(_,handle,e)
events[handle]=e
end,
})
----------------------------------------

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

    -- pass
    --print(event.TYPE.DEGREE)
    --for i,n in ipairs(event.LifeEvents) do print(i,n,type(event.MAP[n][0]),event.MAP[n][1],_(event.MAP[n][1])) end
    local evs = Event.events('c5db97f17c34f298cc32a490f68')
    local ev = Event[evs[1]]

    print(util.dump(ev))
    local e2 = C.Event(evs[1])
    print("gramps_id:",e2.gramps_id)
    print(e2:short())
    print(e2:long(true))
    --print(e2)
    --for k,v in pairs(e2) do print(k,v) end
    --local e1 = C.Event(ev['blob_data'])
    --print(e1.type)
    --print(e1.type['type'])
    --print(e1.handle,e1.gramps_id,e1.type.type,e1.date:long())
    --printfun(e1,"event e1")
    --print(e1)
    --print("e1.date",util.dump(e1.date))
    --print("e1.type",util.dump(e1.type))
else
    return(Event)
end

