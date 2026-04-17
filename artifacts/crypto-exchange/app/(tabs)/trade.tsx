import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  SafeAreaView, Platform
} from 'react-native';
import { useRouter } from 'expo-router';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { MaterialCommunityIcons, Feather } from '@expo/vector-icons';

function formatPrice(p: number) {
  if (p < 1) return `₹${p.toFixed(4)}`;
  if (p >= 100000) return `₹${(p / 100000).toFixed(2)}L`;
  return `₹${p.toLocaleString('en-IN', { maximumFractionDigits: 0 })}`;
}

export default function TradeScreen() {
  const colors = useColors();
  const { coins, orders, positions } = useApp();
  const router = useRouter();
  const [tab, setTab] = useState<'spot' | 'futures'>('spot');

  const popularCoins = coins.slice(0, 8);
  const openOrders = orders.filter(o => o.status === 'open' || o.status === 'partial');

  const s = styles(colors);
  const topPadding = Platform.OS === 'web' ? 80 : 0;

  return (
    <SafeAreaView style={s.container}>
      <ScrollView contentContainerStyle={[s.scroll, { paddingTop: topPadding }]} showsVerticalScrollIndicator={false}>
        <Text style={s.title}>Trade</Text>

        {/* Tab */}
        <View style={s.tabRow}>
          {(['spot', 'futures'] as const).map(t => (
            <TouchableOpacity key={t} style={[s.tabBtn, tab === t && s.tabBtnActive]} onPress={() => setTab(t)}>
              <Text style={[s.tabText, tab === t && s.tabTextActive]}>{t === 'spot' ? 'Spot' : 'Futures'}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Trading Pairs */}
        <Text style={s.sectionTitle}>Popular Pairs</Text>
        <View style={s.pairsGrid}>
          {popularCoins.map(coin => (
            <TouchableOpacity
              key={coin.symbol}
              style={s.pairCard}
              onPress={() => router.push(tab === 'spot' ? `/trading/${coin.symbol}INR` : `/futures/${coin.symbol}USDT` as any)}
            >
              <CryptoIcon symbol={coin.symbol} size={32} />
              <Text style={s.pairSymbol}>{coin.symbol}/{tab === 'spot' ? 'INR' : 'USDT'}</Text>
              <Text style={s.pairPrice}>{formatPrice(coin.price)}</Text>
              <Text style={[s.pairChange, { color: coin.change24h >= 0 ? colors.success : colors.danger }]}>
                {coin.change24h >= 0 ? '+' : ''}{coin.change24h.toFixed(2)}%
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Open Orders */}
        <Text style={s.sectionTitle}>Open Orders</Text>
        {openOrders.length === 0 ? (
          <View style={s.emptyCard}>
            <MaterialCommunityIcons name="order-bool-ascending-variant" size={36} color={colors.mutedForeground} />
            <Text style={s.emptyText}>No open orders</Text>
          </View>
        ) : (
          openOrders.map(order => (
            <View key={order.id} style={s.orderCard}>
              <View style={s.orderHeader}>
                <Text style={s.orderSymbol}>{order.symbol}</Text>
                <View style={[s.orderSideBadge, { backgroundColor: order.side === 'buy' ? colors.success + '22' : colors.danger + '22' }]}>
                  <Text style={[s.orderSide, { color: order.side === 'buy' ? colors.success : colors.danger }]}>
                    {order.side.toUpperCase()}
                  </Text>
                </View>
              </View>
              <View style={s.orderDetails}>
                <View style={s.orderDetail}>
                  <Text style={s.orderDetailLabel}>Price</Text>
                  <Text style={s.orderDetailValue}>₹{order.price.toLocaleString('en-IN')}</Text>
                </View>
                <View style={s.orderDetail}>
                  <Text style={s.orderDetailLabel}>Qty</Text>
                  <Text style={s.orderDetailValue}>{order.quantity}</Text>
                </View>
                <View style={s.orderDetail}>
                  <Text style={s.orderDetailLabel}>Filled</Text>
                  <Text style={s.orderDetailValue}>{((order.filled / order.quantity) * 100).toFixed(0)}%</Text>
                </View>
              </View>
              <View style={s.progressBar}>
                <View style={[s.progressFill, { width: `${(order.filled / order.quantity) * 100}%` as any, backgroundColor: colors.primary }]} />
              </View>
            </View>
          ))
        )}

        {/* Positions (Futures only) */}
        {tab === 'futures' && (
          <>
            <Text style={s.sectionTitle}>Positions</Text>
            {positions.map(pos => (
              <View key={pos.symbol} style={s.posCard}>
                <View style={s.posHeader}>
                  <Text style={s.posSymbol}>{pos.symbol}</Text>
                  <View style={{ flexDirection: 'row', gap: 6 }}>
                    <View style={[s.posSideBadge, { backgroundColor: pos.side === 'long' ? colors.success + '22' : colors.danger + '22' }]}>
                      <Text style={[s.posSide, { color: pos.side === 'long' ? colors.success : colors.danger }]}>
                        {pos.side.toUpperCase()}
                      </Text>
                    </View>
                    <View style={s.leverBadge}>
                      <Text style={s.leverText}>{pos.leverage}x</Text>
                    </View>
                  </View>
                </View>
                <View style={s.posDetails}>
                  {[
                    { label: 'Entry', value: `$${pos.entryPrice.toLocaleString()}` },
                    { label: 'Mark', value: `$${pos.markPrice.toLocaleString()}` },
                    { label: 'Size', value: `${pos.size}` },
                    { label: 'Liq.', value: `$${pos.liquidationPrice.toLocaleString()}` },
                  ].map(({ label, value }) => (
                    <View key={label} style={s.posDetail}>
                      <Text style={s.posDetailLabel}>{label}</Text>
                      <Text style={s.posDetailValue}>{value}</Text>
                    </View>
                  ))}
                </View>
                <View style={[s.pnlBox, { backgroundColor: pos.pnl >= 0 ? colors.success + '15' : colors.danger + '15' }]}>
                  <Text style={[s.pnlValue, { color: pos.pnl >= 0 ? colors.success : colors.danger }]}>
                    {pos.pnl >= 0 ? '+' : ''}${pos.pnl.toFixed(2)} ({pos.pnl >= 0 ? '+' : ''}{pos.pnlPercent.toFixed(2)}%)
                  </Text>
                  <Text style={s.pnlLabel}>Unrealized PnL</Text>
                </View>
              </View>
            ))}
          </>
        )}

        <View style={{ height: 100 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (colors: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  scroll: { paddingHorizontal: 16 },
  title: { fontSize: 24, fontFamily: 'Inter_700Bold', color: colors.foreground, marginBottom: 16 },
  tabRow: { flexDirection: 'row', backgroundColor: colors.secondary, borderRadius: 10, padding: 3, marginBottom: 20, alignSelf: 'flex-start', borderWidth: 1, borderColor: colors.border },
  tabBtn: { paddingHorizontal: 20, paddingVertical: 8, borderRadius: 8 },
  tabBtnActive: { backgroundColor: colors.primary },
  tabText: { fontSize: 14, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  tabTextActive: { color: '#000', fontFamily: 'Inter_700Bold' },
  sectionTitle: { fontSize: 16, fontFamily: 'Inter_700Bold', color: colors.foreground, marginBottom: 12, marginTop: 8 },
  pairsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginBottom: 20 },
  pairCard: { width: '47%', backgroundColor: colors.card, borderRadius: 12, padding: 14, borderWidth: 1, borderColor: colors.border, gap: 4 },
  pairSymbol: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.foreground, marginTop: 6 },
  pairPrice: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  pairChange: { fontSize: 13, fontFamily: 'Inter_600SemiBold' },
  emptyCard: { backgroundColor: colors.card, borderRadius: 12, padding: 30, alignItems: 'center', gap: 8, borderWidth: 1, borderColor: colors.border, marginBottom: 16 },
  emptyText: { fontSize: 14, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  orderCard: { backgroundColor: colors.card, borderRadius: 12, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: colors.border },
  orderHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 },
  orderSymbol: { fontSize: 14, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  orderSideBadge: { borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3 },
  orderSide: { fontSize: 12, fontFamily: 'Inter_700Bold' },
  orderDetails: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 10 },
  orderDetail: { alignItems: 'center' },
  orderDetailLabel: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', textTransform: 'uppercase' },
  orderDetailValue: { fontSize: 13, color: colors.foreground, fontFamily: 'Inter_600SemiBold', marginTop: 2 },
  progressBar: { height: 4, backgroundColor: colors.secondary, borderRadius: 2 },
  progressFill: { height: 4, borderRadius: 2 },
  posCard: { backgroundColor: colors.card, borderRadius: 12, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: colors.border },
  posHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 },
  posSymbol: { fontSize: 14, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  posSideBadge: { borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3 },
  posSide: { fontSize: 11, fontFamily: 'Inter_700Bold' },
  leverBadge: { backgroundColor: colors.primary + '22', borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3 },
  leverText: { fontSize: 11, color: colors.primary, fontFamily: 'Inter_700Bold' },
  posDetails: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 10 },
  posDetail: { alignItems: 'center' },
  posDetailLabel: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', textTransform: 'uppercase' },
  posDetailValue: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_600SemiBold', marginTop: 2 },
  pnlBox: { borderRadius: 8, padding: 10, alignItems: 'center' },
  pnlValue: { fontSize: 16, fontFamily: 'Inter_700Bold' },
  pnlLabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
});
