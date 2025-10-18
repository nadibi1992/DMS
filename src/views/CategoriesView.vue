<template>
  <div class="space-y-6">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">مدیریت دسته‌بندی‌ها</h1>
        <p class="text-gray-600 mt-1">مشاهده و مدیریت دسته‌بندی‌های اسناد</p>
      </div>
      <button
        @click="openAddModal"
        class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
      >
        <FolderPlus class="w-5 h-5" />
        افزودن دسته‌بندی جدید
      </button>
    </div>

    <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-lg">
      {{ error }}
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div class="mb-6">
        <div class="relative">
          <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
            <Search class="h-5 w-5 text-gray-400" />
          </div>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="جستجو در دسته‌بندی‌ها..."
            class="block w-full pr-10 pl-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      <div v-if="loading" class="text-center py-12">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="category in filteredCategories"
          :key="category.id"
          class="bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg p-6 border border-gray-200 hover:shadow-md transition-all"
        >
          <div class="flex items-start justify-between mb-4">
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center">
                <Folder class="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900">{{ category.name }}</h3>
                <p v-if="category.parent_id" class="text-xs text-gray-500">
                  زیرمجموعه: {{ getParentName(category.parent_id) }}
                </p>
              </div>
            </div>
          </div>

          <p v-if="category.description" class="text-sm text-gray-700 mb-4 line-clamp-2">
            {{ category.description }}
          </p>

          <div class="flex items-center justify-between pt-4 border-t border-gray-200">
            <p class="text-xs text-gray-600">
              {{ formatDate(category.created_at) }}
            </p>
            <div class="flex items-center gap-2">
              <button
                @click="editCategory(category)"
                class="p-2 text-blue-600 hover:bg-blue-50 rounded transition-colors"
                title="ویرایش"
              >
                <Edit class="w-4 h-4" />
              </button>
              <button
                @click="deleteCategory(category)"
                class="p-2 text-red-600 hover:bg-red-50 rounded transition-colors"
                title="حذف"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="!loading && filteredCategories.length === 0" class="text-center py-12">
        <Folder class="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <p class="text-gray-600">هیچ دسته‌بندی یافت نشد</p>
      </div>
    </div>

    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">
              {{ editingCategory ? 'ویرایش دسته‌بندی' : 'افزودن دسته‌بندی جدید' }}
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

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              نام دسته‌بندی
              <span class="text-red-500">*</span>
            </label>
            <input
              v-model="categoryForm.name"
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
              v-model="categoryForm.description"
              rows="3"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              دسته‌بندی والد
            </label>
            <select
              v-model="categoryForm.parent_id"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option :value="null">بدون والد (دسته‌بندی اصلی)</option>
              <option
                v-for="cat in parentCategories"
                :key="cat.id"
                :value="cat.id"
              >
                {{ cat.name }}
              </option>
            </select>
            <p class="text-xs text-gray-500 mt-1">می‌توانید این دسته‌بندی را زیرمجموعه یک دسته‌بندی دیگر قرار دهید</p>
          </div>

          <div class="flex items-center gap-2 pt-4 border-t border-gray-200">
            <button
              type="submit"
              :disabled="saving"
              class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ saving ? 'در حال پردازش...' : (editingCategory ? 'ذخیره تغییرات' : 'افزودن دسته‌بندی') }}
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { supabase } from '@/config/supabase';
import { Search, FolderPlus, Folder, Edit, Trash2, X } from 'lucide-vue-next';

const searchQuery = ref('');
const showModal = ref(false);
const editingCategory = ref<any>(null);
const loading = ref(true);
const error = ref<string | null>(null);
const saving = ref(false);
const formError = ref<string | null>(null);

const categoryForm = ref({
  name: '',
  description: '',
  parent_id: null as string | null
});

const categories = ref<any[]>([]);

const filteredCategories = computed(() => {
  if (!searchQuery.value) return categories.value;

  const query = searchQuery.value.toLowerCase();
  return categories.value.filter(cat =>
    cat.name.toLowerCase().includes(query) ||
    (cat.description && cat.description.toLowerCase().includes(query))
  );
});

const parentCategories = computed(() => {
  if (editingCategory.value) {
    return categories.value.filter(cat => cat.id !== editingCategory.value.id);
  }
  return categories.value;
});

const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('fa-IR').format(date);
};

const getParentName = (parentId: string) => {
  const parent = categories.value.find(cat => cat.id === parentId);
  return parent ? parent.name : '-';
};

async function fetchCategories() {
  loading.value = true;
  error.value = null;

  try {
    const { data, error: fetchError } = await supabase
      .from('document_categories')
      .select('*')
      .order('created_at', { ascending: false });

    if (fetchError) throw fetchError;

    categories.value = data || [];
  } catch (err: any) {
    error.value = err.message || 'خطا در بارگذاری دسته‌بندی‌ها';
  } finally {
    loading.value = false;
  }
}

const openAddModal = () => {
  showModal.value = true;
  formError.value = null;
};

const editCategory = (category: any) => {
  editingCategory.value = category;
  categoryForm.value = {
    name: category.name,
    description: category.description || '',
    parent_id: category.parent_id || null
  };
  showModal.value = true;
  formError.value = null;
};

async function deleteCategory(category: any) {
  const hasChildren = categories.value.some(cat => cat.parent_id === category.id);

  if (hasChildren) {
    alert('این دسته‌بندی دارای زیرمجموعه است. ابتدا زیرمجموعه‌ها را حذف کنید.');
    return;
  }

  if (!confirm(`آیا از حذف دسته‌بندی "${category.name}" اطمینان دارید؟`)) {
    return;
  }

  try {
    const { error: deleteError } = await supabase
      .from('document_categories')
      .delete()
      .eq('id', category.id);

    if (deleteError) throw deleteError;

    categories.value = categories.value.filter(cat => cat.id !== category.id);
  } catch (err: any) {
    alert('خطا در حذف دسته‌بندی: ' + err.message);
  }
}

const closeModal = () => {
  showModal.value = false;
  editingCategory.value = null;
  categoryForm.value = {
    name: '',
    description: '',
    parent_id: null
  };
  formError.value = null;
};

async function handleSubmit() {
  saving.value = true;
  formError.value = null;

  try {
    if (editingCategory.value) {
      const { error: updateError } = await supabase
        .from('document_categories')
        .update({
          name: categoryForm.value.name,
          description: categoryForm.value.description || null,
          parent_id: categoryForm.value.parent_id
        })
        .eq('id', editingCategory.value.id);

      if (updateError) throw updateError;

      Object.assign(editingCategory.value, {
        name: categoryForm.value.name,
        description: categoryForm.value.description,
        parent_id: categoryForm.value.parent_id
      });
    } else {
      const { error: insertError } = await supabase
        .from('document_categories')
        .insert({
          name: categoryForm.value.name,
          description: categoryForm.value.description || null,
          parent_id: categoryForm.value.parent_id
        });

      if (insertError) throw insertError;

      await fetchCategories();
    }

    closeModal();
  } catch (err: any) {
    formError.value = err.message || 'خطا در ذخیره اطلاعات';
  } finally {
    saving.value = false;
  }
}

onMounted(() => {
  fetchCategories();
});
</script>
