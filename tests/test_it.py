import asyncio
import unittest

from aws_xray_sdk.core import xray_recorder

from my_lambda.new_async_context import AsyncContext


class ItTest(unittest.TestCase):
    def test_it(self):
        loop = asyncio.new_event_loop()
        xray_recorder.configure(context=AsyncContext(loop=loop))

        async def worker(sleep_time):
            await asyncio.sleep(sleep_time)

        async def launch():
            with xray_recorder.in_segment_async("seg1"):
                async with xray_recorder.capture_async("bal"):
                    await asyncio.gather(worker(0.3), worker(2), worker(1))

        loop.run_until_complete(launch())
