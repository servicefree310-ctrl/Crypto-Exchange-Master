import { createRoot } from "react-dom/client";
import App from "./App";
import "./index.css";

createRoot(document.getElementById("root")!).render(<App />);

// PWA service worker registration (production only — Vite HMR breaks under SW in dev)
if ("serviceWorker" in navigator && import.meta.env.PROD) {
  window.addEventListener("load", () => {
    navigator.serviceWorker
      .register("/user/sw.js", { scope: "/user/" })
      .catch((err) => console.warn("[pwa] sw register failed", err));
  });
}
