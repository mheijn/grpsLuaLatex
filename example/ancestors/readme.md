## example ancestors ##

### make bib file ###

Edit **make_bib.lua** for the correct gramps database.
run <ins>lua make_bib.lua</ins> creating **gramps.bo**.

##  generate pdf ##
Edit **ancestors.tex** for the correct gramps database and
change  **ancestors.tex, ancestors.lua, person.lua** and **pictures.lua** 
at will.

run <ins>lualatex -shell-escape ancestors.tex</ins>

## langiage adjustments ##

For language corrections and adjustments edit **po/??.po**.
See further the use of **mh/gettext**.
