from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from . import db
from .schemas import OrderItem, OrderRequest, OrderResponse, ProductResponse

app = FastAPI(
    title="E-commerce API",
    description="Backend service for a React + FastAPI e-commerce sample app.",
    version="0.1.0",
)

origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _serialize_product(product: dict) -> ProductResponse:
    return ProductResponse(
        id=str(product["_id"]),
        name=product["name"],
        description=product["description"],
        price=product["price"],
        imageUrl=product["imageUrl"],
        stock=product["stock"],
    )

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.on_event("startup")
async def startup_event() -> None:
    db.init_sample_products()


@app.get("/api/products", response_model=List[ProductResponse])
def list_products() -> List[ProductResponse]:
    products = list(db.products_collection.find())
    return [_serialize_product(product) for product in products]


@app.post("/api/orders", response_model=OrderResponse)
def create_order(order: OrderRequest) -> OrderResponse:
    if not order.items:
        raise HTTPException(status_code=400, detail="Order must contain at least one item.")

    product_map = {}
    for item in order.items:
        product = db.products_collection.find_one({"_id": db.ObjectId(item.product_id)})
        if product is None:
            raise HTTPException(status_code=404, detail=f"Product {item.product_id} not found.")
        if item.quantity > product["stock"]:
            raise HTTPException(
                status_code=400,
                detail=f"Requested quantity for {product['name']} exceeds available stock.",
            )
        product_map[item.product_id] = product

    total = 0.0
    order_items = []
    for item in order.items:
        product = product_map[item.product_id]
        total += product["price"] * item.quantity
        order_items.append(
            {
                "product_id": item.product_id,
                "quantity": item.quantity,
                "name": product["name"],
                "unit_price": product["price"],
            }
        )
        db.products_collection.update_one(
            {"_id": db.ObjectId(item.product_id)},
            {"$inc": {"stock": -item.quantity}},
        )

    result = db.orders_collection.insert_one(
        {
            "items": order_items,
            "total": total,
        }
    )

    return OrderResponse(
        order_id=str(result.inserted_id),
        total=total,
        items=order.items,
        message="Order placed successfully.",
    )
