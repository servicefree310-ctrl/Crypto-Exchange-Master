import { Feather } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import { useRouter } from "expo-router";
import React, { useMemo } from "react";
import {
  View, Text, ScrollView, TouchableOpacity, Image,
  StyleSheet, Platform, FlatList,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useQuery } from "@tanstack/react-query";

import { useColors } from "@/hooks/useColors";
import { useApp } from "@/context/AppContext";
import { marketApi } from "@/lib/api";

const COIN_COLORS: Record<string, string> = {
  BTC: "#F7931A", ETH: "#627EEA", BNB: "#F3BA2F", SOL: "#14F195",
  XRP: "#0085C0", DOGE: "#C2A633", MATIC: "#8247E5", USDT: "#26A17B",
  ADA: "#0033AD", AVAX: "#E84142", ATOM: "#2E3148",
};

const QUICK_ACTIONS = [
  { label: "Deposit", icon: "arrow-down-circle", route: "/services/deposit-crypto", color: "#0ecb81" },
  { label: "Withdraw", icon: "arrow-up-circle", route: "/services/withdraw-inr", color: "#f6465d" },
  { label: "Buy Crypto", icon: "credit-card", route: "/services/buy-crypto", color: "#5b8def" },
  { label: "P2P", icon: "users", route: "/services/p2p", color: "#fcd535" },
  { label: "Earn", icon: "trending-up", route: "/services/earn", color: "#a06af5" },
  { label: "Transfer", icon: "repeat", route: "/services/transfer", color: "#00c2ff" },
  { label: "Refer", icon: "gift", route: "/services/refer", color: "#ff8a3d" },
  { label: "More", icon: "grid", route: "/services", color: "#8d96a7" },
];

const BANNERS = [
  { title: "1% TDS Compliant Trading", sub: "Trade INR pairs with full tax compliance", grad: ["#fcd535", "#f0b90b"], icon: "shield" as const },
  { title: "Refer & Earn", sub: "Get 20% commission on every trade", grad: ["#a06af5", "#5b8def"], icon: "gift" as const },
  { title: "Earn up to 12% APY", sub: "Stake your crypto, earn passive income", grad: ["#0ecb81", "#00c2ff"], icon: "trending-up" as const },
];

export default function HomeScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { user, apiWallets, inrUsdtRate } = useApp();
  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 84 : 90;

  const { data: marketsData = [] } = useQuery({
    queryKey: ["home-markets"],
    queryFn: marketApi.getMarkets,
    refetchInterval: 30000,
  });

  const totalInr = useMemo(() => {
    if (!user?.isLoggedIn) return 0;
    return (apiWallets || []).reduce((s: number, w: any) => s + Number(w.inrValue || 0), 0);
  }, [apiWallets, user]);

  const hot = useMemo(() =>
    [...marketsData].sort((a: any, b: any) => Math.abs(b.change24h) - Math.abs(a.change24h)).slice(0, 8)
  , [marketsData]);

  const gainers = useMemo(() =>
    [...marketsData].filter((c: any) => c.change24h > 0).sort((a: any, b: any) => b.change24h - a.change24h).slice(0, 5)
  , [marketsData]);

  const losers = useMemo(() =>
    [...marketsData].filter((c: any) => c.change24h < 0).sort((a: any, b: any) => a.change24h - b.change24h).slice(0, 5)
  , [marketsData]);

  const formatPrice = (p: number, quote: string) => {
    const sym = quote === "INR" ? "₹" : "$";
    const loc = quote === "INR" ? "en-IN" : "en-US";
    return `${sym}${p.toLocaleString(loc, { minimumFractionDigits: p < 1 ? 4 : 2, maximumFractionDigits: p < 1 ? 6 : 2 })}`;
  };

  const goLogin = () => {
    Haptics.selectionAsync();
    router.push("/(auth)/login");
  };

  const goAction = (route: string) => {
    Haptics.selectionAsync();
    if (!user?.isLoggedIn) { router.push("/(auth)/login"); return; }
    router.push(route as any);
  };

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: colors.background }]}
      contentContainerStyle={{ paddingTop: topPad, paddingBottom: bottomPad }}
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <View style={styles.header}>
        <View style={{ flex: 1 }}>
          <Text style={[styles.greeting, { color: colors.mutedForeground }]}>
            {user?.isLoggedIn ? "Welcome back" : "Welcome to"}
          </Text>
          <Text style={[styles.brand, { color: colors.primary }]}>
            {user?.isLoggedIn ? (user.name || user.email?.split("@")[0]) : "CryptoX"}
          </Text>
        </View>
        <TouchableOpacity onPress={() => router.push("/services/notifications" as any)} style={[styles.iconBtn, { backgroundColor: colors.card }]}>
          <Feather name="bell" size={18} color={colors.foreground} />
        </TouchableOpacity>
        <TouchableOpacity onPress={() => router.push("/services/scan" as any)} style={[styles.iconBtn, { backgroundColor: colors.card }]}>
          <Feather name="maximize" size={18} color={colors.foreground} />
        </TouchableOpacity>
      </View>

      {/* Asset Card / Login CTA */}
      {user?.isLoggedIn ? (
        <TouchableOpacity activeOpacity={0.85} onPress={() => router.push("/(tabs)/wallet")}
          style={[styles.assetCard, { backgroundColor: colors.card, borderColor: colors.border }]}>
          <View style={styles.assetTop}>
            <Text style={[styles.assetLabel, { color: colors.mutedForeground }]}>Total Assets (INR)</Text>
            <Feather name="eye" size={14} color={colors.mutedForeground} />
          </View>
          <Text style={[styles.assetValue, { color: colors.foreground }]}>
            ₹{totalInr.toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
          </Text>
          <Text style={[styles.assetSub, { color: colors.mutedForeground }]}>
            ≈ ${(totalInr / (inrUsdtRate || 95)).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })} USDT
          </Text>
          <View style={styles.assetActions}>
            <TouchableOpacity onPress={() => router.push("/services/deposit-inr" as any)} style={[styles.assetBtn, { backgroundColor: colors.primary }]}>
              <Text style={[styles.assetBtnTxt, { color: "#000" }]}>Deposit</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => router.push("/services/withdraw-inr" as any)} style={[styles.assetBtn, { backgroundColor: colors.secondary }]}>
              <Text style={[styles.assetBtnTxt, { color: colors.foreground }]}>Withdraw</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => router.push("/services/transfer" as any)} style={[styles.assetBtn, { backgroundColor: colors.secondary }]}>
              <Text style={[styles.assetBtnTxt, { color: colors.foreground }]}>Transfer</Text>
            </TouchableOpacity>
          </View>
        </TouchableOpacity>
      ) : (
        <TouchableOpacity onPress={goLogin} style={[styles.loginCta, { backgroundColor: colors.primary }]}>
          <View>
            <Text style={[styles.loginCtaTitle, { color: "#000" }]}>Login or Sign Up</Text>
            <Text style={[styles.loginCtaSub, { color: "#000a" }]}>Start trading INR & USDT pairs</Text>
          </View>
          <Feather name="arrow-right-circle" size={26} color="#000" />
        </TouchableOpacity>
      )}

      {/* Quick Actions */}
      <View style={[styles.actionsGrid, { backgroundColor: colors.card }]}>
        {QUICK_ACTIONS.map(a => (
          <TouchableOpacity key={a.label} onPress={() => goAction(a.route)} style={styles.actionItem}>
            <View style={[styles.actionIcon, { backgroundColor: a.color + "22" }]}>
              <Feather name={a.icon as any} size={18} color={a.color} />
            </View>
            <Text style={[styles.actionLabel, { color: colors.foreground }]}>{a.label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Banner Carousel */}
      <FlatList
        horizontal
        data={BANNERS}
        keyExtractor={(b) => b.title}
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.bannerList}
        renderItem={({ item }) => (
          <View style={[styles.banner, { backgroundColor: item.grad[0] }]}>
            <View style={{ flex: 1 }}>
              <Text style={styles.bannerTitle}>{item.title}</Text>
              <Text style={styles.bannerSub}>{item.sub}</Text>
            </View>
            <Feather name={item.icon} size={36} color="#0007" />
          </View>
        )}
      />

      {/* Hot Coins */}
      <View style={styles.section}>
        <View style={styles.sectionHead}>
          <View style={styles.sectionTitleRow}>
            <Text style={styles.fire}>🔥</Text>
            <Text style={[styles.sectionTitle, { color: colors.foreground }]}>Hot Coins</Text>
          </View>
          <TouchableOpacity onPress={() => router.push("/(tabs)/markets")}>
            <Text style={[styles.seeAll, { color: colors.primary }]}>See All →</Text>
          </TouchableOpacity>
        </View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ paddingHorizontal: 14 }}>
          {hot.map((c: any) => (
            <TouchableOpacity key={c.symbol} onPress={() => router.push(`/(tabs)/trade?pair=${c.symbol}` as any)}
              style={[styles.hotCard, { backgroundColor: colors.card, borderColor: colors.border }]}>
              <View style={styles.hotTop}>
                <View style={[styles.coinDot, { backgroundColor: (COIN_COLORS[c.base] || "#888") + "33" }]}>
                  <Text style={[styles.coinDotTxt, { color: COIN_COLORS[c.base] || "#888" }]}>{(c.base || "?")[0]}</Text>
                </View>
                <Text style={[styles.hotSym, { color: colors.foreground }]}>{c.base}</Text>
              </View>
              <Text style={[styles.hotPrice, { color: colors.foreground }]}>{formatPrice(c.price, c.quote)}</Text>
              <Text style={[styles.hotChange, { color: c.change24h >= 0 ? colors.success : colors.destructive }]}>
                {c.change24h >= 0 ? "+" : ""}{c.change24h.toFixed(2)}%
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Top Gainers */}
      <View style={styles.section}>
        <View style={styles.sectionHead}>
          <View style={styles.sectionTitleRow}>
            <Feather name="trending-up" size={16} color={colors.success} />
            <Text style={[styles.sectionTitle, { color: colors.foreground, marginLeft: 6 }]}>Top Gainers</Text>
          </View>
          <TouchableOpacity onPress={() => router.push("/(tabs)/markets")}>
            <Text style={[styles.seeAll, { color: colors.primary }]}>See All →</Text>
          </TouchableOpacity>
        </View>
        <View style={[styles.listCard, { backgroundColor: colors.card, borderColor: colors.border }]}>
          {gainers.length === 0 && <Text style={[styles.empty, { color: colors.mutedForeground }]}>No gainers right now</Text>}
          {gainers.map((c: any, i: number) => (
            <TouchableOpacity key={c.symbol} onPress={() => router.push(`/(tabs)/trade?pair=${c.symbol}` as any)}
              style={[styles.row, { borderBottomColor: colors.border, borderBottomWidth: i === gainers.length - 1 ? 0 : StyleSheet.hairlineWidth }]}>
              <View style={[styles.coinDot, { backgroundColor: (COIN_COLORS[c.base] || "#888") + "33" }]}>
                <Text style={[styles.coinDotTxt, { color: COIN_COLORS[c.base] || "#888" }]}>{(c.base || "?")[0]}</Text>
              </View>
              <View style={{ flex: 1 }}>
                <Text style={[styles.rowSym, { color: colors.foreground }]}>{c.base}<Text style={{ color: colors.mutedForeground }}>/{c.quote}</Text></Text>
                <Text style={[styles.rowVol, { color: colors.mutedForeground }]}>Vol {(c.volume24h / 1e6).toFixed(2)}M</Text>
              </View>
              <View style={{ alignItems: "flex-end" }}>
                <Text style={[styles.rowPrice, { color: colors.foreground }]}>{formatPrice(c.price, c.quote)}</Text>
                <Text style={[styles.rowChange, { color: colors.success }]}>+{c.change24h.toFixed(2)}%</Text>
              </View>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Top Losers */}
      <View style={styles.section}>
        <View style={styles.sectionHead}>
          <View style={styles.sectionTitleRow}>
            <Feather name="trending-down" size={16} color={colors.destructive} />
            <Text style={[styles.sectionTitle, { color: colors.foreground, marginLeft: 6 }]}>Top Losers</Text>
          </View>
          <TouchableOpacity onPress={() => router.push("/(tabs)/markets")}>
            <Text style={[styles.seeAll, { color: colors.primary }]}>See All →</Text>
          </TouchableOpacity>
        </View>
        <View style={[styles.listCard, { backgroundColor: colors.card, borderColor: colors.border }]}>
          {losers.length === 0 && <Text style={[styles.empty, { color: colors.mutedForeground }]}>No losers right now</Text>}
          {losers.map((c: any, i: number) => (
            <TouchableOpacity key={c.symbol} onPress={() => router.push(`/(tabs)/trade?pair=${c.symbol}` as any)}
              style={[styles.row, { borderBottomColor: colors.border, borderBottomWidth: i === losers.length - 1 ? 0 : StyleSheet.hairlineWidth }]}>
              <View style={[styles.coinDot, { backgroundColor: (COIN_COLORS[c.base] || "#888") + "33" }]}>
                <Text style={[styles.coinDotTxt, { color: COIN_COLORS[c.base] || "#888" }]}>{(c.base || "?")[0]}</Text>
              </View>
              <View style={{ flex: 1 }}>
                <Text style={[styles.rowSym, { color: colors.foreground }]}>{c.base}<Text style={{ color: colors.mutedForeground }}>/{c.quote}</Text></Text>
                <Text style={[styles.rowVol, { color: colors.mutedForeground }]}>Vol {(c.volume24h / 1e6).toFixed(2)}M</Text>
              </View>
              <View style={{ alignItems: "flex-end" }}>
                <Text style={[styles.rowPrice, { color: colors.foreground }]}>{formatPrice(c.price, c.quote)}</Text>
                <Text style={[styles.rowChange, { color: colors.destructive }]}>{c.change24h.toFixed(2)}%</Text>
              </View>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* News / Announcements */}
      <View style={styles.section}>
        <View style={styles.sectionHead}>
          <View style={styles.sectionTitleRow}>
            <Feather name="bell" size={16} color={colors.primary} />
            <Text style={[styles.sectionTitle, { color: colors.foreground, marginLeft: 6 }]}>Announcements</Text>
          </View>
        </View>
        <View style={[styles.listCard, { backgroundColor: colors.card, borderColor: colors.border, padding: 14 }]}>
          <Text style={[styles.newsTitle, { color: colors.foreground }]}>Welcome to CryptoX Exchange</Text>
          <Text style={[styles.newsBody, { color: colors.mutedForeground }]}>
            Trade INR & USDT pairs with industry-leading fees. KYC-verified traders enjoy lower fees and higher limits.
          </Text>
          <Text style={[styles.newsTime, { color: colors.mutedForeground }]}>Today</Text>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { flexDirection: "row", alignItems: "center", paddingHorizontal: 16, paddingBottom: 10, gap: 8 },
  greeting: { fontSize: 12, fontFamily: "Inter_400Regular" },
  brand: { fontSize: 22, fontFamily: "Inter_700Bold", marginTop: 2 },
  iconBtn: { width: 36, height: 36, borderRadius: 18, alignItems: "center", justifyContent: "center" },

  loginCta: { marginHorizontal: 14, marginTop: 6, padding: 16, borderRadius: 14, flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  loginCtaTitle: { fontSize: 16, fontFamily: "Inter_700Bold" },
  loginCtaSub: { fontSize: 12, fontFamily: "Inter_400Regular", marginTop: 2 },

  assetCard: { marginHorizontal: 14, marginTop: 6, padding: 16, borderRadius: 14, borderWidth: StyleSheet.hairlineWidth },
  assetTop: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  assetLabel: { fontSize: 12, fontFamily: "Inter_500Medium" },
  assetValue: { fontSize: 24, fontFamily: "Inter_700Bold", marginTop: 6 },
  assetSub: { fontSize: 11, fontFamily: "Inter_400Regular", marginTop: 2 },
  assetActions: { flexDirection: "row", marginTop: 14, gap: 8 },
  assetBtn: { flex: 1, paddingVertical: 9, borderRadius: 8, alignItems: "center" },
  assetBtnTxt: { fontSize: 12, fontFamily: "Inter_600SemiBold" },

  actionsGrid: { marginHorizontal: 14, marginTop: 12, paddingVertical: 14, borderRadius: 14, flexDirection: "row", flexWrap: "wrap" },
  actionItem: { width: "25%", alignItems: "center", marginBottom: 12 },
  actionIcon: { width: 42, height: 42, borderRadius: 21, alignItems: "center", justifyContent: "center", marginBottom: 6 },
  actionLabel: { fontSize: 11, fontFamily: "Inter_500Medium" },

  bannerList: { paddingHorizontal: 14, paddingVertical: 12, gap: 10 },
  banner: { width: 280, padding: 14, borderRadius: 12, marginRight: 10, flexDirection: "row", alignItems: "center" },
  bannerTitle: { fontSize: 14, fontFamily: "Inter_700Bold", color: "#000" },
  bannerSub: { fontSize: 11, fontFamily: "Inter_400Regular", color: "#000a", marginTop: 4 },

  section: { marginTop: 6 },
  sectionHead: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", paddingHorizontal: 16, marginBottom: 8, marginTop: 6 },
  sectionTitleRow: { flexDirection: "row", alignItems: "center" },
  sectionTitle: { fontSize: 15, fontFamily: "Inter_700Bold" },
  fire: { fontSize: 16 },
  seeAll: { fontSize: 12, fontFamily: "Inter_500Medium" },

  hotCard: { width: 130, padding: 12, borderRadius: 12, borderWidth: StyleSheet.hairlineWidth, marginRight: 10 },
  hotTop: { flexDirection: "row", alignItems: "center", marginBottom: 8 },
  hotSym: { fontSize: 13, fontFamily: "Inter_600SemiBold", marginLeft: 8 },
  hotPrice: { fontSize: 13, fontFamily: "Inter_700Bold" },
  hotChange: { fontSize: 11, fontFamily: "Inter_500Medium", marginTop: 2 },

  listCard: { marginHorizontal: 14, borderRadius: 12, borderWidth: StyleSheet.hairlineWidth },
  row: { flexDirection: "row", alignItems: "center", paddingHorizontal: 14, paddingVertical: 12, gap: 10 },
  coinDot: { width: 30, height: 30, borderRadius: 15, alignItems: "center", justifyContent: "center" },
  coinDotTxt: { fontSize: 13, fontFamily: "Inter_700Bold" },
  rowSym: { fontSize: 13, fontFamily: "Inter_600SemiBold" },
  rowVol: { fontSize: 10, fontFamily: "Inter_400Regular", marginTop: 2 },
  rowPrice: { fontSize: 13, fontFamily: "Inter_600SemiBold" },
  rowChange: { fontSize: 11, fontFamily: "Inter_500Medium", marginTop: 2 },
  empty: { textAlign: "center", padding: 18, fontSize: 12 },

  newsTitle: { fontSize: 13, fontFamily: "Inter_600SemiBold" },
  newsBody: { fontSize: 12, fontFamily: "Inter_400Regular", marginTop: 6, lineHeight: 17 },
  newsTime: { fontSize: 10, fontFamily: "Inter_400Regular", marginTop: 8 },
});
