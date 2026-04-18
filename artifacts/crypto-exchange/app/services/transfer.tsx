import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, TextInput, Alert } from 'react-native';
import { Header } from '@/components/Header';
import { useColors } from '@/hooks/useColors';
import { useApp, WalletType } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { Feather } from '@expo/vector-icons';

const WALLETS: { id: WalletType; name: string; desc: string }[] = [
  { id: 'spot', name: 'Spot Wallet', desc: 'Trading' },
  { id: 'futures', name: 'Futures Wallet', desc: 'Margin trading' },
  { id: 'earn', name: 'Earn Wallet', desc: 'Staking & savings' },
  { id: 'inr', name: 'INR Wallet', desc: 'Fiat balance' },
];

export default function Transfer() {
  const colors = useColors();
  const { walletBalances, updateBalance, addTransaction } = useApp();
  const [from, setFrom] = useState<WalletType>('spot');
  const [to, setTo] = useState<WalletType>('futures');
  const [coin, setCoin] = useState('USDT');
  const [amount, setAmount] = useState('');
  const fromBal = walletBalances.find(b => b.symbol === coin && b.walletType === from)?.available || 0;

  const swap = () => { const t = from; setFrom(to); setTo(t); };

  const handleTransfer = () => {
    const amt = parseFloat(amount);
    if (!amt || amt <= 0) { Alert.alert('Error', 'Enter valid amount'); return; }
    if (amt > fromBal) { Alert.alert('Error', 'Insufficient balance'); return; }
    if (from === to) { Alert.alert('Error', 'Select different wallets'); return; }
    updateBalance(coin, from, -amt);
    updateBalance(coin, to, amt);
    addTransaction({
      id: 'TXN' + Date.now(), type: 'transfer', symbol: coin, amount: amt,
      status: 'completed', timestamp: Date.now(), fee: 0,
      address: `${from} → ${to}`, walletType: from,
    });
    Alert.alert('Transfer Successful', `${amt} ${coin} moved from ${from} to ${to} wallet`);
    setAmount('');
  };

  const s = styles(colors);
  return (
    <SafeAreaView style={s.container}>
      <Header title="Internal Transfer" subtitle="Move funds between wallets" />
      <ScrollView contentContainerStyle={s.content}>
        <View style={s.transferCard}>
          <View style={s.walletBox}>
            <Text style={s.walletLbl}>From</Text>
            <Text style={s.walletName}>{WALLETS.find(w => w.id === from)?.name}</Text>
            <Text style={s.walletBal}>{fromBal.toFixed(4)} {coin}</Text>
          </View>

          <TouchableOpacity style={[s.swapBtn, { backgroundColor: colors.primary }]} onPress={swap}>
            <Feather name="repeat" size={18} color="#000" />
          </TouchableOpacity>

          <View style={s.walletBox}>
            <Text style={s.walletLbl}>To</Text>
            <Text style={s.walletName}>{WALLETS.find(w => w.id === to)?.name}</Text>
            <Text style={s.walletBal}>{(walletBalances.find(b => b.symbol === coin && b.walletType === to)?.available || 0).toFixed(4)} {coin}</Text>
          </View>
        </View>

        <Text style={s.sectionTitle}>From Wallet</Text>
        <View style={s.walletGrid}>
          {WALLETS.map(w => (
            <TouchableOpacity key={w.id} style={[s.walletPill, from === w.id && { borderColor: colors.primary, backgroundColor: colors.primary + '15' }]} onPress={() => setFrom(w.id)}>
              <Text style={[s.walletPillText, from === w.id && { color: colors.primary }]}>{w.name}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Text style={s.sectionTitle}>To Wallet</Text>
        <View style={s.walletGrid}>
          {WALLETS.map(w => (
            <TouchableOpacity key={w.id} style={[s.walletPill, to === w.id && { borderColor: colors.primary, backgroundColor: colors.primary + '15' }]} onPress={() => setTo(w.id)}>
              <Text style={[s.walletPillText, to === w.id && { color: colors.primary }]}>{w.name}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Text style={s.sectionTitle}>Coin</Text>
        <View style={s.coinRow}>
          {['USDT', 'BTC', 'ETH', 'BNB', 'INR'].map(c => (
            <TouchableOpacity key={c} style={[s.coinPill, coin === c && { borderColor: colors.primary, backgroundColor: colors.primary + '15' }]} onPress={() => setCoin(c)}>
              <CryptoIcon symbol={c} size={20} />
              <Text style={[s.coinPillText, coin === c && { color: colors.primary }]}>{c}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Text style={s.sectionTitle}>Amount</Text>
        <View style={s.inputBox}>
          <TextInput style={s.input} placeholder="0.00" placeholderTextColor={colors.mutedForeground} value={amount} onChangeText={setAmount} keyboardType="decimal-pad" />
          <Text style={s.unit}>{coin}</Text>
          <TouchableOpacity onPress={() => setAmount(String(fromBal))}><Text style={[s.maxBtn, { color: colors.primary }]}>MAX</Text></TouchableOpacity>
        </View>

        <View style={s.note}>
          <Feather name="info" size={14} color={colors.info} />
          <Text style={s.noteText}>Internal transfers are instant and free between your own wallets.</Text>
        </View>

        <TouchableOpacity style={[s.cta, { backgroundColor: colors.primary }]} onPress={handleTransfer}>
          <Text style={[s.ctaText, { color: '#000' }]}>Confirm Transfer</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (c: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: c.background },
  content: { padding: 16, paddingBottom: 60 },
  transferCard: { backgroundColor: c.card, borderRadius: 14, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: c.border, alignItems: 'center', gap: 10 },
  walletBox: { width: '100%', alignItems: 'center', paddingVertical: 14, backgroundColor: c.secondary, borderRadius: 10 },
  walletLbl: { fontSize: 10, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase' },
  walletName: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_700Bold', marginTop: 4 },
  walletBal: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  swapBtn: { width: 40, height: 40, borderRadius: 20, alignItems: 'center', justifyContent: 'center' },
  sectionTitle: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_700Bold', marginBottom: 8, marginTop: 4, textTransform: 'uppercase', letterSpacing: 0.5 },
  walletGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginBottom: 14 },
  walletPill: { paddingHorizontal: 10, paddingVertical: 7, borderRadius: 7, borderWidth: 1, borderColor: c.border, backgroundColor: c.card },
  walletPillText: { fontSize: 11, color: c.foreground, fontFamily: 'Inter_500Medium' },
  coinRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginBottom: 14 },
  coinPill: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 10, paddingVertical: 6, borderRadius: 7, borderWidth: 1, borderColor: c.border, backgroundColor: c.card },
  coinPillText: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  inputBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, borderWidth: 1, borderColor: c.border, gap: 8, marginBottom: 14 },
  input: { flex: 1, fontSize: 18, color: c.foreground, fontFamily: 'Inter_700Bold' },
  unit: { fontSize: 13, color: c.mutedForeground, fontFamily: 'Inter_600SemiBold' },
  maxBtn: { fontSize: 12, fontFamily: 'Inter_700Bold' },
  note: { flexDirection: 'row', gap: 8, padding: 12, borderRadius: 8, backgroundColor: c.info + '15', marginBottom: 16, alignItems: 'flex-start' },
  noteText: { flex: 1, fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', lineHeight: 16 },
  cta: { borderRadius: 12, paddingVertical: 15, alignItems: 'center' },
  ctaText: { fontSize: 15, fontFamily: 'Inter_700Bold' },
});
