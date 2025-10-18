<template>
  <div class="space-y-6">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">مدیریت اسناد</h1>
        <p class="text-gray-600 mt-1">مشاهده و مدیریت تمام اسناد</p>
      </div>
      <button
        @click="router.push({ name: 'document-upload' })"
        class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
      >
        <Plus class="w-5 h-5" />
        بارگذاری سند جدید
      </button>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="relative">
          <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
            <Search class="h-5 w-5 text-gray-400" />
          </div>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="جستجو در اسناد..."
            class="block w-full pr-10 pl-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <select
          v-model="filterStatus"
          class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"
        >
          <option value="">همه وضعیت‌ها</option>
          <option value="draft">پیش‌نویس</option>
          <option value="pending">در انتظار تایید</option>
          <option value="approved">تایید شده</option>
          <option value="rejected">رد شده</option>
        </select>

        <select
          v-model="filterCategory"
          class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"
        >
          <option value="">همه دسته‌بندی‌ها</option>
          <option value="contracts">قراردادها</option>
          <option value="reports">گزارشات</option>
          <option value="minutes">صورتجلسات</option>
          <option value="financial">مالی</option>
          <option value="hr">پرسنلی</option>
        </select>

        <div class="flex gap-2">
          <button
            @click="viewMode = 'grid'"
            :class="viewMode === 'grid' ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-600'"
            class="flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-lg transition-colors"
          >
            <Grid class="w-5 h-5" />
          </button>
          <button
            @click="viewMode = 'list'"
            :class="viewMode === 'list' ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-600'"
            class="flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-lg transition-colors"
          >
            <List class="w-5 h-5" />
          </button>
        </div>
      </div>

      <div v-if="viewMode === 'grid'" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="doc in filteredDocuments"
          :key="doc.id"
          @click="router.push({ name: 'document-detail', params: { id: doc.id } })"
          class="bg-gray-50 rounded-lg p-4 hover:bg-gray-100 transition-colors cursor-pointer border border-gray-200"
        >
          <div class="flex items-start justify-between mb-3">
            <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <FileText class="w-6 h-6 text-blue-600" />
            </div>
            <span
              :class="{
                'bg-green-100 text-green-700': doc.status === 'approved',
                'bg-yellow-100 text-yellow-700': doc.status === 'pending',
                'bg-red-100 text-red-700': doc.status === 'rejected',
                'bg-gray-100 text-gray-700': doc.status === 'draft'
              }"
              class="px-2 py-1 text-xs font-medium rounded-full"
            >
              {{ getStatusLabel(doc.status) }}
            </span>
          </div>
          <h3 class="font-semibold text-gray-900 mb-2 line-clamp-2">{{ doc.title }}</h3>
          <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ doc.description }}</p>
          <div class="flex items-center justify-between text-xs text-gray-500">
            <span>{{ doc.file_size }} کیلوبایت</span>
            <span>{{ doc.uploaded_at }}</span>
          </div>
          <div class="flex items-center gap-2 mt-3 pt-3 border-t border-gray-200">
            <button
              @click.stop="viewDocument(doc.id)"
              class="flex-1 flex items-center justify-center gap-1 px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded text-sm transition-colors"
            >
              <Eye class="w-4 h-4" />
              مشاهده
            </button>
            <button
              @click.stop="downloadDocument(doc.id)"
              class="flex items-center justify-center gap-1 px-3 py-1.5 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded text-sm transition-colors"
            >
              <Download class="w-4 h-4" />
            </button>
            <button
              v-if="authStore.isAdmin"
              @click.stop="deleteDocument(doc.id)"
              class="flex items-center justify-center gap-1 px-3 py-1.5 bg-red-100 hover:bg-red-200 text-red-700 rounded text-sm transition-colors"
            >
              <Trash2 class="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      <div v-else class="space-y-2">
        <div
          v-for="doc in filteredDocuments"
          :key="doc.id"
          @click="router.push({ name: 'document-detail', params: { id: doc.id } })"
          class="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer border border-gray-200"
        >
          <div class="flex items-center gap-4 flex-1">
            <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center flex-shrink-0">
              <FileText class="w-5 h-5 text-blue-600" />
            </div>
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold text-gray-900 truncate">{{ doc.title }}</h3>
              <p class="text-sm text-gray-600 truncate">{{ doc.description }}</p>
            </div>
            <div class="flex items-center gap-4">
              <span class="text-sm text-gray-600">{{ doc.file_size }} KB</span>
              <span class="text-sm text-gray-600">{{ doc.uploaded_at }}</span>
              <span
                :class="{
                  'bg-green-100 text-green-700': doc.status === 'approved',
                  'bg-yellow-100 text-yellow-700': doc.status === 'pending',
                  'bg-red-100 text-red-700': doc.status === 'rejected',
                  'bg-gray-100 text-gray-700': doc.status === 'draft'
                }"
                class="px-2 py-1 text-xs font-medium rounded-full"
              >
                {{ getStatusLabel(doc.status) }}
              </span>
              <div class="flex items-center gap-2">
                <button
                  @click.stop="viewDocument(doc.id)"
                  class="p-2 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded transition-colors"
                >
                  <Eye class="w-4 h-4" />
                </button>
                <button
                  @click.stop="downloadDocument(doc.id)"
                  class="p-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded transition-colors"
                >
                  <Download class="w-4 h-4" />
                </button>
                <button
                  v-if="authStore.isAdmin"
                  @click.stop="deleteDocument(doc.id)"
                  class="p-2 bg-red-100 hover:bg-red-200 text-red-700 rounded transition-colors"
                >
                  <Trash2 class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="filteredDocuments.length === 0" class="text-center py-12">
        <FileText class="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <p class="text-gray-600">هیچ سندی یافت نشد</p>
      </div>
    </div>

    <div class="flex items-center justify-between">
      <p class="text-sm text-gray-600">
        نمایش {{ filteredDocuments.length }} سند از {{ totalDocuments }} سند
      </p>
      <div class="flex gap-2">
        <button class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
          قبلی
        </button>
        <button class="px-4 py-2 bg-blue-600 text-white rounded-lg">1</button>
        <button class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
          2
        </button>
        <button class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
          3
        </button>
        <button class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
          بعدی
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { Search, Plus, FileText, Eye, Download, Trash2, List, Grid } from 'lucide-vue-next';

const router = useRouter();
const authStore = useAuthStore();

const searchQuery = ref('');
const filterStatus = ref('');
const filterCategory = ref('');
const viewMode = ref<'grid' | 'list'>('grid');

const documents = ref([
  {
    id: '1',
    title: 'قرارداد همکاری با شرکت تکنو پارس',
    description: 'قرارداد همکاری در زمینه توسعه نرم‌افزار',
    file_name: 'contract-techno.pdf',
    file_size: 2450,
    file_type: 'application/pdf',
    category: 'contracts',
    uploaded_at: '1403/07/15',
    status: 'pending'
  },
  {
    id: '2',
    title: 'گزارش عملکرد ماهانه شهریور',
    description: 'گزارش کامل عملکرد واحدهای مختلف',
    file_name: 'monthly-report.pdf',
    file_size: 3200,
    file_type: 'application/pdf',
    category: 'reports',
    uploaded_at: '1403/07/14',
    status: 'approved'
  },
  {
    id: '3',
    title: 'صورتجلسه جلسه هیئت مدیره',
    description: 'صورتجلسه جلسه مورخ 1403/07/10',
    file_name: 'meeting-minutes.pdf',
    file_size: 1800,
    file_type: 'application/pdf',
    category: 'minutes',
    uploaded_at: '1403/07/13',
    status: 'approved'
  },
  {
    id: '4',
    title: 'درخواست خرید تجهیزات IT',
    description: 'درخواست خرید سرور و تجهیزات شبکه',
    file_name: 'purchase-request.pdf',
    file_size: 1500,
    file_type: 'application/pdf',
    category: 'financial',
    uploaded_at: '1403/07/12',
    status: 'draft'
  },
  {
    id: '5',
    title: 'گزارش حسابرسی سه‌ماهه',
    description: 'گزارش حسابرسی مالی سه‌ماهه دوم',
    file_name: 'audit-report.pdf',
    file_size: 4100,
    file_type: 'application/pdf',
    category: 'financial',
    uploaded_at: '1403/07/11',
    status: 'approved'
  },
  {
    id: '6',
    title: 'فرم درخواست مرخصی',
    description: 'فرم استاندارد درخواست مرخصی پرسنل',
    file_name: 'leave-form.pdf',
    file_size: 850,
    file_type: 'application/pdf',
    category: 'hr',
    uploaded_at: '1403/07/10',
    status: 'rejected'
  }
]);

const totalDocuments = computed(() => documents.value.length);

const filteredDocuments = computed(() => {
  return documents.value.filter(doc => {
    const matchesSearch = doc.title.includes(searchQuery.value) ||
                         doc.description.includes(searchQuery.value);
    const matchesStatus = !filterStatus.value || doc.status === filterStatus.value;
    const matchesCategory = !filterCategory.value || doc.category === filterCategory.value;

    return matchesSearch && matchesStatus && matchesCategory;
  });
});

const getStatusLabel = (status: string) => {
  const labels = {
    draft: 'پیش‌نویس',
    pending: 'در انتظار',
    approved: 'تایید شده',
    rejected: 'رد شده'
  };
  return labels[status as keyof typeof labels] || status;
};

const viewDocument = (id: string) => {
  router.push({ name: 'document-detail', params: { id } });
};

const downloadDocument = (id: string) => {
  console.log('Downloading document:', id);
};

const deleteDocument = (id: string) => {
  if (confirm('آیا از حذف این سند اطمینان دارید؟')) {
    documents.value = documents.value.filter(doc => doc.id !== id);
  }
};
</script>
