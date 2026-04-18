import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Platform } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useColors } from '@/hooks/useColors';
import { useApp, WalletType } from '@/context/AppContext';
import { useFocusEffect } from 'expo-router';
import { CryptoIcon } from '@/components/CryptoIcon';
import { Feather, MaterialCommunityIcons } from '@expo/vector-icons';
import { LoginRequired } from '@/components/LoginRequired';

const WALLET_TYPES: { id: WalletType; name: string; icon: any; color: string }[] = [
  { id: 'spot', name: 'Spot', icon: 'wallet-outline', color: '#F0B90B' },
  { id: 'inr', name: 'INR', icon: 'cash', color: '#0ECB81' },
  { id: 'earn', name: 'Earn', icon: 'piggy-bank-outline', color: '#3FB7E5' },
  { id: 'futures', name: 'Futures', icon: 'chart-line', color: '#F6465D' },
];

export default function Wallet() {
  const colors = useColors();
  const router = useRouter();
  const { apiWallets, refreshWallets, transactions, todayPnl, todayPnlPercent, user } = useApp();
  const [walletType, setWalletType] = useState<WalletType>('spot');
  const [hideBalance, setHideBalance] = useState(false);

  useFocusEffect(React.useCallback(() => { if (user.isLoggedIn) refreshWallets(); }, [user.isLoggedIn]));

  if (!user.isLoggedIn) return <LoginRequired feature="your wallet" />;

  const allBalances = apiWallets.map(w => {
    const available = Number(w.balance);
    const locked = Number(w.locked);
    const price = Number(w.coinPrice);
    return {
      walletType: w.walletType as WalletType,
      symbol: w.coinSymbol,
      name: w.coinName,
      available,
      locked,
      inrValue: available * price,
    };
  });
  const balances = allBalances.filter(b => b.walletType === walletType);
  const walletTotal = balances.reduce((s, b) => s + b.inrValue, 0);
  const totalPortfolioValue = allBalances.reduce((s, b) => s + b.inrValue, 0);
  const recentTxns = transactions.slice(0, 5);

  const s = styles(colors);
  const insets = useSafeAreaInsets();
  const topPad = Platform.OS === 'web' ? 80 : insets.top + 8;
  const bottomPad = insets.bottom + (Platform.OS === 'web' ? 100 : 80);

  return (
    <SafeAreaView style={s.container} edges={['top']}>
      <View style={[s.header, { paddingTop: topPad }]}>
        <Text style={s.headerTitle}>Wallet</Text>
        <View style={{ flexDirection: 'row', gap: 8 }}>
          <TouchableOpacity style={s.iconBtn} onPress={() => setHideBalance(!hideBalance)}>
            <Feather name={hideBalance ? 'eye-off' : 'eye'} size={18} color={colors.foreground} />
          </TouchableOpacity>
          <TouchableOpacity style={s.iconBtn} onPress={() => router.push('/wallet-history' as any)}>
            <Feather name="clock" size={18} color={colors.foreground} />
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Total Portfolio */}
        <View style={s.heroCard}>
          <Text style={s.heroLbl}>Estimated Total Value</Text>
          <View style={s.heroValueRow}>
            <Text style={s.heroValue}>{hideBalance ? '••••••' : `₹${totalPortfolioValue.toLocaleString('en-IN', { maximumFractionDigits: 0 })}`}</Text>
            <Text style={s.heroSub}>≈ ${(totalPortfolioValue / 83).toLocaleString('en-IN', { maximumFractionDigits: 0 })}</Text>
          </View>
          <View style={s.pnlRow}>
            <Feather name={todayPnl >= 0 ? 'arrow-up-right' : 'arrow-down-right'} size={14} color={todayPnl >= 0 ? colors.success : colors.danger} />
            <Text style={[s.pnlText, { color: todayPnl >= 0 ? colors.success : colors.danger }]}>
              {hideBalance ? '••••' : `${todayPnl >= 0 ? '+' : ''}₹${todayPnl.toLocaleString('en-IN')} (${todayPnlPercent}%)`}
            </Text>
            <Text style={s.pnlLbl}>Today</Text>
          </View>
        </View>

        {/* Quick Actions */}
        <View style={s.actionGrid}>
          {[
            { label: 'Deposit\nINR', icon: 'plus-circle' as const, color: colors.success, onPress: () => router.push('/services/deposit-inr' as any) },
            { label: 'Withdraw\nINR', icon: 'minus-circle' as const, color: colors.danger, onPress: () => router.push('/services/withdraw-inr' as any) },
            { label: 'Deposit\nCrypto', icon: 'arrow-down-circle' as const, color: colors.info, onPress: () => router.push('/services/deposit-crypto' as any) },
            { label: 'Withdraw\nCrypto', icon: 'arrow-up-circle' as const, color: colors.warning, onPress: () => router.push('/services/withdraw-crypto' as any) },
            { label: 'Transfer', icon: 'repeat' as const, color: colors.primary, onPress: () => router.push('/services/transfer' as any) },
          ].map((a, i) => (
            <TouchableOpacity key={i} style={s.actionItem} onPress={a.onPress}>
              <View style={[s.actionIcon, { backgroundColor: a.color + '22' }]}>
                <Feather name={a.icon} size={18} color={a.color} />
              </View>
              <Text style={s.actionLbl}>{a.label}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Wallet Type Tabs */}
        <Text style={s.sectionTitle}>My Wallets</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.tabScroll}>
          {WALLET_TYPES.map(w => (
            <TouchableOpacity key={w.id} style={[s.walletTab, walletType === w.id && { backgroundColor: w.color + '22', borderColor: w.color }]} onPress={() => setWalletType(w.id)}>
              <MaterialCommunityIcons name={w.icon} size={16} color={walletType === w.id ? w.color : colors.mutedForeground} />
              <Text style={[s.walletTabText, walletType === w.id && { color: w.color }]}>{w.name}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Wallet Total */}
        <View style={s.walletTotalCard}>
          <View>
            <Text style={s.totalLbl}>{WALLET_TYPES.find(w => w.id === walletType)?.name} Wallet Total</Text>
            <Text style={s.totalVal}>{hideBalance ? '••••••' : `₹${walletTotal.toLocaleString('en-IN', { maximumFractionDigits: 0 })}`}</Text>
          </View>
          {walletType === 'earn' && (
            <TouchableOpacity style={[s.earnBtn, { backgroundColor: colors.primary }]} onPress={() => router.push('/services/earn' as any)}>
              <Text style={[s.earnBtnText, { color: '#000' }]}>Stake</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Balances */}
        <View style={s.balanceList}>
          {balances.length === 0 ? (
            <View style={s.emptyBal}>
              <Text style={s.emptyText}>No assets in {WALLET_TYPES.find(w => w.id === walletType)?.name} wallet</Text>
            </View>
          ) : balances.map((b, i) => (
            <TouchableOpacity key={i} style={s.balRow} onPress={() => b.symbol !== 'INR' && router.push(`/trading/${b.symbol}USDT` as any)}>
              <CryptoIcon symbol={b.symbol} size={36} />
              <View style={{ flex: 1, marginLeft: 12 }}>
                <Text style={s.balSym}>{b.symbol}</Text>
                <Text style={s.balName}>{b.name} • Locked: {b.locked.toFixed(b.symbol === 'INR' ? 2 : 6)}</Text>
              </View>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={s.balQty}>{hideBalance ? '••••' : b.symbol === 'INR' ? b.available.toLocaleString('en-IN', { maximumFractionDigits: 2 }) : b.available.toFixed(6)}</Text>
                <Text style={s.balValue}>{hideBalance ? '••••' : `≈ ₹${b.inrValue.toLocaleString('en-IN', { maximumFractionDigits: 0 })}`}</Text>
              </View>
            </TouchableOpacity>
          ))}
        </View>

        {/* Recent Activity */}
        <View style={s.recentHeader}>
          <Text style={s.sectionTitle}>Recent Activity</Text>
          <TouchableOpacity onPress={() => router.push('/wallet-history' as any)}>
            <Text style={[s.viewAll, { color: colors.primary }]}>View All</Text>
          </TouchableOpacity>
        </View>
        <View style={s.txnList}>
          {recentTxns.map(t => (
            <View key={t.id} style={s.txnRow}>
              <View style={[s.txnIcon, { backgroundColor: (t.type === 'deposit' || t.type === 'earn' ? colors.success : t.type === 'withdraw' ? colors.danger : colors.info) + '22' }]}>
                <Feather name={t.type === 'deposit' ? 'arrow-down' : t.type === 'withdraw' ? 'arrow-up' : t.type === 'earn' ? 'gift' : 'repeat'} size={14} color={t.type === 'deposit' || t.type === 'earn' ? colors.success : t.type === 'withdraw' ? colors.danger : colors.info} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={s.txnTitle}>{t.type.charAt(0).toUpperCase() + t.type.slice(1)} {t.symbol}</Text>
                <Text style={s.txnDate}>{new Date(t.timestamp).toLocaleString('en-IN', { dateStyle: 'medium', timeStyle: 'short' })}</Text>
              </View>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={[s.txnAmount, { color: t.type === 'withdraw' ? colors.danger : colors.success }]}>
                  {t.type === 'withdraw' ? '-' : '+'}{t.amount} {t.symbol}
                </Text>
                <Text style={[s.txnStatus, { color: t.status === 'completed' ? colors.success : t.status === 'pending' ? colors.warning : colors.danger }]}>
                  {t.status}
                </Text>
              </View>
            </View>
          ))}
        </View>

        <View style={{ height: 100 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (c: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: c.background },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingBottom: 12 },
  headerTitle: { fontSize: 20, color: c.foreground, fontFamily: 'Inter_700Bold' },
  iconBtn: { width: 36, height: 36, alignItems: 'center', justifyContent: 'center', borderRadius: 8, backgroundColor: c.card, borderWidth: 1, borderColor: c.border },
  heroCard: { backgroundColor: c.card, marginHorizontal: 16, borderRadius: 16, padding: 18, borderWidth: 1, borderColor: c.border, marginBottom: 14 },
  heroLbl: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase' },
  heroValueRow: { flexDirection: 'row', alignItems: 'baseline', gap: 8, marginTop: 6 },
  heroValue: { fontSize: 28, color: c.foreground, fontFamily: 'Inter_700Bold' },
  heroSub: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  pnlRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 8 },
  pnlText: { fontSize: 12, fontFamily: 'Inter_600SemiBold' },
  pnlLbl: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  actionGrid: { flexDirection: 'row', justifyContent: 'space-around', paddingHorizontal: 16, marginBottom: 18 },
  actionItem: { alignItems: 'center', flex: 1 },
  actionIcon: { width: 44, height: 44, borderRadius: 22, alignItems: 'center', justifyContent: 'center', marginBottom: 6 },
  actionLbl: { fontSize: 10, color: c.foreground, fontFamily: 'Inter_500Medium', textAlign: 'center' },
  sectionTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_700Bold', textTransform: 'uppercase', marginHorizontal: 16, marginBottom: 10, letterSpacing: 0.5 },
  tabScroll: { paddingHorizontal: 16, marginBottom: 12 },
  walletTab: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 14, paddingVertical: 8, borderRadius: 8, borderWidth: 1, borderColor: c.border, backgroundColor: c.card, marginRight: 8 },
  walletTabText: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  walletTotalCard: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', backgroundColor: c.card, marginHorizontal: 16, borderRadius: 12, padding: 14, borderWidth: 1, borderColor: c.border, marginBottom: 10 },
  totalLbl: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase' },
  totalVal: { fontSize: 18, color: c.foreground, fontFamily: 'Inter_700Bold', marginTop: 4 },
  earnBtn: { borderRadius: 8, paddingHorizontal: 14, paddingVertical: 8 },
  earnBtnText: { fontSize: 12, fontFamily: 'Inter_700Bold' },
  balanceList: { paddingHorizontal: 16, marginBottom: 16 },
  emptyBal: { padding: 30, alignItems: 'center', backgroundColor: c.card, borderRadius: 12, borderWidth: 1, borderColor: c.border },
  emptyText: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  balRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, padding: 12, marginBottom: 6, borderWidth: 1, borderColor: c.border },
  balSym: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_700Bold' },
  balName: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  balQty: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  balValue: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  recentHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingRight: 16 },
  viewAll: { fontSize: 12, fontFamily: 'Inter_600SemiBold' },
  txnList: { paddingHorizontal: 16 },
  txnRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 10, padding: 12, marginBottom: 6, borderWidth: 1, borderColor: c.border, gap: 12 },
  txnIcon: { width: 32, height: 32, borderRadius: 16, alignItems: 'center', justifyContent: 'center' },
  txnTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  txnDate: { fontSize: 10, color: c.mutedForeground, marginTop: 2, fontFamily: 'Inter_400Regular' },
  txnAmount: { fontSize: 13, fontFamily: 'Inter_700Bold' },
  txnStatus: { fontSize: 10, fontFamily: 'Inter_500Medium', marginTop: 2, textTransform: 'capitalize' },
});
