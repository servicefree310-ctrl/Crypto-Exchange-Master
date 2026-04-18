import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  SafeAreaView, Platform, RefreshControl
} from 'react-native';
import { useRouter } from 'expo-router';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { MiniChart } from '@/components/MiniChart';
import { Feather, MaterialIcons, MaterialCommunityIcons } from '@expo/vector-icons';

function formatINR(n: number) {
  if (n >= 10000000) return `₹${(n / 10000000).toFixed(2)}Cr`;
  if (n >= 100000) return `₹${(n / 100000).toFixed(2)}L`;
  if (n >= 1000) return `₹${(n / 1000).toFixed(1)}K`;
  return `₹${n.toFixed(2)}`;
}

function formatPrice(p: number, symbol: string) {
  if (p < 0.01) return `₹${p.toFixed(6)}`;
  if (p < 1) return `₹${p.toFixed(4)}`;
  if (p >= 100000) return `₹${(p / 100000).toFixed(2)}L`;
  return `₹${p.toLocaleString('en-IN', { maximumFractionDigits: 2 })}`;
}

export default function HomeScreen() {
  const colors = useColors();
  const { coins, totalPortfolioValue, todayPnl, todayPnlPercent, user, walletBalances, botEnabled } = useApp();
  const router = useRouter();
  const [refreshing, setRefreshing] = useState(false);
  const [hideBalance, setHideBalance] = useState(false);

  const gainers = [...coins].sort((a, b) => b.change24h - a.change24h).slice(0, 5);
  const losers = [...coins].sort((a, b) => a.change24h - b.change24h).slice(0, 5);

  const onRefresh = async () => {
    setRefreshing(true);
    await new Promise(r => setTimeout(r, 1000));
    setRefreshing(false);
  };

  const s = styles(colors);
  const topPadding = Platform.OS === 'web' ? 80 : 0;

  return (
    <SafeAreaView style={s.container}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={[s.scroll, { paddingTop: topPadding }]}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />}
      >
        {/* Header */}
        <View style={s.header}>
          <View>
            <Text style={s.greeting}>Hello, {user.name.split(' ')[0]}</Text>
            <Text style={s.uid}>UID: {user.uid}</Text>
          </View>
          <View style={s.headerRight}>
            {botEnabled && (
              <View style={s.botBadge}>
                <MaterialCommunityIcons name="robot" size={12} color="#000" />
                <Text style={s.botText}>BOT</Text>
              </View>
            )}
            <TouchableOpacity style={s.notifBtn}>
              <Feather name="bell" size={20} color={colors.foreground} />
            </TouchableOpacity>
          </View>
        </View>

        {/* Portfolio Card */}
        <View style={s.portfolioCard}>
          <View style={s.portfolioHeader}>
            <Text style={s.portfolioLabel}>Total Portfolio Value</Text>
            <TouchableOpacity onPress={() => setHideBalance(!hideBalance)}>
              <Feather name={hideBalance ? 'eye-off' : 'eye'} size={16} color={colors.mutedForeground} />
            </TouchableOpacity>
          </View>
          <Text style={s.portfolioValue}>
            {hideBalance ? '₹ ••••••' : formatINR(totalPortfolioValue)}
          </Text>
          <View style={s.pnlRow}>
            <MaterialIcons
              name={todayPnl >= 0 ? 'trending-up' : 'trending-down'}
              size={16}
              color={todayPnl >= 0 ? colors.success : colors.danger}
            />
            <Text style={[s.pnlText, { color: todayPnl >= 0 ? colors.success : colors.danger }]}>
              {todayPnl >= 0 ? '+' : ''}{formatINR(todayPnl)} ({todayPnlPercent}%) Today
            </Text>
          </View>

          {/* Quick Actions */}
          <View style={s.quickActions}>
            {[
              { icon: 'arrow-down-circle', label: 'Deposit', route: '/services/deposit-inr' },
              { icon: 'arrow-up-circle', label: 'Withdraw', route: '/services/withdraw-inr' },
              { icon: 'refresh-cw', label: 'Transfer', route: '/services/transfer' },
              { icon: 'bar-chart-2', label: 'Trade', route: '/(tabs)/trade' },
            ].map(({ icon, label, route }) => (
              <TouchableOpacity key={label} style={s.actionBtn} onPress={() => router.push(route as any)}>
                <View style={s.actionIcon}>
                  <Feather name={icon as any} size={20} color={colors.primary} />
                </View>
                <Text style={s.actionLabel}>{label}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Service Shortcuts */}
        <View style={s.serviceGrid}>
          {[
            { icon: 'gift', label: 'Earn', sub: 'Up to 18.5% APY', color: colors.success, route: '/services/earn' },
            { icon: 'shield', label: 'KYC', sub: `Level ${user.kycLevel}`, color: colors.primary, route: '/services/kyc' },
            { icon: 'percent', label: 'Fees', sub: 'Volume tiers', color: colors.info, route: '/services/fees' },
            { icon: 'credit-card', label: 'Banks', sub: 'Manage', color: colors.warning, route: '/services/banks' },
          ].map(item => (
            <TouchableOpacity key={item.label} style={s.serviceCard} onPress={() => router.push(item.route as any)}>
              <View style={[s.serviceIcon, { backgroundColor: item.color + '22' }]}>
                <Feather name={item.icon as any} size={18} color={item.color} />
              </View>
              <Text style={s.serviceLabel}>{item.label}</Text>
              <Text style={s.serviceSub}>{item.sub}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* KYC Banner */}
        {user.kycStatus !== 'verified' && (
          <TouchableOpacity style={s.kycBanner} onPress={() => router.push('/services/kyc' as any)}>
            <MaterialIcons name="verified-user" size={18} color="#F0B90B" />
            <Text style={s.kycText}>
              {user.kycStatus === 'pending' ? 'Complete KYC to unlock full features' :
               user.kycStatus === 'under_review' ? 'KYC under review' : 'KYC rejected - Resubmit'}
            </Text>
            <Feather name="chevron-right" size={16} color={colors.mutedForeground} />
          </TouchableOpacity>
        )}

        {/* Top Gainers */}
        <View style={s.section}>
          <View style={s.sectionHeader}>
            <Text style={s.sectionTitle}>Top Gainers</Text>
            <TouchableOpacity onPress={() => router.push('/(tabs)/markets')}>
              <Text style={s.seeAll}>See All</Text>
            </TouchableOpacity>
          </View>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.coinScroll}>
            {gainers.map(coin => (
              <TouchableOpacity
                key={coin.symbol}
                style={s.coinCard}
                onPress={() => router.push(`/trading/${coin.symbol}INR` as any)}
              >
                <CryptoIcon symbol={coin.symbol} size={32} />
                <Text style={s.coinSymbol}>{coin.symbol}</Text>
                <Text style={s.coinPrice}>{formatPrice(coin.price, coin.symbol)}</Text>
                <MiniChart positive={true} width={60} height={24} />
                <Text style={[s.coinChange, { color: colors.success }]}>+{coin.change24h.toFixed(2)}%</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Top Losers */}
        <View style={s.section}>
          <View style={s.sectionHeader}>
            <Text style={s.sectionTitle}>Top Losers</Text>
            <TouchableOpacity onPress={() => router.push('/(tabs)/markets')}>
              <Text style={s.seeAll}>See All</Text>
            </TouchableOpacity>
          </View>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.coinScroll}>
            {losers.map(coin => (
              <TouchableOpacity
                key={coin.symbol}
                style={s.coinCard}
                onPress={() => router.push(`/trading/${coin.symbol}INR` as any)}
              >
                <CryptoIcon symbol={coin.symbol} size={32} />
                <Text style={s.coinSymbol}>{coin.symbol}</Text>
                <Text style={s.coinPrice}>{formatPrice(coin.price, coin.symbol)}</Text>
                <MiniChart positive={false} width={60} height={24} />
                <Text style={[s.coinChange, { color: colors.danger }]}>{coin.change24h.toFixed(2)}%</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Market Overview */}
        <View style={s.section}>
          <View style={s.sectionHeader}>
            <Text style={s.sectionTitle}>Market</Text>
            <TouchableOpacity onPress={() => router.push('/(tabs)/markets')}>
              <Text style={s.seeAll}>See All</Text>
            </TouchableOpacity>
          </View>
          {coins.slice(0, 6).map(coin => (
            <TouchableOpacity
              key={coin.symbol}
              style={s.marketRow}
              onPress={() => router.push(`/trading/${coin.symbol}INR` as any)}
            >
              <CryptoIcon symbol={coin.symbol} size={40} />
              <View style={s.marketInfo}>
                <Text style={s.marketSymbol}>{coin.symbol}</Text>
                <Text style={s.marketName}>{coin.name}</Text>
              </View>
              <MiniChart positive={coin.change24h >= 0} width={60} height={28} />
              <View style={s.marketPrice}>
                <Text style={s.marketPriceText}>{formatPrice(coin.price, coin.symbol)}</Text>
                <View style={[s.changeBadge, { backgroundColor: coin.change24h >= 0 ? colors.success + '22' : colors.danger + '22' }]}>
                  <Text style={[s.changeText, { color: coin.change24h >= 0 ? colors.success : colors.danger }]}>
                    {coin.change24h >= 0 ? '+' : ''}{coin.change24h.toFixed(2)}%
                  </Text>
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </View>

        <View style={{ height: 100 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (colors: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  scroll: { paddingHorizontal: 16 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 16 },
  greeting: { fontSize: 20, fontFamily: 'Inter_700Bold', color: colors.foreground },
  uid: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  headerRight: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  botBadge: { flexDirection: 'row', alignItems: 'center', gap: 3, backgroundColor: colors.primary, borderRadius: 8, paddingHorizontal: 6, paddingVertical: 3 },
  botText: { fontSize: 10, fontFamily: 'Inter_700Bold', color: '#000' },
  notifBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: colors.card, alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: colors.border },
  portfolioCard: { backgroundColor: colors.card, borderRadius: 16, padding: 20, marginBottom: 16, borderWidth: 1, borderColor: colors.border },
  portfolioHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 4 },
  portfolioLabel: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  portfolioValue: { fontSize: 32, fontFamily: 'Inter_700Bold', color: colors.foreground, letterSpacing: -1, marginVertical: 4 },
  pnlRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: 20 },
  pnlText: { fontSize: 13, fontFamily: 'Inter_500Medium' },
  quickActions: { flexDirection: 'row', justifyContent: 'space-between' },
  actionBtn: { alignItems: 'center', gap: 6 },
  actionIcon: { width: 48, height: 48, borderRadius: 24, backgroundColor: colors.primary + '18', alignItems: 'center', justifyContent: 'center' },
  actionLabel: { fontSize: 11, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  kycBanner: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: '#F0B90B18', borderRadius: 10, padding: 12, marginBottom: 16, borderWidth: 1, borderColor: '#F0B90B44' },
  kycText: { flex: 1, fontSize: 13, fontFamily: 'Inter_500Medium', color: colors.foreground },
  section: { marginBottom: 20 },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  sectionTitle: { fontSize: 16, fontFamily: 'Inter_700Bold', color: colors.foreground },
  seeAll: { fontSize: 13, fontFamily: 'Inter_500Medium', color: colors.primary },
  coinScroll: { marginHorizontal: -4 },
  coinCard: { backgroundColor: colors.card, borderRadius: 12, padding: 12, marginHorizontal: 4, width: 110, alignItems: 'flex-start', borderWidth: 1, borderColor: colors.border },
  coinSymbol: { fontSize: 14, fontFamily: 'Inter_700Bold', color: colors.foreground, marginTop: 8 },
  coinPrice: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginBottom: 4 },
  coinChange: { fontSize: 12, fontFamily: 'Inter_600SemiBold', marginTop: 4 },
  marketRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: colors.border, gap: 12 },
  marketInfo: { flex: 1 },
  marketSymbol: { fontSize: 15, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  marketName: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  marketPrice: { alignItems: 'flex-end', gap: 4 },
  marketPriceText: { fontSize: 14, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  changeBadge: { borderRadius: 6, paddingHorizontal: 6, paddingVertical: 2 },
  changeText: { fontSize: 12, fontFamily: 'Inter_600SemiBold' },
  serviceGrid: { flexDirection: 'row', gap: 8, marginBottom: 18 },
  serviceCard: { flex: 1, backgroundColor: colors.card, borderRadius: 12, padding: 12, alignItems: 'center', borderWidth: 1, borderColor: colors.border },
  serviceIcon: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center', marginBottom: 8 },
  serviceLabel: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_700Bold' },
  serviceSub: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
});
