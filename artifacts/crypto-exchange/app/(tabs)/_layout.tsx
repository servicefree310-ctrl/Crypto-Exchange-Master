import { BlurView } from "expo-blur";
import { isLiquidGlassAvailable } from "expo-glass-effect";
import { Tabs } from "expo-router";
import { Icon, Label, NativeTabs } from "expo-router/unstable-native-tabs";
import { SymbolView } from "expo-symbols";
import { MaterialCommunityIcons, Ionicons, Feather, MaterialIcons } from "@expo/vector-icons";
import React from "react";
import { Platform, StyleSheet, View, useColorScheme } from "react-native";
import { useColors } from "@/hooks/useColors";

function NativeTabLayout() {
  return (
    <NativeTabs>
      <NativeTabs.Trigger name="index">
        <Icon sf={{ default: "house", selected: "house.fill" }} />
        <Label>Home</Label>
      </NativeTabs.Trigger>
      <NativeTabs.Trigger name="markets">
        <Icon sf={{ default: "chart.bar", selected: "chart.bar.fill" }} />
        <Label>Markets</Label>
      </NativeTabs.Trigger>
      <NativeTabs.Trigger name="trade">
        <Icon sf={{ default: "arrow.left.arrow.right", selected: "arrow.left.arrow.right" }} />
        <Label>Trade</Label>
      </NativeTabs.Trigger>
      <NativeTabs.Trigger name="wallet">
        <Icon sf={{ default: "wallet.pass", selected: "wallet.pass.fill" }} />
        <Label>Wallet</Label>
      </NativeTabs.Trigger>
      <NativeTabs.Trigger name="account">
        <Icon sf={{ default: "person", selected: "person.fill" }} />
        <Label>Account</Label>
      </NativeTabs.Trigger>
    </NativeTabs>
  );
}

function ClassicTabLayout() {
  const colors = useColors();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";
  const isIOS = Platform.OS === "ios";
  const isWeb = Platform.OS === "web";

  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.mutedForeground,
        headerShown: false,
        tabBarStyle: {
          position: "absolute",
          backgroundColor: isIOS ? "transparent" : colors.card,
          borderTopWidth: 1,
          borderTopColor: colors.border,
          elevation: 0,
          height: isWeb ? 84 : 64,
          paddingBottom: isWeb ? 34 : 8,
        },
        tabBarLabelStyle: {
          fontFamily: 'Inter_500Medium',
          fontSize: 10,
        },
        tabBarBackground: () =>
          isIOS ? (
            <BlurView intensity={100} tint={isDark ? "dark" : "light"} style={StyleSheet.absoluteFill} />
          ) : null,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Home",
          tabBarIcon: ({ color }) =>
            isIOS ? <SymbolView name="house" tintColor={color} size={22} /> : <Feather name="home" size={22} color={color} />,
        }}
      />
      <Tabs.Screen
        name="markets"
        options={{
          title: "Markets",
          tabBarIcon: ({ color }) =>
            isIOS ? <SymbolView name="chart.bar" tintColor={color} size={22} /> : <Ionicons name="bar-chart" size={22} color={color} />,
        }}
      />
      <Tabs.Screen
        name="trade"
        options={{
          title: "Trade",
          tabBarIcon: ({ color, focused }) => (
            <View style={{
              backgroundColor: focused ? colors.primary : colors.secondary,
              borderRadius: 12,
              width: 40, height: 40,
              alignItems: 'center', justifyContent: 'center',
              marginTop: -8,
            }}>
              <MaterialCommunityIcons name="swap-horizontal" size={24} color={focused ? '#000' : color} />
            </View>
          ),
        }}
      />
      <Tabs.Screen
        name="wallet"
        options={{
          title: "Wallet",
          tabBarIcon: ({ color }) =>
            isIOS ? <SymbolView name="wallet.pass" tintColor={color} size={22} /> : <MaterialIcons name="account-balance-wallet" size={22} color={color} />,
        }}
      />
      <Tabs.Screen
        name="account"
        options={{
          title: "Account",
          tabBarIcon: ({ color }) =>
            isIOS ? <SymbolView name="person" tintColor={color} size={22} /> : <MaterialIcons name="person" size={22} color={color} />,
        }}
      />
    </Tabs>
  );
}

export default function TabLayout() {
  if (isLiquidGlassAvailable()) {
    return <NativeTabLayout />;
  }
  return <ClassicTabLayout />;
}
