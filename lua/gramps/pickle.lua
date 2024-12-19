require("gramps.util")
local dodebug = false
local MAX_SIZE = (2^63 - 1)

-- Pickle opcodes.  See pickletools.py for extensive docs.  The listing
-- here is in kind-of alphabetical order of 1-character pickle code.
-- pickletools groups them by purpose.

MARK           = string.byte('(')   -- push special markobject on stack
STOP           = string.byte('.')   -- every pickle ends with STOP
POP            = string.byte('0')   -- discard topmost stack item
POP_MARK       = string.byte('1')   -- discard stack top through topmost markobject
DUP            = string.byte('2')   -- duplicate top stack item
FLOAT          = string.byte('F')   -- push float object; decimal string argument
INT            = string.byte('I')   -- push integer or bool; decimal string argument
BININT         = string.byte('J')   -- push four-byte signed int
BININT1        = string.byte('K')   -- push 1-byte unsigned int
LONG           = string.byte('L')   -- push long; decimal string argument
BININT2        = string.byte('M')   -- push 2-byte unsigned int
NONE           = string.byte('N')   -- push None
PERSID         = string.byte('P')   -- push persistent object; id is taken from string arg
BINPERSID      = string.byte('Q')   --  "       "         "  ;  "  "   "     "  stack
REDUCE         = string.byte('R')   -- apply callable to argtuple, both on stack
STRING         = string.byte('S')   -- push string; NL-terminated string argument
BINSTRING      = string.byte('T')   -- push string; counted binary string argument
SHORT_BINSTRING= string.byte('U')   --  "     "   ;    "      "       "      " < 256 bytes
UNICODE        = string.byte('V')   -- push Unicode string; raw-unicode-escaped'd argument
BINUNICODE     = string.byte('X')   --   "     "       "  ; counted UTF-8 string argument
APPEND         = string.byte('a')   -- append stack top to list below it
BUILD          = string.byte('b')   -- call __setstate__ or __dict__.update()
GLOBAL         = string.byte('c')   -- push self.find_class(modname, name); 2 string args
DICT           = string.byte('d')   -- build a dict from stack items
EMPTY_DICT     = string.byte('}')   -- push empty dict
APPENDS        = string.byte('e')   -- extend list on stack by topmost stack slice
GET            = string.byte('g')   -- push item from memo on stack; index is string arg
BINGET         = string.byte('h')   --   "    "    "    "   "   "  ;   "    " 1-byte arg
INST           = string.byte('i')   -- build & push class instance
LONG_BINGET    = string.byte('j')   -- push item from memo on stack; index is 4-byte arg
LIST           = string.byte('l')   -- build list from topmost stack items
EMPTY_LIST     = string.byte(']')   -- push empty list
OBJ            = string.byte('o')   -- build & push class instance
PUT            = string.byte('p')   -- store stack top in memo; index is string arg
BINPUT         = string.byte('q')   --   "     "    "   "   " ;   "    " 1-byte arg
LONG_BINPUT    = string.byte('r')   --   "     "    "   "   " ;   "    " 4-byte arg
SETITEM        = string.byte('s')   -- add key+value pair to dict
TUPLE          = string.byte('t')   -- build tuple from topmost stack items
EMPTY_TUPLE    = string.byte(')')   -- push empty tuple
SETITEMS       = string.byte('u')   -- modify dict by adding topmost key+value pairs
BINFLOAT       = string.byte('G')   -- push float; arg is 8-byte float encoding

TRUE           = 'I01'  -- not an opcode; see INT docs in pickletools.py
FALSE          = 'I00'  -- not an opcode; see INT docs in pickletools.py

-- Protocol 2

PROTO          = 0x80  -- identify pickle protocol
NEWOBJ         = 0x81  -- build object by applying cls.__new__ to argtuple
EXT1           = 0x82  -- push object from extension registry; 1-byte index
EXT2           = 0x83  -- ditto, but 2-byte index
EXT4           = 0x84  -- ditto, but 4-byte index
TUPLE1         = 0x85  -- build 1-tuple from stack top
TUPLE2         = 0x86  -- build 2-tuple from two topmost stack items
TUPLE3         = 0x87  -- build 3-tuple from three topmost stack items
NEWTRUE        = 0x88  -- push True
NEWFALSE       = 0x89  -- push False
LONG1          = 0x8a  -- push long from < 256 bytes
LONG4          = 0x8b  -- push really big long

_tuplesize2code = {EMPTY_TUPLE, TUPLE1, TUPLE2, TUPLE3}

-- Protocol 3 (Python 3.x)

BINBYTES       = string.byte('B')   -- push bytes; counted binary string argument
SHORT_BINBYTES = string.byte('C')   --  "     "   ;    "      "       "      " < 256 bytes

-- Protocol 4

SHORT_BINUNICODE = 0x8c  -- push short string; UTF-8 length < 256 bytes
BINUNICODE8      = 0x8d  -- push very long string
BINBYTES8        = 0x8e  -- push very long bytes string
EMPTY_SET        = 0x8f  -- push empty set on the stack
ADDITEMS         = 0x90  -- modify set by adding topmost stack items
FROZENSET        = 0x91  -- build frozenset from topmost stack items
NEWOBJ_EX        = 0x92  -- like NEWOBJ but work with keyword only arguments
STACK_GLOBAL     = 0x93  -- same as GLOBAL but using names on the stacks
MEMOIZE          = 0x94  -- store top of the stack in memo
FRAME            = 0x95  -- indicate the beginning of a new frame

-- Protocol 5

BYTEARRAY8       = 0x96  -- push bytearray
NEXT_BUFFER      = 0x97  -- push next out-of-band buffer
READONLY_BUFFER  = 0x98  -- make top of stack readonly

HIGHEST_PROTOCOL = 5
DEFAULT_PROTOCOL = 5

-----------------------------------------------------------------------------------
--     STACK
-----------------------------------------------------------------------------------
-- Custom type function to check for our custom __type
local function custom_type(obj)
    local mt = getmetatable(obj)
    if mt and mt.__type then
        return mt.__type
    else
        return type(obj)  -- Fallback to default Lua types
    end
end

local Stack = {_TYPE='module', _NAME='stack', __type="stack"}
Stack.__index = Stack
function Stack:new()
    local stack={pile ={} }
    setmetatable(stack,Stack)
    return stack
end
-- Push an element onto the stack
function make_string(val)
    local s=""
    local t = custom_type(val)
    if t=="stack" then
        for i,v in ipairs(val.pile) do
            s=s..make_string(v)
        end
        s = "{"..s.."}, "
    elseif t=="table" then
        for i,v in ipairs(val) do
            s=s..make_string(v)
        end
        s = "{"..s.."}, "
    else
        s=tostring(val)..", "
    end
    return s
end

function Stack:push(value)
    --print("push", custom_type(value),make_string(value))
    if custom_type(value) == "stack" then
        table.insert(self.pile, value:copy())
    elseif custom_type(value) == "table" then
        table.insert(self.pile, table.copy(value))
    else
        table.insert(self.pile, value)
    end
end

-- Pop an element from the stack
function Stack:pop(stack)
    return table.remove(self.pile)
end

function Stack:copy()
    copy = Stack:new()
    for key, value in pairs(self.pile) do
        if type(value) == "table" then
            copy.pile[key] = value
        else
            copy.pile[key] = value
        end
    end
    return copy
end

function Stack:last()
    --print("last",make_string(self.pile))
    return self.pile[#self.pile]
end
function Stack:print()
    print("STACK",make_string(self.pile))
end
function Stack:get()
    return self.pile
end
-----------------------------------------------------------------------------------
--     FRAME
-----------------------------------------------------------------------------------
frame = {size = 0, current_frame = 0}

function frame:new(buf)
    self.size = #buf
    --print("frame",self.size,buf)
    if type(buf)=="string" then
        self.dat = {}
        for i = 1, #buf do
            self.dat[i] = string.byte(buf, i)
        end
    else
        self.dat = buf
    end
    self.current_frame = 1
    return self
end

function frame:read(n)
    local str={}

    for i = self.current_frame, self.current_frame+n-1 do
        assert(i <= self.size,"Read beyound data size in FRAME")
        if dodebug then print(string.format("n=%3d current:%3d of %3d getting %3d", n,i, self.size,self.dat[i])) end
        --assert(string.format("n=%3d current:%3d of %3d getting %3d", n,i, self.size,self.dat[i]))
        table.insert(str,self.dat[i])
    end
    self.current_frame = self.current_frame + n
    --assert(self.current_frame <115,"onder de 400")
    return str
end

function frame:readline(n)
    local data={}
    for i=self.current_frame, self.size do
        assert(i <= self.size,"Read beyound data size in FRAME")
        table.insert(data,self.data[i])
        self.current_frame = self.current_frame + 1
        if self.data[i] == string.byte("\n") then break end
    end
    return data
end

-----------------------------------------------------------------------------------
--     DEPICKLE
-----------------------------------------------------------------------------------
depickle = depickle or {}
function depickle.depickle(data)
    depickle.stack = Stack:new()
    depickle.metastack = Stack:new()
    depickle.append = function(v) depickle.stack:push(v) end
    depickle.memo = {}
    depickle.frame  = frame:new(data)
    --assert(false,string.format("data %d %s",#data,data))

    while true do
        key = frame:read(1)[1]
        if dodebug then print(string.format("key=%3d or %s",key,string.char(key))) end
        assert(depickle.dispatch[key],string.format("Dispatching error key=%3d or %s",key,string.char(key)))
        depickle.dispatch[key]()
        if key==STOP then
            return depickle._Stop
        end
    end
end

function depickle.pop_mark()
        local items = depickle.stack:get()
        depickle.stack = depickle.metastack:pop()
        depickle.append = function(v) depickle.stack:push(v) end
        return items
end

depickle.dispatch = {}

function depickle.load_proto()
        local proto = depickle.read(1)[1]
        assert( 0 <= proto and proto <= HIGHEST_PROTOCOL,
            string.format("unsupported pickle protocol: %d", proto))
        depickle.proto = proto
end
depickle.dispatch[PROTO] = depickle.load_proto

--[[
function depickle.load_frame()
        frame_size, = unpack('<Q', depickle.read(8))
        if frame_size > sys.maxsize:
            raise ValueError("frame size > sys.maxsize: %d" % frame_size)
        depickle._unframer.load_frame(frame_size)
end
depickle.dispatch[FRAME] = depickle.load_frame

function depickle.load_persid()
        try:
            pid = depickle.readline()[:-1].decode("ascii")
        except UnicodeDecodeError:
            raise UnpicklingError(
                "persistent IDs in protocol 0 must be ASCII strings")
        depickle.append(depickle.persistent_load(pid))
end
depickle.dispatch[PERSID[0] ] = depickle.load_persid
function depickle.load_binpersid()
        pid = depickle.stack.pop()
        depickle.append(depickle.persistent_load(pid))
end
depickle.dispatch[BINPERSID[0] ] = depickle.load_binpersid
]]--
function depickle.load_none()
        depickle.append(nil)
end
depickle.dispatch[NONE] = depickle.load_none

function depickle.load_false()
        depickle.append(false)
end
depickle.dispatch[NEWFALSE] = depickle.load_false

function depickle.load_true()
        depickle.append(true)
end
depickle.dispatch[NEWTRUE] = depickle.load_true

function depickle.load_int()
        data = string.char(table.unpack(depickle.readline()))
        if data == FALSE then
            val = false
        elseif data == TRUE then
            val = true
        else
            val = tonumber(data) or 0
        end
        depickle.append(val)
end
depickle.dispatch[INT] = depickle.load_int

function depickle.load_binint()
        depickle.append(string.unpack('<i', string.char(table.unpack(depickle.read(4)))))
end
depickle.dispatch[BININT] = depickle.load_binint

function depickle.load_binint1()
        depickle.append(depickle.read(1)[1])
end
depickle.dispatch[BININT1] = depickle.load_binint1

function depickle.load_binint2()
        depickle.append(string.unpack('<H',string.char(table.unpack(depickle.read(2)))))
end
depickle.dispatch[BININT2] = depickle.load_binint2
--[[
function depickle.load_long()
        val = depickle.readline()[:-1]
        if val and val[-1] == b'L'[0]:
            val = val[:-1]
        depickle.append(int(val, 0))
end
depickle.dispatch[LONG[0] ] = depickle.load_long

function depickle.load_long1()
        n = depickle.read(1)[0]
        data = depickle.read(n)
        depickle.append(decode_long(data))
end
depickle.dispatch[LONG1[0] ] = depickle.load_long1

function depickle.load_long4()
        n, = unpack('<i', depickle.read(4))
        if n < 0:
            # Corrupt or hostile pickle -- we never write one like this
            raise UnpicklingError("LONG pickle has negative byte count")
        data = depickle.read(n)
        depickle.append(decode_long(data))
end
depickle.dispatch[LONG4[0] ] = depickle.load_long4

function depickle.load_float()
        depickle.append(float(depickle.readline()[:-1]))
end
depickle.dispatch[FLOAT[0] ] = depickle.load_float

function depickle.load_binfloat()
        depickle.append(unpack('>d', depickle.read(8))[0])
end
depickle.dispatch[BINFLOAT[0] ] = depickle.load_binfloat

function depickle._decode_string(depickle, value):
        # Used to allow strings from Python 2 to be decoded either as
        # bytes or Unicode strings.  This should be used only with the
        # STRING, BINSTRING and SHORT_BINSTRING opcodes.
        if depickle.encoding == "bytes":
            return value
        else:
            return value.decode(depickle.encoding, depickle.errors)

function depickle.load_string()
        data = depickle.readline()[:-1]
        # Strip outermost quotes
        if len(data) >= 2 and data[0] == data[-1] and data[0] in b'"\'':
            data = data[1:-1]
        else:
            raise UnpicklingError("the STRING opcode argument must be quoted")
        depickle.append(depickle._decode_string(codecs.escape_decode(data)[0]))
end
depickle.dispatch[STRING[0] ] = depickle.load_string

function depickle.load_binstring()
        # Deprecated BINSTRING uses signed 32-bit length
        len, = unpack('<i', depickle.read(4))
        if len < 0:
            raise UnpicklingError("BINSTRING pickle has negative byte count")
        data = depickle.read(len)
        depickle.append(depickle._decode_string(data))
end
depickle.dispatch[BINSTRING[0] ] = depickle.load_binstring

function depickle.load_binbytes()
        len, = unpack('<I', depickle.read(4))
        if len > maxsize:
            raise UnpicklingError("BINBYTES exceeds system's maximum size "
                                  "of %d bytes" % maxsize)
        depickle.append(depickle.read(len))
end
depickle.dispatch[BINBYTES[0] ] = depickle.load_binbytes

function depickle.load_unicode()
        depickle.append(str(depickle.readline()[:-1], 'raw-unicode-escape'))
end
depickle.dispatch[UNICODE[0] ] = depickle.load_unicode
]]--
function depickle.load_binunicode()
        local len = string.unpack('<I', string.char(table.unpack(depickle.read(4))))
        assert( len <= MAX_SIZE , string.format("BINUNICODE exceeds system's maximum size of %f bytes", MAX_SIZE) )
        --depickle.append(str(depickle.read(len), 'utf-8', 'surrogatepass'))
        --local t = depickle.read(len)
        depickle.append(string.char(table.unpack(depickle.read(len))))
end
depickle.dispatch[BINUNICODE] = depickle.load_binunicode

--[[
function depickle.load_binunicode8()
        len, = unpack('<Q', depickle.read(8))
        if len > maxsize:
            raise UnpicklingError("BINUNICODE8 exceeds system's maximum size "
                                  "of %d bytes" % maxsize)
        depickle.append(str(depickle.read(len), 'utf-8', 'surrogatepass'))
end
depickle.dispatch[BINUNICODE8[0] ] = depickle.load_binunicode8

function depickle.load_binbytes8()
        len, = unpack('<Q', depickle.read(8))
        if len > maxsize:
            raise UnpicklingError("BINBYTES8 exceeds system's maximum size "
                                  "of %d bytes" % maxsize)
        depickle.append(depickle.read(len))
end
depickle.dispatch[BINBYTES8[0] ] = depickle.load_binbytes8

function depickle.load_bytearray8()
        len, = unpack('<Q', depickle.read(8))
        if len > maxsize:
            raise UnpicklingError("BYTEARRAY8 exceeds system's maximum size "
                                  "of %d bytes" % maxsize)
        b = bytearray(len)
        depickle.readinto(b)
        depickle.append(b)
end
depickle.dispatch[BYTEARRAY8[0] ] = depickle.load_bytearray8

function depickle.load_next_buffer()
        if depickle._buffers is None:
            raise UnpicklingError("pickle stream refers to out-of-band data "
                                  "but no *buffers* argument was given")
        try:
            buf = next(depickle._buffers)
        except StopIteration:
            raise UnpicklingError("not enough out-of-band buffers")
        depickle.append(buf)
end
depickle.dispatch[NEXT_BUFFER[0] ] = depickle.load_next_buffer

function depickle.load_readonly_buffer()
        buf = depickle.stack[-1]
        with memoryview(buf) as m:
            if not m.readonly:
                depickle.stack[-1] = depickle.m.toreadonly()
end
depickle.dispatch[READONLY_BUFFER[0] ] = depickle.load_readonly_buffer

function depickle.load_short_binstring()
        len = depickle.read(1)[0]
        data = depickle.read(len)
        depickle.append(depickle._decode_string(data))
end
depickle.dispatch[SHORT_BINSTRING[0] ] = depickle.load_short_binstring

function depickle.load_short_binbytes()
        len = depickle.read(1)[0]
        depickle.append(depickle.read(len))
end
depickle.dispatch[SHORT_BINBYTES[0] ] = depickle.load_short_binbytes

function depickle.load_short_binunicode()
        len = depickle.read(1)[0]
        depickle.append(str(depickle.read(len), 'utf-8', 'surrogatepass'))
end
depickle.dispatch[SHORT_BINUNICODE[0] ] = depickle.load_short_binunicode
--]]

function depickle.load_tuple()
        local items = depickle.pop_mark()
        depickle.append(items)
end
depickle.dispatch[TUPLE] = depickle.load_tuple


function depickle.load_empty_tuple()
        depickle.append({})
end
depickle.dispatch[EMPTY_TUPLE] = depickle.load_empty_tuple

function depickle.load_tuple1()
        depickle.stack:push({depickle.stack:pop()})
end
depickle.dispatch[TUPLE1] = depickle.load_tuple1

function depickle.load_tuple2()
        local pop1 = depickle.stack:pop()
        depickle.stack:push({depickle.stack:pop(), pop1})
end
depickle.dispatch[TUPLE2] = depickle.load_tuple2

function depickle.load_tuple3()
        local pop1 = depickle.stack:pop()
        local pop2 = depickle.stack:pop()
        depickle.stack:push({depickle.stack.pop(),pop2,pop1})
end
depickle.dispatch[TUPLE3] = depickle.load_tuple3

function depickle.load_empty_list()
        depickle.append({})
end
depickle.dispatch[EMPTY_LIST] = depickle.load_empty_list

function depickle.load_empty_dictionary()
        depickle.append({})
end
depickle.dispatch[EMPTY_DICT] = depickle.load_empty_dictionary
--[[
function depickle.load_empty_set()
        depickle.append(set())
end
depickle.dispatch[EMPTY_SET[0] ] = depickle.load_empty_set

function depickle.load_frozenset()
        items = depickle.pop_mark()
        depickle.append(frozenset(items))
end
depickle.dispatch[FROZENSET[0] ] = depickle.load_frozenset

function depickle.load_list()
        items = depickle.pop_mark()
        depickle.append(items)
end
depickle.dispatch[LIST[0] ] = depickle.load_list

function depickle.load_dict()
        items = depickle.pop_mark()
        d = {items[i]: items[i+1]
             for i in range(0, len(items), 2)}
        depickle.append(d)
end
depickle.dispatch[DICT[0] ] = depickle.load_dict

    -- INST and OBJ differ only in how they get a class object.  It's not
    -- only sensible to do the rest in a common routine, the two routines
    -- previously diverged and grew different bugs.
    -- klass is the class to instantiate, and k points to the topmost mark
    -- object, following which are the arguments for klass.__init__.
function depickle._instantiate(depickle, klass, args):
        if (args or not isinstance(klass, type) or
            hasattr(klass, "__getinitargs__")):
            try:
                value = klass(*args)
            except TypeError as err:
                raise TypeError("in constructor for %s: %s" %
                                (klass.__name__, str(err)), err.__traceback__)
        else:
            value = klass.__new__(klass)
        depickle.append(value)

function depickle.load_inst()
        module = depickle.readline()[:-1].decode("ascii")
        name = depickle.readline()[:-1].decode("ascii")
        klass = depickle.find_class(module, name)
        depickle._instantiate(klass, depickle.pop_mark())
end
depickle.dispatch[INST[0] ] = depickle.load_inst

function depickle.load_obj()
        # Stack is ... markobject classobject arg1 arg2 ...
        args = depickle.pop_mark()
        cls = args.pop(0)
        depickle._instantiate(cls, args)
end
depickle.dispatch[OBJ[0] ] = depickle.load_obj

function depickle.load_newobj()
        args = depickle.stack.pop()
        cls = depickle.stack.pop()
        obj = cls.__new__(cls, *args)
        depickle.append(obj)
end
depickle.dispatch[NEWOBJ[0] ] = depickle.load_newobj

function depickle.load_newobj_ex()
        kwargs = depickle.stack.pop()
        args = depickle.stack.pop()
        cls = depickle.stack.pop()
        obj = cls.__new__(cls, *args, **kwargs)
        depickle.append(obj)
end
depickle.dispatch[NEWOBJ_EX[0] ] = depickle.load_newobj_ex

function depickle.load_global()
        module = depickle.readline()[:-1].decode("utf-8")
        name = depickle.readline()[:-1].decode("utf-8")
        klass = depickle.find_class(module, name)
        depickle.append(klass)
end
depickle.dispatch[GLOBAL[0] ] = depickle.load_global

function depickle.load_stack_global()
        name = depickle.stack.pop()
        module = depickle.stack.pop()
        if type(name) is not str or type(module) is not str:
            raise UnpicklingError("STACK_GLOBAL requires str")
        depickle.append(depickle.find_class(module, name))
end
depickle.dispatch[STACK_GLOBAL[0] ] = depickle.load_stack_global

function depickle.load_ext1()
        code = depickle.read(1)[0]
        depickle.get_extension(code)
end
depickle.dispatch[EXT1[0] ] = depickle.load_ext1

function depickle.load_ext2()
        code, = unpack('<H', depickle.read(2))
        depickle.get_extension(code)
end
depickle.dispatch[EXT2[0] ] = depickle.load_ext2

function depickle.load_ext4()
        code, = unpack('<i', depickle.read(4))
        depickle.get_extension(code)
end
depickle.dispatch[EXT4[0] ] = depickle.load_ext4

function depickle.get_extension(depickle, code):
        obj = _extension_cache.get(code, _NoValue)
        if obj is not _NoValue:
            depickle.append(obj)
            return
        key = _inverted_registry.get(code)
        if not key:
            if code <= 0: # note that 0 is forbidden
                # Corrupt or hostile pickle.
                raise UnpicklingError("EXT specifies code <= 0")
            raise ValueError("unregistered extension code %d" % code)
        obj = depickle.find_class(*key)
        _extension_cache[code] = depickle.obj
        depickle.append(obj)

function depickle.find_class(depickle, module, name):
        # Subclasses may override this.
        sys.audit('pickle.find_class', module, name)
        if depickle.proto < 3 and depickle.fix_imports:
            if (module, name) in _compat_pickle.NAME_MAPPING:
                module, name = _compat_pickle.NAME_MAPPING[(module, name)]
            elif module in _compat_pickle.IMPORT_MAPPING:
                module = _compat_pickle.IMPORT_MAPPING[module]
        __import__(module, level=0)
        if depickle.proto >= 4 and '.' in name:
            dotted_path = name.split('.')
            try:
                return _getattribute(sys.modules[module], dotted_path)
            except AttributeError:
                raise AttributeError(
                    f"Can't resolve path {name!r} on module {module!r}")
        else:
            return getattr(sys.modules[module], name)

function depickle.load_reduce()
        stack = depickle.stack
        args = stack.pop()
        func = stack[-1]
        stack[-1] = depickle.func(*args)
end
depickle.dispatch[REDUCE[0] ] = depickle.load_reduce

function depickle.load_pop()
        if depickle.stack:
            del depickle.stack[-1]
        else:
            depickle.pop_mark()
end
depickle.dispatch[POP[0] ] = depickle.load_pop

function depickle.load_pop_mark()
        depickle.pop_mark()
end
depickle.dispatch[POP_MARK[0] ] = depickle.load_pop_mark

function depickle.load_dup()
        depickle.append(depickle.stack[-1])
end
depickle.dispatch[DUP[0] ] = depickle.load_dup

function depickle.load_get()
        i = int(depickle.readline()[:-1])
        try:
            depickle.append(depickle.memo[i])
        except KeyError:
            msg = f'Memo value not found at index {i}'
            raise UnpicklingError(msg) from None
end
depickle.dispatch[GET[0] ] = depickle.load_get
]]--

function depickle.load_binget()
        local i = depickle.read(1)[1]
        assert(depickle.memo[i+1] ~= nil,string.format("Memo value not found at index [%d]",i))
        depickle.append(depickle.memo[i+1]) --+1 frompython to lua
end
depickle.dispatch[BINGET] = depickle.load_binget

--[[
function depickle.load_long_binget()
        i, = unpack('<I', depickle.read(4))
        try:
            depickle.append(depickle.memo[i])
        except KeyError as exc:
            msg = f'Memo value not found at index {i}'
            raise UnpicklingError(msg) from None
end
depickle.dispatch[LONG_BINGET[0] ] = depickle.load_long_binget

]]--
function depickle.load_put()
        local i = int(depickle.readline())
        assert(i >= 0, "negative PUT argument")
        depickle.memo[i+1] = depickle.stack:last()
end
depickle.dispatch[PUT] = depickle.load_put

function depickle.load_binput()
        local i = depickle.read(1)[1]
        assert(i >= 0, "negative BINPUT argument")
        depickle.memo[i+1] = depickle.stack:last() -- +1 from python to Lua
end
depickle.dispatch[BINPUT] = depickle.load_binput

function depickle.load_long_binput()
        local i = string.unpack('<I', string.char(table.unpack(depickle.read(4))))
        assert(i < MAX_SIZE,"negative LONG_BINPUT argument")
        depickle.memo[i+1] = depickle.stack:last()
end
depickle.dispatch[LONG_BINPUT] = depickle.load_long_binput
--[[
function depickle.load_memoize()
        memo = depickle.memo
        memo[len(memo)] = depickle.stack[-1]
end
depickle.dispatch[MEMOIZE[0] ] = depickle.load_memoize
]]--
function depickle.load_append()
        local value  = depickle.stack:pop()
        local list  = depickle.stack:pop()
        table.insert(list,value)
        depickle.stack:push(list)
end
depickle.dispatch[APPEND] = depickle.load_append

function depickle.load_appends()
        local items = depickle.pop_mark()
        local list_obj = depickle.stack:pop()
        --try:
        --    extend = list_obj.extend
        --except AttributeError:
        --    pass
        --else:
        --    extend(items)
        --    return
        -- Even if the PEP 307 requires extend() and append() methods,
        -- fall back on append() if the object has no extend() method
        -- for backward compatibility.
        --append = list_obj.append

        for i,item  in ipairs(items) do
            table.insert(list_obj,item)
        end
        depickle.stack:push(list_obj)
end
depickle.dispatch[APPENDS] = depickle.load_appends
--[[
function depickle.load_setitem()
        stack = depickle.stack
        value = stack.pop()
        key = stack.pop()
        dict = stack[-1]
        dict[key] = depickle.value
end
depickle.dispatch[SETITEM[0] ] = depickle.load_setitem

function depickle.load_setitems()
        items = depickle.pop_mark()
        dict = depickle.stack[-1]
        for i in range(0, len(items), 2):
            dict[items[i] ] = depickle.items[i + 1]
end
depickle.dispatch[SETITEMS[0] ] = depickle.load_setitems

function depickle.load_additems()
        items = depickle.pop_mark()
        set_obj = depickle.stack[-1]
        if isinstance(set_obj, set):
            set_obj.update(items)
        else:
            add = set_obj.add
            for item in items:
                add(item)
end
depickle.dispatch[ADDITEMS[0] ] = depickle.load_additems

function depickle.load_build()
        stack = depickle.stack
        state = stack.pop()
        inst = stack[-1]
        setstate = getattr(inst, "__setstate__", _NoValue)
        if setstate is not _NoValue:
            setstate(state)
            return
        slotstate = None
        if isinstance(state, tuple) and len(state) == 2:
            state, slotstate = state
        if state:
            inst_dict = inst.__dict__
            intern = sys.intern
            for k, v in state.items():
                if type(k) is str:
                    inst_dict[intern(k)] = depickle.v
                else:
                    inst_dict[k] = depickle.v
        if slotstate:
            for k, v in slotstate.items():
                setattr(inst, k, v)
end
depickle.dispatch[BUILD[0] ] = depickle.load_build
]]--
function depickle.load_mark()
        depickle.metastack:push(depickle.stack)
        depickle.stack = Stack:new()
        depickle.append = function(v) depickle.stack:push(v) end
end
depickle.dispatch[MARK] = depickle.load_mark

function depickle.load_stop()
        depickle._Stop = depickle.stack:pop()
end
depickle.dispatch[STOP] = depickle.load_stop


function depickle.read(n)
        if depickle.frame then
            data = depickle.frame:read(n)
            if not data and n ~= 0 then
                depickle.frame = nil
                return depickle.file_read(n)
            end
            assert(#data == n, "pickle exhausted before end of frame")
            return data
        else
            return depickle.file_read(n)
        end
end

function depickle.readline()
        if depickle.frame then
            data = depickle.frame:readline(n)
            if not data then
                depickle.frame = nil
                return depickle.file_readline(n)
            end
            assert(data[#data] == string.byte("\n"), "pickle exhausted before end of frame")
            return string.sub(data, 1, -2)
        else
            return depickle.file_readline(n)
        end
end

function depickle.file_read(n) print("NOT INPLANTED") end
function depickle.file_readfile() print("NOT INPLANTED") end

function hex_to_bytes(hex)
    assert((#hex % 2) == 0, "Hex string must have an even number of characters")
    local byte_array = {}

    -- Iterate over the hex string in pairs of two characters
    for i = 1, #hex, 2 do
        local byte = hex:sub(i, i + 1)
        table.insert(byte_array, tonumber(byte, 16))
    end
    return byte_array
end

local function old_method(p)
    local json = require("gramps.json")
    local command = string.format('python3.6 /home/marc/texmf/tex/luatex/lib/gramps/depickle.py %s', p)
    local handle = io.popen(command)
    local result = handle:read("*all")
    handle:close()
    --print(result)
        --local ar=parse_tuple(result)
    return json.decode(result)
end

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    local util=require("texutil.util_base")

    s1=Stack:new()
    print(custom_type(s1))
    s2=Stack:new()
    s1:push("hallo")
    s2:push(2)
    s1:push(s2)
    --80 03 28 58 1B 00 00 00 6335646239376636
    local p1 ="800328581B00000063356462393766363933353531383261393364336266373631373271005805000000453239363371014B0C58000000007102867103284B004B004B00284B1D4B014DD2078974710468024A506B25004B007471056802581B00000063356462393765373539393138386338333435353165376437666671065D71075D71085D71095D710A4A8AE40A515D710B8974710C2E"
    local p2 = "800328581B00000063356462393830303364303237366666363462306263303363643971005805000000493036393571014B0128895D71025D71034E580600000057696C6C656D71045D71052858050000004865696A6E710658000000007107884B016807867108680774710961680768074B02680786710A68074B004B0068076807680774710B5D710C4AFFFFFFFF4B005D710D28895D710E5D710F581B00000063356462393830303364343463346131616566386366333263386671104B016807867111747112615D71135D7114581B0000006335646239376565303537346237656230323931633437363562647115615D71162828895D71175D71185D7119581B000000356364623937666637386365363962386264646330383665663039711A284B3D4B144B434B2274711B74711C28895D711D5D711E5D711F581B0000006466343736666264636533343464663665323436346335633466317120284B0B4B304B2F4B4C74712174712228895D71235D71245D7125581B0000006466343736666264636330323235316639363135616166363338377126284B054B3E4B224B5E74712774712828895D71295D712A5D712B581B000000646634373666626463316231633638366338316131313938353966712C284B174B0D4B284B2B74712D74712E28895D712F5D71305D7131581B0000006466343736666264636432343636323061353036663335656339347132284B334B034B504B3B74713374713428895D71355D71365D7137581B0000006466343736666264636234353939303539633733626363383261617138284B174B004B2E4B1674713974713A28895D713B5D713C5D713D581B000000646634373666626463626331616431346338356662306538663965713E284B014B154B234B3274713F74714028895D71415D71425D7143581B0000006466343736666264633461323239353035646662643738313731317144284B0D4B4B4B174B5A74714574714628895D71475D71485D7149581B000000646634373666626463313637646432636362643230343533373631714A284B294B324B2E4B3C74714B74714C28895D714D5D714E5D714F581B0000006466343736666264633061323664383938363662666631373439647150284B2A4B424B314B4D74715174715228895D71535D71545D7155581B0000006466343736666264636164313666343461656132396438363638377156284B164B4C4B1E4B5B74715774715828895D71595D715A5D715B581B000000646634373666626463346333666666326262376636363134373735715C284B0B4B0D4B294B4B74715D74715E655D715F5D716028895D71615D71624B00580300000052494E716386716458030000003639357165747166615D71675D71685D71695D716A4A84E97B5B5D716B895D716C74716D2E"
    local p3 = "800328581B00000063356462393830303364343463346131616566386366333263386671005805000000453437343171014B0C58000000007102867103284B004B004B00284B144B044DCE078974710468024AEC6525004B007471056802581A000000633564623938303033643864303531646533333934653931613171065D71075D71085D71095D710A4A8EE40A515D710B8974710C2E"
    t=depickle.depickle(hex_to_bytes(p2))
    print(util.dump(t))

    --print()
    --print(util.dump(old_method(p2)))


else
    return depickle
end
