import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, TextInput, Alert } from 'react-native';
import { Header } from '@/components/Header';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { Feather } from '@expo/vector-icons';

const NETWORKS: Record<string, { id: string; name: string; fee: number }[]> = {
  BTC: [{ id: 'btc', name: 'Bitcoin (BTC)', fee: 0.0002 }],
  ETH: [
    { id: 'erc20', name: 'Ethereum (ERC20)', fee: 0.0035 },
    { id: 'arbi', name: 'Arbitrum One', fee: 0.0002 },
  ],
  USDT: [
    { id: 'trc20', name: 'Tron (TRC20)', fee: 1 },
    { id: 'erc20', name: 'Ethereum (ERC20)', fee: 15 },
    { id: 'bep20', name: 'BNB Smart Chain (BEP20)', fee: 0.8 },
  ],
};

export default function WithdrawCrypto() {
  const colors = useColors();
  const { coins, walletBalances, addTransaction, user } = useApp();
  const [coin, setCoin] = useState('USDT');
  const [showCoinList, setShowCoinList] = useState(false);
  const networks = NETWORKS[coin] || NETWORKS.USDT;
  const [networkId, setNetworkId] = useState(networks[0].id);
  const [address, setAddress] = useState('');
  const [amount, setAmount] = useState('');
  const network = networks.find(n => n.id === networkId) || networks[0];
  const balance = walletBalances.find(b => b.symbol === coin && b.walletType === 'spot')?.available || 0;

  React.useEffect(() => { setNetworkId(networks[0].id); }, [coin]);

  const amt = parseFloat(amount || '0');
  const tds = amt * 0.01;
  const fee = network.fee;
  const receive = amt - fee - tds;

  const handleWithdraw = () => {
    if (!amt || amt <= 0) { Alert.alert('Error', 'Enter valid amount'); return; }
    if (amt > balance) { Alert.alert('Error', 'Insufficient balance'); return; }
    if (!address || address.length < 20) { Alert.alert('Error', 'Enter valid address'); return; }
    addTransaction({
      id: 'TXN' + Date.now(), type: 'withdraw', symbol: coin, amount: amt,
      status: 'pending', timestamp: Date.now(), fee, network: network.name, address, walletType: 'spot',
      txHash: '0x' + Math.random().toString(36).slice(2, 14),
    });
    Alert.alert('Withdrawal Submitted', `${receive.toFixed(6)} ${coin} will be sent to ${address.slice(0, 10)}...`);
    setAmount(''); setAddress('');
  };

  const s = styles(colors);
  return (
    <SafeAreaView style={s.container}>
      <Header title="Withdraw Crypto" subtitle="Send crypto to external wallet" />
      <ScrollView contentContainerStyle={s.content}>
        <Text style={s.sectionTitle}>Select Coin</Text>
        <TouchableOpacity style={s.coinSelect} onPress={() => setShowCoinList(!showCoinList)}>
          <CryptoIcon symbol={coin} size={32} />
          <View style={{ flex: 1, marginLeft: 12 }}>
            <Text style={s.coinSym}>{coin}</Text>
            <Text style={s.coinName}>Available: {balance.toFixed(6)} {coin}</Text>
          </View>
          <Feather name={showCoinList ? 'chevron-up' : 'chevron-down'} size={20} color={colors.mutedForeground} />
        </TouchableOpacity>

        {showCoinList && (
          <View style={s.coinList}>
            {Object.keys(NETWORKS).map(c => (
              <TouchableOpacity key={c} style={s.coinListItem} onPress={() => { setCoin(c); setShowCoinList(false); }}>
                <CryptoIcon symbol={c} size={26} />
                <Text style={s.coinListText}>{c}</Text>
                <Text style={s.coinListName}>{coins.find(co => co.symbol === c)?.name}</Text>
              </TouchableOpacity>
            ))}
          </View>
        )}

        <Text style={s.sectionTitle}>Network</Text>
        {networks.map(n => (
          <TouchableOpacity key={n.id} style={[s.netItem, networkId === n.id && { borderColor: colors.primary, backgroundColor: colors.primary + '10' }]} onPress={() => setNetworkId(n.id)}>
            <View style={{ flex: 1 }}>
              <Text style={s.netName}>{n.name}</Text>
              <Text style={s.netDesc}>Network fee: {n.fee} {coin}</Text>
            </View>
            {networkId === n.id && <Feather name="check-circle" size={18} color={colors.primary} />}
          </TouchableOpacity>
        ))}

        <Text style={s.sectionTitle}>Recipient Address</Text>
        <View style={s.inputBox}>
          <TextInput style={s.input} placeholder={`Enter ${coin} address`} placeholderTextColor={colors.mutedForeground} value={address} onChangeText={setAddress} multiline />
          <TouchableOpacity><Feather name="clipboard" size={18} color={colors.primary} /></TouchableOpacity>
        </View>

        <Text style={s.sectionTitle}>Amount</Text>
        <View style={s.inputBox}>
          <TextInput style={[s.input, { fontSize: 18, fontFamily: 'Inter_700Bold' }]} placeholder="0.00" placeholderTextColor={colors.mutedForeground} value={amount} onChangeText={setAmount} keyboardType="decimal-pad" />
          <Text style={s.unit}>{coin}</Text>
          <TouchableOpacity onPress={() => setAmount(String(balance))}><Text style={[s.maxBtn, { color: colors.primary }]}>MAX</Text></TouchableOpacity>
        </View>

        {amt > 0 && (
          <View style={s.summary}>
            <View style={s.sumRow}><Text style={s.sumLbl}>Withdraw Amount</Text><Text style={s.sumVal}>{amt} {coin}</Text></View>
            <View style={s.sumRow}><Text style={s.sumLbl}>Network Fee</Text><Text style={s.sumVal}>{fee} {coin}</Text></View>
            <View style={s.sumRow}><Text style={[s.sumLbl, { color: colors.primary }]}>TDS (1%)</Text><Text style={[s.sumVal, { color: colors.primary }]}>{tds.toFixed(6)} {coin}</Text></View>
            <View style={s.sumDivider} />
            <View style={s.sumRow}><Text style={[s.sumLbl, { fontFamily: 'Inter_700Bold' }]}>You'll Receive</Text><Text style={[s.sumVal, { color: colors.success, fontSize: 15 }]}>{Math.max(0, receive).toFixed(6)} {coin}</Text></View>
          </View>
        )}

        <View style={s.warn}>
          <Feather name="alert-triangle" size={14} color={colors.warning} />
          <Text style={s.warnText}>Double-check the address. Crypto sent to wrong address cannot be recovered. 1% TDS is deducted as per Indian regulations.</Text>
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
  sectionTitle: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_700Bold', marginBottom: 8, marginTop: 12, textTransform: 'uppercase', letterSpacing: 0.5 },
  coinSelect: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, padding: 14, borderWidth: 1, borderColor: c.border },
  coinSym: { fontSize: 16, color: c.foreground, fontFamily: 'Inter_700Bold' },
  coinName: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  coinList: { backgroundColor: c.card, borderRadius: 12, padding: 4, marginTop: 6, borderWidth: 1, borderColor: c.border },
  coinListItem: { flexDirection: 'row', alignItems: 'center', padding: 10, gap: 10 },
  coinListText: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  coinListName: { fontSize: 12, color: c.mutedForeground },
  netItem: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 10, padding: 12, marginBottom: 6, borderWidth: 1, borderColor: c.border },
  netName: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  netDesc: { fontSize: 11, color: c.mutedForeground, marginTop: 2 },
  inputBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, borderWidth: 1, borderColor: c.border, gap: 8 },
  input: { flex: 1, fontSize: 13, color: c.foreground, fontFamily: 'Inter_500Medium', minHeight: 24 },
  unit: { fontSize: 13, color: c.mutedForeground, fontFamily: 'Inter_600SemiBold' },
  maxBtn: { fontSize: 12, fontFamily: 'Inter_700Bold' },
  summary: { backgroundColor: c.card, borderRadius: 12, padding: 14, marginTop: 14, borderWidth: 1, borderColor: c.border, gap: 8 },
  sumRow: { flexDirection: 'row', justifyContent: 'space-between' },
  sumLbl: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  sumVal: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  sumDivider: { height: 1, backgroundColor: c.border, marginVertical: 4 },
  warn: { flexDirection: 'row', gap: 8, padding: 12, borderRadius: 8, backgroundColor: c.warning + '15', marginTop: 14, marginBottom: 16, alignItems: 'flex-start' },
  warnText: { flex: 1, fontSize: 11, color: c.foreground, fontFamily: 'Inter_400Regular', lineHeight: 16 },
  cta: { borderRadius: 12, paddingVertical: 15, alignItems: 'center' },
  ctaText: { fontSize: 15, fontFamily: 'Inter_700Bold' },
});
