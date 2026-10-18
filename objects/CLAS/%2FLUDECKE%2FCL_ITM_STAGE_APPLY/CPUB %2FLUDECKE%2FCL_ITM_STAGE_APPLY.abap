CLASS /ludecke/cl_itm_stage_apply DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_bgmc_op_single_tx_uncontr .

    "! group_id = the /LUDECKE/STAGE_O row (object + target language) to apply
    METHODS constructor
      IMPORTING
        group_id TYPE sysuuid_x16 .
