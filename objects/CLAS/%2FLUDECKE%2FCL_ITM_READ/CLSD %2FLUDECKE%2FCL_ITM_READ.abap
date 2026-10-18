class-pool .
*"* class pool for class /LUDECKE/CL_ITM_READ

*"* local type definitions
include /LUDECKE/CL_ITM_READ==========ccdef.

*"* class /LUDECKE/CL_ITM_READ definition
*"* public declarations
  include /LUDECKE/CL_ITM_READ==========cu.
*"* protected declarations
  include /LUDECKE/CL_ITM_READ==========co.
*"* private declarations
  include /LUDECKE/CL_ITM_READ==========ci.
endclass. "/LUDECKE/CL_ITM_READ definition

*"* macro definitions
include /LUDECKE/CL_ITM_READ==========ccmac.
*"* local class implementation
include /LUDECKE/CL_ITM_READ==========ccimp.

*"* test class
include /LUDECKE/CL_ITM_READ==========ccau.

class /LUDECKE/CL_ITM_READ implementation.
*"* method's implementations
  include methods.
endclass. "/LUDECKE/CL_ITM_READ implementation
