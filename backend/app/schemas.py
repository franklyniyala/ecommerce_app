from pydantic import BaseModel, Field
from typing import List


class ProductResponse(BaseModel):
    id: str
    name: str
    description: str
    price: float
    imageUrl: str
    stock: int


class OrderItem(BaseModel):
    product_id: str = Field(..., alias="product_id")
    quantity: int = Field(..., gt=0)


class OrderRequest(BaseModel):
    items: List[OrderItem]


class OrderResponse(BaseModel):
    order_id: str
    total: float
    items: List[OrderItem]
    message: str

    class Config:
        allow_population_by_field_name = True
