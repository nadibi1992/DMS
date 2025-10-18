<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">داشبورد</h1>
        <p class="text-gray-600 mt-1">خوش آمدید، {{ authStore.user?.fullName }}</p>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <StatCard
        title="کل اسناد"
        :value="stats.totalDocuments"
        icon="FileText"
        color="blue"
        trend="+12%"
      />
      <StatCard
        title="در انتظار تایید"
        :value="stats.pendingDocuments"
        icon="Clock"
        color="yellow"
        trend="+5%"
      />
      <StatCard
        title="تایید شده امروز"
        :value="stats.approvedToday"
        icon="CheckCircle"
        color="green"
        trend="+8%"
      />
      <StatCard
        title="کاربران فعال"
        :value="stats.activeUsers"
        icon="Users"
        color="purple"
        trend="+3%"
      />
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">آخرین اسناد بارگذاری شده</h2>
        <div class="space-y-3">
          <div
            v-for="doc in recentDocuments"
            :key="doc.id"
            class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer"
            @click="router.push({ name: 'document-detail', params: { id: doc.id } })"
          >
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <FileText class="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900">{{ doc.title }}</p>
                <p class="text-xs text-gray-600">{{ doc.uploaded_at }}</p>
              </div>
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
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">فعالیت‌های اخیر</h2>
        <div class="space-y-4">
          <div
            v-for="activity in recentActivities"
            :key="activity.id"
            class="flex items-start gap-3"
          >
            <div
              :class="{
                'bg-blue-100': activity.action.includes('بارگذاری'),
                'bg-green-100': activity.action.includes('تایید'),
                'bg-yellow-100': activity.action.includes('ویرایش'),
                'bg-red-100': activity.action.includes('حذف')
              }"
              class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
            >
              <Activity
                :class="{
                  'text-blue-600': activity.action.includes('بارگذاری'),
                  'text-green-600': activity.action.includes('تایید'),
                  'text-yellow-600': activity.action.includes('ویرایش'),
                  'text-red-600': activity.action.includes('حذف')
                }"
                class="w-4 h-4"
              />
            </div>
            <div class="flex-1">
              <p class="text-sm text-gray-900">{{ activity.action }}</p>
              <p class="text-xs text-gray-600">{{ activity.created_at }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-semibold text-gray-900">دسته‌بندی‌های پرکاربرد</h2>
          <TrendingUp class="w-5 h-5 text-gray-400" />
        </div>
        <div class="space-y-3">
          <div v-for="cat in topCategories" :key="cat.id" class="flex items-center justify-between">
            <span class="text-sm text-gray-700">{{ cat.name }}</span>
            <span class="text-sm font-medium text-gray-900">{{ cat.count }}</span>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-semibold text-gray-900">وضعیت ذخیره‌سازی</h2>
          <HardDrive class="w-5 h-5 text-gray-400" />
        </div>
        <div class="space-y-4">
          <div>
            <div class="flex items-center justify-between text-sm mb-2">
              <span class="text-gray-700">فضای استفاده شده</span>
              <span class="font-medium text-gray-900">{{ storage.used }} GB</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-blue-600 h-2 rounded-full"
                :style="{ width: `${storage.percentage}%` }"
              ></div>
            </div>
            <p class="text-xs text-gray-600 mt-1">از {{ storage.total }} GB</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-semibold text-gray-900">دسترسی سریع</h2>
          <Zap class="w-5 h-5 text-gray-400" />
        </div>
        <div class="space-y-2">
          <button
            @click="router.push({ name: 'document-upload' })"
            class="w-full flex items-center gap-2 px-4 py-2 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-lg transition-colors text-sm"
          >
            <Upload class="w-4 h-4" />
            بارگذاری سند جدید
          </button>
          <button
            @click="router.push({ name: 'documents' })"
            class="w-full flex items-center gap-2 px-4 py-2 bg-gray-50 hover:bg-gray-100 text-gray-700 rounded-lg transition-colors text-sm"
          >
            <Search class="w-4 h-4" />
            جستجو در اسناد
          </button>
          <button
            @click="router.push({ name: 'reports' })"
            class="w-full flex items-center gap-2 px-4 py-2 bg-gray-50 hover:bg-gray-100 text-gray-700 rounded-lg transition-colors text-sm"
          >
            <BarChart3 class="w-4 h-4" />
            مشاهده گزارشات
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import StatCard from '@/components/dashboard/StatCard.vue';
import {
  FileText,
  Clock,
  CheckCircle,
  Users,
  Activity,
  TrendingUp,
  HardDrive,
  Zap,
  Upload,
  Search,
  BarChart3
} from 'lucide-vue-next';

const router = useRouter();
const authStore = useAuthStore();

const stats = ref({
  totalDocuments: 1247,
  pendingDocuments: 23,
  approvedToday: 15,
  activeUsers: 45
});

const recentDocuments = ref([
  {
    id: '1',
    title: 'قرارداد همکاری با شرکت تکنو',
    uploaded_at: '1403/07/15 - 14:30',
    status: 'pending'
  },
  {
    id: '2',
    title: 'گزارش عملکرد ماهانه شهریور',
    uploaded_at: '1403/07/14 - 10:15',
    status: 'approved'
  },
  {
    id: '3',
    title: 'صورتجلسه جلسه هیئت مدیره',
    uploaded_at: '1403/07/13 - 16:45',
    status: 'approved'
  },
  {
    id: '4',
    title: 'درخواست خرید تجهیزات IT',
    uploaded_at: '1403/07/12 - 09:20',
    status: 'draft'
  }
]);

const recentActivities = ref([
  {
    id: '1',
    action: 'علی احمدی سند "قرارداد همکاری" را بارگذاری کرد',
    created_at: '30 دقیقه پیش'
  },
  {
    id: '2',
    action: 'سارا محمدی سند "گزارش مالی" را تایید کرد',
    created_at: '1 ساعت پیش'
  },
  {
    id: '3',
    action: 'رضا کریمی سند "صورتجلسه" را ویرایش کرد',
    created_at: '2 ساعت پیش'
  },
  {
    id: '4',
    action: 'مریم رضایی سند "درخواست خرید" را بارگذاری کرد',
    created_at: '3 ساعت پیش'
  }
]);

const topCategories = ref([
  { id: '1', name: 'قراردادها', count: 300 },
  { id: '2', name: 'گزارشات', count: 250 },
  { id: '3', name: 'صورتجلسات', count: 200 },
  { id: '4', name: 'مالی', count: 180 }
]);

const storage = ref({
  used: 125,
  total: 500,
  percentage: 25
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
</script>
