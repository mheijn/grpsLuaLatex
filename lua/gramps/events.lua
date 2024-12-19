local place=require("gramps.place")
local util=require("gramps.util")
local date=require("gramps.date")
local Event = {_TYPE='module', _NAME='gramps.place' ,_VERSION='0.9.10.2024'}

local function translate(s)
	return(s) 
end

local _=translate
--[[
            "type": "object",
            "title": _("Event"),
            "properties": {
                "_class": {"enum": [cls.__name__]},
                "handle": {"type": "string",
                           "maxLength": 50,
                           "title": _("Handle")},
                "gramps_id": {"type": "string",
                              "title": _("Gramps ID")},
                "type": EventType.get_schema(),
                4"date": {"oneOf": [{"type": "null"}, Date.get_schema()],
                         "title": _("Date")},
                5"description": {"type": "string",
                                "title": _("Description")},
                6"place": {"type": ["string", "null"],
                          "maxLength": 50,
                          "title": _("Place")},
                7"citation_list": {"type": "array",
                                  "items": {"type": "string",
                                            "maxLength": 50},
                                  "title": _("Citations")},
                8"note_list": {"type": "array",
                              "items": {"type": "string",
                                        "maxLength": 50},
                               "title": _("Notes")},
                9"media_list": {"type": "array",
                               "items": MediaRef.get_schema(),
                               "title": _("Media")},
                10"attribute_list": {"type": "array",
                                   "items": Attribute.get_schema(),
                                   "title": _("Media")},
                11"change": {"type": "integer",
                           "title": _("Last changed")},
                12"tag_list": {"type": "array",
                             "items": {"type": "string",
                                       "maxLength": 50},
                             "title": _("Tags")},
                13"private": {"type": "boolean",
                            "title": _("Private")},
]]--
Event.TYPE = {
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
    
Event.MAP = {
        [Event.TYPE.UNKNOWN] = { _("Unknown"), "Unknown"},
        [Event.TYPE.CUSTOM] = {_("Custom"), "Custom"},
        [Event.TYPE.ADOPT] = {_("Adopted"), "Adopted"},
        [Event.TYPE.BIRTH] = {_("Birth"), "Birth"},
        [Event.TYPE.DEATH] = {_("Death"), "Death"},
        [Event.TYPE.ADULT_CHRISTEN] = {_("Adult Christening"), "Adult Christening"},
        [Event.TYPE.BAPTISM] = {_("Baptism"), "Baptism"},
        [Event.TYPE.BAR_MITZVAH] = {_("Bar Mitzvah"), "Bar Mitzvah"},
        [Event.TYPE.BAS_MITZVAH] = {_("Bat Mitzvah"), "Bas Mitzvah"},
        [Event.TYPE.BLESS] = {_("Blessing"), "Blessing"},
        [Event.TYPE.BURIAL] = {_("Burial"), "Burial"},
        [Event.TYPE.CAUSE_DEATH] = {_("Cause Of Death"), "Cause Of Death"},
        [Event.TYPE.CENSUS] = {_("Census"), "Census"},
        [Event.TYPE.CHRISTEN] = {_("Christening"), "Christening"},
        [Event.TYPE.CONFIRMATION] = {_("Confirmation"), "Confirmation"},
        [Event.TYPE.CREMATION] = {_("Cremation"), "Cremation"},
        [Event.TYPE.DEGREE] = {_("Degree"), "Degree"},
        [Event.TYPE.EDUCATION] = {_("Education"), "Education"},
        [Event.TYPE.ELECTED] = {_("Elected"), "Elected"},
        [Event.TYPE.EMIGRATION] = {_("Emigration"), "Emigration"},
        [Event.TYPE.FIRST_COMMUN] = {_("First Communion"), "First Communion"},
        [Event.TYPE.IMMIGRATION] = {_("Immigration"), "Immigration"},
        [Event.TYPE.GRADUATION] = {_("Graduation"), "Graduation"},
        [Event.TYPE.MED_INFO] = {_("Medical Information"), "Medical Information"},
        [Event.TYPE.MILITARY_SERV] = {_("Military Service"), "Military Service"},
        [Event.TYPE.NATURALIZATION] = {_("Naturalization"), "Naturalization"},
        [Event.TYPE.NOB_TITLE] = {_("Nobility Title"), "Nobility Title"},
        [Event.TYPE.NUM_MARRIAGES] = {_("Number of Marriages"), "Number of Marriages"},
        [Event.TYPE.OCCUPATION] = {_("Occupation"), "Occupation"},
        [Event.TYPE.ORDINATION] = {_("Ordination"), "Ordination"},
        [Event.TYPE.PROBATE] = {_("Probate"), "Probate"},
        [Event.TYPE.PROPERTY] = {_("Property"), "Property"},
        [Event.TYPE.RELIGION] = {_("Religion"), "Religion"},
        [Event.TYPE.RESIDENCE] = {_("Residence"), "Residence"},
        [Event.TYPE.RETIREMENT] = {_("Retirement"), "Retirement"},
        [Event.TYPE.WILL] = {_("Will"), "Will"},
        [Event.TYPE.MARRIAGE] = {_("Marriage"), "Marriage"},
        [Event.TYPE.MARR_SETTL] = {_("Marriage Settlement"), "Marriage Settlement"},
        [Event.TYPE.MARR_LIC] = {_("Marriage License"), "Marriage License"},
        [Event.TYPE.MARR_CONTR] = {_("Marriage Contract"), "Marriage Contract"},
        [Event.TYPE.MARR_BANNS] = {_("Marriage Banns"), "Marriage Banns"},
        [Event.TYPE.ENGAGEMENT] = {_("Engagement"), "Engagement"},
        [Event.TYPE.DIVORCE] = {_("Divorce"), "Divorce"},
        [Event.TYPE.DIV_FILING] = {_("Divorce Filing"), "Divorce Filing"},
        [Event.TYPE.ANNULMENT] = {_("Annulment"), "Annulment"},
        [Event.TYPE.MARR_ALT] = {_("Alternate Marriage"), "Alternate Marriage"},
       
        }
        
Event.LifeEvents={Event.TYPE.BIRTH, Event.TYPE.BAPTISM, Event.TYPE.DEATH,
			Event.TYPE.BURIAL, Event.TYPE.CREMATION, Event.TYPE.ADOPT}
--[[             
             [__('Family'),
              [ENGAGEMENT, MARRIAGE, DIVORCE, ANNULMENT, MARR_SETTL, MARR_LIC,
               MARR_CONTR, MARR_BANNS, DIV_FILING, MARR_ALT] ],
             [T_('Religious'),
              [CHRISTEN, ADULT_CHRISTEN, CONFIRMATION, FIRST_COMMUN, BLESS,
               BAR_MITZVAH, BAS_MITZVAH, RELIGION] ],
             [T_('Vocational'),
              [OCCUPATION, RETIREMENT, ELECTED, MILITARY_SERV, ORDINATION] ],
             [T_('Academic'),
              [EDUCATION, DEGREE, GRADUATION] ],
             [_T_('Travel'),
              [EMIGRATION, IMMIGRATION, NATURALIZATION] ],
             [_T_('Legal'),
              [PROBATE, WILL] ],]]--
Event.Residence={Event.TYPE.RESIDENCE, Event.TYPE.CENSUS, Event.TYPE.PROPERTY}
--[[             [_T_('Other'),
              [CAUSE_DEATH, MED_INFO, NOB_TITLE, NUM_MARRIAGES] ] ]
]]--


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
        --if ev.obj_handle then
            if obj_events[ev.obj_handle] == nil then obj_events[ev.obj_handle]={} end
            table.insert(obj_events[ev.obj_handle],ev.handle)
        --end
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
    -- pass
    --print(event.TYPE.DEGREE)
    --for i,n in ipairs(event.LifeEvents) do print(i,n,type(event.MAP[n][0]),event.MAP[n][1],_(event.MAP[n][1])) end
    --Event.events('c5db97f17c34f298cc32a490f68')

else
    return(Event)
end

