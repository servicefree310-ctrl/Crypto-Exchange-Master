// Binance-style palettes. Brand accents (yellow/green/red) stay constant
// across both themes for trading-context recognizability; only surface,
// text, and chrome colors flip.

export type Palette = {
  text: string;
  tint: string;
  background: string;
  foreground: string;
  card: string;
  cardForeground: string;
  primary: string;
  primaryForeground: string;
  secondary: string;
  secondaryForeground: string;
  muted: string;
  mutedForeground: string;
  accent: string;
  accentForeground: string;
  destructive: string;
  destructiveForeground: string;
  success: string;
  successForeground: string;
  border: string;
  input: string;
};

const dark: Palette = {
  text: "#eaecef",
  tint: "#fcd535",
  background: "#0b0e11",
  foreground: "#eaecef",
  card: "#161a1e",
  cardForeground: "#eaecef",
  primary: "#fcd535",
  primaryForeground: "#0b0e11",
  secondary: "#1e2329",
  secondaryForeground: "#eaecef",
  muted: "#1e2329",
  mutedForeground: "#848e9c",
  accent: "#2b2f36",
  accentForeground: "#eaecef",
  destructive: "#f6465d",
  destructiveForeground: "#ffffff",
  success: "#0ecb81",
  successForeground: "#ffffff",
  border: "#2b2f36",
  input: "#2b2f36",
};

const light: Palette = {
  text: "#1e2329",
  tint: "#fcd535",
  background: "#ffffff",
  foreground: "#1e2329",
  card: "#f5f5f5",
  cardForeground: "#1e2329",
  primary: "#fcd535",
  primaryForeground: "#1e2329",
  secondary: "#eff2f5",
  secondaryForeground: "#1e2329",
  muted: "#f5f5f5",
  mutedForeground: "#707a8a",
  accent: "#eaecef",
  accentForeground: "#1e2329",
  destructive: "#cf304a",
  destructiveForeground: "#ffffff",
  success: "#03a66d",
  successForeground: "#ffffff",
  border: "#eaecef",
  input: "#eaecef",
};

const colors = { light, dark, radius: 8 };
export default colors;
