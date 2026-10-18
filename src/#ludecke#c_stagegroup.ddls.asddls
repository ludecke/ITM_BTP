@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITM staging object group'
@Metadata.allowExtensions: true
define view entity /LUDECKE/C_StageGroup
  as projection on /LUDECKE/R_StageGroup
{
  key GroupId,
      StageId,
      ObjectType,
      ObjectName,
      TargLang,
      Status,
      StatusCriticality,
      TransportRequest,
      Message,
      AppliedBy,
      AppliedAt,
      LocalLastChangedAt,
      _Batch : redirected to parent /LUDECKE/C_StageBatch,
      _Line  : redirected to composition child /LUDECKE/C_StageLine
}
