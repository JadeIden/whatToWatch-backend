import schema
import json
from typing import Union, List
import dataclasses
import uuid
import boto3

def list_items(table):
    results = table.scan()

    items = results['Items']

    items_mapped = [schema.Item(**item) for item in items]

    return items_mapped


def listItems(event, context) -> Union[List[schema.Item], schema.Error]:
    """Endpoint for pulling the list of items from the Items table in dynamodb."""
    client = boto3.resource("dynamodb")
    items_table = client.Table("Items-prod")

    result = list_items(items_table)

    return {
        "statusCode": "200",
        "body":  json.dumps([
            dataclasses.asdict(item) for item in result
        ])
    }

def createItem(event, context) -> Union[schema.Item, schema.Error]:
    """Endpoint for adding a new list to the Items table in dynamodb"""
    client = boto3.resource("dynamodb")
    items_table = client.Table("Items-prod")

    parsed_item = None

    if event is not None and event['body'] is not None:
        parsed_body = json.loads(event['body'])
        parsed_item = schema.Item(**parsed_body, itemId=str(uuid.uuid4()))

    _ = items_table.put_item(Key={"itemId": parsed_body.itemId}, Item=parsed_item)

    return {
        "statusCode": "200",
        "body":  json.dumps(parsed_item)
    }

def showItemById(event, context) -> Union[schema.Item, schema.Error]:
    client = boto3.resource("dynamodb")
    items_table = client.Table("Items-prod")

    if event is None or "pathParameters" not in event or "itemId" not in event["pathParameters"]:
        return dataclasses.asdict(schema.Error(
            code = 2,
            message = "Missing id parameter from url"
        ))

    input_id = event['pathParameters']['id']

    response = items_table.get_item(Key={
        "itemId": input_id
    })

    item = response["Item"]

    item_obj = schema.Item(**item)

    return {
        "statusCode": "200",
        "body": json.dumps(dataclasses.asdict(item_obj))
    }
