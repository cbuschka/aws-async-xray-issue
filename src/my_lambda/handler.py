import asyncio
import logging

import aioboto3
from aws_xray_sdk.core import xray_recorder, patch_all
from my_lambda.new_async_context import AsyncContext
from my_lambda.output_bucket import write_some_output

xray_recorder.configure(
    sampling=False,
    context_missing='LOG_ERROR',
    daemon_address='127.0.0.1:3000',
    context=AsyncContext()
)
patch_all()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def handle_event(event, lambda_context):
    logger.info("Event: {}".format(event))

    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(handle_event_async(event))
    return result


async def handle_event_async(event):
    if event["op"] == "single":
        await single_works()
    if event["op"] == "serial":
        await serially_works()
    if event["op"] == "parallel":
        await parallel_fails()


async def single_works():
    async with xray_recorder.in_segment_async(name='single'):
        async with aioboto3.resource("s3") as s3_resource:
            await write_some_output(s3_resource)


async def serially_works():
    async with xray_recorder.in_segment_async(name='serial'):
        async with aioboto3.resource("s3") as s3_resource:
            for _ in range(0, 10):
                await write_some_output(s3_resource)


async def parallel_fails():
    async with xray_recorder.in_segment_async(name='parallel'):
        async with aioboto3.resource("s3") as s3_resource:
            await asyncio.gather(*[write_some_output(s3_resource) for _ in range(0, 10)])
