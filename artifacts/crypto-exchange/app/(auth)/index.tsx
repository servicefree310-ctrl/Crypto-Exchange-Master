import { useRouter } from 'expo-router';
import React, { useEffect } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useColors } from '@/hooks/useColors';
import { useApp } from '@/context/AppContext';

export default function AuthIndex() {
  const router = useRouter();
  const colors = useColors();
  const { user } = useApp();

  useEffect(() => {
    const timer = setTimeout(() => {
      if (user.isLoggedIn) {
        router.replace('/(tabs)');
      } else {
        router.replace('/(auth)/login');
      }
    }, 100);
    return () => clearTimeout(timer);
  }, [user.isLoggedIn]);

  return (
    <View style={{ flex: 1, backgroundColor: colors.background, alignItems: 'center', justifyContent: 'center' }}>
      <ActivityIndicator color={colors.primary} size="large" />
    </View>
  );
}
