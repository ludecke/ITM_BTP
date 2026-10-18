projection;
strict ( 2 );

define behavior for /LUDECKE/C_StageBatch alias Batch
use etag
{
  use delete;
  use association _Group;
}

define behavior for /LUDECKE/C_StageGroup alias Group
use etag
{
  use delete;
  use action apply;
  use association _Batch;
  use association _Line;
}

define behavior for /LUDECKE/C_StageLine alias Line
{
  use association _Group;
  use association _Batch;
}