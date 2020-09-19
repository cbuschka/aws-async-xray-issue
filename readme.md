# aws xray issue with python3.8 asyncio

### Demo for https://github.com/aws/aws-xray-sdk-python/issues/164

## Prerequisites
* make
* tfvm (e.g. from https://github.com/cbuschka/tfvm) or terraform == 0.12.28
* aws cli
* python 3.8

## Steps to reproduce

### Deploy
```
make SCOPE=my deploy_resources deploy_service
```

### Invoke
```
make SCOPE=my invoke_single invoke_serial invoke_parallel
```

### Look into Cloudwatch Log Stream

* Single works
* Serial works
* Parallel logs a stack trace
```
[ERROR] AlreadyEndedException: Already ended segment and subsegment cannot be modified.
Traceback (most recent call last):
  File "/var/task/my_lambda/handler.py", line 26, in handle_event
    result = loop.run_until_complete(handle_event_async(event))
  File "/var/lang/lib/python3.8/asyncio/base_events.py", line 616, in run_until_complete
    return future.result()
  File "/var/task/my_lambda/handler.py", line 36, in handle_event_async
    await parallel_fails()
  File "/var/task/my_lambda/handler.py", line 55, in parallel_fails
    await asyncio.gather(*[write_some_output(s3_resource) for _ in range(0, 10)])
  File "/var/task/my_lambda/output_bucket.py", line 12, in write_some_output
    await s3_object.put(ACL='private', Body=some_uuid)
  File "/var/task/aioboto3/resources/factory.py", line 239, in do_action
    response = await action(self, *args, **kwargs)
  File "/var/task/aioboto3/resources/action.py", line 41, in __call__
    response = await getattr(parent.meta.client, operation_name)(**params)
  File "/var/task/aws_xray_sdk/ext/aiobotocore/patch.py", line 32, in _xray_traced_aiobotocore
    result = await xray_recorder.record_subsegment_async(
  File "/var/task/aws_xray_sdk/core/async_recorder.py", line 93, in record_subsegment_async
    meta_processor(
  File "/var/task/aws_xray_sdk/ext/boto_utils.py", line 56, in aws_meta_processor
    subsegment.put_http_meta(http.STATUS,
  File "/var/task/aws_xray_sdk/core/models/entity.py", line 102, in put_http_meta
    self._check_ended()
  File "/var/task/aws_xray_sdk/core/models/entity.py", line 283, in _check_ended
    raise AlreadyEndedException("Already ended segment and subsegment cannot be modified.")
```

### License
[MIT](./license.txt)
