class-pool .
*"* class pool for class /LUDECKE/CL_ITM_STAGE

*"* local type definitions
include /LUDECKE/CL_ITM_STAGE=========ccdef.

*"* class /LUDECKE/CL_ITM_STAGE definition
*"* public declarations
  include /LUDECKE/CL_ITM_STAGE=========cu.
*"* protected declarations
  include /LUDECKE/CL_ITM_STAGE=========co.
*"* private declarations
  include /LUDECKE/CL_ITM_STAGE=========ci.
endclass. "/LUDECKE/CL_ITM_STAGE definition

*"* macro definitions
include /LUDECKE/CL_ITM_STAGE=========ccmac.
*"* local class implementation
include /LUDECKE/CL_ITM_STAGE=========ccimp.

*"* test class
include /LUDECKE/CL_ITM_STAGE=========ccau.

class /LUDECKE/CL_ITM_STAGE implementation.
*"* method's implementations
  include methods.
endclass. "/LUDECKE/CL_ITM_STAGE implementation
