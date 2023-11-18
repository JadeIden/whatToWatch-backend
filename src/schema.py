from dataclasses import dataclass
from typing import List

@dataclass
class Item:
    itemId: str
    name: str
    status: str
    tags: List[str]

@dataclass
class Error:
    code: int
    message: str

Items = List[Item]
