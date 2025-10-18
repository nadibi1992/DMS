<template>
  <div class="space-y-6">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">مدیریت دسترسی‌ها</h1>
        <p class="text-gray-600 mt-1">تنظیم دسترسی‌ها و اختیارات گروه‌های کاربری</p>
      </div>
    </div>

    <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-lg">
      {{ error }}
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-1">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-bold text-gray-900">گروه‌های کاربری</h2>
            <button
              @click="showGroupModal = true"
              class="p-2 text-blue-600 hover:bg-blue-50 rounded transition-colors"
              title="افزودن گروه"
            >
              <Plus class="w-5 h-5" />
            </button>
          </div>

          <div v-if="loadingGroups" class="text-center py-8">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>

          <div v-else class="space-y-2">
            <button
              v-for="group in groups"
              :key="group.id"
              @click="selectGroup(group)"
              :class="selectedGroup?.id === group.id ? 'bg-blue-50 border-blue-500 text-blue-700' : 'bg-gray-50 border-gray-200 text-gray-700 hover:bg-gray-100'"
              class="w-full text-right px-4 py-3 border rounded-lg transition-colors"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="font-semibold">{{ group.name }}</p>
                  <p v-if="group.description" class="text-xs text-gray-600 mt-1">{{ group.description }}</p>
                </div>
                <Shield class="w-5 h-5" />
              </div>
            </button>
          </div>
        </div>
      </div>

      <div class="lg:col-span-2">
        <div v-if="!selectedGroup" class="bg-white rounded-xl shadow-sm border border-gray-200 p-12 text-center">
          <Shield class="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <p class="text-gray-600">لطفا یک گروه را از لیست انتخاب کنید</p>
        </div>

        <div v-else class="space-y-6">
          <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div class="flex items-center justify-between mb-6">
              <div>
                <h2 class="text-lg font-bold text-gray-900">{{ selectedGroup.name }}</h2>
                <p class="text-sm text-gray-600 mt-1">{{ selectedGroup.description }}</p>
              </div>
              <button
                @click="openAddPermissionModal"
                class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
              >
                <Plus class="w-5 h-5" />
                افزودن دسترسی
              </button>
            </div>

            <div v-if="loadingPermissions" class="text-center py-8">
              <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>

            <div v-else-if="groupPermissions.length === 0" class="text-center py-8">
              <Lock class="w-12 h-12 text-gray-300 mx-auto mb-3" />
              <p class="text-gray-600">هیچ دسترسی تعریف نشده است</p>
            </div>

            <div v-else class="space-y-3">
              <div
                v-for="permission in groupPermissions"
                :key="permission.id"
                class="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
              >
                <div class="flex items-center gap-4">
                  <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                    <Shield class="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">{{ getResourceTypeLabel(permission.resource_type) }}</p>
                    <p class="text-sm text-gray-600">
                      {{ getActionLabel(permission.action) }}
                      <span v-if="permission.category_name" class="text-xs">
                        - دسته‌بندی: {{ permission.category_name }}
                      </span>
                    </p>
                  </div>
                </div>
                <button
                  @click="deletePermission(permission)"
                  class="p-2 text-red-600 hover:bg-red-50 rounded transition-colors"
                  title="حذف"
                >
                  <Trash2 class="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-4">اعضای گروه</h3>

            <div v-if="loadingMembers" class="text-center py-8">
              <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>

            <div v-else>
              <div class="flex items-center gap-2 mb-4">
                <select
                  v-model="selectedUserId"
                  class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">انتخاب کاربر...</option>
                  <option
                    v-for="user in availableUsers"
                    :key="user.id"
                    :value="user.id"
                  >
                    {{ user.full_name }} ({{ user.username }})
                  </option>
                </select>
                <button
                  @click="addUserToGroup"
                  :disabled="!selectedUserId"
                  class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  افزودن
                </button>
              </div>

              <div class="space-y-2">
                <div
                  v-for="member in groupMembers"
                  :key="member.id"
                  class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                >
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white text-sm font-bold">
                      {{ member.user_name?.charAt(0) }}
                    </div>
                    <div>
                      <p class="text-sm font-semibold text-gray-900">{{ member.user_name }}</p>
                      <p class="text-xs text-gray-600">{{ member.user_email }}</p>
                    </div>
                  </div>
                  <button
                    @click="removeUserFromGroup(member)"
                    class="p-2 text-red-600 hover:bg-red-50 rounded transition-colors"
                    title="حذف از گروه"
                  >
                    <X class="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showGroupModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full">
        <div class="p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">افزودن گروه جدید</h2>
            <button
              @click="closeGroupModal"
              class="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <X class="w-6 h-6" />
            </button>
          </div>
        </div>

        <form @submit.prevent="handleAddGroup" class="p-6 space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              نام گروه
              <span class="text-red-500">*</span>
            </label>
            <input
              v-model="groupForm.name"
              type="text"
              required
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              توضیحات
            </label>
            <textarea
              v-model="groupForm.description"
              rows="3"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            ></textarea>
          </div>

          <div class="flex items-center gap-2 pt-4 border-t border-gray-200">
            <button
              type="submit"
              :disabled="savingGroup"
              class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ savingGroup ? 'در حال ذخیره...' : 'افزودن گروه' }}
            </button>
            <button
              type="button"
              @click="closeGroupModal"
              class="flex-1 px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors"
            >
              انصراف
            </button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showPermissionModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full">
        <div class="p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">افزودن دسترسی جدید</h2>
            <button
              @click="closePermissionModal"
              class="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <X class="w-6 h-6" />
            </button>
          </div>
        </div>

        <form @submit.prevent="handleAddPermission" class="p-6 space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              نوع منبع
              <span class="text-red-500">*</span>
            </label>
            <select
              v-model="permissionForm.resource_type"
              required
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="">انتخاب کنید...</option>
              <option value="documents">اسناد</option>
              <option value="categories">دسته‌بندی‌ها</option>
              <option value="users">کاربران</option>
              <option value="workflows">گردش کارها</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              عملیات
              <span class="text-red-500">*</span>
            </label>
            <select
              v-model="permissionForm.action"
              required
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="">انتخاب کنید...</option>
              <option value="create">ایجاد</option>
              <option value="read">مشاهده</option>
              <option value="update">ویرایش</option>
              <option value="delete">حذف</option>
              <option value="approve">تایید</option>
              <option value="reject">رد</option>
            </select>
          </div>

          <div v-if="permissionForm.resource_type === 'documents'">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              دسته‌بندی خاص (اختیاری)
            </label>
            <select
              v-model="permissionForm.category_id"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option :value="null">همه دسته‌بندی‌ها</option>
              <option
                v-for="cat in categories"
                :key="cat.id"
                :value="cat.id"
              >
                {{ cat.name }}
              </option>
            </select>
          </div>

          <div class="flex items-center gap-2 pt-4 border-t border-gray-200">
            <button
              type="submit"
              :disabled="savingPermission"
              class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ savingPermission ? 'در حال ذخیره...' : 'افزودن دسترسی' }}
            </button>
            <button
              type="button"
              @click="closePermissionModal"
              class="flex-1 px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors"
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
import { ref, computed, watch } from 'vue';
import { supabase } from '@/config/supabase';
import { Shield, Plus, Trash2, X, Lock } from 'lucide-vue-next';

const error = ref<string | null>(null);
const loadingGroups = ref(true);
const loadingPermissions = ref(false);
const loadingMembers = ref(false);
const showGroupModal = ref(false);
const showPermissionModal = ref(false);
const savingGroup = ref(false);
const savingPermission = ref(false);
const selectedGroup = ref<any>(null);
const selectedUserId = ref('');

const groupForm = ref({
  name: '',
  description: ''
});

const permissionForm = ref({
  resource_type: '',
  action: '',
  category_id: null as string | null
});

const groups = ref<any[]>([]);
const groupPermissions = ref<any[]>([]);
const groupMembers = ref<any[]>([]);
const categories = ref<any[]>([]);
const users = ref<any[]>([]);

const availableUsers = computed(() => {
  const memberIds = groupMembers.value.map(m => m.user_id);
  return users.value.filter(u => !memberIds.includes(u.id));
});

const getResourceTypeLabel = (type: string) => {
  const labels: any = {
    documents: 'اسناد',
    categories: 'دسته‌بندی‌ها',
    users: 'کاربران',
    workflows: 'گردش کارها'
  };
  return labels[type] || type;
};

const getActionLabel = (action: string) => {
  const labels: any = {
    create: 'ایجاد',
    read: 'مشاهده',
    update: 'ویرایش',
    delete: 'حذف',
    approve: 'تایید',
    reject: 'رد'
  };
  return labels[action] || action;
};

async function fetchGroups() {
  loadingGroups.value = true;
  error.value = null;

  try {
    const { data, error: fetchError } = await supabase
      .from('user_groups')
      .select('*')
      .order('name');

    if (fetchError) throw fetchError;
    groups.value = data || [];
  } catch (err: any) {
    error.value = err.message || 'خطا در بارگذاری گروه‌ها';
  } finally {
    loadingGroups.value = false;
  }
}

async function fetchPermissions(groupId: string) {
  loadingPermissions.value = true;

  try {
    const { data, error: fetchError } = await supabase
      .from('permissions')
      .select(`
        *,
        category:document_categories(name)
      `)
      .eq('group_id', groupId);

    if (fetchError) throw fetchError;

    groupPermissions.value = (data || []).map(p => ({
      ...p,
      category_name: p.category?.name
    }));
  } catch (err: any) {
    console.error('Error fetching permissions:', err);
  } finally {
    loadingPermissions.value = false;
  }
}

async function fetchGroupMembers(groupId: string) {
  loadingMembers.value = true;

  try {
    const { data, error: fetchError } = await supabase
      .from('user_group_members')
      .select(`
        *,
        user:users(full_name, email, username)
      `)
      .eq('group_id', groupId);

    if (fetchError) throw fetchError;

    groupMembers.value = (data || []).map(m => ({
      ...m,
      user_name: m.user?.full_name,
      user_email: m.user?.email
    }));
  } catch (err: any) {
    console.error('Error fetching members:', err);
  } finally {
    loadingMembers.value = false;
  }
}

async function fetchCategories() {
  try {
    const { data, error: fetchError } = await supabase
      .from('document_categories')
      .select('*')
      .order('name');

    if (fetchError) throw fetchError;
    categories.value = data || [];
  } catch (err) {
    console.error('Error fetching categories:', err);
  }
}

async function fetchUsers() {
  try {
    const { data, error: fetchError } = await supabase
      .from('users')
      .select('id, full_name, email, username')
      .eq('is_active', true)
      .order('full_name');

    if (fetchError) throw fetchError;
    users.value = data || [];
  } catch (err) {
    console.error('Error fetching users:', err);
  }
}

const selectGroup = (group: any) => {
  selectedGroup.value = group;
  fetchPermissions(group.id);
  fetchGroupMembers(group.id);
};

const openAddPermissionModal = () => {
  permissionForm.value = {
    resource_type: '',
    action: '',
    category_id: null
  };
  showPermissionModal.value = true;
};

const closeGroupModal = () => {
  showGroupModal.value = false;
  groupForm.value = { name: '', description: '' };
};

const closePermissionModal = () => {
  showPermissionModal.value = false;
  permissionForm.value = { resource_type: '', action: '', category_id: null };
};

async function handleAddGroup() {
  savingGroup.value = true;

  try {
    const { error: insertError } = await supabase
      .from('user_groups')
      .insert({
        name: groupForm.value.name,
        description: groupForm.value.description || null
      });

    if (insertError) throw insertError;

    await fetchGroups();
    closeGroupModal();
  } catch (err: any) {
    alert('خطا در افزودن گروه: ' + err.message);
  } finally {
    savingGroup.value = false;
  }
}

async function handleAddPermission() {
  savingPermission.value = true;

  try {
    const { error: insertError } = await supabase
      .from('permissions')
      .insert({
        group_id: selectedGroup.value.id,
        resource_type: permissionForm.value.resource_type,
        action: permissionForm.value.action,
        category_id: permissionForm.value.resource_type === 'documents' ? permissionForm.value.category_id : null
      });

    if (insertError) throw insertError;

    await fetchPermissions(selectedGroup.value.id);
    closePermissionModal();
  } catch (err: any) {
    alert('خطا در افزودن دسترسی: ' + err.message);
  } finally {
    savingPermission.value = false;
  }
}

async function deletePermission(permission: any) {
  if (!confirm('آیا از حذف این دسترسی اطمینان دارید؟')) {
    return;
  }

  try {
    const { error: deleteError } = await supabase
      .from('permissions')
      .delete()
      .eq('id', permission.id);

    if (deleteError) throw deleteError;

    groupPermissions.value = groupPermissions.value.filter(p => p.id !== permission.id);
  } catch (err: any) {
    alert('خطا در حذف دسترسی: ' + err.message);
  }
}

async function addUserToGroup() {
  if (!selectedUserId.value) return;

  try {
    const { error: insertError } = await supabase
      .from('user_group_members')
      .insert({
        group_id: selectedGroup.value.id,
        user_id: selectedUserId.value
      });

    if (insertError) throw insertError;

    await fetchGroupMembers(selectedGroup.value.id);
    selectedUserId.value = '';
  } catch (err: any) {
    alert('خطا در افزودن کاربر به گروه: ' + err.message);
  }
}

async function removeUserFromGroup(member: any) {
  if (!confirm('آیا از حذف این کاربر از گروه اطمینان دارید؟')) {
    return;
  }

  try {
    const { error: deleteError } = await supabase
      .from('user_group_members')
      .delete()
      .eq('id', member.id);

    if (deleteError) throw deleteError;

    groupMembers.value = groupMembers.value.filter(m => m.id !== member.id);
  } catch (err: any) {
    alert('خطا در حذف کاربر از گروه: ' + err.message);
  }
}

fetchGroups();
fetchCategories();
fetchUsers();
</script>
