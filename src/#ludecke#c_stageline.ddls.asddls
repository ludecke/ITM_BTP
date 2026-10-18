@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITM staging text line'
@Metadata.allowExtensions: true
define view entity /LUDECKE/C_StageLine
  as projection on /LUDECKE/R_StageLine
{
  key LineId,
      GroupId,
      StageId,
      LineNumber,
      Textkey,
      SourceText,
      TargetText,
      _Group : redirected to parent /LUDECKE/C_StageGroup,
      _Batch : redirected to /LUDECKE/C_StageBatch
}
