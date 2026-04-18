import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, TextInput, Alert } from 'react-native';
import { Header } from '@/components/Header';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { Feather, MaterialCommunityIcons, FontAwesome5 } from '@expo/vector-icons';

const METHODS = [
  { id: 'upi', name: 'UPI', desc: 'Instant • Free', icon: 'qrcode' as const, time: 'Instant', fee: 0, min: 100, max: 200000 },
  { id: 'imps', name: 'IMPS', desc: '24x7 • ₹5 fee', icon: 'flash' as const, time: '5-30 mins', fee: 5, min: 1000, max: 500000 },
  { id: 'neft', name: 'NEFT', desc: 'Bank hours • Free', icon: 'bank' as const, time: '2-4 hours', fee: 0, min: 1000, max: 1000000 },
  { id: 'rtgs', name: 'RTGS', desc: 'Large amount • Free', icon: 'bank-transfer' as const, time: '30 mins', fee: 0, min: 200000, max: 10000000 },
];

export default function DepositInr() {
  const colors = useColors();
  const { addTransaction, banks, user, kycLevels } = useApp();
  const kycLimit = kycLevels[user.kycLevel];
  const [method, setMethod] = useState('upi');
  const [amount, setAmount] = useState('');
  const selected = METHODS.find(m => m.id === method) || METHODS[0];
  const verifiedBanks = banks.filter(b => b.status === 'verified');

  const handleDeposit = () => {
    const amt = parseFloat(amount);
    if (!amt || amt < selected.min) { Alert.alert('Error', `Minimum deposit ₹${selected.min}`); return; }
    if (amt > selected.max) { Alert.alert('Error', `Maximum deposit ₹${selected.max}`); return; }
    addTransaction({
      id: 'TXN' + Date.now(), type: 'deposit', symbol: 'INR', amount: amt,
      status: 'pending', timestamp: Date.now(), fee: selected.fee, walletType: 'inr',
      address: verifiedBanks[0]?.bankName, bankRef: `${selected.id.toUpperCase()}/${Date.now().toString().slice(-8)}`,
    });
    Alert.alert('Deposit Initiated', `₹${amt.toLocaleString('en-IN')} via ${selected.name}\nProcessing time: ${selected.time}`);
    setAmount('');
  };

  const s = styles(colors);
  return (
    <SafeAreaView style={s.container}>
      <Header title="Deposit INR" subtitle="Add funds to your INR wallet" />
      <ScrollView contentContainerStyle={s.content}>
        <View style={s.balCard}>
          <Text style={s.balLabel}>INR Wallet Balance</Text>
          <Text style={s.balValue}>₹50,000.00</Text>
          <View style={s.kycRow}>
            <Feather name="shield" size={12} color={colors.success} />
            <Text style={[s.kycText, { color: colors.success }]}>KYC Level {user.kycLevel} • Deposit limit ₹{kycLimit.depositLimit.toLocaleString('en-IN')}</Text>
          </View>
        </View>

        <Text style={s.sectionTitle}>Select Payment Method</Text>
        {METHODS.map(m => (
          <TouchableOpacity key={m.id} style={[s.methodCard, method === m.id && { borderColor: colors.primary, backgroundColor: colors.primary + '10' }]} onPress={() => setMethod(m.id)}>
            <View style={[s.methodIcon, { backgroundColor: method === m.id ? colors.primary : colors.secondary }]}>
              <MaterialCommunityIcons name={m.icon} size={22} color={method === m.id ? '#000' : colors.foreground} />
            </View>
            <View style={{ flex: 1 }}>
              <View style={s.methodTop}>
                <Text style={s.methodName}>{m.name}</Text>
                <Text style={s.methodTime}>{m.time}</Text>
              </View>
              <Text style={s.methodDesc}>{m.desc} • Limit: ₹{m.min.toLocaleString('en-IN')} - ₹{m.max.toLocaleString('en-IN')}</Text>
            </View>
            {method === m.id && <Feather name="check-circle" size={20} color={colors.primary} />}
          </TouchableOpacity>
        ))}

        <Text style={s.sectionTitle}>Amount</Text>
        <View style={s.inputBox}>
          <Text style={s.currency}>₹</Text>
          <TextInput style={s.input} placeholder="0.00" placeholderTextColor={colors.mutedForeground} value={amount} onChangeText={setAmount} keyboardType="decimal-pad" />
        </View>

        <View style={s.quickRow}>
          {[1000, 5000, 10000, 50000].map(v => (
            <TouchableOpacity key={v} style={s.quickBtn} onPress={() => setAmount(String(v))}>
              <Text style={s.quickText}>₹{v >= 1000 ? `${v/1000}K` : v}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {method === 'upi' && (
          <View style={s.upiBox}>
            <Text style={s.upiTitle}>Pay via UPI</Text>
            <View style={s.upiQr}>
              <FontAwesome5 name="qrcode" size={70} color={colors.foreground} />
            </View>
            <Text style={s.upiId}>cryptox@hdfcbank</Text>
            <Text style={s.upiNote}>Scan QR or use UPI ID</Text>
          </View>
        )}

        {(method === 'imps' || method === 'neft' || method === 'rtgs') && (
          <View style={s.bankBox}>
            <Text style={s.bankTitle}>Bank Transfer Details</Text>
            <View style={s.bankRow}><Text style={s.bankKey}>Account Name</Text><Text style={s.bankVal}>CryptoX Tech Pvt Ltd</Text></View>
            <View style={s.bankRow}><Text style={s.bankKey}>Account Number</Text><Text style={s.bankVal}>123456789012</Text></View>
            <View style={s.bankRow}><Text style={s.bankKey}>IFSC</Text><Text style={s.bankVal}>HDFC0001234</Text></View>
            <View style={s.bankRow}><Text style={s.bankKey}>Reference (UTR)</Text><Text style={[s.bankVal, { color: colors.primary }]}>{user.uid}</Text></View>
          </View>
        )}

        {parseFloat(amount || '0') > 0 && (
          <View style={s.summary}>
            <View style={s.sumRow}><Text style={s.sumLbl}>Amount</Text><Text style={s.sumVal}>₹{parseFloat(amount).toLocaleString('en-IN')}</Text></View>
            <View style={s.sumRow}><Text style={s.sumLbl}>Fee</Text><Text style={s.sumVal}>₹{selected.fee}</Text></View>
            <View style={s.sumDivider} />
            <View style={s.sumRow}><Text style={[s.sumLbl, { fontFamily: 'Inter_700Bold' }]}>You'll Receive</Text><Text style={[s.sumVal, { color: colors.success, fontSize: 16 }]}>₹{(parseFloat(amount) - selected.fee).toLocaleString('en-IN')}</Text></View>
          </View>
        )}

        <TouchableOpacity style={[s.cta, { backgroundColor: colors.primary }]} onPress={handleDeposit}>
          <Text style={[s.ctaText, { color: '#000' }]}>Confirm Deposit</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (c: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: c.background },
  content: { padding: 16, paddingBottom: 60 },
  balCard: { backgroundColor: c.card, borderRadius: 14, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: c.border },
  balLabel: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase', letterSpacing: 0.5 },
  balValue: { fontSize: 24, color: c.foreground, fontFamily: 'Inter_700Bold', marginTop: 4 },
  kycRow: { flexDirection: 'row', alignItems: 'center', gap: 5, marginTop: 8 },
  kycText: { fontSize: 11, fontFamily: 'Inter_500Medium' },
  sectionTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_700Bold', marginBottom: 10, textTransform: 'uppercase', letterSpacing: 0.5 },
  methodCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, padding: 14, marginBottom: 8, borderWidth: 1, borderColor: c.border, gap: 12 },
  methodIcon: { width: 42, height: 42, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  methodTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  methodName: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  methodTime: { fontSize: 11, color: c.success, fontFamily: 'Inter_500Medium' },
  methodDesc: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  inputBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, paddingHorizontal: 16, paddingVertical: 14, borderWidth: 1, borderColor: c.border, marginTop: 12, marginBottom: 10 },
  currency: { fontSize: 22, color: c.mutedForeground, fontFamily: 'Inter_500Medium', marginRight: 8 },
  input: { flex: 1, fontSize: 22, color: c.foreground, fontFamily: 'Inter_700Bold' },
  quickRow: { flexDirection: 'row', gap: 8, marginBottom: 18 },
  quickBtn: { flex: 1, alignItems: 'center', paddingVertical: 8, backgroundColor: c.secondary, borderRadius: 8, borderWidth: 1, borderColor: c.border },
  quickText: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_500Medium' },
  upiBox: { backgroundColor: c.card, borderRadius: 14, padding: 20, alignItems: 'center', marginBottom: 18, borderWidth: 1, borderColor: c.border },
  upiTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold', marginBottom: 14 },
  upiQr: { width: 130, height: 130, backgroundColor: c.background, borderRadius: 12, alignItems: 'center', justifyContent: 'center', marginBottom: 12, borderWidth: 1, borderColor: c.border },
  upiId: { fontSize: 16, color: c.primary, fontFamily: 'Inter_700Bold', letterSpacing: 0.5 },
  upiNote: { fontSize: 11, color: c.mutedForeground, marginTop: 6, fontFamily: 'Inter_400Regular' },
  bankBox: { backgroundColor: c.card, borderRadius: 14, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: c.border, gap: 10 },
  bankTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold', marginBottom: 4 },
  bankRow: { flexDirection: 'row', justifyContent: 'space-between' },
  bankKey: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  bankVal: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  summary: { backgroundColor: c.card, borderRadius: 12, padding: 14, marginBottom: 16, borderWidth: 1, borderColor: c.border, gap: 8 },
  sumRow: { flexDirection: 'row', justifyContent: 'space-between' },
  sumLbl: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  sumVal: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  sumDivider: { height: 1, backgroundColor: c.border, marginVertical: 4 },
  cta: { borderRadius: 12, paddingVertical: 15, alignItems: 'center' },
  ctaText: { fontSize: 15, fontFamily: 'Inter_700Bold' },
});
