import React, { useMemo } from 'react';
import { View, Dimensions } from 'react-native';
import Svg, { Rect, Line, Text as SvgText } from 'react-native-svg';

interface Candle {
  open: number;
  high: number;
  low: number;
  close: number;
}

interface CandleChartProps {
  basePrice: number;
  positive: boolean;
  height?: number;
}

const screenWidth = Dimensions.get('window').width;

export function CandleChart({ basePrice, positive, height = 220 }: CandleChartProps) {
  const width = screenWidth - 32;
  const candles = useMemo<Candle[]>(() => {
    const result: Candle[] = [];
    let price = basePrice;
    for (let i = 0; i < 30; i++) {
      const open = price;
      const change = (Math.random() - (positive ? 0.42 : 0.58)) * price * 0.025;
      const close = open + change;
      const high = Math.max(open, close) + Math.random() * price * 0.01;
      const low = Math.min(open, close) - Math.random() * price * 0.01;
      result.push({ open, high, low, close });
      price = close;
    }
    return result;
  }, [basePrice, positive]);

  const allHighs = candles.map(c => c.high);
  const allLows = candles.map(c => c.low);
  const maxPrice = Math.max(...allHighs);
  const minPrice = Math.min(...allLows);
  const range = maxPrice - minPrice || 1;

  const padding = { top: 20, bottom: 30, left: 8, right: 8 };
  const chartH = height - padding.top - padding.bottom;
  const candleWidth = (width - padding.left - padding.right) / candles.length;
  const bodyGap = candleWidth * 0.15;

  const priceToY = (p: number) => padding.top + chartH - ((p - minPrice) / range) * chartH;

  return (
    <View style={{ width, height }}>
      <Svg width={width} height={height}>
        {candles.map((c, i) => {
          const x = padding.left + i * candleWidth;
          const centerX = x + candleWidth / 2;
          const isGreen = c.close >= c.open;
          const color = isGreen ? '#0ECB81' : '#F6465D';
          const bodyTop = priceToY(Math.max(c.open, c.close));
          const bodyBottom = priceToY(Math.min(c.open, c.close));
          const bodyHeight = Math.max(1, bodyBottom - bodyTop);
          return (
            <React.Fragment key={i}>
              <Line x1={centerX} y1={priceToY(c.high)} x2={centerX} y2={bodyTop} stroke={color} strokeWidth={1} />
              <Rect x={x + bodyGap} y={bodyTop} width={candleWidth - bodyGap * 2} height={bodyHeight} fill={color} rx={1} />
              <Line x1={centerX} y1={bodyBottom} x2={centerX} y2={priceToY(c.low)} stroke={color} strokeWidth={1} />
            </React.Fragment>
          );
        })}
      </Svg>
    </View>
  );
}
