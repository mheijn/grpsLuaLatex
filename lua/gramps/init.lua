local grps = {_TYPE='module', _NAME='gramps', _VERSION='0.9.10.2024',
        _DESCRIPTION='gramps routines gebruikt voor LuaLaTeX'}

require("gramps.util")
local person = require("gramps.person")
local tprt   = require("gramps.grpstex")

table.deep_merge(grps,require("gramps.pedegree"))

grps.fullname  = person.fullname
grps.allperson = tprt.allperson

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    --pass
    grps.setdatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

    print(grps.fullname('I0018'))
    print(grps.descendent_tree_data('I0018',4))

else
    return(grps)
end

