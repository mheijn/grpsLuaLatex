local Lan = {}

function Lan:Lan(str) return str end

setmetatable(Lan, {
    __call = function(_,str)
        return Lan:Lan(str)
    end,


})

Lan.Addrestype={
    0, -- unknown
    1, -- street postal city etc
    2,-- street city country postal
    }
    
--{name,code adres}
local languages ={
    nl={Lan(Dutch),31,1}
    }
    
Language = 'nl'
function Lan.language() return Language end
function Lan.addressform() return languages[Language][3] end



return Lan
