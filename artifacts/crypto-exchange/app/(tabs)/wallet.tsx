import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  SafeAreaView, Platform, Modal, TextInput, Alert
} from 'react-native';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { MaterialIcons, Feather, MaterialCommunityIcons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';

type WalletTab = 'overview' | 'deposit' | 'withdraw' | 'transfer' | 'history';

const NETWORKS: Record<string, string[]> = {
  BTC: ['Bitcoin (BTC)'],
  ETH: ['Ethereum (ERC20)', 'Arbitrum', 'Optimism'],
  BNB: ['BNB Smart Chain (BEP20)', 'Binance Chain (BEP2)'],
  USDT: ['Ethereum (ERC20)', 'Tron (TRC20)', 'BNB Smart Chain (BEP20)', 'Polygon'],
  SOL: ['Solana'],
  XRP: ['XRP Ledger'],
  ADA: ['Cardano'],
  INR: ['Bank Transfer', 'UPI'],
};

const PAYMENT_METHODS = ['Bank Transfer (NEFT/IMPS/RTGS)', 'UPI', 'Paytm', 'PhonePe', 'Google Pay'];

export default function WalletScreen() {
  const colors = useColors();
  const { walletBalances, transactions, addTransaction, banks } = useApp();
  const [tab, setTab] = useState<WalletTab>('overview');
  const [selectedCoin, setSelectedCoin] = useState('INR');
  const [selectedNetwork, setSelectedNetwork] = useState('');
  const [amount, setAmount] = useState('');
  const [address, setAddress] = useState('');
  const [paymentMethod, setPaymentMethod] = useState(PAYMENT_METHODS[0]);
  const [hideBalance, setHideBalance] = useState(false);

  const totalINR = walletBalances.reduce((s, b) => s + b.inrValue, 0);
  const networks = NETWORKS[selectedCoin] || ['Default'];

  const handleDeposit = async () => {
    if (!amount || parseFloat(amount) <= 0) { Alert.alert('Error', 'Enter valid amount'); return; }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    addTransaction({
      id: 'TXN' + Date.now(),
      type: 'deposit',
      symbol: selectedCoin,
      amount: parseFloat(amount),
      status: 'pending',
      timestamp: Date.now(),
      fee: selectedCoin === 'INR' ? 0 : 1,
      network: selectedNetwork || networks[0],
    });
    setAmount('');
    Alert.alert('Success', `Deposit request submitted for ${selectedCoin} ${amount}`);
  };

  const handleWithdraw = async () => {
    if (!amount || parseFloat(amount) <= 0) { Alert.alert('Error', 'Enter valid amount'); return; }
    if (selectedCoin !== 'INR' && !address) { Alert.alert('Error', 'Enter wallet address'); return; }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    const fee = selectedCoin === 'INR' ? 0 : parseFloat(amount) * 0.001;
    const tds = selectedCoin !== 'INR' ? parseFloat(amount) * 0.01 : 0;
    addTransaction({
      id: 'TXN' + Date.now(),
      type: 'withdraw',
      symbol: selectedCoin,
      amount: parseFloat(amount),
      status: 'pending',
      timestamp: Date.now(),
      fee,
      network: selectedNetwork || networks[0],
      address,
    });
    setAmount('');
    setAddress('');
    Alert.alert('Submitted', `Withdraw request: ${selectedCoin} ${amount}\nFee: ${fee}\nTDS (1%): ${tds.toFixed(4)}`);
  };

  const s = styles(colors);
  const topPadding = Platform.OS === 'web' ? 80 : 0;

  const tabs: { key: WalletTab; label: string; icon: string }[] = [
    { key: 'overview', label: 'Overview', icon: 'pie-chart' },
    { key: 'deposit', label: 'Deposit', icon: 'arrow-down-circle' },
    { key: 'withdraw', label: 'Withdraw', icon: 'arrow-up-circle' },
    { key: 'transfer', label: 'Transfer', icon: 'refresh-cw' },
    { key: 'history', label: 'History', icon: 'clock' },
  ];

  return (
    <SafeAreaView style={s.container}>
      <ScrollView contentContainerStyle={[s.scroll, { paddingTop: topPadding }]} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={s.header}>
          <Text style={s.title}>Wallet</Text>
          <TouchableOpacity onPress={() => setHideBalance(!hideBalance)}>
            <Feather name={hideBalance ? 'eye-off' : 'eye'} size={20} color={colors.mutedForeground} />
          </TouchableOpacity>
        </View>

        {/* Total Balance Card */}
        <View style={s.balanceCard}>
          <Text style={s.balanceLabel}>Total Balance (INR)</Text>
          <Text style={s.balanceValue}>{hideBalance ? '₹ ••••••' : `₹${totalINR.toLocaleString('en-IN', { maximumFractionDigits: 2 })}`}</Text>
        </View>

        {/* Tab Navigation */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.tabScroll}>
          {tabs.map(t => (
            <TouchableOpacity key={t.key} style={[s.tab, tab === t.key && s.tabActive]} onPress={() => setTab(t.key)}>
              <Feather name={t.icon as any} size={14} color={tab === t.key ? '#000' : colors.mutedForeground} />
              <Text style={[s.tabText, tab === t.key && s.tabTextActive]}>{t.label}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Overview */}
        {tab === 'overview' && (
          <View>
            {walletBalances.map(bal => (
              <View key={bal.symbol} style={s.balRow}>
                <CryptoIcon symbol={bal.symbol} size={40} />
                <View style={s.balInfo}>
                  <Text style={s.balSymbol}>{bal.symbol}</Text>
                  <Text style={s.balAvail}>Available: {hideBalance ? '••••' : bal.available.toLocaleString('en-IN', { maximumFractionDigits: 6 })}</Text>
                  {bal.locked > 0 && <Text style={s.balLocked}>Locked: {bal.locked.toLocaleString('en-IN', { maximumFractionDigits: 6 })}</Text>}
                </View>
                <View style={s.balRight}>
                  <Text style={s.balINR}>{hideBalance ? '₹ ••••' : `₹${bal.inrValue.toLocaleString('en-IN', { maximumFractionDigits: 0 })}`}</Text>
                  <Text style={s.balINRLabel}>INR Value</Text>
                </View>
              </View>
            ))}
          </View>
        )}

        {/* Deposit */}
        {tab === 'deposit' && (
          <View style={s.formCard}>
            <Text style={s.formTitle}>Deposit</Text>

            <Text style={s.label}>Select Coin</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.coinSelect}>
              {['INR', 'BTC', 'ETH', 'BNB', 'USDT', 'SOL', 'XRP'].map(c => (
                <TouchableOpacity key={c} style={[s.coinChip, selectedCoin === c && { borderColor: colors.primary, backgroundColor: colors.primary + '18' }]} onPress={() => { setSelectedCoin(c); setSelectedNetwork(''); }}>
                  <CryptoIcon symbol={c} size={18} />
                  <Text style={[s.coinChipText, selectedCoin === c && { color: colors.primary }]}>{c}</Text>
                </TouchableOpacity>
              ))}
            </ScrollView>

            {selectedCoin !== 'INR' && (
              <>
                <Text style={s.label}>Select Network</Text>
                {networks.map(n => (
                  <TouchableOpacity key={n} style={[s.networkChip, selectedNetwork === n && { borderColor: colors.primary }]} onPress={() => setSelectedNetwork(n)}>
                    <View style={[s.radioOuter, selectedNetwork === n && { borderColor: colors.primary }]}>
                      {selectedNetwork === n && <View style={[s.radioInner, { backgroundColor: colors.primary }]} />}
                    </View>
                    <Text style={s.networkText}>{n}</Text>
                  </TouchableOpacity>
                ))}

                <View style={s.addressBox}>
                  <Text style={s.addressLabel}>Deposit Address</Text>
                  <Text style={s.address}>1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8</Text>
                  <TouchableOpacity style={s.copyBtn}>
                    <Feather name="copy" size={14} color={colors.primary} />
                    <Text style={s.copyText}>Copy Address</Text>
                  </TouchableOpacity>
                </View>

                <View style={s.warningBox}>
                  <MaterialIcons name="warning" size={14} color="#F0B90B" />
                  <Text style={s.warningText}>Only send {selectedCoin} via selected network. Wrong network will result in permanent loss.</Text>
                </View>
              </>
            )}

            {selectedCoin === 'INR' && (
              <>
                <Text style={s.label}>Payment Method</Text>
                {PAYMENT_METHODS.map(m => (
                  <TouchableOpacity key={m} style={[s.networkChip, paymentMethod === m && { borderColor: colors.primary }]} onPress={() => setPaymentMethod(m)}>
                    <View style={[s.radioOuter, paymentMethod === m && { borderColor: colors.primary }]}>
                      {paymentMethod === m && <View style={[s.radioInner, { backgroundColor: colors.primary }]} />}
                    </View>
                    <Text style={s.networkText}>{m}</Text>
                  </TouchableOpacity>
                ))}

                <Text style={s.label}>Amount (INR)</Text>
                <View style={s.inputRow}>
                  <Text style={s.rupee}>₹</Text>
                  <TextInput style={s.amtInput} value={amount} onChangeText={setAmount} placeholder="0.00" placeholderTextColor={colors.mutedForeground} keyboardType="decimal-pad" />
                </View>
                <Text style={s.minNote}>Min: ₹100 | Max: ₹500,000 per day</Text>

                <TouchableOpacity style={s.submitBtn} onPress={handleDeposit}>
                  <Text style={s.submitBtnText}>Submit Deposit</Text>
                </TouchableOpacity>
              </>
            )}
          </View>
        )}

        {/* Withdraw */}
        {tab === 'withdraw' && (
          <View style={s.formCard}>
            <Text style={s.formTitle}>Withdraw</Text>

            <Text style={s.label}>Select Coin</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.coinSelect}>
              {['INR', 'BTC', 'ETH', 'BNB', 'USDT', 'SOL'].map(c => (
                <TouchableOpacity key={c} style={[s.coinChip, selectedCoin === c && { borderColor: colors.primary, backgroundColor: colors.primary + '18' }]} onPress={() => { setSelectedCoin(c); setSelectedNetwork(''); }}>
                  <CryptoIcon symbol={c} size={18} />
                  <Text style={[s.coinChipText, selectedCoin === c && { color: colors.primary }]}>{c}</Text>
                </TouchableOpacity>
              ))}
            </ScrollView>

            {selectedCoin !== 'INR' && (
              <>
                <Text style={s.label}>Select Network</Text>
                {networks.map(n => (
                  <TouchableOpacity key={n} style={[s.networkChip, selectedNetwork === n && { borderColor: colors.primary }]} onPress={() => setSelectedNetwork(n)}>
                    <View style={[s.radioOuter, selectedNetwork === n && { borderColor: colors.primary }]}>
                      {selectedNetwork === n && <View style={[s.radioInner, { backgroundColor: colors.primary }]} />}
                    </View>
                    <Text style={s.networkText}>{n}</Text>
                  </TouchableOpacity>
                ))}

                <Text style={s.label}>Recipient Address</Text>
                <View style={s.inputRow}>
                  <TextInput style={[s.amtInput, { flex: 1 }]} value={address} onChangeText={setAddress} placeholder="Wallet address" placeholderTextColor={colors.mutedForeground} />
                </View>
              </>
            )}

            {selectedCoin === 'INR' && (
              <>
                <Text style={s.label}>Bank Account</Text>
                {banks.filter(b => b.status === 'verified').map(b => (
                  <View key={b.id} style={s.bankChip}>
                    <MaterialIcons name="account-balance" size={18} color={colors.primary} />
                    <View style={{ flex: 1 }}>
                      <Text style={s.bankName}>{b.bankName}</Text>
                      <Text style={s.bankAcct}>••••{b.accountNumber.slice(-4)}</Text>
                    </View>
                    <View style={s.verifiedBadge}>
                      <Text style={s.verifiedText}>Verified</Text>
                    </View>
                  </View>
                ))}
                {banks.filter(b => b.status === 'verified').length === 0 && (
                  <Text style={s.noBank}>No verified bank account. Add one in Account section.</Text>
                )}
              </>
            )}

            <Text style={s.label}>Amount ({selectedCoin})</Text>
            <View style={s.inputRow}>
              <Text style={s.rupee}>{selectedCoin === 'INR' ? '₹' : selectedCoin}</Text>
              <TextInput style={s.amtInput} value={amount} onChangeText={setAmount} placeholder="0.00" placeholderTextColor={colors.mutedForeground} keyboardType="decimal-pad" />
            </View>

            <View style={s.feeBox}>
              <View style={s.feeRow}>
                <Text style={s.feeLabel}>Network Fee</Text>
                <Text style={s.feeValue}>{selectedCoin === 'INR' ? '₹0' : `0.1% ${selectedCoin}`}</Text>
              </View>
              <View style={s.feeRow}>
                <Text style={s.feeLabel}>TDS (1% on sell)</Text>
                <Text style={s.feeValue}>{selectedCoin === 'INR' ? '₹0' : `1% ${selectedCoin}`}</Text>
              </View>
              <View style={s.feeRow}>
                <Text style={s.feeLabel}>Daily Limit</Text>
                <Text style={s.feeValue}>₹5,00,000</Text>
              </View>
            </View>

            <TouchableOpacity style={s.submitBtn} onPress={handleWithdraw}>
              <Text style={s.submitBtnText}>Submit Withdrawal</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Transfer */}
        {tab === 'transfer' && (
          <View style={s.formCard}>
            <Text style={s.formTitle}>Internal Transfer</Text>
            <Text style={s.transferNote}>Transfer between your Spot, Futures, and Earn wallets</Text>

            {[
              { from: 'Spot Wallet', to: 'Futures Wallet', desc: 'Move funds for futures trading' },
              { from: 'Spot Wallet', to: 'Earn Wallet', desc: 'Move funds for staking/earn' },
              { from: 'Futures Wallet', to: 'Spot Wallet', desc: 'Move profits to spot' },
            ].map(({ from, to, desc }) => (
              <View key={from + to} style={s.transferCard}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                  <Text style={s.transferFrom}>{from}</Text>
                  <MaterialCommunityIcons name="arrow-right" size={14} color={colors.primary} />
                  <Text style={s.transferTo}>{to}</Text>
                </View>
                <Text style={s.transferDesc}>{desc}</Text>
                <TouchableOpacity style={s.transferBtn} onPress={() => Alert.alert('Transfer', 'Transfer feature coming soon')}>
                  <Text style={s.transferBtnText}>Transfer</Text>
                </TouchableOpacity>
              </View>
            ))}
          </View>
        )}

        {/* History */}
        {tab === 'history' && (
          <View>
            {transactions.map(tx => (
              <View key={tx.id} style={s.txRow}>
                <View style={[s.txIcon, { backgroundColor: tx.type === 'deposit' ? colors.success + '22' : colors.danger + '22' }]}>
                  <Feather name={tx.type === 'deposit' ? 'arrow-down' : tx.type === 'withdraw' ? 'arrow-up' : 'refresh-cw'} size={16} color={tx.type === 'deposit' ? colors.success : colors.danger} />
                </View>
                <View style={s.txInfo}>
                  <Text style={s.txType}>{tx.type.charAt(0).toUpperCase() + tx.type.slice(1)} {tx.symbol}</Text>
                  <Text style={s.txDate}>{new Date(tx.timestamp).toLocaleDateString('en-IN')} {new Date(tx.timestamp).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}</Text>
                  {tx.network && <Text style={s.txNetwork}>{tx.network}</Text>}
                </View>
                <View style={s.txRight}>
                  <Text style={[s.txAmount, { color: tx.type === 'deposit' ? colors.success : colors.danger }]}>
                    {tx.type === 'deposit' ? '+' : '-'}{tx.amount} {tx.symbol}
                  </Text>
                  <View style={[s.txStatus, { backgroundColor: tx.status === 'completed' ? colors.success + '22' : tx.status === 'pending' ? '#F0B90B22' : colors.danger + '22' }]}>
                    <Text style={[s.txStatusText, { color: tx.status === 'completed' ? colors.success : tx.status === 'pending' ? '#F0B90B' : colors.danger }]}>
                      {tx.status}
                    </Text>
                  </View>
                </View>
              </View>
            ))}
          </View>
        )}

        <View style={{ height: 100 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (colors: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  scroll: { paddingHorizontal: 16 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 16 },
  title: { fontSize: 24, fontFamily: 'Inter_700Bold', color: colors.foreground },
  balanceCard: { backgroundColor: colors.primary, borderRadius: 16, padding: 24, marginBottom: 16, alignItems: 'center' },
  balanceLabel: { fontSize: 12, color: '#000000AA', fontFamily: 'Inter_500Medium', marginBottom: 4 },
  balanceValue: { fontSize: 32, fontFamily: 'Inter_700Bold', color: '#000', letterSpacing: -1 },
  tabScroll: { marginBottom: 16 },
  tab: { flexDirection: 'row', alignItems: 'center', gap: 5, paddingHorizontal: 14, paddingVertical: 8, borderRadius: 20, backgroundColor: colors.secondary, marginRight: 8, borderWidth: 1, borderColor: colors.border },
  tabActive: { backgroundColor: colors.primary },
  tabText: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  tabTextActive: { color: '#000', fontFamily: 'Inter_700Bold' },
  balRow: { flexDirection: 'row', alignItems: 'center', padding: 14, backgroundColor: colors.card, borderRadius: 12, marginBottom: 8, gap: 12, borderWidth: 1, borderColor: colors.border },
  balInfo: { flex: 1 },
  balSymbol: { fontSize: 15, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  balAvail: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  balLocked: { fontSize: 11, color: colors.danger, fontFamily: 'Inter_400Regular' },
  balRight: { alignItems: 'flex-end' },
  balINR: { fontSize: 14, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  balINRLabel: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  formCard: { backgroundColor: colors.card, borderRadius: 16, padding: 16, borderWidth: 1, borderColor: colors.border },
  formTitle: { fontSize: 18, fontFamily: 'Inter_700Bold', color: colors.foreground, marginBottom: 16 },
  label: { fontSize: 11, fontFamily: 'Inter_500Medium', color: colors.mutedForeground, marginBottom: 8, marginTop: 14, textTransform: 'uppercase', letterSpacing: 0.5 },
  coinSelect: { marginBottom: 4 },
  coinChip: { flexDirection: 'row', alignItems: 'center', gap: 5, paddingHorizontal: 10, paddingVertical: 6, borderRadius: 20, borderWidth: 1, borderColor: colors.border, marginRight: 8, backgroundColor: colors.secondary },
  coinChipText: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.foreground },
  networkChip: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 12, borderRadius: 8, borderWidth: 1, borderColor: colors.border, marginBottom: 6, backgroundColor: colors.secondary },
  radioOuter: { width: 18, height: 18, borderRadius: 9, borderWidth: 2, borderColor: colors.border, alignItems: 'center', justifyContent: 'center' },
  radioInner: { width: 8, height: 8, borderRadius: 4 },
  networkText: { fontSize: 13, color: colors.foreground, fontFamily: 'Inter_400Regular' },
  addressBox: { backgroundColor: colors.secondary, borderRadius: 10, padding: 14, marginTop: 10, borderWidth: 1, borderColor: colors.border },
  addressLabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginBottom: 6 },
  address: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_500Medium', letterSpacing: 0.5 },
  copyBtn: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 8 },
  copyText: { fontSize: 13, color: colors.primary, fontFamily: 'Inter_500Medium' },
  warningBox: { flexDirection: 'row', gap: 8, backgroundColor: '#F0B90B18', borderRadius: 8, padding: 10, marginTop: 10, alignItems: 'flex-start' },
  warningText: { flex: 1, fontSize: 12, color: colors.foreground, fontFamily: 'Inter_400Regular', lineHeight: 18 },
  inputRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: colors.secondary, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, gap: 8, borderWidth: 1, borderColor: colors.border },
  rupee: { fontSize: 16, color: colors.mutedForeground, fontFamily: 'Inter_500Medium' },
  amtInput: { flex: 1, fontSize: 16, color: colors.foreground, fontFamily: 'Inter_600SemiBold' },
  minNote: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 6 },
  submitBtn: { backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 14, alignItems: 'center', marginTop: 16 },
  submitBtnText: { fontSize: 16, fontFamily: 'Inter_700Bold', color: '#000' },
  bankChip: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: colors.secondary, borderRadius: 10, padding: 12, marginBottom: 8, borderWidth: 1, borderColor: colors.border },
  bankName: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  bankAcct: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  verifiedBadge: { backgroundColor: colors.success + '22', borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3 },
  verifiedText: { fontSize: 11, color: colors.success, fontFamily: 'Inter_600SemiBold' },
  noBank: { fontSize: 13, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 4 },
  feeBox: { backgroundColor: colors.secondary, borderRadius: 10, padding: 12, marginTop: 12, gap: 6, borderWidth: 1, borderColor: colors.border },
  feeRow: { flexDirection: 'row', justifyContent: 'space-between' },
  feeLabel: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  feeValue: { fontSize: 12, color: colors.foreground, fontFamily: 'Inter_500Medium' },
  txRow: { flexDirection: 'row', alignItems: 'center', padding: 12, borderBottomWidth: 1, borderBottomColor: colors.border, gap: 12 },
  txIcon: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  txInfo: { flex: 1 },
  txType: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  txDate: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  txNetwork: { fontSize: 10, color: colors.primary, fontFamily: 'Inter_400Regular', marginTop: 1 },
  txRight: { alignItems: 'flex-end', gap: 4 },
  txAmount: { fontSize: 13, fontFamily: 'Inter_600SemiBold' },
  txStatus: { borderRadius: 6, paddingHorizontal: 6, paddingVertical: 2 },
  txStatusText: { fontSize: 10, fontFamily: 'Inter_500Medium' },
  transferNote: { fontSize: 13, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginBottom: 16 },
  transferCard: { backgroundColor: colors.secondary, borderRadius: 10, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: colors.border },
  transferFrom: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  transferTo: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.primary },
  transferDesc: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginBottom: 10 },
  transferBtn: { backgroundColor: colors.primary + '18', borderRadius: 8, paddingVertical: 8, alignItems: 'center', borderWidth: 1, borderColor: colors.primary + '44' },
  transferBtnText: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.primary },
});
