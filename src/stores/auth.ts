import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { supabase } from '@/config/supabase';
import type { User } from '@/types';

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const isAuthenticated = computed(() => !!user.value);
  const isAdmin = computed(() => user.value?.role === 'admin');

  async function login(username: string, password: string) {
    loading.value = true;
    error.value = null;

    try {
      const { data, error: loginError } = await supabase
        .from('users')
        .select('*')
        .eq('username', username)
        .eq('is_active', true)
        .maybeSingle();

      if (loginError) throw loginError;
      if (!data) {
        error.value = 'نام کاربری یا رمز عبور اشتباه است';
        return false;
      }

      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: password,
      });

      if (authError) {
        error.value = 'نام کاربری یا رمز عبور اشتباه است';
        return false;
      }

      user.value = {
        id: data.id,
        username: data.username,
        fullName: data.full_name,
        email: data.email,
        role: data.role,
        department: data.department,
      };

      localStorage.setItem('user', JSON.stringify(user.value));
      return true;
    } catch (err: any) {
      error.value = err.message || 'خطا در ورود به سیستم';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function logout() {
    await supabase.auth.signOut();
    user.value = null;
    localStorage.removeItem('user');
  }

  function initAuth() {
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      user.value = JSON.parse(storedUser);
    }
  }

  return {
    user,
    loading,
    error,
    isAuthenticated,
    isAdmin,
    login,
    logout,
    initAuth,
  };
});
