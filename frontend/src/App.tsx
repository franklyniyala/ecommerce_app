import { useEffect, useMemo, useState } from "react";
import { fetchProducts, createOrder } from "./api";
import { CartItem, Product } from "./types";

function App() {
  const [products, setProducts] = useState<Product[]>([]);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [message, setMessage] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchProducts().then(setProducts).catch(() => {
      setMessage("Unable to load products. Is the backend running?");
    });
  }, []);

  const cartItems = useMemo(
    () =>
      cart.map((item) => {
        const product = products.find((product) => product.id === item.product_id);
        return {
          ...item,
          name: product?.name ?? "Unknown product",
          price: product?.price ?? 0,
        };
      }),
    [cart, products]
  );

  const cartTotal = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0);

  const addToCart = (product: Product) => {
    setCart((current) => {
      const existing = current.find((item) => item.product_id === product.id);
      if (existing) {
        return current.map((item) =>
          item.product_id === product.id
            ? { ...item, quantity: Math.min(item.quantity + 1, product.stock) }
            : item
        );
      }
      return [...current, { product_id: product.id, quantity: 1 }];
    });
  };

  const removeFromCart = (product_id: string) => {
    setCart((current) => current.filter((item) => item.product_id !== product_id));
  };

  const updateQuantity = (product_id: string, value: number) => {
    setCart((current) =>
      current
        .map((item) =>
          item.product_id === product_id
            ? { ...item, quantity: Math.max(1, value) }
            : item
        )
        .filter((item) => item.quantity > 0)
    );
  };

  const submitOrder = async () => {
    if (!cart.length) {
      setMessage("Add some products to your cart before placing an order.");
      return;
    }

    setIsSubmitting(true);
    setMessage(null);
    try {
      const response = await createOrder(cart);
      setMessage(`Order placed successfully: ${response.order_id}`);
      setCart([]);
      fetchProducts().then(setProducts);
    } catch (error) {
      setMessage("Unable to place order. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <h1>React E-commerce Store</h1>
          <p>Browse products, add favorites to cart, and place a simple order.</p>
        </div>
      </header>

      <main>
        <section className="product-grid">
          {products.map((product) => (
            <article key={product.id} className="product-card">
              <img src={product.imageUrl} alt={product.name} />
              <div className="product-details">
                <h2>{product.name}</h2>
                <p>{product.description}</p>
                <div className="product-footer">
                  <span>${product.price.toFixed(2)}</span>
                  <button
                    type="button"
                    disabled={product.stock === 0}
                    onClick={() => addToCart(product)}
                  >
                    {product.stock === 0 ? "Sold out" : "Add to cart"}
                  </button>
                </div>
              </div>
            </article>
          ))}
        </section>

        <aside className="cart-panel">
          <div className="cart-header">
            <h2>Shopping Cart</h2>
            <span>{cartItems.length} items</span>
          </div>

          {cartItems.length === 0 ? (
            <p className="empty-cart">Your cart is empty.</p>
          ) : (
            <div className="cart-items">
              {cartItems.map((item) => (
                <div key={item.product_id} className="cart-item">
                  <div>
                    <strong>{item.name}</strong>
                    <p>${item.price.toFixed(2)} each</p>
                  </div>
                  <div className="cart-controls">
                    <input
                      type="number"
                      min="1"
                      max="99"
                      value={item.quantity}
                      onChange={(event) => updateQuantity(item.product_id, Number(event.target.value))}
                    />
                    <button type="button" onClick={() => removeFromCart(item.product_id)}>
                      Remove
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="cart-footer">
            <div>
              <span>Total</span>
              <strong>${cartTotal.toFixed(2)}</strong>
            </div>
            <button type="button" onClick={submitOrder} disabled={isSubmitting || cartItems.length === 0}>
              {isSubmitting ? "Placing order..." : "Place order"}
            </button>
          </div>
        </aside>
      </main>

      {message ? <div className="toast">{message}</div> : null}
    </div>
  );
}

export default App;
