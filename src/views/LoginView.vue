<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-slate-50 to-blue-50 flex items-center justify-center p-4">
    <div class="w-full max-w-6xl flex gap-8">
      <div class="flex-1 bg-white rounded-3xl shadow-2xl p-12">
        <div class="max-w-md mx-auto">
          <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-blue-600 to-blue-700 rounded-3xl mb-6 shadow-lg shadow-blue-600/30">
              <FileText class="w-10 h-10 text-white" />
            </div>
            <h1 class="text-4xl font-bold text-slate-800 mb-3">سیستم مدیریت اسناد</h1>
            <p class="text-slate-600 text-lg">ورود به پنل کاربری</p>
          </div>

          <form @submit.prevent="handleLogin" class="space-y-6">
              <div v-if="authStore.error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
                {{ authStore.error }}
              </div>

              <div>
                <label for="username" class="block text-sm font-medium text-gray-700 mb-2">
                  نام کاربری
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                    <User class="h-5 w-5 text-gray-400" />
                  </div>
                  <input
                    id="username"
                    v-model="username"
                    type="text"
                    required
                    class="block w-full pr-10 pl-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                    placeholder="نام کاربری خود را وارد کنید"
                  />
                </div>
              </div>

              <div>
                <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                  رمز عبور
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                    <Lock class="h-5 w-5 text-gray-400" />
                  </div>
                  <input
                    id="password"
                    v-model="password"
                    type="password"
                    required
                    class="block w-full pr-10 pl-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                    placeholder="رمز عبور خود را وارد کنید"
                  />
                </div>
              </div>

              <button
                type="submit"
                :disabled="authStore.loading"
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span v-if="!authStore.loading">ورود به سیستم</span>
                <span v-else class="flex items-center gap-2">
                  <Loader2 class="w-5 h-5 animate-spin" />
                  در حال ورود...
                </span>
              </button>
          </form>
        </div>
      </div>

      <div class="hidden lg:flex flex-1 flex-col justify-center">
        <div class="bg-gradient-to-br from-blue-600 to-blue-700 rounded-3xl p-12 text-white shadow-2xl">
          <h2 class="text-3xl font-bold mb-6">سیستم مدیریت اسناد حرفه‌ای</h2>
          <div class="space-y-6">
            <div class="flex items-start gap-4">
              <div class="flex-shrink-0 w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
                <FileText class="w-5 h-5" />
              </div>
              <div>
                <h3 class="font-semibold text-lg mb-2">مدیریت کامل اسناد</h3>
                <p class="text-blue-100">ایجاد، ویرایش، آپلود و مدیریت اسناد با امکانات پیشرفته</p>
              </div>
            </div>

            <div class="flex items-start gap-4">
              <div class="flex-shrink-0 w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
                <FileText class="w-5 h-5" />
              </div>
              <div>
                <h3 class="font-semibold text-lg mb-2">ورژن‌بندی خودکار</h3>
                <p class="text-blue-100">تاریخچه کامل تغییرات و نسخه‌های مختلف اسناد</p>
              </div>
            </div>

            <div class="flex items-start gap-4">
              <div class="flex-shrink-0 w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
                <FileText class="w-5 h-5" />
              </div>
              <div>
                <h3 class="font-semibold text-lg mb-2">کنترل دسترسی پیشرفته</h3>
                <p class="text-blue-100">مدیریت سطوح دسترسی و فرآیندهای تایید</p>
              </div>
            </div>

            <div class="flex items-start gap-4">
              <div class="flex-shrink-0 w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
                <FileText class="w-5 h-5" />
              </div>
              <div>
                <h3 class="font-semibold text-lg mb-2">گزارش‌گیری جامع</h3>
                <p class="text-blue-100">تحلیل و آمار دقیق از عملکرد و فعالیت‌ها</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { FileText, Mail, Lock, AlertCircle } from 'lucide-vue-next';

const router = useRouter();
const authStore = useAuthStore();

const username = ref('');
const password = ref('');

const handleLogin = async () => {
  const success = await authStore.login(username.value, password.value);
  if (success) {
    router.push({ name: 'dashboard' });
  }
};
</script>