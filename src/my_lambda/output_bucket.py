import os
from uuid import uuid4

SCOPE = os.environ.get("SCOPE", "")
OUTPUT_BUCKET = "{SCOPE}-output".format(SCOPE=SCOPE)


async def write_some_output(s3_resource):
    some_uuid = str(uuid4())
    object_key = "{}.txt".format(some_uuid)
    s3_object = await s3_resource.Object(OUTPUT_BUCKET, object_key)
    await s3_object.put(ACL='private', Body=some_uuid)
