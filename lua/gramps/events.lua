if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then require("gramps") end
if gramps and not gramps.Event.Type then


    local util=require("gramps.util")
    local _ = require("mh.gettext")

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
    gramps.Event.Type = TYPE


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
    gramps.Event.Map = MAP

    gramps.Event.LifeEvents={TYPE.BIRTH, TYPE.BAPTISM, TYPE.DEATH, TYPE.BURIAL, TYPE.CREMATION, TYPE.ADOPT}

    gramps.Event.Family =
                {TYPE.ENGAGEMENT, TYPE.MARRIAGE, TYPE.DIVORCE,
                TYPE.ANNULMENT, TYPE.MARR_SETTL, TYPE.MARR_LIC,
                TYPE.MARR_CONTR, TYPE.MARR_BANNS, TYPE.DIV_FILING,
                TYPE.MARR_ALT}
    gramps.Event.Religious =
                {TYPE.CHRISTEN, TYPE.ADULT_CHRISTEN, TYPE.CONFIRMATION,
                TYPE.FIRST_COMMUN, TYPE.BLESS, TYPE.BAR_MITZVAH,
                TYPE.BAS_MITZVAH, TYPE.RELIGION}
    gramps.Event.Vocational={
                TYPE.OCCUPATION, TYPE.RETIREMENT, TYPE.ELECTED,
                TYPE.MILITARY_SERV, TYPE.ORDINATION}
    gramps.Event.Academic = {
                TYPE.EDUCATION, TYPE.DEGREE, TYPE.GRADUATION}
    gramps.Event.Travel = {
                TYPE.EMIGRATION, TYPE.IMMIGRATION, TYPE.NATURALIZATION}
    gramps.Event.Legal = { TYPE.PROBATE, TYPE.WILL}
    gramps.Event.Residence = {TYPE.RESIDENCE, TYPE.CENSUS, TYPE.PROPERTY}
    --[[             [_T_('Other'),
                [CAUSE_DEATH, MED_INFO, NOB_TITLE, NUM_MARRIAGES]
    ]]--

    function gramps.Event:datum()
        return self.date:short()
    end

    function gramps.Event:short(type)
        if type and self.type.number ~= type then return "" end
        local s=string.format(_.T("EventType %d"),self.type.number)
        s=util.is_empty(s,"",s.." ") ..self.date:short()
        return s
    end

    function gramps.Event:long(weekday,type)
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




end
----------------------------------------

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
	query.init("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

    -- pass
    --print(event.TYPE.DEGREE)
    --for i,n in ipairs(event.LifeEvents) do print(i,n,type(event.MAP[n][0]),event.MAP[n][1],_(event.MAP[n][1])) end
    local evs = Event.events('c5db97f17c34f298cc32a490f68')
    local ev = Event[evs[1]]

    print(util.dump(ev))
    local e2 = gramps.Event(evs[1])
    print("gramps_id:",e2.gramps_id)
    print(e2:short())
    print(e2:long(true))
    --print(e2)
    --for k,v in pairs(e2) do print(k,v) end
    --local e1 = gramps.Event(ev['blob_data'])
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

