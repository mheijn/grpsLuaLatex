if not table.deep_merge then function table.deep_merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            deep_merge(t1[k], v)
        else
            t1[k] = v
        end
    end
end end

if not table.copy then function table.copy(orig)
    local copy = {}
    for key, value in pairs(orig) do
        if type(value)=="table" then
            copy[key]= table.copy(value)
        else
            copy[key] = value
        end
    end
    return copy
end end

--- delivers the next index
--
if not table.next then function table.next(tab,index)
    local temp = nil
    local totleft = #tab
    for i,_ in pairs(tab) do
        totleft = totleft - 1
        if temp==index then return i,totleft end
        temp=i
    end
    return 0,-1
end end

--- delivers the previous index
--
if not table.priv then function table.priv(t,index)
    local temp=nil
    for i,_ in pairs(t) do
        if i==index then return (temp) end
        temp=i
    end
    return nil
end end

--- delivers the nlast index
--
if not table.last then function table.last(t,index)
    local temp=nil
    for i,_ in pairs(t) do
        temp=i
    end
    return temp
end end

if not string.bytes then function string.bytes(str)
    local bytes = {}
    for i = 1, #str do
        bytes[i] = string.byte(str, i)
    end
    return bytes
end end

if not string.split then function string:split(delimiter)
    if not delimiter or delimiter == "" then
        return {self} -- If no delimiter is given, return the whole string
    end
    local result = {}

    for match in (self .. delimiter):gmatch("([^..delimiter..*])" .. delimiter) do
        table.insert(result, match)
    end
    return result
end end

if not string.gdef then function string.gdef(key,value)
    return "\\gdef\\"..key.."{"..value.."}"
end end

if not string.texcommand then function string.texcommand(command)
    return "\\"..command
end end

if not table.join then function table.join(tab,delimiter)
    s=""
    for i=1,#tab-1 do
        if type(tab[i])=="string" then
            if #tab[i]>0 then
                if #s>0 then s=s..delimiter end
                s=s..tab[i]
            end
        end
    end
    return s
end end

local u={}

function texify(s, t)
    if t==nil then t=true end
    if(tex and t )then
        s=string.gsub(s,"\\","\\backslash")
        s=string.gsub(s,"\n","\\newline ")
        s=string.gsub(s,"{","$\\{$")
        s=string.gsub(s,"}","$\\}$")
        s=string.gsub(s,'%[',"(")
        s=string.gsub(s,'%]',")")
        s=string.gsub(s,"/","$/$")
        s=string.gsub(s,'_',"\\_")
    end
    return s
end

function u.dump(o,gen,t)
    if t==nil then t=true end
    if gen == nil then gen=0 end

   if type(o) == 'table' then
      local s = texify("{\n",t)
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = "'"..k.."'" end
         s =  s .. string.rep("-", gen*3)..texify("["..k.."]",t)..' = '
         local sn = u.dump(v,gen+1,t) .. texify(',\n',t)
         s = s..sn
      end
      if tex then
        return string.sub(s,1,-10) .."$\\}$"
      else
        return string.sub(s,1,-2) .."}"
      end
   else
      return texify(tostring(o),t)
   end
end

function u.dump_key(o,gen)
   if gen == nil then gen=0 end

   if type(o) == 'table' then
      local s = '{\n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s =  s .. string.rep(".", gen*3)..'['..k..'] = '
         local sn = u.dump_key(v,gen+1) .. ',\n'
         s = s..sn
      end
      return string.sub(s,1,-2) ..'}'
   else
      return "--"
   end
end

function u.is_zero(s,a,b)
if s==0 then return(a) else return(b) end end

function u.is_empty(s,a,b)
if #s>0 then return(b) else return(a) end end

function u.comma_con(s1,s2)
   return s1..u.is_empty(s1,"",u.is_empty(s2,"",", "))..s2
end

function u.roman(num)
   res={'i','ii','iii','iv','v','vi','vii','viii','ix','x','xi','xii','xiii','xiv'}
   return res[num]
end

function u.Roman(num)
   res={'','I','II','III','IV','V','VI','VII','VIII','IX'}
   tens={'X','XX','XXX','XXXX',}
   s=res[(num % 10)+1]
   if num > 9 then
      s=tens[math.floor(num/10)]..s
    end
   return s
end

function u.alphanumber(n)
  local s=""
  if n>0 then
    local num1 = (n-1) % 26 +1
    local num2 = math.floor(n/26)
    s = string.char(96+num1)
    if num2>0 then s = string.char(96+num2)..s end
  end
  return s
end

function u.printfun(f,n)
	print("\n"..n.." =")
	if f then
        if type(f) == "table" then
            for k,v in pairs(f) do print(string.format("data     %-20s %-20s %s",tostring(k),type(v), tostring(v))) end
            local m = getmetatable(f)
            if m then
                for k,v in pairs(m) do print("metadata ",k,type(v),v) end
            end
        else
            print(f.." is not a table")
        end
	end
end


if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    -- pass
    print(u.days_from_year_0(0,0,0))
    print(u.days_from_year_0(1962,6,9))
    print(u.alphanumber(0))
    print(string.byte('a' ))
    print(u.alphanumber(1))
    print(u.alphanumber(27))
    print(table,join({"een","twee","","drie",4}," ++ "))
else
    return(u)
end
