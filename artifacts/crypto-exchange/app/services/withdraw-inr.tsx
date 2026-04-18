import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, TextInput, Alert } from 'react-native';
import { Header } from '@/components/Header';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { Feather } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

export default function WithdrawInr() {
  const colors = useColors();
  const router = useRouter();
  const { addTransaction, banks, user, walletBalances, kycLevels } = useApp();
  const kycLimit = kycLevels[user.kycLevel];
  const verifiedBanks = banks.filter(b => b.status === 'verified');
  const [bankId, setBankId] = useState(verifiedBanks[0]?.id || '');
  const [amount, setAmount] = useState('');
  const inrBal = walletBalances.find(b => b.symbol === 'INR' && b.walletType === 'inr')?.available || 0;

  const amt = parseFloat(amount || '0');
  const fee = amt > 0 ? Math.max(10, amt * 0.001) : 0;
  const tax = amt * 0.0;
  const receive = amt - fee;

  const handleWithdraw = () => {
    if (!amt || amt < 100) { Alert.alert('Error', 'Minimum withdraw ₹100'); return; }
    if (amt > inrBal) { Alert.alert('Error', 'Insufficient balance'); return; }
    if (!bankId) { Alert.alert('Error', 'Add a verified bank first'); return; }
    addTransaction({
      id: 'TXN' + Date.now(), type: 'withdraw', symbol: 'INR', amount: amt,
      status: 'pending', timestamp: Date.now(), fee, walletType: 'inr',
      address: verifiedBanks.find(b => b.id === bankId)?.bankName,
      bankRef: `IMPS/${Date.now().toString().slice(-8)}`,
    });
    Alert.alert('Withdrawal Requested', `₹${receive.toLocaleString('en-IN')} will be credited to your bank account within 30 minutes`);
    setAmount('');
  };

  const s = styles(colors);
  return (
    <SafeAreaView style={s.container}>
      <Header title="Withdraw INR" subtitle="Transfer to your bank" />
      <ScrollView contentContainerStyle={s.content}>
        <View style={s.balCard}>
          <Text style={s.balLabel}>Available Balance</Text>
          <Text style={s.balValue}>₹{inrBal.toLocaleString('en-IN')}</Text>
          <View style={s.limitRow}>
            <Text style={s.limitText}>Daily limit: ₹{kycLimit.withdrawLimitDaily.toLocaleString('en-IN')}</Text>
          </View>
        </View>

        <Text style={s.sectionTitle}>Bank Account</Text>
        {verifiedBanks.length === 0 ? (
          <TouchableOpacity style={s.addBank} onPress={() => router.push('/services/banks' as any)}>
            <Feather name="plus-circle" size={20} color={colors.primary} />
            <Text style={[s.addBankText, { color: colors.primary }]}>Add Verified Bank Account</Text>
          </TouchableOpacity>
        ) : verifiedBanks.map(b => (
          <TouchableOpacity key={b.id} style={[s.bankItem, bankId === b.id && { borderColor: colors.primary, backgroundColor: colors.primary + '10' }]} onPress={() => setBankId(b.id)}>
            <View style={[s.bankIconBox, { backgroundColor: colors.primary + '22' }]}>
              <Feather name="credit-card" size={18} color={colors.primary} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.bankName}>{b.bankName}</Text>
              <Text style={s.bankAcc}>••••{b.accountNumber.slice(-4)} • {b.ifsc}</Text>
            </View>
            {bankId === b.id && <Feather name="check-circle" size={18} color={colors.primary} />}
          </TouchableOpacity>
        ))}

        <Text style={s.sectionTitle}>Amount</Text>
        <View style={s.inputBox}>
          <Text style={s.currency}>₹</Text>
          <TextInput style={s.input} placeholder="0.00" placeholderTextColor={colors.mutedForeground} value={amount} onChangeText={setAmount} keyboardType="decimal-pad" />
          <TouchableOpacity onPress={() => setAmount(String(inrBal))}><Text style={[s.maxBtn, { color: colors.primary }]}>MAX</Text></TouchableOpacity>
        </View>

        <View style={s.quickRow}>
          {[25, 50, 75, 100].map(p => (
            <TouchableOpacity key={p} style={s.quickBtn} onPress={() => setAmount(String((inrBal * p / 100).toFixed(0)))}>
              <Text style={s.quickText}>{p}%</Text>
            </TouchableOpacity>
          ))}
        </View>

        {amt > 0 && (
          <View style={s.summary}>
            <View style={s.sumRow}><Text style={s.sumLbl}>Withdraw Amount</Text><Text style={s.sumVal}>₹{amt.toLocaleString('en-IN')}</Text></View>
            <View style={s.sumRow}><Text style={s.sumLbl}>Processing Fee (0.1%)</Text><Text style={s.sumVal}>₹{fee.toFixed(2)}</Text></View>
            <View style={s.sumDivider} />
            <View style={s.sumRow}><Text style={[s.sumLbl, { fontFamily: 'Inter_700Bold' }]}>You'll Receive</Text><Text style={[s.sumVal, { color: colors.success, fontSize: 16 }]}>₹{receive.toLocaleString('en-IN')}</Text></View>
          </View>
        )}

        <View style={s.note}>
          <Feather name="info" size={14} color={colors.warning} />
          <Text style={s.noteText}>Withdrawals are processed within 30 minutes via IMPS during banking hours.</Text>
        </View>

        <TouchableOpacity style={[s.cta, { backgroundColor: colors.primary }]} onPress={handleWithdraw}>
          <Text style={[s.ctaText, { color: '#000' }]}>Confirm Withdrawal</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (c: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: c.background },
  content: { padding: 16, paddingBottom: 60 },
  balCard: { backgroundColor: c.card, borderRadius: 14, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: c.border },
  balLabel: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase' },
  balValue: { fontSize: 24, color: c.foreground, fontFamily: 'Inter_700Bold', marginTop: 4 },
  limitRow: { marginTop: 6 },
  limitText: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  sectionTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_700Bold', marginBottom: 10, marginTop: 4, textTransform: 'uppercase' },
  addBank: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', backgroundColor: c.card, borderRadius: 12, padding: 16, borderWidth: 1, borderColor: c.primary, borderStyle: 'dashed', gap: 8, marginBottom: 18 },
  addBankText: { fontSize: 13, fontFamily: 'Inter_600SemiBold' },
  bankItem: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, padding: 14, borderWidth: 1, borderColor: c.border, gap: 12, marginBottom: 8 },
  bankIconBox: { width: 38, height: 38, borderRadius: 8, alignItems: 'center', justifyContent: 'center' },
  bankName: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  bankAcc: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  inputBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, paddingHorizontal: 16, paddingVertical: 14, borderWidth: 1, borderColor: c.border, marginTop: 8, marginBottom: 10 },
  currency: { fontSize: 22, color: c.mutedForeground, fontFamily: 'Inter_500Medium', marginRight: 8 },
  input: { flex: 1, fontSize: 22, color: c.foreground, fontFamily: 'Inter_700Bold' },
  maxBtn: { fontSize: 12, fontFamily: 'Inter_700Bold' },
  quickRow: { flexDirection: 'row', gap: 8, marginBottom: 18 },
  quickBtn: { flex: 1, alignItems: 'center', paddingVertical: 8, backgroundColor: c.secondary, borderRadius: 8, borderWidth: 1, borderColor: c.border },
  quickText: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_500Medium' },
  summary: { backgroundColor: c.card, borderRadius: 12, padding: 14, marginBottom: 14, borderWidth: 1, borderColor: c.border, gap: 8 },
  sumRow: { flexDirection: 'row', justifyContent: 'space-between' },
  sumLbl: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  sumVal: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  sumDivider: { height: 1, backgroundColor: c.border, marginVertical: 4 },
  note: { flexDirection: 'row', gap: 8, padding: 12, borderRadius: 8, backgroundColor: c.warning + '15', marginBottom: 16, alignItems: 'flex-start' },
  noteText: { flex: 1, fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', lineHeight: 16 },
  cta: { borderRadius: 12, paddingVertical: 15, alignItems: 'center' },
  ctaText: { fontSize: 15, fontFamily: 'Inter_700Bold' },
});
