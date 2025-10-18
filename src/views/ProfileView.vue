<template>
  <div class="p-8">
    <div class="max-w-4xl mx-auto">
      <h1 class="text-3xl font-bold mb-8 text-gray-800">پروفایل کاربری</h1>

      <div v-if="loading" class="text-center py-12">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>

      <div v-else-if="error" class="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-lg">
        {{ error }}
      </div>

      <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-1">
          <div class="bg-white rounded-xl shadow-md p-6 sticky top-8">
            <div class="text-center">
              <div class="w-24 h-24 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full mx-auto flex items-center justify-center text-white text-3xl font-bold mb-4">
                {{ userInitials }}
              </div>
              <h2 class="text-xl font-bold text-gray-800 mb-1">{{ userProfile?.full_name }}</h2>
              <p class="text-gray-600 mb-1">@{{ userProfile?.username }}</p>
              <span :class="roleClass" class="inline-block px-3 py-1 rounded-full text-sm font-semibold">
                {{ roleLabel }}
              </span>
            </div>

            <div class="mt-6 pt-6 border-t border-gray-200 space-y-3">
              <div class="flex items-center text-gray-700">
                <svg class="w-5 h-5 ml-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
                <span class="text-sm">{{ userProfile?.email }}</span>
              </div>

              <div v-if="userProfile?.department" class="flex items-center text-gray-700">
                <svg class="w-5 h-5 ml-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
                <span class="text-sm">{{ userProfile?.department }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="lg:col-span-2 space-y-6">
          <div class="bg-white rounded-xl shadow-md p-6">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-xl font-bold text-gray-800">اطلاعات پروفایل</h3>
              <button
                v-if="!editMode"
                @click="enableEditMode"
                class="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                ویرایش پروفایل
              </button>
            </div>

            <form @submit.prevent="saveProfile" class="space-y-6">
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">نام کاربری</label>
                <input
                  type="text"
                  :value="userProfile?.username"
                  disabled
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-gray-500 cursor-not-allowed"
                />
                <p class="text-xs text-gray-500 mt-1">نام کاربری قابل تغییر نیست</p>
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">ایمیل</label>
                <input
                  type="email"
                  :value="userProfile?.email"
                  disabled
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-gray-500 cursor-not-allowed"
                />
                <p class="text-xs text-gray-500 mt-1">ایمیل قابل تغییر نیست</p>
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">نام کامل *</label>
                <input
                  v-model="editForm.full_name"
                  type="text"
                  :disabled="!editMode"
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  :class="editMode ? 'bg-white' : 'bg-gray-50 text-gray-500 cursor-not-allowed'"
                />
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">دپارتمان</label>
                <input
                  v-model="editForm.department"
                  type="text"
                  :disabled="!editMode"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  :class="editMode ? 'bg-white' : 'bg-gray-50 text-gray-500 cursor-not-allowed'"
                />
              </div>

              <div v-if="editMode" class="flex gap-3 pt-4">
                <button
                  type="submit"
                  :disabled="saving"
                  class="flex-1 px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-semibold"
                >
                  {{ saving ? 'در حال ذخیره...' : 'ذخیره تغییرات' }}
                </button>
                <button
                  type="button"
                  @click="cancelEdit"
                  :disabled="saving"
                  class="flex-1 px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-semibold"
                >
                  لغو
                </button>
              </div>

              <div v-if="saveSuccess" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg">
                ✓ تغییرات با موفقیت ذخیره شد
              </div>

              <div v-if="saveError" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                {{ saveError }}
              </div>
            </form>
          </div>

          <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-800 mb-6">تغییر رمز عبور</h3>

            <form @submit.prevent="changePassword" class="space-y-6">
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">رمز عبور فعلی *</label>
                <input
                  v-model="passwordForm.currentPassword"
                  type="password"
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">رمز عبور جدید *</label>
                <input
                  v-model="passwordForm.newPassword"
                  type="password"
                  required
                  minlength="6"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <p class="text-xs text-gray-500 mt-1">حداقل 6 کاراکتر</p>
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">تکرار رمز عبور جدید *</label>
                <input
                  v-model="passwordForm.confirmPassword"
                  type="password"
                  required
                  minlength="6"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <button
                type="submit"
                :disabled="changingPassword"
                class="w-full px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-semibold"
              >
                {{ changingPassword ? 'در حال تغییر رمز عبور...' : 'تغییر رمز عبور' }}
              </button>

              <div v-if="passwordSuccess" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg">
                ✓ رمز عبور با موفقیت تغییر یافت
              </div>

              <div v-if="passwordError" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                {{ passwordError }}
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { supabase } from '@/config/supabase';
import { useAuthStore } from '@/stores/auth';

const authStore = useAuthStore();

const userProfile = ref<any>(null);
const loading = ref(true);
const error = ref<string | null>(null);

const editMode = ref(false);
const saving = ref(false);
const saveSuccess = ref(false);
const saveError = ref<string | null>(null);

const changingPassword = ref(false);
const passwordSuccess = ref(false);
const passwordError = ref<string | null>(null);

const editForm = ref({
  full_name: '',
  department: '',
});

const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
});

const userInitials = computed(() => {
  if (!userProfile.value?.full_name) return '?';
  const names = userProfile.value.full_name.split(' ');
  if (names.length >= 2) {
    return names[0][0] + names[1][0];
  }
  return names[0][0];
});

const roleLabel = computed(() => {
  return userProfile.value?.role === 'admin' ? 'مدیر' : 'کاربر';
});

const roleClass = computed(() => {
  return userProfile.value?.role === 'admin'
    ? 'bg-purple-100 text-purple-700'
    : 'bg-blue-100 text-blue-700';
});

async function fetchUserProfile() {
  loading.value = true;
  error.value = null;

  try {
    const userId = authStore.user?.id;
    if (!userId) {
      error.value = 'کاربر وارد نشده است';
      return;
    }

    const { data, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (fetchError) throw fetchError;
    if (!data) {
      error.value = 'اطلاعات کاربر یافت نشد';
      return;
    }

    userProfile.value = data;
    editForm.value = {
      full_name: data.full_name,
      department: data.department || '',
    };
  } catch (err: any) {
    error.value = err.message || 'خطا در بارگذاری اطلاعات';
  } finally {
    loading.value = false;
  }
}

function enableEditMode() {
  editMode.value = true;
  saveSuccess.value = false;
  saveError.value = null;
}

function cancelEdit() {
  editMode.value = false;
  editForm.value = {
    full_name: userProfile.value?.full_name || '',
    department: userProfile.value?.department || '',
  };
  saveSuccess.value = false;
  saveError.value = null;
}

async function saveProfile() {
  saving.value = true;
  saveSuccess.value = false;
  saveError.value = null;

  try {
    const userId = authStore.user?.id;
    if (!userId) {
      saveError.value = 'کاربر وارد نشده است';
      return;
    }

    const { error: updateError } = await supabase
      .from('users')
      .update({
        full_name: editForm.value.full_name,
        department: editForm.value.department || null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId);

    if (updateError) throw updateError;

    userProfile.value.full_name = editForm.value.full_name;
    userProfile.value.department = editForm.value.department;

    if (authStore.user) {
      authStore.user.fullName = editForm.value.full_name;
      authStore.user.department = editForm.value.department;
      localStorage.setItem('user', JSON.stringify(authStore.user));
    }

    saveSuccess.value = true;
    editMode.value = false;

    setTimeout(() => {
      saveSuccess.value = false;
    }, 3000);
  } catch (err: any) {
    saveError.value = err.message || 'خطا در ذخیره تغییرات';
  } finally {
    saving.value = false;
  }
}

async function changePassword() {
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    passwordError.value = 'رمز عبور جدید و تکرار آن یکسان نیستند';
    return;
  }

  if (passwordForm.value.newPassword.length < 6) {
    passwordError.value = 'رمز عبور باید حداقل 6 کاراکتر باشد';
    return;
  }

  changingPassword.value = true;
  passwordSuccess.value = false;
  passwordError.value = null;

  try {
    const { data: { user } } = await supabase.auth.getUser();

    if (!user?.email) {
      passwordError.value = 'کاربر وارد نشده است';
      return;
    }

    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: user.email,
      password: passwordForm.value.currentPassword,
    });

    if (signInError) {
      passwordError.value = 'رمز عبور فعلی اشتباه است';
      return;
    }

    const { error: updateError } = await supabase.auth.updateUser({
      password: passwordForm.value.newPassword,
    });

    if (updateError) throw updateError;

    passwordSuccess.value = true;
    passwordForm.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    };

    setTimeout(() => {
      passwordSuccess.value = false;
    }, 3000);
  } catch (err: any) {
    passwordError.value = err.message || 'خطا در تغییر رمز عبور';
  } finally {
    changingPassword.value = false;
  }
}

onMounted(() => {
  fetchUserProfile();
});
</script>
