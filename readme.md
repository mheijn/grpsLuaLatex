# grpsLuaLaTeX #

This lua module opens the way in LuaLaTeX to 
the [Gramps Data Model](https://gramps-project.org/wiki/index.php/Gramps_Data_Model).

Calling require("gramps") loads the object gramps in the global memory:

### gramps.Containers ###
Contains the data structure of the gramps sqlite database.

### gramps.DataContainers ###
Access to the data via the [Gramps Data Model](https://gramps-project.org/wiki/index.php/Gramps_Data_Model).

### gramps.Person ###
Use  *p=gramps.Person(handle or gramps_id)*  to access person data.

- p:fullname()
- p:firstname()
- p:surname()
- p:Life() Gives the 4 live events
- p:age() Returns age in day, month, year
- p:events() return array of all person events
- p:event(key) return key-event
- p:has_children() returns bool
- p:has_parets() returns bool
- gramps.Person.all() returns a list of all persons. This is done by gramps.Person() to select all persons and
 gramps.Person:sort_on({key1,key2,..}) sorting by key1, key2, etc. This list of persons is in
 gramps.Person.Order as {handle,}


### gramps.Event ###
Use  *e=gramps.Event(handle or gramps_id)*  to access event data.

- e:datum()
- e:plaats()
- e:short([type])
- e:long([bool (weekday)],[type])

### gramps.Date ###
### gramps.Family ###
### gramps.Media ###
### gramps.Place ###
### gramps.Source, gramps.Citation and gramps.Repository ###
In **bib.lua**
