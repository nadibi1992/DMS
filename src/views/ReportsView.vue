<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">گزارشات و آمار</h1>
        <p class="text-gray-600 mt-1">مشاهده گزارشات و تحلیل‌های سیستم</p>
      </div>
      <button class="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors">
        <Download class="w-5 h-5" />
        خروجی Excel
      </button>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div class="flex flex-col md:flex-row gap-4 mb-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">از تاریخ</label>
          <input
            v-model="dateFrom"
            type="text"
            class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"
            placeholder="1403/01/01"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">تا تاریخ</label>
          <input
            v-model="dateTo"
            type="text"
            class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"
            placeholder="1403/07/15"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">دسته‌بندی</label>
          <select v-model="filterCategory" class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
            <option value="">همه دسته‌ها</option>
            <option value="contracts">قراردادها</option>
            <option value="reports">گزارشات</option>
            <option value="minutes">صورتجلسات</option>
            <option value="financial">مالی</option>
            <option value="hr">پرسنلی</option>
          </select>
        </div>
        <div class="flex items-end">
          <button class="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors">
            اعمال فیلتر
          </button>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-sm p-6 text-white">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
            <FileText class="w-6 h-6" />
          </div>
          <TrendingUp class="w-6 h-6 opacity-75" />
        </div>
        <p class="text-3xl font-bold mb-1">1,247</p>
        <p class="text-sm opacity-90">کل اسناد</p>
      </div>

      <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-sm p-6 text-white">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
            <CheckCircle class="w-6 h-6" />
          </div>
          <TrendingUp class="w-6 h-6 opacity-75" />
        </div>
        <p class="text-3xl font-bold mb-1">1,180</p>
        <p class="text-sm opacity-90">اسناد تایید شده</p>
      </div>

      <div class="bg-gradient-to-br from-yellow-500 to-yellow-600 rounded-xl shadow-sm p-6 text-white">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
            <Clock class="w-6 h-6" />
          </div>
          <TrendingUp class="w-6 h-6 opacity-75" />
        </div>
        <p class="text-3xl font-bold mb-1">23</p>
        <p class="text-sm opacity-90">در انتظار تایید</p>
      </div>

      <div class="bg-gradient-to-br from-red-500 to-red-600 rounded-xl shadow-sm p-6 text-white">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
            <XCircle class="w-6 h-6" />
          </div>
          <TrendingDown class="w-6 h-6 opacity-75" />
        </div>
        <p class="text-3xl font-bold mb-1">44</p>
        <p class="text-sm opacity-90">اسناد رد شده</p>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-6">روند بارگذاری اسناد (6 ماه اخیر)</h2>
        <div class="h-80">
          <Line :data="uploadTrendData" :options="chartOptions" />
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-6">توزیع اسناد بر اساس دسته‌بندی</h2>
        <div class="h-80">
          <Bar :data="categoryData" :options="barChartOptions" />
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-6">وضعیت اسناد</h2>
        <div class="h-80">
          <Doughnut :data="statusData" :options="doughnutOptions" />
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-6">فعالیت کاربران (تعداد بارگذاری)</h2>
        <div class="space-y-4">
          <div v-for="user in topUsers" :key="user.id" class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-medium text-sm">
                {{ user.name.charAt(0) }}
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900">{{ user.name }}</p>
                <p class="text-xs text-gray-600">{{ user.department }}</p>
              </div>
            </div>
            <div class="flex items-center gap-4">
              <div class="flex-1 bg-gray-200 rounded-full h-2 w-32">
                <div
                  class="bg-blue-600 h-2 rounded-full"
                  :style="{ width: `${(user.uploads / 100) * 100}%` }"
                ></div>
              </div>
              <span class="text-sm font-medium text-gray-900 w-8 text-left">{{ user.uploads }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-lg font-semibold text-gray-900">گزارش تفصیلی اسناد</h2>
        <button class="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1">
          <Download class="w-4 h-4" />
          دانلود PDF
        </button>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">دسته‌بندی</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">کل اسناد</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">تایید شده</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">در انتظار</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">رد شده</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">درصد تایید</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="cat in categoryStats" :key="cat.name" class="hover:bg-gray-50">
              <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ cat.name }}</td>
              <td class="px-6 py-4 text-sm text-gray-700">{{ cat.total }}</td>
              <td class="px-6 py-4">
                <span class="px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                  {{ cat.approved }}
                </span>
              </td>
              <td class="px-6 py-4">
                <span class="px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">
                  {{ cat.pending }}
                </span>
              </td>
              <td class="px-6 py-4">
                <span class="px-2 py-1 text-xs font-medium rounded-full bg-red-100 text-red-700">
                  {{ cat.rejected }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-2">
                  <div class="flex-1 bg-gray-200 rounded-full h-2">
                    <div
                      class="bg-green-600 h-2 rounded-full"
                      :style="{ width: `${cat.approvalRate}%` }"
                    ></div>
                  </div>
                  <span class="text-sm font-medium text-gray-900 w-10 text-left">{{ cat.approvalRate }}%</span>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { Line, Bar, Doughnut } from 'vue-chartjs';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js';
import { Download, FileText, CheckCircle, Clock, XCircle, TrendingUp, TrendingDown } from 'lucide-vue-next';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

const dateFrom = ref('1403/01/01');
const dateTo = ref('1403/07/15');
const filterCategory = ref('');

const uploadTrendData = {
  labels: ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور'],
  datasets: [
    {
      label: 'تعداد اسناد',
      data: [120, 150, 180, 210, 190, 220],
      borderColor: 'rgb(37, 99, 235)',
      backgroundColor: 'rgba(37, 99, 235, 0.1)',
      fill: true,
      tension: 0.4
    }
  ]
};

const categoryData = {
  labels: ['قراردادها', 'گزارشات', 'صورتجلسات', 'مالی', 'پرسنلی', 'سایر'],
  datasets: [
    {
      label: 'تعداد اسناد',
      data: [300, 250, 200, 180, 150, 167],
      backgroundColor: [
        'rgba(37, 99, 235, 0.8)',
        'rgba(16, 185, 129, 0.8)',
        'rgba(245, 158, 11, 0.8)',
        'rgba(239, 68, 68, 0.8)',
        'rgba(139, 92, 246, 0.8)',
        'rgba(107, 114, 128, 0.8)'
      ]
    }
  ]
};

const statusData = {
  labels: ['تایید شده', 'در انتظار', 'رد شده', 'پیش‌نویس'],
  datasets: [
    {
      data: [1180, 23, 44, 20],
      backgroundColor: [
        'rgba(16, 185, 129, 0.8)',
        'rgba(245, 158, 11, 0.8)',
        'rgba(239, 68, 68, 0.8)',
        'rgba(107, 114, 128, 0.8)'
      ]
    }
  ]
};

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    }
  },
  scales: {
    y: {
      beginAtZero: true
    }
  }
};

const barChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    }
  },
  scales: {
    y: {
      beginAtZero: true
    }
  }
};

const doughnutOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom' as const
    }
  }
};

const topUsers = ref([
  { id: 1, name: 'علی احمدی', department: 'فناوری اطلاعات', uploads: 85 },
  { id: 2, name: 'سارا محمدی', department: 'مالی', uploads: 72 },
  { id: 3, name: 'رضا کریمی', department: 'منابع انسانی', uploads: 68 },
  { id: 4, name: 'مریم رضایی', department: 'بازاریابی', uploads: 54 },
  { id: 5, name: 'محمد حسینی', department: 'فروش', uploads: 48 }
]);

const categoryStats = ref([
  { name: 'قراردادها', total: 300, approved: 285, pending: 8, rejected: 7, approvalRate: 95 },
  { name: 'گزارشات', total: 250, approved: 230, pending: 12, rejected: 8, approvalRate: 92 },
  { name: 'صورتجلسات', total: 200, approved: 190, pending: 5, rejected: 5, approvalRate: 95 },
  { name: 'مالی', total: 180, approved: 165, pending: 10, rejected: 5, approvalRate: 92 },
  { name: 'پرسنلی', total: 150, approved: 140, pending: 7, rejected: 3, approvalRate: 93 },
  { name: 'سایر', total: 167, approved: 150, pending: 10, rejected: 7, approvalRate: 90 }
]);
</script>
