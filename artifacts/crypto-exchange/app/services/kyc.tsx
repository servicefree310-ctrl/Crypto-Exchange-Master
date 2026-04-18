import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, Alert } from 'react-native';
import { Header } from '@/components/Header';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { Feather, MaterialCommunityIcons } from '@expo/vector-icons';

export default function Kyc() {
  const colors = useColors();
  const { user, kycLevels, setUser } = useApp();
  const [upgrading, setUpgrading] = useState<number | null>(null);

  const handleUpgrade = (level: number) => {
    Alert.alert(
      `Upgrade to Level ${level}`,
      `Submit documents for verification. Approval takes 24-48 hours.`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Submit', onPress: () => {
          setUser({ kycLevel: level as any, kycStatus: 'under_review' });
          Alert.alert('Submitted', 'Documents under review');
        }},
      ]
    );
  };

  const s = styles(colors);
  return (
    <SafeAreaView style={s.container}>
      <Header title="KYC Verification" subtitle="Complete identity verification" />
      <ScrollView contentContainerStyle={s.content}>
        {/* Current Status */}
        <View style={s.statusCard}>
          <View style={[s.statusIcon, { backgroundColor: user.kycStatus === 'verified' ? colors.success + '22' : colors.warning + '22' }]}>
            <Feather name={user.kycStatus === 'verified' ? 'check-circle' : 'clock'} size={28} color={user.kycStatus === 'verified' ? colors.success : colors.warning} />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={s.statusTitle}>Level {user.kycLevel} - {kycLevels[user.kycLevel]?.name}</Text>
            <Text style={[s.statusBadge, { color: user.kycStatus === 'verified' ? colors.success : colors.warning }]}>
              {user.kycStatus === 'verified' ? '✓ Verified' : user.kycStatus.replace('_', ' ').toUpperCase()}
            </Text>
          </View>
        </View>

        {/* Levels */}
        <Text style={s.sectionTitle}>Verification Levels</Text>
        {kycLevels.filter(l => l.level > 0).map(level => {
          const isCurrent = level.level === user.kycLevel;
          const isCompleted = level.level <= user.kycLevel;
          const canUpgrade = level.level === user.kycLevel + 1;
          return (
            <View key={level.level} style={[s.levelCard, isCurrent && { borderColor: colors.primary, backgroundColor: colors.primary + '08' }]}>
              <View style={s.levelHeader}>
                <View style={[s.levelBadge, { backgroundColor: isCompleted ? colors.success : colors.secondary }]}>
                  {isCompleted ? <Feather name="check" size={14} color="#fff" /> : <Text style={[s.levelBadgeText, { color: colors.foreground }]}>{level.level}</Text>}
                </View>
                <View style={{ flex: 1, marginLeft: 12 }}>
                  <Text style={s.levelTitle}>{level.name}</Text>
                  <Text style={s.levelSub}>Level {level.level}</Text>
                </View>
                {isCurrent && <View style={s.activePill}><Text style={s.activeText}>ACTIVE</Text></View>}
              </View>

              <View style={s.limitsBox}>
                <View style={s.limitItem}>
                  <Text style={s.limitLbl}>Daily Withdraw</Text>
                  <Text style={s.limitVal}>₹{level.withdrawLimitDaily.toLocaleString('en-IN')}</Text>
                </View>
                <View style={s.limitItem}>
                  <Text style={s.limitLbl}>Monthly Withdraw</Text>
                  <Text style={s.limitVal}>₹{(level.withdrawLimitMonthly / 100000).toFixed(0)}L</Text>
                </View>
                <View style={s.limitItem}>
                  <Text style={s.limitLbl}>Deposit Limit</Text>
                  <Text style={s.limitVal}>₹{(level.depositLimit / 100000).toFixed(0)}L</Text>
                </View>
              </View>

              <Text style={s.featTitle}>Features Unlocked</Text>
              {level.features.map((f, i) => (
                <View key={i} style={s.featRow}>
                  <Feather name="check-circle" size={12} color={colors.success} />
                  <Text style={s.featText}>{f}</Text>
                </View>
              ))}

              <Text style={[s.featTitle, { marginTop: 10 }]}>Required Documents</Text>
              {level.required.map((r, i) => (
                <View key={i} style={s.featRow}>
                  <MaterialCommunityIcons name="file-document-outline" size={13} color={colors.mutedForeground} />
                  <Text style={[s.featText, { color: colors.mutedForeground }]}>{r}</Text>
                </View>
              ))}

              {canUpgrade && (
                <TouchableOpacity style={[s.upgradeBtn, { backgroundColor: colors.primary }]} onPress={() => handleUpgrade(level.level)}>
                  <Text style={[s.upgradeText, { color: '#000' }]}>Upgrade to Level {level.level}</Text>
                </TouchableOpacity>
              )}
              {isCompleted && !isCurrent && (
                <View style={[s.completedBtn, { backgroundColor: colors.success + '20' }]}>
                  <Feather name="check" size={14} color={colors.success} />
                  <Text style={[s.completedText, { color: colors.success }]}>Completed</Text>
                </View>
              )}
            </View>
          );
        })}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (c: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: c.background },
  content: { padding: 16, paddingBottom: 60 },
  statusCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: c.card, borderRadius: 14, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: c.border },
  statusIcon: { width: 52, height: 52, borderRadius: 26, alignItems: 'center', justifyContent: 'center', marginRight: 14 },
  statusTitle: { fontSize: 14, color: c.foreground, fontFamily: 'Inter_700Bold' },
  statusBadge: { fontSize: 12, fontFamily: 'Inter_600SemiBold', marginTop: 4 },
  sectionTitle: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_700Bold', marginBottom: 10, textTransform: 'uppercase' },
  levelCard: { backgroundColor: c.card, borderRadius: 14, padding: 16, marginBottom: 12, borderWidth: 1, borderColor: c.border },
  levelHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 14 },
  levelBadge: { width: 28, height: 28, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  levelBadgeText: { fontSize: 13, fontFamily: 'Inter_700Bold' },
  levelTitle: { fontSize: 15, color: c.foreground, fontFamily: 'Inter_700Bold' },
  levelSub: { fontSize: 11, color: c.mutedForeground, marginTop: 2 },
  activePill: { backgroundColor: c.primary, borderRadius: 5, paddingHorizontal: 8, paddingVertical: 4 },
  activeText: { fontSize: 9, color: '#000', fontFamily: 'Inter_700Bold' },
  limitsBox: { flexDirection: 'row', backgroundColor: c.secondary, borderRadius: 10, padding: 12, marginBottom: 14 },
  limitItem: { flex: 1, alignItems: 'center' },
  limitLbl: { fontSize: 10, color: c.mutedForeground, fontFamily: 'Inter_500Medium', textTransform: 'uppercase' },
  limitVal: { fontSize: 13, color: c.foreground, fontFamily: 'Inter_700Bold', marginTop: 4 },
  featTitle: { fontSize: 11, color: c.mutedForeground, fontFamily: 'Inter_700Bold', textTransform: 'uppercase', marginBottom: 8 },
  featRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 5 },
  featText: { fontSize: 12, color: c.foreground, fontFamily: 'Inter_400Regular' },
  upgradeBtn: { borderRadius: 8, paddingVertical: 11, alignItems: 'center', marginTop: 14 },
  upgradeText: { fontSize: 13, fontFamily: 'Inter_700Bold' },
  completedBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, borderRadius: 8, paddingVertical: 9, marginTop: 14 },
  completedText: { fontSize: 12, fontFamily: 'Inter_700Bold' },
});
