require("gramps")
	--gramps.SetDatabase("/home/marc/Nextcloud/gramps/grampsdb/63a99d81/sqlite.db")
	gramps.SetDatabase("sqlite.db")

local file = io.open("gramps.bib", "w")

if not file then 
	print("Error opening file!")
    return 
end
    
file:write(gramps.Source.all())
file:write(gramps.Repository.all())
file:close()
tex=nil

print("Bibliographic data are writen to gramps.bib")
