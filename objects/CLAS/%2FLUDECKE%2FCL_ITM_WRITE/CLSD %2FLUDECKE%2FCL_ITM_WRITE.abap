class-pool .
*"* class pool for class /LUDECKE/CL_ITM_WRITE

*"* local type definitions
include /LUDECKE/CL_ITM_WRITE=========ccdef.

*"* class /LUDECKE/CL_ITM_WRITE definition
*"* public declarations
  include /LUDECKE/CL_ITM_WRITE=========cu.
*"* protected declarations
  include /LUDECKE/CL_ITM_WRITE=========co.
*"* private declarations
  include /LUDECKE/CL_ITM_WRITE=========ci.
endclass. "/LUDECKE/CL_ITM_WRITE definition

*"* macro definitions
include /LUDECKE/CL_ITM_WRITE=========ccmac.
*"* local class implementation
include /LUDECKE/CL_ITM_WRITE=========ccimp.

*"* test class
include /LUDECKE/CL_ITM_WRITE=========ccau.

class /LUDECKE/CL_ITM_WRITE implementation.
*"* method's implementations
  include methods.
endclass. "/LUDECKE/CL_ITM_WRITE implementation
