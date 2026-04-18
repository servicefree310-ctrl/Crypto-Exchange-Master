import { useApp } from '@/context/AppContext';
import { darkColors, lightColors, ColorScheme } from '@/constants/colors';

export function useColors(): ColorScheme {
  const { effectiveTheme } = useApp();
  return effectiveTheme === 'light' ? lightColors : darkColors;
}
