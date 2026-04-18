import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  SafeAreaView, Platform, Switch, Alert, TextInput
} from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';
import { MaterialIcons, Feather, MaterialCommunityIcons, Ionicons } from '@expo/vector-icons';
import { useApp as useAppHook } from '@/context/AppContext';
import { LoginRequired } from '@/components/LoginRequired';

type AccountTab = 'profile' | 'kyc' | 'security' | 'subscription' | 'refer' | 'bank' | 'tds' | 'settings';

export default function AccountScreen() {
  const colors = useColors();
  const { user, setUser, logout, theme, setTheme, language, setLanguage, loginLogs, activeSessions, apiBanks, addBankApi, removeBankApi, refreshBanks, botEnabled, setBotEnabled } = useApp();
  const router = useRouter();
  const params = useLocalSearchParams<{ tab?: string }>();
  const initialTab = (params.tab as AccountTab) || 'profile';
  const [tab, setTab] = useState<AccountTab>(initialTab);
  React.useEffect(() => { if (params.tab) setTab(params.tab as AccountTab); }, [params.tab]);
  const [addingBank, setAddingBank] = useState(false);
  const [bankHolder, setBankHolder] = useState('');
  const [bankAcct, setBankAcct] = useState('');
  const [bankIFSC, setBankIFSC] = useState('');
  const [bankName, setBankName] = useState('');

  const s = styles(colors);
  const topPadding = Platform.OS === 'web' ? 80 : 0;

  const subLevels = [
    { level: 0, name: 'Basic', fee: '0.5%', withdrawLimit: '₹1L/day', color: '#848E9C' },
    { level: 1, name: 'Silver', fee: '0.25%', withdrawLimit: '₹5L/day', color: '#C0C0C0' },
    { level: 2, name: 'Gold', fee: '0.15%', withdrawLimit: '₹20L/day', color: '#F0B90B' },
    { level: 3, name: 'Platinum', fee: '0.1%', withdrawLimit: 'Unlimited', color: '#7DF9FF' },
  ];

  const [bankSubmitting, setBankSubmitting] = useState(false);

  React.useEffect(() => { if (user.isLoggedIn && tab === 'bank') refreshBanks(); }, [user.isLoggedIn, tab]);

  if (!user.isLoggedIn) return <LoginRequired feature="your account" />;

  const handleAddBank = async () => {
    if (!bankHolder || !bankAcct || !bankIFSC || !bankName) { Alert.alert('Error', 'Fill all fields'); return; }
    setBankSubmitting(true);
    try {
      await addBankApi({ holderName: bankHolder, accountNumber: bankAcct, ifsc: bankIFSC, bankName });
      setAddingBank(false);
      setBankHolder(''); setBankAcct(''); setBankIFSC(''); setBankName('');
      if (Platform.OS !== 'web') Alert.alert('Submitted', 'Bank added! Under review (24-48 hrs)');
    } catch (e: any) {
      Alert.alert('Error', e?.message || 'Failed to add bank');
    } finally {
      setBankSubmitting(false);
    }
  };

  const handleRemoveBank = (id: number) => {
    const confirmAndRemove = async () => {
      try { await removeBankApi(id); }
      catch (e: any) { Alert.alert('Error', e?.message || 'Failed to remove bank'); }
    };
    if (Platform.OS === 'web') { confirmAndRemove(); return; }
    Alert.alert('Remove Bank', 'Are you sure?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Remove', style: 'destructive', onPress: confirmAndRemove },
    ]);
  };

  const menuItems: { key: AccountTab; icon: string; label: string; iconLib?: 'feather' | 'material' | 'mi' }[] = [
    { key: 'profile', icon: 'person', label: 'Profile', iconLib: 'material' },
    { key: 'kyc', icon: 'verified-user', label: 'KYC Verification', iconLib: 'material' },
    { key: 'security', icon: 'shield', label: 'Security', iconLib: 'feather' },
    { key: 'subscription', icon: 'star', label: 'Subscription', iconLib: 'feather' },
    { key: 'refer', icon: 'gift', label: 'Refer & Earn', iconLib: 'feather' },
    { key: 'bank', icon: 'account-balance', label: 'Bank Accounts', iconLib: 'material' },
    { key: 'tds', icon: 'receipt', label: 'TDS Report', iconLib: 'material' },
    { key: 'settings', icon: 'settings', label: 'Settings', iconLib: 'feather' },
  ];

  return (
    <SafeAreaView style={s.container}>
      <ScrollView contentContainerStyle={[s.scroll, { paddingTop: topPadding }]} showsVerticalScrollIndicator={false}>
        <Text style={s.title}>Account</Text>

        {/* User Card */}
        <View style={s.userCard}>
          <View style={s.avatar}>
            <Text style={s.avatarText}>{user.name.charAt(0)}</Text>
          </View>
          <View style={s.userInfo}>
            <Text style={s.userName}>{user.name}</Text>
            <Text style={s.userEmail}>{user.email}</Text>
            <Text style={s.userUID}>UID: {user.uid}</Text>
          </View>
          <View style={[s.kycBadge, { backgroundColor: user.kycStatus === 'verified' ? colors.success + '22' : '#F0B90B22' }]}>
            <Text style={[s.kycBadgeText, { color: user.kycStatus === 'verified' ? colors.success : '#F0B90B' }]}>
              {user.kycStatus === 'verified' ? 'KYC Verified' : user.kycStatus === 'under_review' ? 'Under Review' : 'KYC Pending'}
            </Text>
          </View>
        </View>

        {/* Menu */}
        <View style={s.menuGrid}>
          {menuItems.map(item => (
            <TouchableOpacity key={item.key} style={[s.menuItem, tab === item.key && { borderColor: colors.primary, backgroundColor: colors.primary + '0D' }]} onPress={() => setTab(item.key)}>
              {item.iconLib === 'material' ? <MaterialIcons name={item.icon as any} size={20} color={tab === item.key ? colors.primary : colors.foreground} /> :
               <Feather name={item.icon as any} size={20} color={tab === item.key ? colors.primary : colors.foreground} />}
              <Text style={[s.menuLabel, tab === item.key && { color: colors.primary }]}>{item.label}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Content */}
        <View style={s.contentCard}>

          {/* Profile */}
          {tab === 'profile' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>Profile Information</Text>
              {[
                { label: 'Full Name', value: user.name, icon: 'person' },
                { label: 'Email', value: user.email, icon: 'email' },
                { label: 'Phone', value: user.phone, icon: 'phone' },
                { label: 'UID', value: user.uid, icon: 'fingerprint' },
                { label: 'Subscription', value: `Level ${user.subscriptionLevel} - ${subLevels[user.subscriptionLevel].name}`, icon: 'star' },
              ].map(({ label, value, icon }) => (
                <View key={label} style={s.profileRow}>
                  <MaterialIcons name={icon as any} size={16} color={colors.mutedForeground} />
                  <View style={{ flex: 1 }}>
                    <Text style={s.profileLabel}>{label}</Text>
                    <Text style={s.profileValue}>{value}</Text>
                  </View>
                </View>
              ))}
            </View>
          )}

          {/* KYC */}
          {tab === 'kyc' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>KYC Verification</Text>
              <View style={[s.kycStatus, { borderColor: user.kycStatus === 'verified' ? colors.success : user.kycStatus === 'rejected' ? colors.danger : '#F0B90B' }]}>
                <MaterialIcons name="verified-user" size={32} color={user.kycStatus === 'verified' ? colors.success : user.kycStatus === 'rejected' ? colors.danger : '#F0B90B'} />
                <Text style={[s.kycStatusText, { color: user.kycStatus === 'verified' ? colors.success : user.kycStatus === 'rejected' ? colors.danger : '#F0B90B' }]}>
                  {user.kycStatus === 'verified' ? 'KYC Verified' : user.kycStatus === 'under_review' ? 'Under Review' : user.kycStatus === 'rejected' ? 'Rejected' : 'Not Started'}
                </Text>
                <Text style={s.kycStatusDesc}>
                  {user.kycStatus === 'verified' ? 'Your identity is verified. Full trading access enabled.' :
                   user.kycStatus === 'under_review' ? 'Documents submitted. Verification in 24-48 hours.' :
                   user.kycStatus === 'rejected' ? 'Documents rejected. Please resubmit with clear images.' :
                   'Complete KYC to increase limits and unlock features.'}
                </Text>
              </View>
              {user.kycStatus !== 'verified' && (
                <TouchableOpacity style={s.kycBtn} onPress={() => Alert.alert('KYC', 'Complete KYC: Submit Aadhaar, PAN, and selfie')}>
                  <Text style={s.kycBtnText}>{user.kycStatus === 'rejected' ? 'Resubmit KYC' : 'Start KYC'}</Text>
                </TouchableOpacity>
              )}
              <Text style={s.kycStepsTitle}>Required Documents:</Text>
              {['Aadhaar Card (Front & Back)', 'PAN Card', 'Live Selfie', 'Bank Statement (optional)'].map(d => (
                <View key={d} style={s.kycDoc}>
                  <MaterialIcons name="check-circle" size={16} color={user.kycStatus === 'verified' ? colors.success : colors.mutedForeground} />
                  <Text style={s.kycDocText}>{d}</Text>
                </View>
              ))}
            </View>
          )}

          {/* Security */}
          {tab === 'security' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>Security Settings</Text>
              {[
                { label: '2FA Authentication', sublabel: 'Google Authenticator', enabled: true },
                { label: 'Biometric Login', sublabel: 'Fingerprint / Face ID', enabled: true },
                { label: 'Anti-Phishing Code', sublabel: 'Set a code for emails', enabled: false },
                { label: 'Login Notifications', sublabel: 'Email alerts on new login', enabled: true },
              ].map(({ label, sublabel, enabled }) => (
                <View key={label} style={s.securityRow}>
                  <View style={{ flex: 1 }}>
                    <Text style={s.securityLabel}>{label}</Text>
                    <Text style={s.securitySublabel}>{sublabel}</Text>
                  </View>
                  <Switch value={enabled} onValueChange={() => {}} thumbColor={enabled ? colors.primary : colors.mutedForeground} trackColor={{ false: colors.border, true: colors.primary + '66' }} />
                </View>
              ))}

              <Text style={[s.sectionTitle, { marginTop: 20 }]}>Login History</Text>
              {loginLogs.map(log => (
                <View key={log.id} style={s.logRow}>
                  <View style={[s.logIcon, { backgroundColor: log.status === 'success' ? colors.success + '22' : colors.danger + '22' }]}>
                    <MaterialIcons name={log.status === 'success' ? 'check-circle' : 'cancel'} size={16} color={log.status === 'success' ? colors.success : colors.danger} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={s.logDevice}>{log.device}</Text>
                    <Text style={s.logLocation}>{log.location} • {log.ip}</Text>
                    <Text style={s.logTime}>{new Date(log.timestamp).toLocaleString('en-IN')}</Text>
                  </View>
                  <View style={[s.logBadge, { backgroundColor: log.status === 'success' ? colors.success + '22' : colors.danger + '22' }]}>
                    <Text style={[s.logBadgeText, { color: log.status === 'success' ? colors.success : colors.danger }]}>{log.status}</Text>
                  </View>
                </View>
              ))}

              <Text style={[s.sectionTitle, { marginTop: 20 }]}>Active Sessions</Text>
              {activeSessions.map(session => (
                <View key={session.id} style={s.sessionRow}>
                  <View style={s.sessionIcon}>
                    <MaterialCommunityIcons name={session.device.includes('iPhone') ? 'cellphone' : 'laptop'} size={20} color={colors.primary} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={s.sessionDevice}>{session.device}</Text>
                    <Text style={s.sessionLocation}>{session.location}</Text>
                    <Text style={s.sessionTime}>Last active: {session.isCurrent ? 'Now' : new Date(session.lastActive).toLocaleString('en-IN')}</Text>
                  </View>
                  {!session.isCurrent && (
                    <TouchableOpacity onPress={() => Alert.alert('Terminate', 'Session terminated')}>
                      <Feather name="x-circle" size={20} color={colors.danger} />
                    </TouchableOpacity>
                  )}
                </View>
              ))}
            </View>
          )}

          {/* Subscription */}
          {tab === 'subscription' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>Subscription Plans</Text>
              <Text style={s.subDesc}>Higher subscription = Lower fees + Higher limits</Text>
              {subLevels.map(sub => (
                <TouchableOpacity key={sub.level} style={[s.subCard, user.subscriptionLevel === sub.level && { borderColor: sub.color, borderWidth: 2 }]}>
                  <View style={[s.subBadge, { backgroundColor: sub.color + '22' }]}>
                    <Text style={[s.subBadgeText, { color: sub.color }]}>{sub.name}</Text>
                    {user.subscriptionLevel === sub.level && <Text style={[s.activeSub, { color: sub.color }]}>Active</Text>}
                  </View>
                  <View style={s.subDetails}>
                    <View style={s.subDetail}><Text style={s.subDetailLabel}>Trading Fee</Text><Text style={s.subDetailValue}>{sub.fee}</Text></View>
                    <View style={s.subDetail}><Text style={s.subDetailLabel}>Withdraw Limit</Text><Text style={s.subDetailValue}>{sub.withdrawLimit}</Text></View>
                    <View style={s.subDetail}><Text style={s.subDetailLabel}>TDS</Text><Text style={s.subDetailValue}>1% on sell</Text></View>
                  </View>
                  {user.subscriptionLevel !== sub.level && (
                    <TouchableOpacity style={[s.upgradeBtn, { backgroundColor: sub.color }]}>
                      <Text style={s.upgradeBtnText}>Upgrade to {sub.name}</Text>
                    </TouchableOpacity>
                  )}
                </TouchableOpacity>
              ))}
            </View>
          )}

          {/* Refer & Earn */}
          {tab === 'refer' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>Refer & Earn</Text>
              <TouchableOpacity onPress={() => router.push('/services/refer' as any)} style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', backgroundColor: colors.primary + '15', borderRadius: 10, padding: 12, marginBottom: 12 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                  <Feather name="external-link" size={16} color={colors.primary} />
                  <Text style={{ color: colors.primary, fontSize: 13, fontFamily: 'Inter_700Bold' }}>Open full referral dashboard</Text>
                </View>
                <Feather name="chevron-right" size={18} color={colors.primary} />
              </TouchableOpacity>
              <View style={s.referCard}>
                <MaterialCommunityIcons name="gift" size={40} color={colors.primary} />
                <Text style={s.referTitle}>Invite friends, earn rewards</Text>
                <Text style={s.referDesc}>Earn up to 30% of your referral's trading fee forever</Text>
                <View style={s.referCodeBox}>
                  <Text style={s.referCodeLabel}>Your Referral Code</Text>
                  <Text style={s.referCode}>{user.referralCode}</Text>
                  <TouchableOpacity style={s.copyBtn} onPress={() => Alert.alert('Copied', 'Referral code copied!')}>
                    <Feather name="copy" size={14} color={colors.primary} />
                    <Text style={s.copyBtnText}>Copy Code</Text>
                  </TouchableOpacity>
                </View>
                <View style={s.referStats}>
                  <View style={s.referStat}>
                    <Text style={s.referStatValue}>3</Text>
                    <Text style={s.referStatLabel}>Friends Referred</Text>
                  </View>
                  <View style={s.referStat}>
                    <Text style={s.referStatValue}>₹{user.referralEarnings.toLocaleString()}</Text>
                    <Text style={s.referStatLabel}>Total Earned</Text>
                  </View>
                  <View style={s.referStat}>
                    <Text style={s.referStatValue}>30%</Text>
                    <Text style={s.referStatLabel}>Commission Rate</Text>
                  </View>
                </View>
              </View>
              <Text style={s.referLevelsTitle}>3-Level Referral Program</Text>
              {[
                { level: 1, percent: '30%', desc: 'Direct referrals' },
                { level: 2, percent: '10%', desc: 'Referrals of referrals' },
                { level: 3, percent: '5%', desc: '3rd level referrals' },
              ].map(({ level, percent, desc }) => (
                <View key={level} style={s.levelRow}>
                  <View style={[s.levelBadge, { backgroundColor: colors.primary + '22' }]}>
                    <Text style={[s.levelText, { color: colors.primary }]}>L{level}</Text>
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={s.levelDesc}>{desc}</Text>
                  </View>
                  <Text style={s.levelPercent}>{percent}</Text>
                </View>
              ))}
            </View>
          )}

          {/* Bank */}
          {tab === 'bank' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>Bank Accounts</Text>
              {apiBanks.length === 0 && (
                <Text style={{ color: colors.mutedForeground, fontSize: 12, marginBottom: 8 }}>No bank accounts added yet.</Text>
              )}
              {apiBanks.map(bank => (
                <View key={bank.id} style={s.bankCard}>
                  <View style={s.bankHeader}>
                    <MaterialIcons name="account-balance" size={20} color={colors.primary} />
                    <Text style={s.bankNameText}>{bank.bankName}</Text>
                    <View style={[s.bankStatusBadge, { backgroundColor: bank.status === 'verified' ? colors.success + '22' : bank.status === 'rejected' ? colors.danger + '22' : '#F0B90B22' }]}>
                      <Text style={[s.bankStatusText, { color: bank.status === 'verified' ? colors.success : bank.status === 'rejected' ? colors.danger : '#F0B90B' }]}>
                        {bank.status === 'under_review' ? 'Under Review' : bank.status}
                      </Text>
                    </View>
                    <TouchableOpacity onPress={() => handleRemoveBank(bank.id)} style={{ padding: 4 }}>
                      <Feather name="trash-2" size={16} color={colors.danger} />
                    </TouchableOpacity>
                  </View>
                  <Text style={s.bankAcctText}>{bank.holderName}</Text>
                  <Text style={s.bankAcctNum}>A/C: ••••{bank.accountNumber.slice(-4)} | IFSC: {bank.ifsc}</Text>
                  {bank.rejectReason ? <Text style={[s.bankAcctNum, { color: colors.danger }]}>Reason: {bank.rejectReason}</Text> : null}
                </View>
              ))}

              {!addingBank ? (
                <TouchableOpacity style={s.addBankBtn} onPress={() => setAddingBank(true)}>
                  <Feather name="plus" size={16} color={colors.primary} />
                  <Text style={s.addBankText}>Add Bank Account</Text>
                </TouchableOpacity>
              ) : (
                <View style={s.addBankForm}>
                  <Text style={s.addBankTitle}>Add New Bank</Text>
                  {[
                    { label: 'Account Holder Name', value: bankHolder, set: setBankHolder, placeholder: 'Full name as per bank' },
                    { label: 'Bank Name', value: bankName, set: setBankName, placeholder: 'e.g. HDFC, SBI, Axis' },
                    { label: 'Account Number', value: bankAcct, set: setBankAcct, placeholder: 'Enter account number', keyboardType: 'numeric' as const },
                    { label: 'IFSC Code', value: bankIFSC, set: setBankIFSC, placeholder: 'e.g. HDFC0001234' },
                  ].map(({ label, value, set, placeholder, keyboardType }) => (
                    <View key={label} style={{ marginBottom: 12 }}>
                      <Text style={s.label}>{label}</Text>
                      <TextInput style={s.bankInput} value={value} onChangeText={set} placeholder={placeholder} placeholderTextColor={colors.mutedForeground} keyboardType={keyboardType} />
                    </View>
                  ))}
                  <View style={s.bankBtns}>
                    <TouchableOpacity style={s.cancelBtn} onPress={() => setAddingBank(false)}>
                      <Text style={s.cancelBtnText}>Cancel</Text>
                    </TouchableOpacity>
                    <TouchableOpacity style={[s.saveBankBtn, { opacity: bankSubmitting ? 0.6 : 1 }]} disabled={bankSubmitting} onPress={handleAddBank}>
                      <Text style={s.saveBankBtnText}>{bankSubmitting ? 'Submitting...' : 'Submit'}</Text>
                    </TouchableOpacity>
                  </View>
                </View>
              )}
            </View>
          )}

          {/* TDS */}
          {tab === 'tds' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>TDS Report</Text>
              <View style={s.tdsCards}>
                <View style={s.tdsCard}>
                  <Text style={s.tdsCardLabel}>Total TDS Paid</Text>
                  <Text style={s.tdsCardValue}>₹{user.totalTdsPaid.toLocaleString()}</Text>
                </View>
                <View style={[s.tdsCard, { borderColor: '#F0B90B66' }]}>
                  <Text style={s.tdsCardLabel}>TDS Unpaid</Text>
                  <Text style={[s.tdsCardValue, { color: '#F0B90B' }]}>₹{user.totalTdsUnpaid.toLocaleString()}</Text>
                </View>
              </View>
              <View style={s.tdsInfo}>
                <MaterialIcons name="info" size={14} color={colors.primary} />
                <Text style={s.tdsInfoText}>1% TDS deducted on crypto sell transactions as per Indian IT Act Section 194S</Text>
              </View>
              <View style={s.tdsSummary}>
                {[
                  { label: 'FY 2023-24', tds: '₹2,150', txns: 48 },
                  { label: 'FY 2024-25', tds: '₹1,430', txns: 32 },
                ].map(({ label, tds, txns }) => (
                  <View key={label} style={s.tdsYear}>
                    <View>
                      <Text style={s.tdsYearLabel}>{label}</Text>
                      <Text style={s.tdsYearTxns}>{txns} transactions</Text>
                    </View>
                    <View style={{ alignItems: 'flex-end' }}>
                      <Text style={s.tdsYearVal}>{tds}</Text>
                      <TouchableOpacity onPress={() => Alert.alert('Download', 'TDS Certificate PDF downloading...')}>
                        <Text style={s.downloadBtn}>Download PDF</Text>
                      </TouchableOpacity>
                    </View>
                  </View>
                ))}
              </View>
            </View>
          )}

          {/* Settings */}
          {tab === 'settings' && (
            <View style={s.section}>
              <Text style={s.sectionTitle}>App Settings</Text>

              <Text style={s.settingGroup}>Theme</Text>
              <View style={s.themeRow}>
                {(['light', 'dark', 'system'] as const).map(t => (
                  <TouchableOpacity key={t} style={[s.themeBtn, theme === t && { borderColor: colors.primary, backgroundColor: colors.primary + '18' }]} onPress={() => setTheme(t)}>
                    <Feather name={t === 'light' ? 'sun' : t === 'dark' ? 'moon' : 'smartphone'} size={16} color={theme === t ? colors.primary : colors.mutedForeground} />
                    <Text style={[s.themeBtnText, theme === t && { color: colors.primary }]}>{t.charAt(0).toUpperCase() + t.slice(1)}</Text>
                  </TouchableOpacity>
                ))}
              </View>

              <Text style={s.settingGroup}>Language</Text>
              <View style={s.langRow}>
                {([{ key: 'en', label: 'English' }, { key: 'hi', label: 'हिंदी' }] as const).map(l => (
                  <TouchableOpacity key={l.key} style={[s.langBtn, language === l.key && { borderColor: colors.primary, backgroundColor: colors.primary + '18' }]} onPress={() => setLanguage(l.key)}>
                    <Text style={[s.langBtnText, language === l.key && { color: colors.primary }]}>{l.label}</Text>
                  </TouchableOpacity>
                ))}
              </View>

              <Text style={s.settingGroup}>Trading Bot</Text>
              <View style={s.settingRow}>
                <View>
                  <Text style={s.settingLabel}>Auto Trading Bot</Text>
                  <Text style={s.settingDesc}>Bot fills order book automatically</Text>
                </View>
                <Switch value={botEnabled} onValueChange={setBotEnabled} thumbColor={botEnabled ? colors.primary : colors.mutedForeground} trackColor={{ false: colors.border, true: colors.primary + '66' }} />
              </View>

              <TouchableOpacity style={s.logoutBtn} onPress={async () => { await logout(); router.replace('/(auth)/login'); }}>
                <MaterialIcons name="logout" size={18} color={colors.danger} />
                <Text style={s.logoutText}>Sign Out</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>

        <View style={{ height: 100 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = (colors: ReturnType<typeof useColors>) => StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  scroll: { paddingHorizontal: 16 },
  title: { fontSize: 24, fontFamily: 'Inter_700Bold', color: colors.foreground, paddingVertical: 16 },
  userCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: colors.card, borderRadius: 16, padding: 16, marginBottom: 16, gap: 12, borderWidth: 1, borderColor: colors.border },
  avatar: { width: 52, height: 52, borderRadius: 26, backgroundColor: colors.primary, alignItems: 'center', justifyContent: 'center' },
  avatarText: { fontSize: 22, fontFamily: 'Inter_700Bold', color: '#000' },
  userInfo: { flex: 1 },
  userName: { fontSize: 16, fontFamily: 'Inter_700Bold', color: colors.foreground },
  userEmail: { fontSize: 12, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 1 },
  userUID: { fontSize: 11, color: colors.primary, fontFamily: 'Inter_500Medium', marginTop: 2 },
  kycBadge: { borderRadius: 8, paddingHorizontal: 8, paddingVertical: 4 },
  kycBadgeText: { fontSize: 10, fontFamily: 'Inter_600SemiBold' },
  menuGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 16 },
  menuItem: { width: '47.5%', flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: colors.card, borderRadius: 10, padding: 12, borderWidth: 1, borderColor: colors.border },
  menuLabel: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.foreground },
  contentCard: { backgroundColor: colors.card, borderRadius: 16, padding: 16, borderWidth: 1, borderColor: colors.border },
  section: {},
  sectionTitle: { fontSize: 16, fontFamily: 'Inter_700Bold', color: colors.foreground, marginBottom: 14 },
  profileRow: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 10, borderBottomWidth: 1, borderBottomColor: colors.border },
  profileLabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  profileValue: { fontSize: 14, color: colors.foreground, fontFamily: 'Inter_500Medium', marginTop: 2 },
  kycStatus: { alignItems: 'center', padding: 20, borderRadius: 12, borderWidth: 2, marginBottom: 16, gap: 8 },
  kycStatusText: { fontSize: 18, fontFamily: 'Inter_700Bold' },
  kycStatusDesc: { fontSize: 13, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', textAlign: 'center', lineHeight: 20 },
  kycBtn: { backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 12, alignItems: 'center', marginBottom: 16 },
  kycBtnText: { fontSize: 15, fontFamily: 'Inter_700Bold', color: '#000' },
  kycStepsTitle: { fontSize: 13, fontFamily: 'Inter_600SemiBold', color: colors.foreground, marginBottom: 8 },
  kycDoc: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingVertical: 6 },
  kycDocText: { fontSize: 13, color: colors.foreground, fontFamily: 'Inter_400Regular' },
  securityRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: colors.border },
  securityLabel: { fontSize: 14, fontFamily: 'Inter_500Medium', color: colors.foreground },
  securitySublabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  logRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10, gap: 10, borderBottomWidth: 1, borderBottomColor: colors.border },
  logIcon: { width: 32, height: 32, borderRadius: 16, alignItems: 'center', justifyContent: 'center' },
  logDevice: { fontSize: 13, fontFamily: 'Inter_500Medium', color: colors.foreground },
  logLocation: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  logTime: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  logBadge: { borderRadius: 6, paddingHorizontal: 6, paddingVertical: 3 },
  logBadgeText: { fontSize: 10, fontFamily: 'Inter_600SemiBold' },
  sessionRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10, gap: 10, borderBottomWidth: 1, borderBottomColor: colors.border },
  sessionIcon: { width: 36, height: 36, borderRadius: 18, backgroundColor: colors.primary + '22', alignItems: 'center', justifyContent: 'center' },
  sessionDevice: { fontSize: 13, fontFamily: 'Inter_500Medium', color: colors.foreground },
  sessionLocation: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  sessionTime: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  subDesc: { fontSize: 13, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginBottom: 12 },
  subCard: { backgroundColor: colors.secondary, borderRadius: 12, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: colors.border },
  subBadge: { flexDirection: 'row', justifyContent: 'space-between', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 6, marginBottom: 10 },
  subBadgeText: { fontSize: 14, fontFamily: 'Inter_700Bold' },
  activeSub: { fontSize: 12, fontFamily: 'Inter_600SemiBold' },
  subDetails: { flexDirection: 'row', justifyContent: 'space-between' },
  subDetail: {},
  subDetailLabel: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', textTransform: 'uppercase' },
  subDetailValue: { fontSize: 13, color: colors.foreground, fontFamily: 'Inter_600SemiBold', marginTop: 2 },
  upgradeBtn: { borderRadius: 8, paddingVertical: 8, alignItems: 'center', marginTop: 12 },
  upgradeBtnText: { fontSize: 13, fontFamily: 'Inter_700Bold', color: '#000' },
  referCard: { backgroundColor: colors.secondary, borderRadius: 12, padding: 20, alignItems: 'center', gap: 8, borderWidth: 1, borderColor: colors.border, marginBottom: 16 },
  referTitle: { fontSize: 17, fontFamily: 'Inter_700Bold', color: colors.foreground },
  referDesc: { fontSize: 13, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', textAlign: 'center' },
  referCodeBox: { backgroundColor: colors.card, borderRadius: 10, padding: 14, alignItems: 'center', width: '100%', borderWidth: 1, borderColor: colors.border },
  referCodeLabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  referCode: { fontSize: 24, fontFamily: 'Inter_700Bold', color: colors.primary, letterSpacing: 3, marginVertical: 4 },
  copyBtn: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  copyBtnText: { fontSize: 13, color: colors.primary, fontFamily: 'Inter_500Medium' },
  referStats: { flexDirection: 'row', width: '100%', justifyContent: 'space-around' },
  referStat: { alignItems: 'center' },
  referStatValue: { fontSize: 18, fontFamily: 'Inter_700Bold', color: colors.primary },
  referStatLabel: { fontSize: 10, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  referLevelsTitle: { fontSize: 14, fontFamily: 'Inter_700Bold', color: colors.foreground, marginBottom: 10 },
  levelRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10, gap: 10, borderBottomWidth: 1, borderBottomColor: colors.border },
  levelBadge: { width: 32, height: 32, borderRadius: 16, alignItems: 'center', justifyContent: 'center' },
  levelText: { fontSize: 12, fontFamily: 'Inter_700Bold' },
  levelDesc: { fontSize: 13, color: colors.foreground, fontFamily: 'Inter_400Regular' },
  levelPercent: { fontSize: 16, fontFamily: 'Inter_700Bold', color: colors.primary },
  bankCard: { backgroundColor: colors.secondary, borderRadius: 12, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: colors.border },
  bankHeader: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 6 },
  bankNameText: { flex: 1, fontSize: 14, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  bankStatusBadge: { borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3 },
  bankStatusText: { fontSize: 10, fontFamily: 'Inter_600SemiBold' },
  bankAcctText: { fontSize: 13, color: colors.foreground, fontFamily: 'Inter_500Medium' },
  bankAcctNum: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  addBankBtn: { flexDirection: 'row', alignItems: 'center', gap: 8, borderWidth: 1, borderColor: colors.primary, borderRadius: 10, padding: 14, justifyContent: 'center', borderStyle: 'dashed' },
  addBankText: { fontSize: 14, color: colors.primary, fontFamily: 'Inter_500Medium' },
  addBankForm: { backgroundColor: colors.secondary, borderRadius: 12, padding: 14, borderWidth: 1, borderColor: colors.border },
  addBankTitle: { fontSize: 15, fontFamily: 'Inter_700Bold', color: colors.foreground, marginBottom: 12 },
  label: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_500Medium', marginBottom: 6, textTransform: 'uppercase' },
  bankInput: { backgroundColor: colors.card, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 10, fontSize: 14, color: colors.foreground, fontFamily: 'Inter_400Regular', borderWidth: 1, borderColor: colors.border },
  bankBtns: { flexDirection: 'row', gap: 10, marginTop: 4 },
  cancelBtn: { flex: 1, borderRadius: 8, paddingVertical: 10, borderWidth: 1, borderColor: colors.border, alignItems: 'center' },
  cancelBtnText: { fontSize: 13, color: colors.mutedForeground, fontFamily: 'Inter_500Medium' },
  saveBankBtn: { flex: 1, borderRadius: 8, paddingVertical: 10, backgroundColor: colors.primary, alignItems: 'center' },
  saveBankBtnText: { fontSize: 13, color: '#000', fontFamily: 'Inter_700Bold' },
  tdsCards: { flexDirection: 'row', gap: 10, marginBottom: 14 },
  tdsCard: { flex: 1, backgroundColor: colors.secondary, borderRadius: 10, padding: 14, borderWidth: 1, borderColor: colors.success + '44' },
  tdsCardLabel: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular' },
  tdsCardValue: { fontSize: 20, fontFamily: 'Inter_700Bold', color: colors.success, marginTop: 4 },
  tdsInfo: { flexDirection: 'row', gap: 8, backgroundColor: colors.primary + '18', borderRadius: 8, padding: 10, marginBottom: 14, alignItems: 'flex-start' },
  tdsInfoText: { flex: 1, fontSize: 12, color: colors.foreground, fontFamily: 'Inter_400Regular', lineHeight: 18 },
  tdsSummary: {},
  tdsYear: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: colors.border },
  tdsYearLabel: { fontSize: 14, fontFamily: 'Inter_600SemiBold', color: colors.foreground },
  tdsYearTxns: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  tdsYearVal: { fontSize: 16, fontFamily: 'Inter_700Bold', color: colors.foreground },
  downloadBtn: { fontSize: 12, color: colors.primary, fontFamily: 'Inter_500Medium', marginTop: 4 },
  settingGroup: { fontSize: 12, fontFamily: 'Inter_600SemiBold', color: colors.mutedForeground, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 10, marginTop: 16 },
  themeRow: { flexDirection: 'row', gap: 8 },
  themeBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 10, borderRadius: 8, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.secondary },
  themeBtnText: { fontSize: 12, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  langRow: { flexDirection: 'row', gap: 10 },
  langBtn: { flex: 1, alignItems: 'center', paddingVertical: 10, borderRadius: 8, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.secondary },
  langBtnText: { fontSize: 14, fontFamily: 'Inter_500Medium', color: colors.mutedForeground },
  settingRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: colors.border },
  settingLabel: { fontSize: 14, fontFamily: 'Inter_500Medium', color: colors.foreground },
  settingDesc: { fontSize: 11, color: colors.mutedForeground, fontFamily: 'Inter_400Regular', marginTop: 2 },
  logoutBtn: { flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 24, backgroundColor: colors.danger + '18', borderRadius: 10, paddingVertical: 14, justifyContent: 'center', borderWidth: 1, borderColor: colors.danger + '44' },
  logoutText: { fontSize: 15, fontFamily: 'Inter_600SemiBold', color: colors.danger },
});
