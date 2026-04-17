import React, { useState, useMemo } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  SafeAreaView, Platform, TextInput, Alert
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { CandleChart } from '@/components/CandleChart';
import { CryptoIcon } from '@/components/CryptoIcon';
import { Feather, MaterialIcons, MaterialCommunityIcons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';

type OrderType = 'market' | 'limit' | 'stop';
type ChartPeriod = '1m' | '5m' | '15m' | '1h' | '4h' | '1d';

function generateOrderBook(basePrice: number, isBuy: boolean) {
  return Array.from({ length: 8 }, (_, i) => {
    const offset = isBuy ? -(i + 1) * basePrice * 0.0005 : (i + 1) * basePrice * 0.0005;
    const price = basePrice + offset;
    const qty = parseFloat((Math.random() * 2).toFixed(4));
    const total = price * qty;
    return { price, qty, total };
  });
}

export default function TradingScreen() {
  const { symbol } = useLocalSearchParams<{ symbol: string }>();
  const router = useRouter();
  const colors = useColors();
  const { coins, addOrder, walletBalances, botEnabled } = useApp();

  const base = symbol?.replace('INR', '') || 'BTC';
  const coin = coins.find(c => c.symbol === base) || coins[0];

  const [side, setSide] = useState<'buy' | 'sell'>('buy');
  const [orderType, setOrderType] = useState<OrderType>('limit');
  const [price, setPrice] = useState(coin?.price.toFixed(2) || '0');
  const [qty, setQty] = useState('');
  const [percent, setPercent] = useState(0);
  const [period, setPeriod] = useState<ChartPeriod>('1h');
  const [tab, setTab] = useState<'orderbook' | 'trades' | 'orders'>('orderbook');

  const balance = walletBalances.find(b => b.symbol === (side === 'buy' ? 'INR' : base));
  const availableBalance = balance?.available || 0;

  const asks = useMemo(() => generateOrderBook(coin?.price || 0, false), [coin?.price]);
  const bids = useMemo(() => generateOrderBook(coin?.price || 0, true), [coin?.price]);

  const botTrades = useMemo(() => Array.from({ length: 12 }, (_, i) => ({
    id: i,
    price: (coin?.price || 0) * (1 + (Math.random() - 0.5) * 0.003),
    qty: parseFloat((Math.random() * 0.5).toFixed(4)),
    side: Math.random() > 0.5 ? 'buy' : 'sell',
    time: new Date(Date.now() - i * 8000).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
  })), [coin?.price]);

  const handleOrder = () => {
    if (!qty || parseFloat(qty) <= 0) { Alert.alert('Error', 'Enter valid quantity'); return; }
    const orderPrice = orderType === 'market' ? coin.price : parseFloat(price);
    const total = orderPrice * parseFloat(qty);
    const fee = total * 0.002;
    const tds = side === 'sell' ? total * 0.01 : 0;
    const invoice = `INV-${Date.now().toString().slice(-8)}`;

    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    addOrder({
      id: 'ORD' + Date.now(),
      symbol: `${base}/INR`,
      type: orderType,
      side,
      price: orderPrice,
      quantity: parseFloat(qty),
      filled: orderType === 'market' ? parseFloat(qty) : 0,
      status: orderType === 'market' ? 'filled' : 'open',
      timestamp: Date.now(),
      fee,
      tds,
      total,
    });

    Alert.alert(
      'Order Placed',
      `${side === 'buy' ? 'Buy' : 'Sell'} ${qty} ${base}\nPrice: ₹${orderPrice.toLocaleString('en-IN')}\nTotal: ₹${total.toLocaleString('en-IN', { maximumFractionDigits: 2 })}\nFee: ₹${fee.toFixed(2)}${tds > 0 ? `\nTDS (1%): ₹${tds.toFixed(2)}` : ''}\n\nInvoice: ${invoice}`
    );
    setQty('');
  };

  const s = styles(colors);
  const topPadding = Platform.OS === 'web' ? 80 : 0;

  return (
    <SafeAreaView style={s.container}>
      {/* Header */}
      <View style={[s.header, { paddingTop: topPadding || 12 }]}>
        <TouchableOpacity onPress={() => router.back()}>
          <Feather name="arrow-left" size={22} color={colors.foreground} />
        </TouchableOpacity>
        <View style={s.headerCenter}>
          <CryptoIcon symbol={base} size={24} />
          <Text style={s.headerSymbol}>{base}/INR</Text>
          {botEnabled && (
            <View style={s.botBadge}>
              <MaterialCommunityIcons name="robot" size={10} color="#000" />
            </View>
          )}
        </View>
        <View style={s.headerPrice}>
          <Text style={[s.currentPrice, { color: (coin?.change24h || 0) >= 0 ? colors.success : colors.danger }]}>
            ₹{(coin?.price || 0).toLocaleString('en-IN', { maximumFractionDigits: 2 })}
          </Text>
          <Text style={[s.changeText, { color: (coin?.change24h || 0) >= 0 ? colors.success : colors.danger }]}>
            {(coin?.change24h || 0) >= 0 ? '+' : ''}{(coin?.change24h || 0).toFixed(2)}%
          </Text>
        </View>
      </View>

      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Stats Bar */}
        <View style={s.statsBar}>
          {[
            { label: '24H High', value: `₹${(coin?.high24h || 0).toLocaleString('en-IN', { maximumFractionDigits: 0 })}` },
            { label: '24H Low', value: `₹${(coin?.low24h || 0).toLocaleString('en-IN', { maximumFractionDigits: 0 })}` },
            { label: '24H Vol', value: `${((coin?.volume24h || 0) / 1e6).toFixed(0)}M` },
          ].map(({ label, value }) => (
            <View key={label} style={s.statItem}>
              <Text style={s.statLabel}>{label}</Text>
              <Text style={s.statValue}>{value}</Text>
            </View>
          ))}
        </View>

        {/* Chart Period */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.periodRow}>
          {(['1m', '5m', '15m', '1h', '4h', '1d'] as ChartPeriod[]).map(p => (
            <TouchableOpacity key={p} style={[s.periodBtn, period === p && { backgroundColor: colors.primary + '22', borderColor: colors.primary }]} onPress={() => setPeriod(p)}>
              <Text style={[s.periodText, period === p && { color: colors.primary }]}>{p}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Candle Chart */}
        <View style={s.chartContainer}>
          <CandleChart basePrice={coin?.price || 0} positive={(coin?.change24h || 0) >= 0} height={200} />
        </View>

        {/* Order Book / Trades */}
        <View style={s.tabRow}>
          {([{ key: 'orderbook', label: 'Order Book' }, { key: 'trades', label: 'Recent Trades' }, { key: 'orders', label: 'My Orders' }] as const).map(t => (
            <TouchableOpacity key={t.key} style={[s.tab, tab === t.key && { borderBottomColor: colors.primary }]} onPress={() => setTab(t.key)}>
              <Text style={[s.tabText, tab === t.key && { color: colors.primary }]}>{t.label}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {tab === 'orderbook' && (
          <View style={s.orderBook}>
            <View style={s.obHeader}>
              <Text style={s.obLabel}>Price (INR)</Text>
              <Text style={s.obLabel}>Qty ({base})</Text>
              <Text style={s.obLabel}>Total (INR)</Text>
            </View>
            {asks.slice(0, 6).map((a, i) => (
              <View key={i} style={s.obRow}>
                <View style={[s.obFill, { width: `${(a.qty / 2) * 100}%`, backgroundColor: colors.danger + '22' }]} />
                <Text style={[s.obPrice, { color: colors.danger }]}>{a.price.toLocaleString('en-IN', { maximumFractionDigits: 2 })}</Text>
                <Text style={s.obQty}>{a.qty.toFixed(4)}</Text>
                <Text style={s.obTotal}>{(a.total / 1000).toFixed(1)}K</Text>
              </View>
            ))}
            <View style={s.midPrice}>
              <Text style={[s.midPriceText, { color: (coin?.change24h || 0) >= 0 ? colors.success : colors.danger }]}>
                ₹{(coin?.price || 0).toLocaleString('en-IN', { maximumFractionDigits: 2 })}
              </Text>
              <MaterialIcons name={coin?.change24h >= 0 ? 'arrow-upward' : 'arrow-downward'} size={14} color={(coin?.change24h || 0) >= 0 ? colors.success : colors.danger} />
            </View>
            {bids.slice(0, 6).map((b, i) => (
              <View key={i} style={s.obRow}>
                <View style={[s.obFill, { width: `${(b.qty / 2) * 100}%`, backgroundColor: colors.success + '22' }]} />
                <Text style={[s.obPrice, { color: colors.success }]}>{b.price.toLocaleString('en-IN', { maximumFractionDigits: 2 })}</Text>
                <Text style={s.obQty}>{b.qty.toFixed(4)}</Text>
                <Text style={s.obTotal}>{(b.total / 1000).toFixed(1)}K</Text>
              </View>
            ))}
          </View>
        )}

        {tab === 'trades' && (
          <View style={s.tradesSection}>
            <View style={s.obHeader}>
              <Text style={s.obLabel}>Price (INR)</Text>
              <Text style={s.obLabel}>Qty ({base})</Text>
              <Text style={s.obLabel}>Time</Text>
            </View>
            {botTrades.map(t => (
              <View key={t.id} style={s.tradeRow}>
                <Text style={[s.tradePrice, { color: t.side === 'buy' ? colors.success : colors.danger }]}>
                  {t.price.toLocaleString('en-IN', { maximumFractionDigits: 2 })}
                </Text>
                <Text style={s.tradeQty}>{t.qty}</Text>
                <Text style={s.tradeTime}>{t.time}</Text>
              </View>
            ))}
          </View>
        )}

        {/* Buy/Sell Form */}
        <View style={s.tradeForm}>
          {/* Side Toggle */}
          <View style={s.sideRow}>
            <TouchableOpacity style={[s.sideBtn, side === 'buy' && { backgroundColor: colors.success }]} onPress={() => setSide('buy')}>
              <Text style={[s.sideBtnText, side === 'buy' && { color: '#fff' }]}>Buy</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[s.sideBtn, side === 'sell' && { backgroundColor: colors.danger }]} onPress={() => setSide('sell')}>
              <Text style={[s.sideBtnText, side === 'sell' && { color: '#fff' }]}>Sell</Text>
            </TouchableOpacity>
          </View>

          {/* Order Type */}
          <View style={s.orderTypeRow}>
            {(['limit', 'market', 'stop'] as OrderType[]).map(t => (
              <TouchableOpacity key={t} style={[s.orderTypeBtn, orderType === t && { borderBottomWidth: 2, borderBottomColor: colors.primary }]} onPress={() => setOrderType(t)}>
                <Text style={[s.orderTypeText, orderType === t && { color: colors.primary }]}>{t.charAt(0).toUpperCase() + t.slice(1)}</Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Balance */}
          <View style={s.balRow}>
            <Text style={s.balLabel}>Available:</Text>
            <Text style={s.balValue}>{side === 'buy' ? `₹${availableBalance.toLocaleString('en-IN')}` : `${availableBalance} ${base}`}</Text>
          </View>

          {/* Price */}
          {orderType !== 'market' && (
            <View style={s.inputGroup}>
              <Text style={s.inputLabel}>Price (INR)</Text>
              <View style={s.inputRow}>
                <TextInput style={s.tradeInput} value={price} onChangeText={setPrice} keyboardType="decimal-pad" />
                <TouchableOpacity onPress={() => setPrice(coin?.price.toFixed(2) || '0')}>
                  <Text style={s.bestPrice}>Best</Text>
                </TouchableOpacity>
              </View>
            </View>
          )}

          {/* Qty */}
          <View style={s.inputGroup}>
            <Text style={s.inputLabel}>Quantity ({base})</Text>
            <View style={s.inputRow}>
              <TextInput style={s.tradeInput} value={qty} onChangeText={setQty} placeholder="0.00" placeholderTextColor={colors.mutedForeground} keyboardType="decimal-pad" />
            </View>
          </View>

          {/* Percent Buttons */}
          <View style={s.percentRow}>
            {[25, 50, 75, 100].map(p => (
              <TouchableOpacity key={p} style={[s.percentBtn, percent === p && { backgroundColor: side === 'buy' ? colors.success : colors.danger, borderColor: 'transparent' }]} onPress={() => {
                setPercent(p);
                const total = side === 'buy' ? availableBalance * p / 100 : availableBalance * p / 100;
                const orderPrice = orderType === 'market' ? coin.price : parseFloat(price);
                const calcQty = side === 'buy' ? total / orderPrice : total;
                setQty(calcQty.toFixed(6));
              }}>
                <Text style={[s.percentText, percent === p && { color: '#fff' }]}>{p}%</Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Total */}
          {qty && (
            <View style={s.totalBox}>
              <View style={s.totalRow}>
                <Text style={s.totalLabel}>Total</Text>
                <Text style={s.totalValue}>₹{(parseFloat(qty || '0') * (orderType === 'market' ? coin.price : parseFloat(price || '0'))).toLocaleString('en-IN', { maximumFractionDigits: 2 })}</Text>
              </View>
              <View style={s.totalRow}>
                <Text style={s.totalLabel}>Fee (0.2%)</Text>
                <Text style={s.totalValue}>₹{(parseFloat(qty || '0') * (orderType === 'market' ? coin.price : parseFloat(price || '0')) * 0.002).toFixed(2)}</Text>
              </View>
              {side === 'sell' && (
                <View style={s.totalRow}>
                  <Text style={[s.totalLabel, { color: '#F0B90B' }]}>TDS (1%)</Text>
                  <Text style={[s.totalValue, { color: '#F0B90B' }]}>₹{(parseFloat(qty || '0') * (orderType === 'market' ? coin.price : parseFloat(price || '0')) * 0.01).toFixed(2)}</Text>
                </View>
              )}
            </View>
          )}

          {/* Submit */}
          <TouchableOpacity style={[s.submitBtn, { backgroundColor: side === 'buy' ? colors.success : colors.danger }]} onPress={handleOrder}>
            <Text style={s.submitBtnText}>{side === 'buy' ? 'Buy' : 'Sell'} {base}</Text>
          </TouchableOpacity>
        </View>

        <View style={{ height: 100 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (colors: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  header: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingBottom: 12, borderBottomWidth: 1, borderBottomColor: colors.border },
  headerCenter: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 6, justifyContent: 'center' },
  headerSymbol: { fontSize: 16, fontFamily: 'Inter_700Bold', color: colors.foreground },
  botBadge: { backgroundColor: colors.primary, borderRadius: 6, paddingHorizontal: 4, paddingVertical: 2 },
  headerPrice: { alignItems: 'flex-end' },
  currentPrice: { fontSize: 16, fontFamily: 'Inter_700Bold' },
  changeText: { fontSize: 11, fontFamily: 'Inter_500Medium', marginTop: 1 },
  statsBar: { flexDirection: 'row', justifyContent: 'space-around', paddingVertical: 10, paddingHorizontal: 16, borderBottomWidth: 1, borderBottomColor: colors.border },
  statItem: { alignItems: 'center' },
  statLabel: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  statValue: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_600SemiBold', marginTop: 2 },
  periodRow: { paddingHorizontal: 16, paddingVertical: 8 },
  periodBtn: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 8, borderWidth: 1, borderColor: colors.border, marginRight: 6, backgroundColor: colors.secondary },
  periodText: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  chartContainer: { paddingHorizontal: 16, paddingBottom: 8 },
  tabRow: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: colors.border },
  tab: { flex: 1, alignItems: 'center', paddingVertical: 10, borderBottomWidth: 2, borderBottomColor: 'transparent' },
  tabText: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  orderBook: { paddingHorizontal: 16 },
  obHeader: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: colors.border },
  obLabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_500Medium', flex: 1, textAlign: 'center' },
  obRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4, position: 'relative' },
  obFill: { position: 'absolute', top: 0, right: 0, bottom: 0, borderRadius: 2 },
  obPrice: { fontSize: 12, fontFamily: 'Inter_600SemiBold', flex: 1, textAlign: 'center' },
  obQty: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_400Regular', flex: 1, textAlign: 'center' },
  obTotal: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', flex: 1, textAlign: 'center' },
  midPrice: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 4, paddingVertical: 8, borderTopWidth: 1, borderBottomWidth: 1, borderColor: colors.border },
  midPriceText: { fontSize: 16, fontFamily: 'Inter_700Bold' },
  tradesSection: { paddingHorizontal: 16 },
  tradeRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 5 },
  tradePrice: { fontSize: 12, fontFamily: 'Inter_600SemiBold', flex: 1 },
  tradeQty: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_400Regular', flex: 1, textAlign: 'center' },
  tradeTime: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', flex: 1, textAlign: 'right' },
  tradeForm: { padding: 16 },
  sideRow: { flexDirection: 'row', backgroundColor: colors.secondary, borderRadius: 10, padding: 4, marginBottom: 14, borderWidth: 1, borderColor: colors.border },
  sideBtn: { flex: 1, alignItems: 'center', paddingVertical: 10, borderRadius: 8 },
  sideBtnText: { fontSize: 15, fontFamily: 'Inter_700Bold', color: colors.mutedForeground },
  orderTypeRow: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: colors.border, marginBottom: 14 },
  orderTypeBtn: { paddingHorizontal: 14, paddingVertical: 8, borderBottomWidth: 2, borderBottomColor: 'transparent' },
  orderTypeText: { fontSize: 13, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  balRow: { flexDirection: 'row', justifyContent: 'flex-end', gap: 6, marginBottom: 10 },
  balLabel: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  balValue: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_600SemiBold' },
  inputGroup: { marginBottom: 12 },
  inputLabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_500Medium', marginBottom: 6, textTransform: 'uppercase', letterSpacing: 0.5 },
  inputRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: colors.secondary, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 10, gap: 8, borderWidth: 1, borderColor: colors.border },
  tradeInput: { flex: 1, fontSize: 15, color: colors.foreground, fontFamily: 'Inter_600SemiBold' },
  bestPrice: { fontSize: 12, color: colors.primary, fontFamily: 'Inter_500Medium' },
  percentRow: { flexDirection: 'row', gap: 8, marginBottom: 14 },
  percentBtn: { flex: 1, alignItems: 'center', paddingVertical: 6, borderRadius: 6, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.secondary },
  percentText: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  totalBox: { backgroundColor: colors.secondary, borderRadius: 8, padding: 12, marginBottom: 14, gap: 6, borderWidth: 1, borderColor: colors.border },
  totalRow: { flexDirection: 'row', justifyContent: 'space-between' },
  totalLabel: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  totalValue: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_600SemiBold' },
  submitBtn: { borderRadius: 10, paddingVertical: 14, alignItems: 'center' },
  submitBtnText: { fontSize: 16, fontFamily: 'Inter_700Bold', color: '#fff' },
});
