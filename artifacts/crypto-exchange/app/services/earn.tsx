import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, TextInput, Alert, Switch } from 'react-native';
import { Header } from '@/components/Header';
import { useColors } from '@/hooks/useColors';
import { useApp, EarnProduct } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { Feather, MaterialCommunityIcons } from '@expo/vector-icons';

export default function Earn() {
  const colors = useColors();
  const { earnProducts, earnPositions, addEarnPosition, updateBalance, addTransaction } = useApp();
  const [tab, setTab] = useState<'simple' | 'advanced' | 'positions'>('simple');
  const [selectedProduct, setSelectedProduct] = useState<EarnProduct | null>(null);
  const [stakeAmount, setStakeAmount] = useState('');
  const [autoMaturity, setAutoMaturity] = useState(false);

  const totalStaked = earnPositions.reduce((s, p) => s + p.amount, 0);
  const totalEarned = earnPositions.reduce((s, p) => s + p.earned, 0);
  const filtered = earnProducts.filter(p => p.type === tab);

  const handleStake = () => {
    if (!selectedProduct) return;
    const amt = parseFloat(stakeAmount);
    if (!amt || amt < selectedProduct.minAmount) {
      Alert.alert('Error', `Minimum stake: ${selectedProduct.minAmount} ${selectedProduct.symbol}`);
      return;
    }
    addEarnPosition({
      id: 'EP' + Date.now(),
      productId: selectedProduct.id,
      symbol: selectedProduct.symbol,
      type: selectedProduct.type,
      amount: amt,
      apy: selectedProduct.apy,
      startDate: Date.now(),
      endDate: selectedProduct.duration ? Date.now() + selectedProduct.duration * 86400000 : undefined,
      earned: 0,
      status: 'active',
      autoMaturity: selectedProduct.type === 'advanced' ? autoMaturity : false,
    });
    updateBalance(selectedProduct.symbol, 'spot', -amt);
    updateBalance(selectedProduct.symbol, 'earn', amt);
    addTransaction({
      id: 'TXN' + Date.now(), type: 'earn', symbol: selectedProduct.symbol, amount: amt,
      status: 'completed', timestamp: Date.now(), fee: 0, walletType: 'earn',
    });
    Alert.alert('Success', `${amt} ${selectedProduct.symbol} staked at ${selectedProduct.apy}% APY`);
    setSelectedProduct(null); setStakeAmount('');
  };

  const s = styles(colors);
  return (
    <SafeAreaView style={s.container}>
      <Header title="Earn" subtitle="Grow your crypto holdings" />
      <ScrollView contentContainerStyle={s.content}>
        {/* Stats */}
        <View style={s.statsCard}>
          <View style={{ flex: 1 }}>
            <Text style={s.statLbl}>Total Earnings</Text>
            <Text style={[s.statVal, { color: colors.success }]}>+${totalEarned.toFixed(2)}</Text>
            <Text style={s.statSub}>Lifetime rewards</Text>
          </View>
          <View style={s.statDivider} />
          <View style={{ flex: 1 }}>
            <Text style={s.statLbl}>Total Staked</Text>
            <Text style={s.statVal}>${totalStaked.toFixed(2)}</Text>
            <Text style={s.statSub}>{earnPositions.length} active</Text>
          </View>
        </View>

        {/* Tabs */}
        <View style={s.tabs}>
          {([
            { key: 'simple', label: 'Simple Earn', icon: 'lock-open' as const },
            { key: 'advanced', label: 'Fixed Term', icon: 'lock' as const },
            { key: 'positions', label: 'My Earnings', icon: 'wallet' as const },
          ] as const).map(t => (
            <TouchableOpacity key={t.key} style={[s.tab, tab === t.key && { backgroundColor: colors.primary }]} onPress={() => setTab(t.key)}>
              <Feather name={t.icon} size={13} color={tab === t.key ? '#000' : colors.mutedForeground} />
              <Text style={[s.tabText, { color: tab === t.key ? '#000' : colors.mutedForeground }]}>{t.label}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Simple Tab */}
        {tab === 'simple' && (
          <>
            <View style={s.infoBanner}>
              <MaterialCommunityIcons name="lock-open-outline" size={20} color={colors.success} />
              <View style={{ flex: 1 }}>
                <Text style={s.bannerTitle}>Flexible Savings</Text>
                <Text style={s.bannerDesc}>Unlock anytime • Daily interest • No fixed term</Text>
              </View>
            </View>
            {filtered.map(p => (
              <TouchableOpacity key={p.id} style={s.productCard} onPress={() => setSelectedProduct(p)}>
                <CryptoIcon symbol={p.symbol} size={36} />
                <View style={{ flex: 1, marginLeft: 12 }}>
                  <Text style={s.prodSym}>{p.symbol}</Text>
                  <Text style={s.prodDesc}>Min: {p.minAmount} {p.symbol} • Flexible</Text>
                </View>
                <View style={{ alignItems: 'flex-end' }}>
                  <Text style={[s.prodApy, { color: colors.success }]}>{p.apy}%</Text>
                  <Text style={s.prodApyLbl}>Est. APY</Text>
                </View>
              </TouchableOpacity>
            ))}
          </>
        )}

        {/* Advanced Tab */}
        {tab === 'advanced' && (
          <>
            <View style={[s.infoBanner, { backgroundColor: colors.primary + '15' }]}>
              <MaterialCommunityIcons name="trending-up" size={20} color={colors.primary} />
              <View style={{ flex: 1 }}>
                <Text style={s.bannerTitle}>Fixed Income (Locked)</Text>
                <Text style={s.bannerDesc}>Higher APY • Auto-maturity • Monthly lock-in</Text>
              </View>
            </View>
            {filtered.map(p => (
              <TouchableOpacity key={p.id} style={s.productCard} onPress={() => setSelectedProduct(p)}>
                <CryptoIcon symbol={p.symbol} size={36} />
                <View style={{ flex: 1, marginLeft: 12 }}>
                  <Text style={s.prodSym}>{p.symbol}</Text>
                  <View style={s.lockBadge}>
                    <Feather name="lock" size={10} color={colors.warning} />
                    <Text style={[s.lockText, { color: colors.warning }]}>{p.duration}D Lock</Text>
                  </View>
                  <Text style={s.prodDesc}>Min: {p.minAmount} {p.symbol}</Text>
                </View>
                <View style={{ alignItems: 'flex-end' }}>
                  <Text style={[s.prodApy, { color: colors.primary }]}>{p.apy}%</Text>
                  <Text style={s.prodApyLbl}>Fixed APY</Text>
                </View>
              </TouchableOpacity>
            ))}
          </>
        )}

        {/* My Positions */}
        {tab === 'positions' && (
          <>
            {earnPositions.length === 0 ? (
              <View style={s.empty}>
                <MaterialCommunityIcons name="piggy-bank-outline" size={50} color={colors.mutedForeground} />
                <Text style={s.emptyText}>No active earnings yet</Text>
              </View>
            ) : earnPositions.map(p => {
              const days = p.endDate ? Math.max(0, Math.ceil((p.endDate - Date.now()) / 86400000)) : 0;
              return (
                <View key={p.id} style={s.posCard}>
                  <View style={s.posHeader}>
                    <CryptoIcon symbol={p.symbol} size={32} />
                    <View style={{ flex: 1, marginLeft: 10 }}>
                      <Text style={s.posSym}>{p.symbol} {p.type === 'simple' ? 'Flexible' : `${days}D Locked`}</Text>
                      <Text style={s.posDate}>Started {new Date(p.startDate).toLocaleDateString('en-IN')}</Text>
                    </View>
                    <View style={[s.statusBadge, { backgroundColor: colors.success + '22' }]}>
                      <Text style={[s.statusText, { color: colors.success }]}>{p.status.toUpperCase()}</Text>
                    </View>
                  </View>
                  <View style={s.posGrid}>
                    <View style={s.posItem}><Text style={s.posLbl}>Amount</Text><Text style={s.posValue}>{p.amount} {p.symbol}</Text></View>
                    <View style={s.posItem}><Text style={s.posLbl}>APY</Text><Text style={[s.posValue, { color: colors.success }]}>{p.apy}%</Text></View>
                    <View style={s.posItem}><Text style={s.posLbl}>Earned</Text><Text style={[s.posValue, { color: colors.success }]}>+{p.earned.toFixed(4)}</Text></View>
                    <View style={s.posItem}><Text style={s.posLbl}>Auto Maturity</Text><Text style={s.posValue}>{p.autoMaturity ? 'On' : 'Off'}</Text></View>
                  </View>
                  <TouchableOpacity style={[s.redeemBtn, { borderColor: p.type === 'simple' ? colors.success : colors.warning }]}
                    onPress={() => Alert.alert(p.type === 'simple' ? 'Redeemed' : 'Early Redeem', p.type === 'simple' ? 'Funds moved to spot wallet' : 'Early redemption may incur penalty')}>
                    <Text style={[s.redeemText, { color: p.type === 'simple' ? colors.success : colors.warning }]}>
                      {p.type === 'simple' ? 'Redeem' : 'Early Redeem'}
                    </Text>
                  </TouchableOpacity>
                </View>
              );
            })}
          </>
        )}

        {/* Stake Modal */}
        {selectedProduct && (
          <View style={s.stakeModal}>
            <View style={s.modalHeader}>
              <CryptoIcon symbol={selectedProduct.symbol} size={32} />
              <View style={{ flex: 1, marginLeft: 10 }}>
                <Text style={s.modalTitle}>Stake {selectedProduct.symbol}</Text>
                <Text style={s.modalSub}>{selectedProduct.type === 'simple' ? 'Flexible • Unlock anytime' : `${selectedProduct.duration}D Locked`}</Text>
              </View>
              <TouchableOpacity onPress={() => setSelectedProduct(null)}>
                <Feather name="x" size={20} color={colors.foreground} />
              </TouchableOpacity>
            </View>
            <View style={s.apyBox}>
              <Text style={s.apyLbl}>Estimated APY</Text>
              <Text style={[s.apyValue, { color: colors.success }]}>{selectedProduct.apy}%</Text>
            </View>
            <View style={s.inputBox}>
              <TextInput style={s.input} placeholder="0.00" placeholderTextColor={colors.mutedForeground} value={stakeAmount} onChangeText={setStakeAmount} keyboardType="decimal-pad" />
              <Text style={s.unit}>{selectedProduct.symbol}</Text>
            </View>
            <Text style={s.minNote}>Minimum: {selectedProduct.minAmount} {selectedProduct.symbol}</Text>

            {selectedProduct.type === 'advanced' && (
              <View style={s.autoRow}>
                <View style={{ flex: 1 }}>
                  <Text style={s.autoTitle}>Auto Maturity</Text>
                  <Text style={s.autoDesc}>Automatically reinvest when matured</Text>
                </View>
                <Switch value={autoMaturity} onValueChange={setAutoMaturity} trackColor={{ false: colors.border, true: colors.primary }} thumbColor="#fff" />
              </View>
            )}

            {stakeAmount && parseFloat(stakeAmount) > 0 && (
              <View style={s.estBox}>
                <View style={s.estRow}>
                  <Text style={s.estLbl}>Daily</Text>
                  <Text style={s.estVal}>+{(parseFloat(stakeAmount) * selectedProduct.apy / 100 / 365).toFixed(6)}</Text>
                </View>
                <View style={s.estRow}>
                  <Text style={s.estLbl}>Monthly</Text>
                  <Text style={s.estVal}>+{(parseFloat(stakeAmount) * selectedProduct.apy / 100 / 12).toFixed(4)}</Text>
                </View>
                <View style={s.estRow}>
                  <Text style={s.estLbl}>Yearly</Text>
                  <Text style={[s.estVal, { color: colors.success }]}>+{(parseFloat(stakeAmount) * selectedProduct.apy / 100).toFixed(4)}</Text>
                </View>
              </View>
            )}

            <TouchableOpacity style={[s.cta, { backgroundColor: colors.primary }]} onPress={handleStake}>
              <Text style={[s.ctaText, { color: '#000' }]}>Confirm Stake</Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (c: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: c.background },
  content: { padding: 16, paddingBottom: 60 },
  statsCard: { flexDirection: 'row', backgroundColor: c.card, borderRadius: 14, padding: 16, marginBottom: 16, borderWidth: 1, borderColor: c.border },
  statLbl: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase' },
  statVal: { fontSize: 22, color: c.foreground, fontFamily: 'Inter_700Bold', marginTop: 4 },
  statSub: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  statDivider: { width: 1, backgroundColor: c.border, marginHorizontal: 16 },
  tabs: { flexDirection: 'row', backgroundColor: c.card, borderRadius: 10, padding: 4, marginBottom: 16, borderWidth: 1, borderColor: c.border, gap: 4 },
  tab: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, paddingVertical: 9, borderRadius: 7 },
  tabText: { fontSize: 11, fontFamily: 'Inter_600SemiBold' },
  infoBanner: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 12, borderRadius: 10, backgroundColor: c.success + '15', marginBottom: 14 },
  bannerTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_700Bold' },
  bannerDesc: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  productCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, padding: 14, marginBottom: 8, borderWidth: 1, borderColor: c.border },
  prodSym: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_700Bold' },
  prodDesc: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 3 },
  prodApy: { fontSize: 18, fontFamily: 'Inter_700Bold' },
  prodApyLbl: { fontSize: 10, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  lockBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 3, alignSelf: 'flex-start' },
  lockText: { fontSize: 10, fontFamily: 'Inter_700Bold' },
  empty: { alignItems: 'center', padding: 40 },
  emptyText: { fontSize: 13, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 12 },
  posCard: { backgroundColor: c.card, borderRadius: 12, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: c.border },
  posHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  posSym: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_700Bold' },
  posDate: { fontSize: 10, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  statusBadge: { borderRadius: 5, paddingHorizontal: 7, paddingVertical: 3 },
  statusText: { fontSize: 9, fontFamily: 'Inter_700Bold' },
  posGrid: { flexDirection: 'row', flexWrap: 'wrap', marginBottom: 10 },
  posItem: { width: '50%', marginBottom: 8 },
  posLbl: { fontSize: 10, color: c.mutedForeground, fontFamily: 'Inter_400Regular', textTransform: 'uppercase' },
  posValue: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold', marginTop: 2 },
  redeemBtn: { borderRadius: 8, paddingVertical: 9, alignItems: 'center', borderWidth: 1 },
  redeemText: { fontSize: 12, fontFamily: 'Inter_600SemiBold' },
  stakeModal: { backgroundColor: c.card, borderRadius: 14, padding: 16, marginTop: 16, borderWidth: 1, borderColor: c.primary },
  modalHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 14 },
  modalTitle: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_700Bold' },
  modalSub: { fontSize: 11, color: c.mutedForeground, marginTop: 2 },
  apyBox: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', backgroundColor: c.secondary, borderRadius: 10, padding: 12, marginBottom: 12 },
  apyLbl: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_500Medium' },
  apyValue: { fontSize: 24, fontFamily: 'Inter_700Bold' },
  inputBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.secondary, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, gap: 8, borderWidth: 1, borderColor: c.border },
  input: { flex: 1, fontSize: 18, color: c.foreground, fontFamily: 'Inter_700Bold' },
  unit: { fontSize: 13, color: c.mutedForeground, fontFamily: 'Inter_600SemiBold' },
  minNote: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 6 },
  autoRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.secondary, borderRadius: 10, padding: 12, marginTop: 12 },
  autoTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  autoDesc: { fontSize: 11, color: c.mutedForeground, marginTop: 2 },
  estBox: { backgroundColor: c.secondary, borderRadius: 10, padding: 12, marginTop: 12, gap: 6 },
  estRow: { flexDirection: 'row', justifyContent: 'space-between' },
  estLbl: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  estVal: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  cta: { borderRadius: 10, paddingVertical: 13, alignItems: 'center', marginTop: 14 },
  ctaText: { fontSize: 14, fontFamily: 'Inter_700Bold' },
});
