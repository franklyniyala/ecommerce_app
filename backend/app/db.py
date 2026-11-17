import os

from pymongo import MongoClient
from bson.objectid import ObjectId

MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
client = MongoClient(MONGODB_URI, serverSelectionTimeoutMS=5000)

database = client["ecommerce"]
products_collection = database["products"]
orders_collection = database["orders"]


def init_sample_products() -> None:
    if products_collection.count_documents({}) > 0:
        return

    sample_products = [
        {
            "name": "Smart Home Speaker",
            "description": "A voice-controlled speaker with premium sound and smart home integration.",
            "price": 129.99,
            "imageUrl": "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=800&q=80",
            "stock": 22,
        },
        {
            "name": "Heritage Denim Jacket",
            "description": "A rugged denim jacket with vintage wash and modern fit.",
            "price": 89.99,
            "imageUrl": "https://images.unsplash.com/photo-1519741495562-d7e5fd8f39cc?auto=format&fit=crop&w=800&q=80",
            "stock": 14,
        },
        {
            "name": "Portable Travel Charger",
            "description": "Compact USB-C power bank designed for fast, reliable charging on the go.",
            "price": 39.99,
            "imageUrl": "https://images.unsplash.com/photo-1517495306984-8d9b5d1a2dd6?auto=format&fit=crop&w=800&q=80",
            "stock": 30,
        },
    ]
    products_collection.insert_many(sample_products)


def ObjectId(id_string: str) -> ObjectId:
    return ObjectId(id_string)
