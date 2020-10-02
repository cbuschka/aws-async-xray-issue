import asyncio
import os
from uuid import uuid4

SCOPE = os.environ.get("SCOPE", "")
OUTPUT_BUCKET = "{SCOPE}-output".format(SCOPE=SCOPE)


async def write_some_output(s3_resource):
    some_uuid = str(uuid4())
    object_key = "{}.txt".format(some_uuid)
    s3_object = await s3_resource.Object(OUTPUT_BUCKET, object_key)
    await s3_object.put(ACL='private', Body=some_uuid)


async def write_some_output_in_parallel(s3_resource):
    return await asyncio.gather(*[write_some_output(s3_resource) for _ in range(0, 4)])
