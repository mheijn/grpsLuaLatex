local pc = {}
pc.COM ={
MARK           = string.byte('('),   -- push special markobject on stack
STOP           = string.byte('.'),   -- every pickle ends with STOP
POP            = string.byte('0'),   -- discard topmost stack item
POP_MARK       = string.byte('1'),   -- discard stack top through topmost markobject
DUP            = string.byte('2'),   -- duplicate top stack item
FLOAT          = string.byte('F'),   -- push float object; decimal string argument
INT            = string.byte('I'),   -- push integer or bool; decimal string argument
BININT         = string.byte('J'),   -- push four-byte signed int
BININT1        = string.byte('K'),   -- push 1-byte unsigned int
LONG           = string.byte('L'),   -- push long; decimal string argument
BININT2        = string.byte('M'),   -- push 2-byte unsigned int
NONE           = string.byte('N'),   -- push None
PERSID         = string.byte('P'),   -- push persistent object; id is taken from string arg
BINPERSID      = string.byte('Q'),   --  "       "         "  ;  "  "   "     "  stack
REDUCE         = string.byte('R'),   -- apply callable to argtuple, both on stack
STRING         = string.byte('S'),   -- push string; NL-terminated string argument
BINSTRING      = string.byte('T'),   -- push string; counted binary string argument
SHORT_BINSTRING= string.byte('U'),   --  "     "   ;    "      "       "      " < 256 bytes
UNICODE        = string.byte('V'),   -- push Unicode string; raw-unicode-escaped'd argument
BINUNICODE     = string.byte('X'),   --   "     "       "  ; counted UTF-8 string argument
APPEND         = string.byte('a'),   -- append stack top to list below it
BUILD          = string.byte('b'),   -- call __setstate__ or __dict__.update()
GLOBAL         = string.byte('c'),   -- push self.find_class(modname, name); 2 string args
DICT           = string.byte('d'),   -- build a dict from stack items
EMPTY_DICT     = string.byte('}'),   -- push empty dict
APPENDS        = string.byte('e'),   -- extend list on stack by topmost stack slice
GET            = string.byte('g'),   -- push item from memo on stack; index is string arg
BINGET         = string.byte('h'),   --   "    "    "    "   "   "  ;   "    " 1-byte arg
INST           = string.byte('i'),   -- build & push class instance
LONG_BINGET    = string.byte('j'),   -- push item from memo on stack; index is 4-byte arg
LIST           = string.byte('l'),   -- build list from topmost stack items
EMPTY_LIST     = string.byte(']'),   -- push empty list
OBJ            = string.byte('o'),   -- build & push class instance
PUT            = string.byte('p'),   -- store stack top in memo; index is string arg
BINPUT         = string.byte('q'),   --   "     "    "   "   " ;   "    " 1-byte arg
LONG_BINPUT    = string.byte('r'),   --   "     "    "   "   " ;   "    " 4-byte arg
SETITEM        = string.byte('s'),   -- add key+value pair to dict
TUPLE          = string.byte('t'),   -- build tuple from topmost stack items
EMPTY_TUPLE    = string.byte(')'),   -- push empty tuple
SETITEMS       = string.byte('u'),   -- modify dict by adding topmost key+value pairs
BINFLOAT       = string.byte('G'),   -- push float; arg is 8-byte float encoding

-- Protocol 2

PROTO          = 0x80,  -- identify pickle protocol
NEWOBJ         = 0x81,  -- build object by applying cls.__new__ to argtuple
EXT1           = 0x82,  -- push object from extension registry; 1-byte index
EXT2           = 0x83,  -- ditto, but 2-byte index
EXT4           = 0x84,  -- ditto, but 4-byte index
TUPLE1         = 0x85,  -- build 1-tuple from stack top
TUPLE2         = 0x86,  -- build 2-tuple from two topmost stack items
TUPLE3         = 0x87,  -- build 3-tuple from three topmost stack items
NEWTRUE        = 0x88,  -- push True
NEWFALSE       = 0x89,  -- push False
LONG1          = 0x8a,  -- push long from < 256 bytes
LONG4          = 0x8b,  -- push really big long

-- Protocol 3 (Python 3.x)

BINBYTES       = string.byte('B'),   -- push bytes; counted binary string argument
SHORT_BINBYTES = string.byte('C'),   --  "     "   ;    "      "       "      " < 256 bytes

-- Protocol 4

SHORT_BINUNICODE = 0x8c,  -- push short string; UTF-8 length < 256 bytes
BINUNICODE8      = 0x8d,  -- push very long string
BINBYTES8        = 0x8e,  -- push very long bytes string
EMPTY_SET        = 0x8f,  -- push empty set on the stack
ADDITEMS         = 0x90,  -- modify set by adding topmost stack items
FROZENSET        = 0x91,  -- build frozenset from topmost stack items
NEWOBJ_EX        = 0x92,  -- like NEWOBJ but work with keyword only arguments
STACK_GLOBAL     = 0x93,  -- same as GLOBAL but using names on the stacks
MEMOIZE          = 0x94,  -- store top of the stack in memo
FRAME            = 0x95,  -- indicate the beginning of a new frame

-- Protocol 5

BYTEARRAY8       = 0x96,  -- push bytearray
NEXT_BUFFER      = 0x97,  -- push next out-of-band buffer
READONLY_BUFFER  = 0x98  -- make top of stack readonly
}
pc.RCOM = {}
for k, v in pairs(pc.COM) do pc.RCOM[v]=k end

--print(string.byte('B'),pc.RCOM[string.byte('B')],pc.RCOM[66])

return pc
