import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """Logs the name of each file uploaded to the assets bucket."""
    for record in event.get("Records", []):
        key = record["s3"]["object"]["key"]
        logger.info("Image received: %s", key)
    return {"statusCode": 200, "body": "processed"}
