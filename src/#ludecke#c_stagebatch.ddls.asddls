@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITM staging batch'
@Metadata.allowExtensions: true
define root view entity /LUDECKE/C_StageBatch
  provider contract transactional_query
  as projection on /LUDECKE/R_StageBatch
{
  key StageId,
      ProjectId,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,
      _Count.OpenCount   as OpenCount,
      _Count.QueuedCount as QueuedCount,
      _Count.ErrorCount  as ErrorCount,
      _Group : redirected to composition child /LUDECKE/C_StageGroup
}
