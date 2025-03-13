if gramps then return end

if not gettext then require('mh.gettext') end
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*)/")
--print("Script path:", script_path)
--print("Script directory:", script_dir)
gettext.setDirectory(script_dir)

gramps = require("gramps.containers")

gramps.__TYPE='module'
gramps.__NAME='gramps'
gramps.__VERSION='0.8.3.2025'
gramps.__DESCRIPTION='gramps routines gebruikt voor LuaLaTeX'

gramps.query=require("gramps.queries")
gramps.SetDatabase = gramps.query.init

require('gramps.place')
require('gramps.person')
require('gramps.family')
require('gramps.events')
require('gramps.date')
require('gramps.bib')
require('gramps.metadata')
require('gramps.media')



--require('gramps.')
--require("gramps.util")
--local person = require("gramps.person")
--local tprt   = require("gramps.grpstex")
--local ptr    = require("gramps.output")
--local meta   = require("gramps.metadata")
--local data   = require("gramps.gendata")

--table.deep_merge(grps,require("gramps.pedegree"))
--[[
grps.fullname       = person.fullname
grps.firstname      = person.firstname

grps.allperson      = tprt.allperson
grps.OPTION         = tprt.OPTION
grps.set_options    = tprt.set_options
grps.remove_options = tprt.remove_options
grps.default_options= tprt.default_options
grps.print_person   = tprt.print_person
grps.long_print_person = tprt.long_print_person
grps.short_print_person = tprt.short_print_person

grps.format         = ptr.format
grps.procent        = ptr.procent

grps.generate_data  = data.gendata

function grps.researcher() return meta.new("researcher") end
]]--

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then

    gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")

    print(gramps.Person('I0018'):fullname())
    --print(grps.descendent_tree_data('I0018',4))
    --local r=grps.researcher()
    --print(r['name'])

else
    return(gramps)
end

