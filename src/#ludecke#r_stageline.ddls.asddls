@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITM staging text line'
define view entity /LUDECKE/R_StageLine
  as select from /ludecke/stage_i
  association        to parent /LUDECKE/R_StageGroup as _Group on $projection.GroupId = _Group.GroupId
  association [1..1] to /LUDECKE/R_StageBatch        as _Batch on $projection.StageId = _Batch.StageId
{
  key line_id     as LineId,
      group_id    as GroupId,
      stage_id    as StageId,
      line_no     as LineNumber,
      textkey     as Textkey,
      source_text as SourceText,
      target_text as TargetText,
      _Group,
      _Batch
}
