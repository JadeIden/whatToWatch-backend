import schema
import json
from typing import Union, List
import dataclasses
import boto3

def listItems(event, context) -> Union[List[schema.Item], schema.Error]:
    """Endpoint for pulling the list of items from the Items table in dynamodb."""
    client = boto3.resource("dynamodb")
    items_table = client.Table("Items-dev")

    items_table.load()

    return {
        "statusCode": "200",
        "body":  json.dumps([dataclasses.asdict(schema.Item(itemId = 1, name = "asdf", status = items_table.item_count, tags = []))])
    }

    return dataclasses.asdict(schema.Error(
        code = 1,
        message = "Method not implemented"
    ))

def createItem(event, context) -> Union[schema.Item, schema.Error]:
    return dataclasses.asdict(schema.Error(
        code = 1,
        message = "Method not implemented"
    ))

def showItemById(event, context) -> Union[schema.Item, schema.Error]:
    return dataclasses.asdict(schema.Error(
        code = 1,
        message = "Method not implemented"
    ))
