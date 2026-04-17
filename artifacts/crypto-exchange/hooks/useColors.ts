import { useColorScheme } from "react-native";
import colors from "@/constants/colors";
import { useContext } from "react";
import { AppContext } from "@/context/AppContext";

export function useColors() {
  const ctx = useContext(AppContext);
  const systemScheme = useColorScheme();
  const effectiveTheme = ctx ? ctx.effectiveTheme : (systemScheme ?? 'dark');
  const palette =
    effectiveTheme === "dark" && "dark" in colors
      ? (colors as Record<string, typeof colors.light>).dark
      : colors.light;
  return { ...palette, radius: colors.radius };
}
