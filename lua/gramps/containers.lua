-- When containers are defined
if Containers and Containers.Person then return Containers end
--else
Containers = Containers or {}
local _=require("mh.gettext")
local print = require("mh.print")
local container = require("gramps.datacontainer")
Containers.list={}
--[[
table.insert(Containers.list,"")
Containers. = container({
string = {index=1, map={
--------
}},
scheme_type={title=""}
})
----------------------------
table.insert(Containers.list,"")
Containers. = container({
----------------
scheme_type={title=""}
})

]]--
table.insert(Containers.list,"EventType")
Containers.EventType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[11]={ _("Adopted"), "Adopted"},
[12]={ _("Birth"), "Birth"},
[13]={ _("Death"), "Death"},
[14]={ _("Adult Christening"), "Adult Christening"},
[15]={ _("Baptism"), "Baptism"},
[16]={ _("Bar Mitzvah"), "Bar Mitzvah"},
[17]={ _("Bat Mitzvah"), "Bas Mitzvah"},
[18]={ _("Blessing"), "Blessing"},
[19]={ _("Burial"), "Burial"},
[20]={ _("Cause Of Death"), "Cause Of Death"},
[21]={ _("Census"), "Census"},
[22]={ _("Christening"), "Christening"},
[23]={ _("Confirmation"), "Confirmation"},
[24]={ _("Cremation"), "Cremation"},
[25]={ _("Degree"), "Degree"},
[26]={ _("Education"), "Education"},
[27]={ _("Elected"), "Elected"},
[28]={ _("Emigration"), "Emigration"},
[29]={ _("First Communion"), "First Communion"},
[30]={ _("Immigration"), "Immigration"},
[31]={ _("Graduation"), "Graduation"},
[32]={ _("Medical Information"), "Medical Information"},
[33]={ _("Military Service"), "Military Service"},
[34]={ _("Naturalization"), "Naturalization"},
[35]={ _("Nobility Title"), "Nobility Title"},
[36]={ _("Number of Marriages"), "Number of Marriages"},
[37]={ _("Occupation"), "Occupation"},
[38]={ _("Ordination"), "Ordination"},
[39]={ _("Probate"), "Probate"},
[40]={ _("Property"), "Property"},
[41]={ _("Religion"), "Religion"},
[42]={ _("Residence"), "Residence"},
[43]={ _("Retirement"), "Retirement"},
[44]={ _("Will"), "Will"},
[1]={ _("Marriage"), "Marriage"},
[2]={ _("Marriage Settlement"), "Marriage Settlement"},
[3]={ _("Marriage License"), "Marriage License"},
[4]={ _("Marriage Contract"), "Marriage Contract"},
[5]={ _("Marriage Banns"), "Marriage Banns"},
[6]={ _("Engagement"), "Engagement"},
[7]={ _("Divorce"), "Divorce"},
[8]={ _("Divorce Filing"), "Divorce Filing"},
[9]={ _("Annulment"), "Annulment"},
[10]={ _("Alternate Marriage"), "Alternate Marriage"}
}},
scheme_type={title="Event Type"}
})

table.insert(Containers.list,"EventRoleType")
Containers.EventRoleType = container({
string = {index=1, map={
[1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[1]={ _("Role|Primary"), "Primary"},
[2]={ _("Clergy"), "Clergy"},
[3]={ _("Celebrant"), "Celebrant"},
[4]={ _("Aide"), "Aide"},
[5]={ _("Bride"), "Bride"},
[6]={ _("Groom"), "Groom"},
[7]={ _("Witness"), "Witness"},
[8]={ _("Role|Family"), "Family"},
[9]={ _("Informant"), "Informant"},
}},
scheme_type={title="Event Role Type"}
})


table.insert(Containers.list,"NoteType")
Containers.NoteType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[1]={ _("Also Known As"), "Also Known As"},
[2]={ _("Birth Name"), "Birth Name"},
[3]={ _("Married Name"), "Married Name"},
}},
scheme_type={title="Note type"}
})


table.insert(Containers.list,"UrlType")
Containers.UrlType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[1]={ _("E-mail"), "E-mail"},
[2]={ _("Web Home"), "Web Home"},
[3]={ _("Web Search"), "Web Search"},
[4]={ _("FTP"), "FTP"},
}},
scheme_type={title="URL type"}
})


table.insert(Containers.list,"RepositoryType")
Containers.RepositoryType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[1]={ _("Library"), "Library"},
[2]={ _("Cemetery"), "Cemetery"},
[3]={ _("Church"), "Church"},
[4]={ _("Archive"), "Archive"},
[5]={ _("Album"), "Album"},
[6]={ _("Web site"), "Web site"},
[7]={ _("Bookstore"), "Bookstore"},
[8]={ _("Collection"), "Collection"},
[9]={ _("Safe"), "Safe"},
}},
scheme_type={title="Repository type"}
})

table.insert(Containers.list,"NameType")
Containers.NameType = container({
string = {index=1, map={
 [-1]= {_("Unknown"), "Unknown"},
 [0]= {_("Custom"), "Custom"},
 [1]= {_("Also Known As"), "Also Known As"},
 [2]= {_("Birth Name"), "Birth Name"},
 [3]= {_("Married Name"), "Married Name"}
}},
scheme_type={title="Name type"}
})

table.insert(Containers.list,"NameType")
Containers.NameType = container({
string = {index=1, map={
 [-1]= {_("Unknown"), "Unknown"},
 [0]= {_("Custom"), "Custom"},
 [1]= {_("Also Known As"), "Also Known As"},
 [2]= {_("Birth Name"), "Birth Name"},
 [3]= {_("Married Name"), "Married Name"}
}},
scheme_type={title="Name type"}
})

table.insert(Containers.list,"AttributeType")
Containers.AttributeType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[1]={ _("Caste"), "Caste"},
[2]={ _("Description"), "Description"},
[3]={ _("Identification Number"), "Identification Number"},
[4]={ _("National Origin"), "National Origin"},
[5]={ _("Number of Children"), "Number of Children"},
[6]={ _("Social Security Number"), "Social Security Number"},
[7]={ _("Nickname"), "Nickname"},
[8]={ _("Cause"), "Cause"},
[9]={ _("Agency"), "Agency"},
[10]={ _("Age"), "Age"},
[11]={ _("Father's Age"), "Father Age"},
[12]={ _("Mother's Age"), "Mother Age"},
[13]={ _("Witness"), "Witness"},
[14]={ _("Time"), "Time"},
[15]={ _("Occupation"), "Occupation"}
}},
scheme_type={title="AttributeType"}
})

table.insert(Containers.list,"NameOriginType")
Containers.NameOriginType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown "},
[0]={ _("Custom"), "Custom"},
[1]={ "", ""},
[2]={ _("Surname|Inherited"), "Inherited"},
[3]={ _("Surname|Given"), "Given"},
[4]={ _("Surname|Taken"), "Taken"},
[5]={ _("Patronymic"), "Patronymic"},
[6]={ _("Matronymic"), "Matronymic"},
[7]={ _("Surname|Feudal"), "Feudal"},
[8]={ _("Pseudonym"), "Pseudonym"},
[9]={ _("Patrilineal"), "Patrilineal"},
[10]={ _("Matrilineal"), "Matrilineal"},
[11]={ _("Occupation"), "Occupation"},
[12]={ _("Location"), "Location"}
}},
scheme_type={title="NameOriginType"}
})

table.insert(Containers.list,"StyledTextTagType")
Containers.StyledTextTagType = container({
string = {index=1, map={
[0]={ _("Bold"), "bold"},
[1]={ _("Italic"), "italic"},
[2]={ _("Underline"), "underline"},
[3]={ _("Fontface"), "fontface"},
[4]={ _("Fontsize"), "fontsize"},
[5]={ _("Fontcolor"), "fontcolor"},
[6]={ _("Highlight"), "highlight"},
[7]={ _("Superscript"), "superscript"},
[8]={ _("Link"), "link"}
}},
scheme_type={title="StyledTextTagType"}
})

table.insert(Containers.list,"SrcAttributeType")
Containers.SrcAttributeType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"}
}},
scheme_type={title="SrcAttributeType"}
})

table.insert(Containers.list,"SourceMediaType")
Containers.SourceMediaType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[1]={ _("Audio"), "Audio"},
[2]={ _("Book"), "Book"},
[3]={ _("Card"), "Card"},
[4]={ _("Electronic"), "Electronic"},
[5]={ _("Fiche"), "Fiche"},
[6]={ _("Film"), "Film"},
[7]={ _("Magazine"), "Magazine"},
[8]={ _("Manuscript"), "Manuscript"},
[9]={ _("Map"), "Map"},
[10]={ _("Newspaper"), "Newspaper"},
[11]={ _("Photo"), "Photo"},
[12]={ _("Tombstone"), "Tombstone"},
[13]={ _("Video"), "Video"}
}},
scheme_type={title="SourceMediaType"}
})

table.insert(Containers.list,"PlaceType")
Containers.PlaceType = container({
string = {index=1, map={
[-1]={ _("Unknown"), "Unknown"},
[0]={ _("Custom"), "Custom"},
[1]={ _("Country"), "Country"},
[2]={ _("State"), "State"},
[3]={ _("County"), "County"},
[4]={ _("City"), "City"},
[5]={ _("Parish"), "Parish"},
[6]={ _("Locality"), "Locality"},
[7]={ _("Street"), "Street"},
[8]={ _("Province"), "Province"},
[9]={ _("Region"), "Region"},
[10]={ _("Department"), "Department"},
[11]={ _("Neighborhood"), "Neighborhood"},
[12]={ _("District"), "District"},
[13]={ _("Borough"), "Borough"},
[14]={ _("Municipality"), "Municipality"},
[15]={ _("Town"), "Town"},
[16]={ _("Village"), "Village"},
[17]={ _("Hamlet"), "Hamlet"},
[18]={ _("Farm"), "Farm"},
[19]={ _("Building"), "Building"},
[20]={ _("Number"), "Number"}
}},
scheme_type={title="PlaceType"}
})

table.insert(Containers.list,"FamilyRelType")
Containers.FamilyRelType = container({
string = {index=1, map={
[0]={ _("Married"), "Married"},
[1]={ _("Unmarried"), "Unmarried"},
[2]={ _("Civil Union"), "Civil Union"},
[3]={ _("Unknown"), "Unknown"},
[4]={ _("Custom"), "Custom"},
}},
scheme_type={title="FamilyRelType"}
})

table.insert(Containers.list,"ChildRefType")
Containers.ChildRefType = container({
string = {index=1, map={
[0]={ _("None"), "None"},
[1]={ _("Birth"), "Birth"},
[2]={ _("Adopted"), "Adopted"},
[3]={ _("Stepchild"), "Stepchild"},
[4]={ _("Sponsored"), "Sponsored"},
[5]={ _("Foster"), "Foster"},
[6]={ _("Unknown"), "Unknown"},
[7]={ _("Custom"), "Custom"},
}},
scheme_type={title="ChildRefType"}
})

-------------------------------------------------------------------------------------------------------------------------
table.insert(Containers.list,"RepoRef")
Containers.RepoRef = container({
note_list   = {index=1,type= "array",title =  _("Notes"), items= {type= "string",maxLength= 50}},
ref         = {index=2,type= "string",title =  _("Handle"), maxLength= 50},
call_number = {index=3,type= "string",title =  _("Call Number")},
media_type  = {index=4,class= Containers.SourceMediaType},
private     = {index=5,type= "boolean",title =  _("Private")},
scheme_type={title="RepoRef"}
})

table.insert(Containers.list,"SrcAttribute")
Containers.SrcAttribute = container({
private     = {index=1, type= "boolean",title = _("Private")},
type        = {index=2, class = Containers.SrcAttributeType},
value       = {index=3, type= "string",title = _("Value")},
scheme_type ={title="SrcAttribute"}
})


table.insert(Containers.list,"StyledTextTag")
Containers.StyledTextTag = container({
name   = {index=1, class=Containers.StyledTextTagType},
value  = {index=2, type= {"null", "string", "integer"},title =  _("Value")},
ranges = {index=3, type= "array",items =  {type =  "array",items =  {type =  "integer"}, minItems = 2, maxItems = 2},title =  _("Ranges")},
scheme_type={title="StyledTextTag"}
})

table.insert(Containers.list,"StyledText")
Containers.StyledText = container({
string = {index=1,type= "string",title =  _("Text")},
tags   = {index=2,type= "array",items = {class = Containers.StyledTextTag},title =  _("Styled Text Tags")},
scheme_type={title="StyledText"}
})

table.insert(Containers.list,"Location")
Containers.Location = container({
street   = {index=1,type= "string", title= _("Street")},
locality = {index=2,type= "string", title= _("Locality")},
city     = {index=3,type= "string", title= _("City")},
county   = {index=4,type= "string", title= _("County")},
state    = {index=5,type= "string", title= _("State")},
country  = {index=6,type= "string", title= _("Country")},
postal   = {index=7,type= "string", title= _("Postal Code")},
phone    = {index=8,type= "string", title= _("Phone")},
parish   = {index=9,type= "string", title= _("Parish")},
scheme_type={title="Location"}
})

table.insert(Containers.list,"Data")
Containers.Date = container({
calendar    ={index=1 ,type= "integer", title= _("Calendar")},
modifier    ={index=2 ,type= "integer", title= _("Modifier")},
quality     ={index=3 ,type= "integer",  title= _("Quality")},
dateval     ={index=4 ,type= "array", title= _("Values"), items= {type= {"integer", "boolean"}}},
text        ={index=5 ,type= "string", title= _("Text")},
sortval     ={index=6 ,type= "integer", title= _("Sort value")},
newyear     ={index=7 ,type= "integer", title= _("New year begins")},
scheme_type={title="Date"}
})

table.insert(Containers.list,"Url")
Containers.Url  = container({
 private    = {index=1,type= "boolean", title= _("Private")},
 path       = {index=2,type= "string", title= _("Path")},
 desc       = {index=3,type= "string", title= _("Description")},
 type       = {index=4,class = Containers.UrlType},
 scheme_type= {title="URL", }
})

table.insert(Containers.list,"Atribute")
Containers.Attribute = container({
 private       ={index = 1,type = "boolean", title = _("Private")},
 citation_list ={index = 2,type = "array",title = _("Citations"), items ={type = "string", maxLength = 50}},
 note_list     ={index = 3,type = "array",title = _("Notes"),items ={type = "string", maxLength = 50}},
 type          = {index=4, class = Containers.AttributeType}, 
 value         ={index =5, type="string", title= _("Value")},
 scheme_type={title='Attribute'}
 })

table.insert(Containers.list,"MediaRef")
Containers.MediaRef = container({
 private        ={index= 1,type = "boolean",title = _("Private")},
 citation_list  ={index =2,type = "array", title = _("Citations"),items ={type = "string", maxLength = 50}},
 note_list      ={index =3 ,type = "array",title = _("Notes"),items ={type = "string",maxLength = 50}},
 attribute_list ={index =4 ,type = "array", title = _("Attributes"), items = {class = Containers.Attribute}},
 ref            ={index =5 ,type = "string",title = _("Handle"),maxLength = 50},
 rect           ={index =6 ,title = _("Region"), oneOf = {{type = "null"},{type = "array",items ={type = "integer"},minItems = 4,maxItems = 4}}},
 scheme_type={title='Media Ref'}
 })

table.insert(Containers.list,"Surname")
Containers.Surname = container({
surname    = {index=1,type= "string", title= _("Surname")},
prefix     = {index=2,type= "string", title= _("Prefix")},
primary    = {index=3,type= "boolean", title= _("Primary")},
origintype = {index=4 ,class=Containers.NameOriginType},
connector  = {index=5, type= "string", title= _("Connector")},
scheme_type= {title=_("Surename"), }
})

table.insert(Containers.list,"Address")
Containers.Address = container({
private       = {index=1,type= "boolean", title= _("Private")},
citation_list = {index=2,type= "array", title= _("Citations"), items = {type= "string", maxLength= 50}},
note_list     = {index=3,type= "array", title= _("Notes"), items= {type= "string", maxLength= 50}},
date          = {index=4,oneOf= {{type= "null"}, {class=Containers.Date}},title= _("Date")},
location      = {index=5, class = Containers.Location, title= _("Location")},
scheme_type   = {title=_("Address"), }
})

table.insert(Containers.list,"PersonRef")
Containers.PersonRef = container({
private       = {index=1,type= "boolean", title= _("Private")},
citation_list = {index=2,type= "array", title= _("Citations"),items ={type= "string", maxLength= 50}},
note_list     = {index=3,type= "array", title= _("Notes"),items ={type= "string", maxLength= 50}},
ref           = {index=4,type= "string", title= _("Handle"), maxLength = 50},
rel           = {index=5,type= "string", title= _("Association")},
scheme_type   = {title=_("Person reference"), }
})

table.insert(Containers.list,"ChildRef")
Containers.ChildRef = container({
private       = {index=1,type= "boolean",title= _("Private")},
citation_list = {index=2,type= "array",items= {type= "string",maxLength= 50},title= _("Citations")},
note_list     = {index=3,type= "array",items= {type= "string",maxLength= 50},title= _("Notes")},
ref           = {index=4,type= "string",maxLength= 50,title= _("Handle")},
frel          = {index=5, class = Containers.ChildRefType},
mrel          = {index=6, class = Containers.ChildRefType},
scheme_type={title="ChildRef"}
})

table.insert(Containers.list,"Name")
Containers.Name = container({
 private      = {index=1,type= "boolean", title= _("Private")},
 citation_list= {index=2,type= "array", items= {type= "string", maxLength= 50}, title= _("Citations")},
 note_list    = {index=3,type= "array", items= {type= "string", maxLength= 50}, title= _("Notes")},
 date         = {index=4,oneOf= {{type= "null"}, {class = Containers.Date}}, title= _("Date")},
 first_name   = {index=5,type= "string", title= _("Given name")},
 surname_list = {index=6,type= "array", items={class = Containers.Surname}, title= _("Surnames")},
 suffix       = {index=7,type= "string", title= _("Suffix")},
 title        = {index=8,type= "string", title= _("Title")},
 type         = {index=9, class = Containers.NameType},
 group_as     = {index=10,type= "string", title= _("Group as")},
 sort_as      = {index=11,type= "integer", title= _("Sort as")},
 display_as   = {index=12,type= "integer", title= _("Display as")},
 call         = {index=13,type= "string", title= _("Call name")},
 nick         = {index=14,type= "string", title= _("Nick name")},
 famnick      = {index=15,type= "string", title= _("Family nick name")},
 scheme_type    = {title="Name", }
})


table.insert(Containers.list,"Citation")
Containers.Citation = container({
handle        = {index=1,type= "string", maxLength= 50, title= _("Handle")},
gramps_id     = {index=2,type= "string", title= _("Gramps ID")},
date          = {index=3,oneOf= {{type= "null"}, {class=Containers.Date}},title= _("Date")},
page          = {index=4,type= "string", title= _("Page")},
confidence    = {index=5,type= "integer", minimum= 0, maximum= 4,title =  _("Confidence")},
source_handle = {index=6,type= "string", maxLength= 50,title =  _("Source")},
note_list     = {index=7,type= "array", items= {type="string", maxLength= 50},title =  _("Notes")},
media_list    = {index=8,type= "array", items={class=Containers.MediaRef},title =  _("Media")},
attribute_list= {index=9,type= "array", items={class=Containers.SrcAttribute},title =  _("Source Attributes")},
change        = {index=10,type= "integer", title= _("Last changed")},
tag_list      = {index=11,type= "array", items= {type= "string", maxLength= 50},title =  _("Tags")},
private       = {index=12,type= "boolean", title= _("Private")},
scheme_type   ={title=_("Citation"), hash = 'gramps_id',table='citation'}
})


table.insert(Containers.list,"Source")
Containers.Source = container({
handle     = {index=1,type= "string", maxLength= 50,title =  _("Handle")},
gramps_id  = {index=2,type= "string", title= _("Gramps ID")},
title      = {index=3,type= "string", title= _("Title")},
author     = {index=4,type= "string", title= _("Author")},
pubinfo    = {index=5,type= "string", title= _("Publication info")},
note_list  = {index=6,type= "array", items= {type= "string", maxLength= 50},title =  _("Notes")},
media_list = {index=7,type= "array", items= {class=Containers.MediaRef},title =  _("Media")},
abbrev     = {index=8,type= "string", title= _("Abbreviation")},
change         = {index=9,type= "integer", title= _("Last changed")},
attribute_list = {index=10,type= "array", items={class=Containers.SrcAttribute},title =  _("Source Attributes")},
reporef_list   = {index=11,type= "array", items={class=Containers.RepoRef},title =  _("Repositories")},
tag_list       = {index=12,type= "array", items= {type= "string", maxLength= 50},title =  _("Tags")},
private        = {index=13,type= "boolean", title= _("Private")},
scheme_type   ={title=_("Source"), hash = 'gramps_id',table='source', sort=true}
})


table.insert(Containers.list,"Note")
Containers.Note = container({
handle    = {index=1,type= "string", maxLength= 50,title =  _("Handle")},
gramps_id = {index=2,type= "string", title= _("Gramps ID")},
text      = {index=3,class=Containers.StyledText}, 
format    = {index=4,type= "integer", title= _("Format")},
type      = {index=5,class=Containers.NoteType},
change    = {index=6,type= "integer", title= _("Last changed")},
tag_list  = {index=7,type= "array", items= {type= "string", maxLength= 50},title =  _("Tags")},
private  =  {index=8,type= "boolean", title= _("Private")},
scheme_type   ={title=_("Note"), hash = 'gramps_id',table='note'}
})

table.insert(Containers.list,"Repository")
Containers.Repository = container({
handle       = {index=1,type= "string", maxLength= 50,title =  _("Handle")},
gramps_id    = {index=2,type= "string", title= _("Gramps ID")},
type         = {index=3, class= Containers.RepositoryType},
name         = {index=4,type= "string", title= _("Name")},
note_list    = {index=5,type= "array", items= {type "string", maxLength= 50},title =  _("Notes")},
address_list = {index=6,type= "array", items= {class= Containers.Address},title =  _("Addresses")},
urls         = {index=7,type= "array", items={class=Containers.Url},title =  _("URLs")},
change       = {index=8,type= "integer", title= _("Last changed")},
tag_list     = {index=9,type= "array", items= {type= "string", maxLength= 50},title =  _("Tags")},
private      = {index=10,type= "boolean", title= _("Private")},
scheme_type   ={title=_("Repository"), hash = 'gramps_id',table='repository', sort=true}
})


table.insert(Containers.list,"EventRef")
Containers.EventRef  = container({
 private        = {index=1,type= "boolean", title= _("Private")},
 note_list      = {index=2,type= "array", items= {type= "string", maxLength= 50}, title= _("Notes")},
 attribute_list = {index=3,type= "array", items={class = Containers.Attribute}, title= _("Attributes")},
 ref            = {index=4,type= "string", maxLength= 50,title= _("Event")},
 role           = {index=5,class = Containers.EventRoleType},
 scheme_type    = {title="Event reference", }
 })


table.insert(Containers.list,"LdsOrd")
Containers.LdsOrd = container({
 citation_list = {index=1,type= "array", title= _("Citations"), items= {type= "string", maxLength= 50}},
 note_list     = {index=2,type= "array", title= _("Notes"), items = {type= "string", maxLength= 50}},
 date          = {index=3,oneOf= {{type= "null"},{class = Containers.Date}}, title= _("Date")},
 type          = {index=4,type= "integer", title= _("Type")},
 place         = {index=5,type= "string", title= _("Place")},
 famc          = {index=6,type= {"null", "string"}, title= _("Family")},
 temple        = {index=7,type= "string", title= _("Temple")},
 status        = {index=8,type= "integer", title= _("Status")},
 private       = {index=9,type= "boolean", title= _("Private")},
 scheme_type   = {title="LDS Ordinance", }
})

table.insert(Containers.list,"PlaceRef")
Containers.PlaceRef = container({
ref  = {index=1,type= "string", title= _("Handle"),maxLength= 50},
date = {index=2,oneOf= {{type= "null"}, {class=Containers.Date}}, title= _("Date")},
scheme_type={title="PlaceRef"}
})

table.insert(Containers.list,"PlaceName")
Containers.PlaceName = container({
value = {index=1,type= "string",title= _("Text")},
date  = {index=2,oneOf= {{type= "null"}, {class=Containers.Date}}, title= _("Date")},
lang  = {index=3,type= "string", title= _("Language")},
scheme_type={title="PlaceName"}
})

table.insert(Containers.list,"Place")
Containers.Place = container({
handle        = {index=1,type= "string", maxLength= 50, title= _("Handle")},
gramps_id     = {index=2,type= "string",title= _("Gramps ID")},
title         = {index=3,type= "string",title= _("Title")},
long          = {index=4,type= "string", title= _("Longitude")},
lat           = {index=5,type= "string",title= _("Latitude")},
placeref_list = {index=6,type= "array",items= {class=Containers.PlaceRef},title= _("Places")},
name          = {index=7, class=Containers.PlaceName},
alt_names     = {index=8,type= "array",items= {class=Containers.PlaceName},title= _("Alternate Names")},
place_type    = {index=9, class=Containers.PlaceType},
code          = {index=10,type= "string", title= _("Code")},
alt_loc       = {index=11,type= "array",items= {class=Containers.Location},title= _("Alternate Locations")},
urls          = {index=12,type= "array", items= {class=Containers.Url}, title= _("URLs")},
media_list    = {index=13,type= "array", items= {class=Containers.MediaRef}, title= _("Media")},
citation_list = {index=14,type= "array",items= {type= "string",maxLength= 50},title= _("Citations")},
note_list     = {index=15,type= "array",items= {type= "string",maxLength= 50},title= _("Notes")},
change        = {index=16,type= "integer", title= _("Last changed")},
tag_list      = {index=17,type= "array", items= {type= "string", maxLength= 50}, title= _("Tags")},
private       = {index=18,type= "boolean",title= _("Private")},
scheme_type={title="Place",hash = 'gramps_id',table='place', sort=true}
})

table.insert(Containers.list,"Event")
Containers.Event = container({
handle        ={index=1, type = 'string',  maxLength = 50, title = _('Handle')},
gramps_id     ={index=2, type = 'string',  title = _('Gramps ID')},
type          ={index=3, class = Containers.EventType},
date          ={index=4, oneOf = {{type = 'null'}, {class = Containers.Date}}, title = _('Date')},
description   ={index=5, type = 'string', title = _('Description')},
place         ={index=6, type = {'string', 'null'},maxLength = 50, title = _('Place')},
citation_list ={index=7, type = 'array', items= { type = 'string', maxLength = 50}, title = _('Citations')},
note_list     ={index=8, type = 'array', items={ type = 'string', maxLength = 50}, title = _('Notes')},
media_list    ={index=9, type = 'array', items={class =Containers.MediaRef}, title = _('Media')},
attribute_list={index=10, type = 'array', items={class=Containers.Attribute}, title = _('Media')},
change        ={index=11, type = 'integer', title = _('Last changed')},
tag_list      ={index=12, type = 'array', items={type = 'string',  maxLength = 50}, title = _('Tags')},
private       ={index=13, type = 'boolean', title = _('Private')},
scheme_type   ={title="Event", hash = 'gramps_id',table='event'}
})

table.insert(Containers.list,"Family")
Containers.Family = container({
handle         = {index=1,type= "string", maxLength= 50, title= _("Handle")},
gramps_id      = {index=2,type= "string",title= _("Gramps ID")},
father_handle  = {index=3,type= {"string", "null"},maxLength= 50,title= _("Father")},
mother_handle  = {index=4,type= {"string", "null"},maxLength= 50,title= _("Mother")},
child_ref_list = {index=5,type= "array", items= {class=Containers.ChildRef}, title= _("Children")},
type           = {index=6, class=FamilyRelType},
event_ref_list = {index=7,type= "array", items= {class=Containers.EventRef}, title= _("Events")},
media_list     = {index=8,type= "array", items= {class=Containers.MediaRef}, title= _("Media")},
attribute_list = {index=9,type= "array", items= {class=Containers.Attribute}, title= _("Attributes")},
lds_ord_list   = {index=10,type= "array", items= {class=Containers.LdsOrd}, title= _("LDS ordinances")},
citation_list  = {index=11,type= "array",items= {type= "string",maxLength= 50}, title= _("Citations")},
note_list      = {index=12,type= "array",items= {type= "string",maxLength= 50},title= _("Notes")},
change         = {index=13,type= "integer", title= _("Last changed")},
tag_list       = {index=14,type= "array", items= {type= "string", maxLength= 50}, title= _("Tags")},
private        = {index=15,type= "boolean",title= _("Private")},
scheme_type    = {title="Family", hash="gramps_id", table="family", sort=false}
})

table.insert(Containers.list,"Media")
Containers.Media = container({
handle        = {index=1,type= "string",maxLength=  50,title=  _("Handle")},
gramps_id     = {index=2,type= "string",title=  _("Gramps ID")},
path          = {index=3,type= "string",title=  _("Path")},
mime          = {index=4,type= "string",title=  _("MIME")},
desc          = {index=5,type= "string",title=  _("Description")},
checksum      = {index=6,type= "string",title=  _("Checksum")},
attribute_list= {index=7,type= "array",items={class=Containers.Attribute}, title=  _("Attributes")},
citation_list = {index=8,type= "array",items= {type=  "string", maxLength=  50},title=  _("Citations")},
note_list     = {index=9,type= "array",items= {type=  "string"}, title=  _("Notes")},
change        = {index=10,type= "integer",title=  _("Last changed")},
date          = {index=11,oneOf= {{type=  "null"}, {class=Containers.Date}},title=  _("Date")},
tag_list      = {index=12,type= "array",items=  {type=  "string",maxLength=  50},title=  _("Tags")},
private       = {index=13,type= "boolean",title=  _("Private")},
scheme_type={title="Media", hash="gramps_id", table="media", sort=true}
})


table.insert(Containers.list,"Person")
Containers.Person = {}
Containers.Person = container({
 handle            = {index= 1, type= "string", maxLength= 50, title= _("Handle")},
 gramps_id         = {index= 2, type= "string", title= _("Gramps ID")},
 gender            = {index= 3, type= "integer", minimum= 0, maximum= 2, title= _("Gender")},
 primary_name      = {index= 4, class = Containers.Name, title=_("Primary name")},
 alternate_names   = {index= 5, type= "array", items={class = Containers.Name}, title= _("Alternate names")},
 death_ref_index   = {index= 6, type= "integer", title= _("Death reference index")},
 birth_ref_index   = {index= 7, type= "integer", title= _("Birth reference index")},
 event_ref_list    = {index= 8, type= "array", items = {class = Containers.EventRef}, title= _("Event references")},
 family_list       = {index= 9, type= "array", items = {type = "string", maxLength= 50}, title= _("Families")},
 parent_family_list= {index= 10, type= "array", items= {type = "string", maxLength= 50}, title= _("Parent families")},
 media_list        = {index= 11, type ="array", items= {class = Containers.MediaRef}, title= _("Media")},
 address_list      = {index= 12, type= "array", items= {class = Containers.Address}, title= _("Addresses")},
 attribute_list    = {index= 13, type= "array", items= {class = Containers.Attribute}, title= _("Attributes")},
 urls              = {index= 14, type= "array", items= {class = Containers.Url}, title= _("Urls")},
 lds_ord_list      = {index= 15, type= "array", items= {class = Containers.LdsOrd}, title= _("LDS ordinances")},
 citation_list     = {index= 16, type= "array", items= {type = "string", maxLength= 50}, title= _("Citations")},
 note_list         = {index= 17, type= "array", items= {type = "string", maxLength= 50}, title= _("Notes")},
 change            = {index= 18, type= "integer", title= _("Last changed")},
 tag_list          = {index= 19, type= "array", items= {type= "string", maxLength= 50}, title= _("Tags")},
 private           = {index= 20, type= "boolean", title= _("Private")},
 person_ref_list   = {index= 21, type= "array", items={class = Containers.PersonRef}, title= _("Person references")},
 scheme_type       = {title="Person", hash = 'gramps_id',table='person', sort=true}

})

Containers.containers={}
for i,v in ipairs(Containers.list) do Containers.containers[v]=i end 


local schemes ={}
local classes ={}
local uses = {}
local base={}
local error =""

local function get_info()
	local file = io.open("./containers.lua", "r")	
	if file then
       local r=0
       local mod=""
		for line in file:lines() do 
           r=r+1
           m = line:match('Containers%.(%w+)%s*=%s*container%(')
           if m then 
               mod=m
               table.insert(schemes,mod)   
               uses[mod]={}
           end
           local c = line:match('class%s*=%s*Containers%.(%w+)')
           if c then 
               table.insert(classes,c) 
               table.insert(uses[mod],c)
               if not uses[c] then 
                   error = error .. string.format("\nModule %s in %s (line %d) not yet defined",c,mod,r)
               end
           end 
           
       end
       file:close()
   end
   
   for i,v in ipairs(schemes) do
      local found=false
      --print(i,v) 
      for _,v2 in ipairs(schemes) do 
            for k,m in pairs(uses[v2]) do 
                if  m==v then  found=true; break; end 
            end
            if found then break; end
      end
      if not found then table.insert(base,v) end 
   end
end

local function make_node(name,t,Class)
        local tab=""
        if t then tab=t.."   " end
        if 0==#tab then
            s = string.format("\\node[treenode]{%s}",_.T(name))       
        else
            s = string.format("%schild { node {%s}",t,_.T(name))
        end
        
        if Class then 
            name = Class.scheme.scheme_type.title
        end
        if Containers[name] then
            for i,key in pairs(Containers[name].scheme_index) do
        --if key=="gramps_id" then break end
            
                local entry = Containers[name].scheme[key]
                local class=entry.class
                if not class  and entry.items then 
                    class=entry.items.class
                end
                if not class and entry.oneOf then 
                    class=entry.oneOf[2].class
                end
                --print(i,key,class)
                
                s=s..make_node(key,tab,class) 
            end
        end 
        if 0==#tab then s=s.."; " else s = s.."} " end
        return s
end

local _make_forest,_make_forest_class, make_forest

Containers.extra_forest = {"Date","Name"}

local function inTable(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true  end
    end
    return false
end

local function indexTable(tbl,value)
    for i, v in ipairs(tbl) do
        if v == value then return i  end
    end
    print(value)
    return 0
end
    

function _make_forest_class(class,tab)
    local sc
    local name=class.scheme.scheme_type.title
    if inTable(Containers.extra_forest,name) then
        sc = string.format("[ %s",
             _.T(name))
    else
        sc = string.format("[ %s", _.T(name))
        sc=sc.._make_forest(class,tab)
    end
    sc=sc..string.format("\n%s]",tab)
    return sc
end

local _entry_type
function _entry_type(entry)
    if type(entry)=="table" then
        local ret={}
        for k,v in pairs(entry) do table.insert(ret,_entry_type(v)) end
        return table.concat(ret,';')

    elseif entry=="string" then return "S"
    elseif entry=="boolean" then return "B"
    elseif entry=="integer" then return "I"
    elseif entry=="null" then return "nill"
    end 
end

function _make_forest(cont,t,Class)
    local tab=t.."   "
    local s=""

    for i=#cont.scheme_index,1,-1 do
        local key=cont.scheme_index[i]
        --print(i,key)
        s = s..string.format("\n%s[ %s ",tab,_.T(key))

        local entry = cont.scheme[key]
        if entry and entry.type then
            if entry.type=="array" then
                if entry.items.type=="string" then  s=s.._.T("{S} ")
                elseif entry.items.class  then
                    s=s.._.T("{C} ")
                    s=s .. _make_forest_class(entry.items.class,tab)
                end
            else            
                s=s.."("
                s=s.._entry_type(entry.type)
                s=s..") "
            end
            --s=s.."}"
        elseif entry and entry.class then
            --print(entry.class.scheme.scheme_type.title)
            s=s .. _make_forest_class(entry.class,tab)
        end

        s=s..string.format("]")
    end
    return s
end


function make_forest(name)
    if 0==#schemes then  get_info()end
    local s = string.format("\\begin{forest} "..
        "for tree={grow=east, l sep=5ex, s sep=-1ex}"..
        " [%s",_.T(name))

    if Containers[name] then
        local cont = Containers[name]
        s=s.._make_forest(cont,"")
    end
    s=s.."\n] \\end{forest} "
    return s
end

Containers.make_node = make_node
Containers.make_forest = make_forest
function Containers.makenode(n) return _.T(make_node(n)) end
    

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    tex={}
    get_info()
    --print("SCHEMES");for i,v in ipairs(schemes) do print(i,v) end
    --print("USES");for k,v in pairs(uses) do print(k,table.concat(v,", ")) end
    --print("CLASSES");for i,v in ipairs(classes) do print(i,v) end
    --print("BASE");for i,v in ipairs(base) do print(i,v) end
       
    print(error)
    print(make_forest('Person'))
    --for i,v in ipairs(base) do print(make_forest(v)) end

    --print(Containers.make_node('Citation'))
    --\\begin{tikzpicture}
    --make_node('Note'))
else
  return Containers
end
