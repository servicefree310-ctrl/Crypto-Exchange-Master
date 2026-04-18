import React, { useState, useMemo, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, Alert, Platform } from 'react-native';
import * as Clipboard from 'expo-clipboard';
import { Header } from '@/components/Header';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { Feather, FontAwesome5 } from '@expo/vector-icons';

type Network = { id: string; name: string; chain: string; fee: number; minDeposit: number; confirmations: number; memoRequired?: boolean };

const NETWORKS: Record<string, Network[]> = {
  BTC:  [{ id: 'btc', name: 'Bitcoin (BTC)', chain: 'BTC', fee: 0.0001, minDeposit: 0.0001, confirmations: 2 }],
  ETH:  [
    { id: 'erc20', name: 'Ethereum (ERC20)', chain: 'ERC20', fee: 0.005, minDeposit: 0.005, confirmations: 12 },
    { id: 'arbi',  name: 'Arbitrum One',     chain: 'ARBITRUM', fee: 0.0001, minDeposit: 0.001, confirmations: 12 },
  ],
  USDT: [
    { id: 'trc20', name: 'Tron (TRC20)',           chain: 'TRC20', fee: 1,   minDeposit: 1,  confirmations: 1  },
    { id: 'erc20', name: 'Ethereum (ERC20)',       chain: 'ERC20', fee: 10,  minDeposit: 10, confirmations: 12 },
    { id: 'bep20', name: 'BNB Smart Chain (BEP20)',chain: 'BEP20', fee: 0.5, minDeposit: 1,  confirmations: 15 },
  ],
  USDC: [
    { id: 'erc20', name: 'Ethereum (ERC20)',       chain: 'ERC20', fee: 5,   minDeposit: 5,  confirmations: 12 },
    { id: 'arbi',  name: 'Arbitrum One',           chain: 'ARBITRUM', fee: 0.5, minDeposit: 1, confirmations: 12 },
  ],
  BNB:  [{ id: 'bep20', name: 'BNB Smart Chain (BEP20)', chain: 'BEP20', fee: 0.0005, minDeposit: 0.001, confirmations: 15 }],
  SOL:  [{ id: 'sol',   name: 'Solana',                  chain: 'SOLANA', fee: 0.001,  minDeposit: 0.01,  confirmations: 1  }],
  XRP:  [{ id: 'xrp',   name: 'XRP Ledger',              chain: 'XRP',    fee: 0.25,   minDeposit: 1,     confirmations: 1, memoRequired: true }],
  ADA:  [{ id: 'ada',   name: 'Cardano',                 chain: 'CARDANO', fee: 1,     minDeposit: 1,     confirmations: 15 }],
  MATIC:[{ id: 'poly',  name: 'Polygon',                 chain: 'POLYGON', fee: 0.1,   minDeposit: 1,     confirmations: 100 }],
  DOGE: [{ id: 'doge',  name: 'Dogecoin',                chain: 'DOGE',    fee: 5,     minDeposit: 10,    confirmations: 6   }],
};

// Browser-friendly deterministic hash (FNV-1a 64-bit → 64 hex chars via mixing)
function detHash(input: string): string {
  let h1 = 0xcbf29ce4n, h2 = 0x84222325n;
  const prime = 0x100000001b3n;
  for (let i = 0; i < input.length; i++) {
    const c = BigInt(input.charCodeAt(i));
    h1 = (h1 ^ c) * prime & 0xffffffffffffffffn;
    h2 = (h2 ^ (c + 31n)) * prime & 0xffffffffffffffffn;
  }
  let s = (h1.toString(16).padStart(16, '0') + h2.toString(16).padStart(16, '0'));
  while (s.length < 64) s += detHash(s).slice(0, 8);
  return s.slice(0, 64);
}

function generateAddress(uid: string, chain: string): { address: string; memo?: string } {
  const seed = detHash(`cx:${uid}:${chain}`);
  const c = chain.toUpperCase();
  if (c.includes('BTC') || c === 'BITCOIN') return { address: 'bc1q' + seed.slice(0, 38) };
  if (c.includes('TRC')) return { address: 'T' + seed.slice(0, 33).toUpperCase().replace(/[^A-Z0-9]/g, 'A') };
  if (c.includes('SOL')) return { address: seed.slice(0, 44) };
  if (c.includes('XRP')) return { address: 'r' + seed.slice(0, 33), memo: String(parseInt(seed.slice(0, 8), 16)) };
  if (c === 'CARDANO' || c === 'ADA') return { address: 'addr1' + seed.slice(0, 53) };
  return { address: '0x' + seed.slice(0, 40) };
}

export default function DepositCrypto() {
  const colors = useColors();
  const { coins, user } = useApp();

  const supportedSymbols = useMemo(() => Object.keys(NETWORKS).filter(s => coins.find(c => c.symbol === s)), [coins]);
  const [coin, setCoin] = useState(supportedSymbols[0] || 'USDT');
  const [showCoinList, setShowCoinList] = useState(false);
  const networks = NETWORKS[coin] || NETWORKS.USDT;
  const [networkId, setNetworkId] = useState(networks[0].id);
  const network = networks.find(n => n.id === networkId) || networks[0];

  useEffect(() => { setNetworkId(networks[0].id); }, [coin]);

  const { address, memo } = useMemo(
    () => generateAddress(user?.uid || 'guest', network.chain),
    [user?.uid, network.chain]
  );

  const copy = async (value: string, label: string) => {
    try {
      if (Platform.OS === 'web' && navigator.clipboard) await navigator.clipboard.writeText(value);
      else await Clipboard.setStringAsync(value);
      Alert.alert('Copied', `${label} copied to clipboard`);
    } catch {
      Alert.alert('Copy failed', value);
    }
  };

  const s = styles(colors);
  return (
    <SafeAreaView style={s.container}>
      <Header title="Deposit Crypto" subtitle="Receive crypto to your wallet" />
      <ScrollView contentContainerStyle={s.content}>
        <Text style={s.sectionTitle}>Select Coin</Text>
        <TouchableOpacity style={s.coinSelect} onPress={() => setShowCoinList(!showCoinList)}>
          <CryptoIcon symbol={coin} size={32} />
          <View style={{ flex: 1, marginLeft: 12 }}>
            <Text style={s.coinSym}>{coin}</Text>
            <Text style={s.coinName}>{coins.find(c => c.symbol === coin)?.name || coin}</Text>
          </View>
          <Feather name={showCoinList ? 'chevron-up' : 'chevron-down'} size={20} color={colors.mutedForeground} />
        </TouchableOpacity>

        {showCoinList && (
          <View style={s.coinList}>
            {supportedSymbols.map(c => (
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
              <Text style={s.netDesc}>Confirmations: {n.confirmations} • Min: {n.minDeposit} {coin} • Fee: {n.fee} {coin}</Text>
            </View>
            {networkId === n.id && <Feather name="check-circle" size={18} color={colors.primary} />}
          </TouchableOpacity>
        ))}

        <View style={s.qrCard}>
          <View style={s.qrBox}>
            <FontAwesome5 name="qrcode" size={120} color={colors.foreground} />
          </View>
          <Text style={s.qrLabel}>Deposit Address (auto-generated)</Text>
          <View style={s.addressBox}>
            <Text style={s.addressText} numberOfLines={1} ellipsizeMode="middle">{address}</Text>
          </View>
          <TouchableOpacity style={[s.copyBtn, { backgroundColor: colors.primary }]} onPress={() => copy(address, 'Address')}>
            <Feather name="copy" size={16} color="#000" />
            <Text style={[s.copyText, { color: '#000' }]}>Copy Address</Text>
          </TouchableOpacity>

          {memo && (
            <View style={{ marginTop: 12, width: '100%' }}>
              <Text style={s.qrLabel}>Memo / Tag {network.memoRequired ? '(required)' : ''}</Text>
              <View style={s.addressBox}>
                <Text style={s.addressText}>{memo}</Text>
              </View>
              <TouchableOpacity style={[s.copyBtn, { backgroundColor: colors.secondary, alignSelf: 'center' }]} onPress={() => copy(memo, 'Memo')}>
                <Feather name="copy" size={14} color={colors.foreground} />
                <Text style={[s.copyText, { color: colors.foreground }]}>Copy Memo</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>

        <View style={s.infoGrid}>
          <View style={s.infoItem}>
            <Text style={s.infoLbl}>Min Deposit</Text>
            <Text style={s.infoVal}>{network.minDeposit} {coin}</Text>
          </View>
          <View style={s.infoItem}>
            <Text style={s.infoLbl}>Confirmations</Text>
            <Text style={s.infoVal}>{network.confirmations}</Text>
          </View>
          <View style={s.infoItem}>
            <Text style={s.infoLbl}>Network Fee</Text>
            <Text style={s.infoVal}>{network.fee} {coin}</Text>
          </View>
        </View>

        <View style={s.warn}>
          <Feather name="alert-triangle" size={14} color={colors.warning} />
          <Text style={s.warnText}>Send only {coin} via {network.name} to this address. Sending other assets or using wrong network will result in permanent loss{network.memoRequired ? '. Memo/Tag is mandatory for this network' : ''}.</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (c: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: c.background },
  content: { padding: 16, paddingBottom: 60 },
  sectionTitle: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_700Bold', marginBottom: 8, marginTop: 4, textTransform: 'uppercase', letterSpacing: 0.5 },
  coinSelect: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 12, padding: 14, borderWidth: 1, borderColor: c.border, marginBottom: 14 },
  coinSym: { fontSize: 16, color: c.foreground, fontFamily: 'Inter_700Bold' },
  coinName: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  coinList: { backgroundColor: c.card, borderRadius: 12, padding: 4, marginBottom: 14, borderWidth: 1, borderColor: c.border },
  coinListItem: { flexDirection: 'row', alignItems: 'center', padding: 10, gap: 10 },
  coinListText: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  coinListName: { fontSize: 12, color: c.mutedForeground, fontFamily: 'Inter_400Regular' },
  netItem: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 10, padding: 12, marginBottom: 6, borderWidth: 1, borderColor: c.border },
  netName: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold' },
  netDesc: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  qrCard: { backgroundColor: c.card, borderRadius: 14, padding: 20, alignItems: 'center', marginTop: 14, marginBottom: 14, borderWidth: 1, borderColor: c.border },
  qrBox: { width: 180, height: 180, backgroundColor: c.background, borderRadius: 12, alignItems: 'center', justifyContent: 'center', marginBottom: 14, borderWidth: 1, borderColor: c.border },
  qrLabel: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase', marginBottom: 6 },
  addressBox: { backgroundColor: c.background, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 10, width: '100%', marginBottom: 12 },
  addressText: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_500Medium', textAlign: 'center' },
  copyBtn: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingHorizontal: 18, paddingVertical: 10, borderRadius: 8 },
  copyText: { fontSize: 13, fontFamily: 'Inter_700Bold' },
  infoGrid: { flexDirection: 'row', backgroundColor: c.card, borderRadius: 12, padding: 14, borderWidth: 1, borderColor: c.border, marginBottom: 14 },
  infoItem: { flex: 1, alignItems: 'center' },
  infoLbl: { fontSize: 10, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase' },
  infoVal: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_600SemiBold', marginTop: 4 },
  warn: { flexDirection: 'row', gap: 8, padding: 12, borderRadius: 8, backgroundColor: c.warning + '15', alignItems: 'flex-start' },
  warnText: { flex: 1, fontSize: 11, color: c.foreground, fontFamily: 'Inter_400Regular', lineHeight: 16 },
});
