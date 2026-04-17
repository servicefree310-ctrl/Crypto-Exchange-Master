import React, { useState, useMemo } from 'react';
import {
  View, Text, StyleSheet, FlatList, TouchableOpacity,
  SafeAreaView, Platform, TextInput
} from 'react-native';
import { useRouter } from 'expo-router';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { CryptoIcon } from '@/components/CryptoIcon';
import { MiniChart } from '@/components/MiniChart';
import { Feather, MaterialIcons } from '@expo/vector-icons';

type Filter = 'all' | 'gainers' | 'losers' | 'new' | 'fiat';
type Sort = 'default' | 'price_asc' | 'price_desc' | 'change_asc' | 'change_desc' | 'vol_desc';

function formatPrice(p: number) {
  if (p < 0.01) return `₹${p.toFixed(6)}`;
  if (p < 1) return `₹${p.toFixed(4)}`;
  if (p >= 100000) return `₹${(p / 100000).toFixed(2)}L`;
  return `₹${p.toLocaleString('en-IN', { maximumFractionDigits: 2 })}`;
}

function formatVol(v: number) {
  if (v >= 1e9) return `₹${(v / 1e9).toFixed(1)}B`;
  if (v >= 1e6) return `₹${(v / 1e6).toFixed(1)}M`;
  return `₹${(v / 1e3).toFixed(0)}K`;
}

export default function MarketsScreen() {
  const colors = useColors();
  const { coins } = useApp();
  const router = useRouter();
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<Filter>('all');
  const [sort, setSort] = useState<Sort>('default');

  const filtered = useMemo(() => {
    let list = coins.filter(c =>
      c.symbol.toLowerCase().includes(search.toLowerCase()) ||
      c.name.toLowerCase().includes(search.toLowerCase())
    );
    if (filter === 'gainers') list = list.filter(c => c.change24h > 0);
    if (filter === 'losers') list = list.filter(c => c.change24h < 0);

    if (sort === 'price_asc') list = [...list].sort((a, b) => a.price - b.price);
    if (sort === 'price_desc') list = [...list].sort((a, b) => b.price - a.price);
    if (sort === 'change_asc') list = [...list].sort((a, b) => a.change24h - b.change24h);
    if (sort === 'change_desc') list = [...list].sort((a, b) => b.change24h - a.change24h);
    if (sort === 'vol_desc') list = [...list].sort((a, b) => b.volume24h - a.volume24h);

    return list;
  }, [coins, search, filter, sort]);

  const s = styles(colors);
  const topPadding = Platform.OS === 'web' ? 80 : 0;

  const filters: { key: Filter; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'gainers', label: 'Gainers' },
    { key: 'losers', label: 'Losers' },
    { key: 'new', label: 'New' },
    { key: 'fiat', label: 'INR' },
  ];

  return (
    <SafeAreaView style={s.container}>
      <View style={[s.top, { paddingTop: topPadding || 16 }]}>
        <Text style={s.title}>Markets</Text>

        {/* Search */}
        <View style={s.searchRow}>
          <Feather name="search" size={16} color={colors.mutedForeground} />
          <TextInput
            style={s.searchInput}
            value={search}
            onChangeText={setSearch}
            placeholder="Search coin..."
            placeholderTextColor={colors.mutedForeground}
          />
          {search ? <TouchableOpacity onPress={() => setSearch('')}><Feather name="x" size={16} color={colors.mutedForeground} /></TouchableOpacity> : null}
        </View>

        {/* Filters */}
        <View style={s.filterRow}>
          {filters.map(f => (
            <TouchableOpacity
              key={f.key}
              style={[s.filterBtn, filter === f.key && { backgroundColor: colors.primary }]}
              onPress={() => setFilter(f.key)}
            >
              <Text style={[s.filterText, filter === f.key && { color: '#000' }]}>{f.label}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Sort Header */}
        <View style={s.tableHeader}>
          <Text style={s.th}>Coin</Text>
          <Text style={s.th}>Chart</Text>
          <TouchableOpacity onPress={() => setSort(sort === 'price_desc' ? 'price_asc' : 'price_desc')}>
            <Text style={[s.th, { color: sort.startsWith('price') ? colors.primary : colors.mutedForeground }]}>
              Price {sort === 'price_desc' ? '▼' : sort === 'price_asc' ? '▲' : ''}
            </Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => setSort(sort === 'change_desc' ? 'change_asc' : 'change_desc')}>
            <Text style={[s.th, { color: sort.startsWith('change') ? colors.primary : colors.mutedForeground }]}>
              24h {sort === 'change_desc' ? '▼' : sort === 'change_asc' ? '▲' : ''}
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      <FlatList
        data={filtered}
        keyExtractor={c => c.symbol}
        contentContainerStyle={{ paddingBottom: 100 }}
        scrollEnabled={!!filtered.length}
        renderItem={({ item: coin }) => (
          <TouchableOpacity
            style={s.row}
            onPress={() => router.push(`/trading/${coin.symbol}INR` as any)}
          >
            <View style={s.coinInfo}>
              <CryptoIcon symbol={coin.symbol} size={38} />
              <View style={s.coinText}>
                <Text style={s.symbol}>{coin.symbol}</Text>
                <Text style={s.name}>{coin.name}</Text>
              </View>
            </View>
            <MiniChart positive={coin.change24h >= 0} width={56} height={28} />
            <View style={s.priceBox}>
              <Text style={s.price}>{formatPrice(coin.price)}</Text>
              <Text style={s.vol}>{formatVol(coin.volume24h)}</Text>
            </View>
            <View style={[s.badge, { backgroundColor: coin.change24h >= 0 ? colors.success + '22' : colors.danger + '22' }]}>
              <Text style={[s.badgeText, { color: coin.change24h >= 0 ? colors.success : colors.danger }]}>
                {coin.change24h >= 0 ? '+' : ''}{coin.change24h.toFixed(2)}%
              </Text>
            </View>
          </TouchableOpacity>
        )}
        ListEmptyComponent={
          <View style={s.empty}>
            <MaterialIcons name="search-off" size={48} color={colors.mutedForeground} />
            <Text style={s.emptyText}>No coins found</Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}

const styles = (colors: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  top: { paddingHorizontal: 16 },
  title: { fontSize: 24, fontFamily: 'Inter_700Bold', color: colors.foreground, marginBottom: 14 },
  searchRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: colors.card, borderRadius: 10, paddingHorizontal: 12, paddingVertical: 10, marginBottom: 12, gap: 8, borderWidth: 1, borderColor: colors.border },
  searchInput: { flex: 1, fontSize: 14, color: colors.foreground, fontFamily: 'Inter_400Regular' },
  filterRow: { flexDirection: 'row', gap: 8, marginBottom: 14 },
  filterBtn: { paddingHorizontal: 14, paddingVertical: 6, borderRadius: 20, backgroundColor: colors.secondary, borderWidth: 1, borderColor: colors.border },
  filterText: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  tableHeader: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: 0, paddingBottom: 8, borderBottomWidth: 1, borderBottomColor: colors.border, marginBottom: 4 },
  th: { fontSize: 11, fontFamily: 'Inter_500Medium', color: colors.mutedForeground, textTransform: 'uppercase', letterSpacing: 0.5 },
  row: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, paddingHorizontal: 16, borderBottomWidth: 1, borderBottomColor: colors.border, gap: 8 },
  coinInfo: { flex: 1.2, flexDirection: 'row', alignItems: 'center', gap: 8 },
  coinText: {},
  symbol: { fontSize: 14, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  name: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 1 },
  priceBox: { flex: 1, alignItems: 'flex-end' },
  price: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  vol: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  badge: { minWidth: 62, borderRadius: 6, paddingHorizontal: 6, paddingVertical: 3, alignItems: 'center' },
  badgeText: { fontSize: 12, fontFamily: 'Inter_600SemiBold' },
  empty: { alignItems: 'center', justifyContent: 'center', paddingVertical: 60, gap: 10 },
  emptyText: { fontSize: 15, color: colors.mutedForeground, fontFamily: 'Inter_500Medium' },
});
