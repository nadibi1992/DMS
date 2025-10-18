<template>
  <div class="space-y-6">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">مدیریت کاربران</h1>
        <p class="text-gray-600 mt-1">مشاهده و مدیریت کاربران سیستم</p>
      </div>
      <button
        @click="showAddModal = true"
        class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
      >
        <UserPlus class="w-5 h-5" />
        افزودن کاربر جدید
      </button>
    </div>

    <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-lg">
      {{ error }}
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div class="flex flex-col md:flex-row gap-4 mb-6">
        <div class="relative flex-1">
          <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
            <Search class="h-5 w-5 text-gray-400" />
          </div>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="جستجو در کاربران..."
            class="block w-full pr-10 pl-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <select
          v-model="filterRole"
          class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"
        >
          <option value="">همه نقش‌ها</option>
          <option value="admin">مدیر سیستم</option>
          <option value="user">کاربر عادی</option>
        </select>

        <select
          v-model="filterStatus"
          class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"
        >
          <option value="">همه وضعیت‌ها</option>
          <option value="active">فعال</option>
          <option value="inactive">غیرفعال</option>
        </select>
      </div>

      <div v-if="loading" class="text-center py-12">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>

      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                کاربر
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                نام کاربری
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                نقش
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                بخش
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                وضعیت
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                تاریخ ثبت
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                عملیات
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="user in filteredUsers"
              :key="user.id"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-700 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0">
                    {{ user.full_name.charAt(0) }}
                  </div>
                  <div class="mr-3">
                    <p class="text-sm font-medium text-gray-900">{{ user.full_name }}</p>
                    <p class="text-sm text-gray-600">{{ user.email }}</p>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <p class="text-sm text-gray-900">{{ user.username }}</p>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  :class="user.role === 'admin' ? 'bg-orange-100 text-orange-700' : 'bg-gray-100 text-gray-700'"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ getRoleLabel(user.role) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ user.department || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  :class="user.is_active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ user.is_active ? 'فعال' : 'غیرفعال' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                {{ formatDate(user.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex items-center gap-2">
                  <button
                    @click="editUser(user)"
                    class="p-2 text-blue-600 hover:bg-blue-50 rounded transition-colors"
                    title="ویرایش"
                  >
                    <Edit class="w-4 h-4" />
                  </button>
                  <button
                    @click="toggleUserStatus(user)"
                    class="p-2 text-yellow-600 hover:bg-yellow-50 rounded transition-colors"
                    :title="user.is_active ? 'غیرفعال کردن' : 'فعال کردن'"
                  >
                    <ShieldOff v-if="user.is_active" class="w-4 h-4" />
                    <ShieldCheck v-else class="w-4 h-4" />
                  </button>
                  <button
                    @click="resetPassword(user)"
                    class="p-2 text-green-600 hover:bg-green-50 rounded transition-colors"
                    title="بازنشانی رمز عبور"
                  >
                    <Key class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="!loading && filteredUsers.length === 0" class="text-center py-12">
        <Users class="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <p class="text-gray-600">هیچ کاربری یافت نشد</p>
      </div>
    </div>

    <div v-if="showAddModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">
              {{ editingUser ? 'ویرایش کاربر' : 'افزودن کاربر جدید' }}
            </h2>
            <button
              @click="closeModal"
              class="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <X class="w-6 h-6" />
            </button>
          </div>
        </div>

        <form @submit.prevent="handleSubmit" class="p-6 space-y-4">
          <div v-if="formError" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
            {{ formError }}
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نام و نام خانوادگی
                <span class="text-red-500">*</span>
              </label>
              <input
                v-model="userForm.full_name"
                type="text"
                required
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نام کاربری
                <span class="text-red-500">*</span>
              </label>
              <input
                v-model="userForm.username"
                type="text"
                required
                :disabled="!!editingUser"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                :class="editingUser ? 'bg-gray-100 cursor-not-allowed' : ''"
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              ایمیل
              <span class="text-red-500">*</span>
            </label>
            <input
              v-model="userForm.email"
              type="email"
              required
              :disabled="!!editingUser"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              :class="editingUser ? 'bg-gray-100 cursor-not-allowed' : ''"
            />
          </div>

          <div v-if="!editingUser">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              رمز عبور
              <span class="text-red-500">*</span>
            </label>
            <input
              v-model="userForm.password"
              type="password"
              :required="!editingUser"
              minlength="6"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <p class="text-xs text-gray-500 mt-1">حداقل 6 کاراکتر</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نقش
                <span class="text-red-500">*</span>
              </label>
              <select
                v-model="userForm.role"
                required
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="user">کاربر عادی</option>
                <option value="admin">مدیر سیستم</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                بخش
              </label>
              <input
                v-model="userForm.department"
                type="text"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>

          <div class="flex items-center gap-2">
            <input
              v-model="userForm.is_active"
              type="checkbox"
              id="is_active"
              class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            />
            <label for="is_active" class="text-sm font-medium text-gray-700">
              کاربر فعال است
            </label>
          </div>

          <div class="flex items-center gap-2 pt-4 border-t border-gray-200">
            <button
              type="submit"
              :disabled="saving"
              class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ saving ? 'در حال پردازش...' : (editingUser ? 'ذخیره تغییرات' : 'افزودن کاربر') }}
            </button>
            <button
              type="button"
              @click="closeModal"
              :disabled="saving"
              class="flex-1 px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              انصراف
            </button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showResetPasswordModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full">
        <div class="p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">بازنشانی رمز عبور</h2>
            <button
              @click="closeResetPasswordModal"
              class="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <X class="w-6 h-6" />
            </button>
          </div>
        </div>

        <form @submit.prevent="handleResetPassword" class="p-6 space-y-4">
          <div v-if="resetPasswordError" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
            {{ resetPasswordError }}
          </div>

          <p class="text-gray-700">
            بازنشانی رمز عبور برای کاربر: <strong>{{ resetPasswordUser?.full_name }}</strong>
          </p>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              رمز عبور جدید
              <span class="text-red-500">*</span>
            </label>
            <input
              v-model="newPassword"
              type="password"
              required
              minlength="6"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <p class="text-xs text-gray-500 mt-1">حداقل 6 کاراکتر</p>
          </div>

          <div class="flex items-center gap-2 pt-4 border-t border-gray-200">
            <button
              type="submit"
              :disabled="resettingPassword"
              class="flex-1 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ resettingPassword ? 'در حال بازنشانی...' : 'بازنشانی رمز عبور' }}
            </button>
            <button
              type="button"
              @click="closeResetPasswordModal"
              :disabled="resettingPassword"
              class="flex-1 px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              انصراف
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { supabase } from '@/config/supabase';
import { Search, UserPlus, Edit, Users, X, ShieldOff, ShieldCheck, Key } from 'lucide-vue-next';

const searchQuery = ref('');
const filterRole = ref('');
const filterStatus = ref('');
const showAddModal = ref(false);
const editingUser = ref<any>(null);
const loading = ref(true);
const error = ref<string | null>(null);
const saving = ref(false);
const formError = ref<string | null>(null);

const showResetPasswordModal = ref(false);
const resetPasswordUser = ref<any>(null);
const newPassword = ref('');
const resettingPassword = ref(false);
const resetPasswordError = ref<string | null>(null);

const userForm = ref({
  full_name: '',
  username: '',
  email: '',
  password: '',
  role: 'user' as 'admin' | 'user',
  department: '',
  is_active: true
});

const users = ref<any[]>([]);

const filteredUsers = computed(() => {
  return users.value.filter(user => {
    const matchesSearch = user.full_name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                         user.username.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                         user.email.toLowerCase().includes(searchQuery.value.toLowerCase());
    const matchesRole = !filterRole.value || user.role === filterRole.value;
    const matchesStatus = !filterStatus.value ||
                         (filterStatus.value === 'active' && user.is_active) ||
                         (filterStatus.value === 'inactive' && !user.is_active);

    return matchesSearch && matchesRole && matchesStatus;
  });
});

const getRoleLabel = (role: string) => {
  return role === 'admin' ? 'مدیر سیستم' : 'کاربر عادی';
};

const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('fa-IR').format(date);
};

async function fetchUsers() {
  loading.value = true;
  error.value = null;

  try {
    const { data, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .order('created_at', { ascending: false });

    if (fetchError) throw fetchError;

    users.value = data || [];
  } catch (err: any) {
    error.value = err.message || 'خطا در بارگذاری کاربران';
  } finally {
    loading.value = false;
  }
}

const editUser = (user: any) => {
  editingUser.value = user;
  userForm.value = {
    full_name: user.full_name,
    username: user.username,
    email: user.email,
    password: '',
    role: user.role,
    department: user.department || '',
    is_active: user.is_active
  };
  showAddModal.value = true;
  formError.value = null;
};

async function toggleUserStatus(user: any) {
  const newStatus = !user.is_active;
  const action = newStatus ? 'فعال' : 'غیرفعال';

  if (!confirm(`آیا از ${action} کردن کاربر "${user.full_name}" اطمینان دارید؟`)) {
    return;
  }

  try {
    const { error: updateError } = await supabase
      .from('users')
      .update({
        is_active: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', user.id);

    if (updateError) throw updateError;

    user.is_active = newStatus;
  } catch (err: any) {
    alert('خطا در تغییر وضعیت کاربر: ' + err.message);
  }
}

const resetPassword = (user: any) => {
  resetPasswordUser.value = user;
  newPassword.value = '';
  resetPasswordError.value = null;
  showResetPasswordModal.value = true;
};

const closeResetPasswordModal = () => {
  showResetPasswordModal.value = false;
  resetPasswordUser.value = null;
  newPassword.value = '';
  resetPasswordError.value = null;
};

async function handleResetPassword() {
  resettingPassword.value = true;
  resetPasswordError.value = null;

  try {
    const { error: updateError } = await supabase.auth.admin.updateUserById(
      resetPasswordUser.value.id,
      { password: newPassword.value }
    );

    if (updateError) throw updateError;

    alert('رمز عبور با موفقیت بازنشانی شد');
    closeResetPasswordModal();
  } catch (err: any) {
    resetPasswordError.value = err.message || 'خطا در بازنشانی رمز عبور';
  } finally {
    resettingPassword.value = false;
  }
}

const closeModal = () => {
  showAddModal.value = false;
  editingUser.value = null;
  userForm.value = {
    full_name: '',
    username: '',
    email: '',
    password: '',
    role: 'user',
    department: '',
    is_active: true
  };
  formError.value = null;
};

async function handleSubmit() {
  saving.value = true;
  formError.value = null;

  try {
    if (editingUser.value) {
      const { error: updateError } = await supabase
        .from('users')
        .update({
          full_name: userForm.value.full_name,
          role: userForm.value.role,
          department: userForm.value.department || null,
          is_active: userForm.value.is_active,
          updated_at: new Date().toISOString()
        })
        .eq('id', editingUser.value.id);

      if (updateError) throw updateError;

      Object.assign(editingUser.value, {
        full_name: userForm.value.full_name,
        role: userForm.value.role,
        department: userForm.value.department,
        is_active: userForm.value.is_active
      });
    } else {
      const { data: authData, error: signUpError } = await supabase.auth.signUp({
        email: userForm.value.email,
        password: userForm.value.password,
      });

      if (signUpError) throw signUpError;
      if (!authData.user) throw new Error('خطا در ایجاد کاربر');

      const { error: insertError } = await supabase
        .from('users')
        .insert({
          id: authData.user.id,
          username: userForm.value.username,
          email: userForm.value.email,
          full_name: userForm.value.full_name,
          role: userForm.value.role,
          department: userForm.value.department || null,
          is_active: userForm.value.is_active
        });

      if (insertError) throw insertError;

      await fetchUsers();
    }

    closeModal();
  } catch (err: any) {
    formError.value = err.message || 'خطا در ذخیره اطلاعات';
  } finally {
    saving.value = false;
  }
}

onMounted(() => {
  fetchUsers();
});
</script>
