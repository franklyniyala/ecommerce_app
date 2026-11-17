import axios from "axios";
import { CartItem, Product } from "./types";

const api = axios.create({
  baseURL: "/api",
  headers: {
    "Content-Type": "application/json",
  },
});

export const fetchProducts = async (): Promise<Product[]> => {
  const response = await api.get<Product[]>("/products");
  return response.data;
};

export const createOrder = async (items: CartItem[]): Promise<{ order_id: string }> => {
  const response = await api.post<{ order_id: string }>("/orders", { items });
  return response.data;
};
