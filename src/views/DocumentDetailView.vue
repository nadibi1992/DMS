<template>
  <div class="space-y-6">
    <div class="flex items-center gap-4">
      <button
        @click="router.back()"
        class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
      >
        <ArrowRight class="w-6 h-6" />
      </button>
      <div class="flex-1">
        <h1 class="text-3xl font-bold text-gray-900">جزئیات سند</h1>
        <p class="text-gray-600 mt-1">مشاهده و مدیریت اطلاعات سند</p>
      </div>
      <div class="flex items-center gap-2">
        <button
          @click="downloadDocument"
          class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
        >
          <Download class="w-5 h-5" />
          دانلود
        </button>
        <button
          v-if="authStore.isAdmin"
          @click="showActions = !showActions"
          class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
        >
          <MoreVertical class="w-6 h-6" />
        </button>
      </div>
    </div>

    <div v-if="showActions" class="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
      <div class="flex items-center gap-2">
        <button
          @click="approveDocument"
          class="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors"
        >
          <Check class="w-5 h-5" />
          تایید سند
        </button>
        <button
          @click="rejectDocument"
          class="flex items-center gap-2 px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg transition-colors"
        >
          <X class="w-5 h-5" />
          رد سند
        </button>
        <button
          @click="editDocument"
          class="flex items-center gap-2 px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-lg transition-colors"
        >
          <Edit class="w-5 h-5" />
          ویرایش
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold text-gray-900">{{ document.title }}</h2>
            <span
              :class="{
                'bg-green-100 text-green-700': document.status === 'approved',
                'bg-yellow-100 text-yellow-700': document.status === 'pending',
                'bg-red-100 text-red-700': document.status === 'rejected',
                'bg-gray-100 text-gray-700': document.status === 'draft'
              }"
              class="px-3 py-1 text-sm font-medium rounded-full"
            >
              {{ getStatusLabel(document.status) }}
            </span>
          </div>

          <div class="aspect-[16/10] bg-gray-100 rounded-lg mb-6 flex items-center justify-center">
            <FileText class="w-24 h-24 text-gray-400" />
          </div>

          <div class="space-y-4">
            <div>
              <h3 class="text-sm font-medium text-gray-700 mb-1">توضیحات</h3>
              <p class="text-gray-900">{{ document.description }}</p>
            </div>

            <div v-if="document.tags && document.tags.length > 0">
              <h3 class="text-sm font-medium text-gray-700 mb-2">برچسب‌ها</h3>
              <div class="flex flex-wrap gap-2">
                <span
                  v-for="tag in document.tags"
                  :key="tag"
                  class="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm"
                >
                  {{ tag }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">نسخه‌های سند</h2>
          <div class="space-y-3">
            <div
              v-for="version in versions"
              :key="version.id"
              class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
            >
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                  <FileText class="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">نسخه {{ version.version }}</p>
                  <p class="text-xs text-gray-600">{{ version.uploaded_at }}</p>
                </div>
              </div>
              <button class="px-3 py-1 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded text-sm transition-colors">
                دانلود
              </button>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">نظرات</h2>
          <div class="space-y-4 mb-4">
            <div
              v-for="comment in comments"
              :key="comment.id"
              class="flex gap-3 p-3 bg-gray-50 rounded-lg"
            >
              <div class="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-medium flex-shrink-0">
                {{ comment.user_name.charAt(0) }}
              </div>
              <div class="flex-1">
                <div class="flex items-center justify-between mb-1">
                  <p class="text-sm font-medium text-gray-900">{{ comment.user_name }}</p>
                  <p class="text-xs text-gray-600">{{ comment.created_at }}</p>
                </div>
                <p class="text-sm text-gray-700">{{ comment.content }}</p>
              </div>
            </div>
          </div>

          <div class="border-t border-gray-200 pt-4">
            <textarea
              v-model="newComment"
              rows="3"
              placeholder="نظر خود را بنویسید..."
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
            ></textarea>
            <button
              @click="addComment"
              class="mt-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
            >
              ارسال نظر
            </button>
          </div>
        </div>
      </div>

      <div class="space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">اطلاعات سند</h2>
          <div class="space-y-3">
            <div>
              <p class="text-sm text-gray-600">نام فایل</p>
              <p class="text-sm font-medium text-gray-900">{{ document.file_name }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">حجم فایل</p>
              <p class="text-sm font-medium text-gray-900">{{ document.file_size }} کیلوبایت</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">نوع فایل</p>
              <p class="text-sm font-medium text-gray-900">{{ document.file_type }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">دسته‌بندی</p>
              <p class="text-sm font-medium text-gray-900">{{ getCategoryLabel(document.category) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">نسخه فعلی</p>
              <p class="text-sm font-medium text-gray-900">{{ document.version }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">بارگذاری شده توسط</p>
              <p class="text-sm font-medium text-gray-900">{{ document.uploaded_by }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">تاریخ بارگذاری</p>
              <p class="text-sm font-medium text-gray-900">{{ document.uploaded_at }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">آخرین ویرایش</p>
              <p class="text-sm font-medium text-gray-900">{{ document.updated_at }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">فعالیت‌های اخیر</h2>
          <div class="space-y-3">
            <div
              v-for="activity in activities"
              :key="activity.id"
              class="flex gap-3"
            >
              <div
                :class="{
                  'bg-blue-100': activity.action.includes('بارگذاری'),
                  'bg-green-100': activity.action.includes('تایید'),
                  'bg-yellow-100': activity.action.includes('ویرایش')
                }"
                class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
              >
                <div
                  :class="{
                    'text-blue-600': activity.action.includes('بارگذاری'),
                    'text-green-600': activity.action.includes('تایید'),
                    'text-yellow-600': activity.action.includes('ویرایش')
                  }"
                  class="w-2 h-2 rounded-full bg-current"
                ></div>
              </div>
              <div class="flex-1">
                <p class="text-sm text-gray-900">{{ activity.action }}</p>
                <p class="text-xs text-gray-600">{{ activity.created_at }}</p>
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
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { ArrowRight, Download, Edit, MoreVertical, FileText, Check, X } from 'lucide-vue-next';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

const showActions = ref(false);
const newComment = ref('');

const document = ref({
  id: route.params.id,
  title: 'قرارداد همکاری با شرکت تکنو پارس',
  description: 'قرارداد همکاری در زمینه توسعه نرم‌افزار و ارائه خدمات فنی به شرکت تکنو پارس. این قرارداد شامل شرایط و ضوابط همکاری، تعهدات طرفین، و جزئیات مالی می‌باشد.',
  file_name: 'contract-techno.pdf',
  file_size: 2450,
  file_type: 'application/pdf',
  category: 'contracts',
  version: 3,
  uploaded_by: 'علی احمدی',
  uploaded_at: '1403/07/15 - 14:30',
  updated_at: '1403/07/16 - 09:15',
  status: 'pending',
  tags: ['قرارداد', 'تکنو پارس', 'توسعه نرم‌افزار', 'همکاری']
});

const versions = ref([
  {
    id: '1',
    version: 3,
    uploaded_at: '1403/07/16 - 09:15'
  },
  {
    id: '2',
    version: 2,
    uploaded_at: '1403/07/15 - 16:20'
  },
  {
    id: '3',
    version: 1,
    uploaded_at: '1403/07/15 - 14:30'
  }
]);

const comments = ref([
  {
    id: '1',
    user_name: 'سارا محمدی',
    content: 'لطفا بند 3 قرارداد را بررسی و اصلاح کنید.',
    created_at: '1403/07/15 - 15:30'
  },
  {
    id: '2',
    user_name: 'رضا کریمی',
    content: 'موارد مالی تایید شد.',
    created_at: '1403/07/16 - 10:00'
  }
]);

const activities = ref([
  {
    id: '1',
    action: 'رضا کریمی نسخه جدیدی بارگذاری کرد',
    created_at: '1403/07/16 - 09:15'
  },
  {
    id: '2',
    action: 'سارا محمدی نظری ثبت کرد',
    created_at: '1403/07/15 - 15:30'
  },
  {
    id: '3',
    action: 'علی احمدی سند را بارگذاری کرد',
    created_at: '1403/07/15 - 14:30'
  }
]);

const getStatusLabel = (status: string) => {
  const labels = {
    draft: 'پیش‌نویس',
    pending: 'در انتظار',
    approved: 'تایید شده',
    rejected: 'رد شده'
  };
  return labels[status as keyof typeof labels] || status;
};

const getCategoryLabel = (category: string) => {
  const labels = {
    contracts: 'قراردادها',
    reports: 'گزارشات',
    minutes: 'صورتجلسات',
    financial: 'مالی',
    hr: 'پرسنلی'
  };
  return labels[category as keyof typeof labels] || category;
};

const downloadDocument = () => {
  console.log('Downloading document');
};

const approveDocument = () => {
  document.value.status = 'approved';
  showActions.value = false;
};

const rejectDocument = () => {
  document.value.status = 'rejected';
  showActions.value = false;
};

const editDocument = () => {
  console.log('Edit document');
};

const addComment = () => {
  if (newComment.value.trim()) {
    comments.value.unshift({
      id: String(comments.value.length + 1),
      user_name: authStore.user?.fullName || 'کاربر',
      content: newComment.value,
      created_at: 'همین الان'
    });
    newComment.value = '';
  }
};
</script>
