<template>
  <div>
    <div
      v-if="isOpen"
      @click="$emit('close')"
      class="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
    ></div>

    <aside
      :class="isOpen ? 'translate-x-0' : 'translate-x-full lg:translate-x-0'"
      class="fixed top-0 right-0 w-64 h-full bg-white border-l border-gray-200 z-50 transition-transform duration-300 ease-in-out"
    >
      <div class="flex flex-col h-full">
        <div class="flex items-center justify-between p-6 border-b border-gray-200">
          <div class="flex items-center gap-2">
            <div class="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center">
              <FileText class="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 class="text-lg font-bold text-gray-900">DMS</h1>
              <p class="text-xs text-gray-600">سامانه مدیریت اسناد</p>
            </div>
          </div>
          <button
            @click="$emit('close')"
            class="lg:hidden p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
          >
            <X class="w-5 h-5" />
          </button>
        </div>

        <nav class="flex-1 p-4 overflow-y-auto">
          <ul class="space-y-1">
            <li>
              <router-link
                to="/"
                :class="isActive('/') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <LayoutDashboard class="w-5 h-5" />
                <span class="font-medium">داشبورد</span>
              </router-link>
            </li>

            <li>
              <router-link
                to="/documents"
                :class="isActive('/documents') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <FileText class="w-5 h-5" />
                <span class="font-medium">مدیریت اسناد</span>
              </router-link>
            </li>

            <li>
              <router-link
                to="/documents/upload"
                :class="isActive('/documents/upload') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <Upload class="w-5 h-5" />
                <span class="font-medium">بارگذاری سند</span>
              </router-link>
            </li>

            <li v-if="authStore.isAdmin">
              <router-link
                to="/users"
                :class="isActive('/users') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <Users class="w-5 h-5" />
                <span class="font-medium">مدیریت کاربران</span>
              </router-link>
            </li>

            <li v-if="authStore.isAdmin">
              <router-link
                to="/categories"
                :class="isActive('/categories') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <FolderTree class="w-5 h-5" />
                <span class="font-medium">مدیریت دسته‌بندی‌ها</span>
              </router-link>
            </li>

            <li v-if="authStore.isAdmin">
              <router-link
                to="/workflows"
                :class="isActive('/workflows') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <GitBranch class="w-5 h-5" />
                <span class="font-medium">مدیریت گردش کار</span>
              </router-link>
            </li>

            <li v-if="authStore.isAdmin">
              <router-link
                to="/permissions"
                :class="isActive('/permissions') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <Shield class="w-5 h-5" />
                <span class="font-medium">مدیریت دسترسی‌ها</span>
              </router-link>
            </li>

            <li>
              <router-link
                to="/reports"
                :class="isActive('/reports') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <BarChart3 class="w-5 h-5" />
                <span class="font-medium">گزارشات</span>
              </router-link>
            </li>

            <li>
              <router-link
                to="/profile"
                :class="isActive('/profile') ? 'bg-blue-50 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
                class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors"
              >
                <UserCircle class="w-5 h-5" />
                <span class="font-medium">پروفایل کاربری</span>
              </router-link>
            </li>
          </ul>

          <div class="mt-6 pt-6 border-t border-gray-200">
            <p class="px-4 text-xs font-medium text-gray-500 uppercase mb-2">دسته‌بندی‌ها</p>
            <ul class="space-y-1">
              <li>
                <a href="#" class="flex items-center gap-3 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
                  <Folder class="w-5 h-5" />
                  <span class="text-sm">قراردادها</span>
                  <span class="mr-auto text-xs bg-gray-200 px-2 py-0.5 rounded-full">300</span>
                </a>
              </li>
              <li>
                <a href="#" class="flex items-center gap-3 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
                  <Folder class="w-5 h-5" />
                  <span class="text-sm">گزارشات</span>
                  <span class="mr-auto text-xs bg-gray-200 px-2 py-0.5 rounded-full">250</span>
                </a>
              </li>
              <li>
                <a href="#" class="flex items-center gap-3 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
                  <Folder class="w-5 h-5" />
                  <span class="text-sm">صورتجلسات</span>
                  <span class="mr-auto text-xs bg-gray-200 px-2 py-0.5 rounded-full">200</span>
                </a>
              </li>
              <li>
                <a href="#" class="flex items-center gap-3 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
                  <Folder class="w-5 h-5" />
                  <span class="text-sm">مالی</span>
                  <span class="mr-auto text-xs bg-gray-200 px-2 py-0.5 rounded-full">180</span>
                </a>
              </li>
              <li>
                <a href="#" class="flex items-center gap-3 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
                  <Folder class="w-5 h-5" />
                  <span class="text-sm">پرسنلی</span>
                  <span class="mr-auto text-xs bg-gray-200 px-2 py-0.5 rounded-full">150</span>
                </a>
              </li>
            </ul>
          </div>
        </nav>

        <div class="p-4 border-t border-gray-200">
          <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-4 mb-3">
            <div class="flex items-center gap-3 mb-2">
              <div class="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center">
                <HelpCircle class="w-5 h-5 text-white" />
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900">راهنما</p>
              </div>
            </div>
            <p class="text-xs text-gray-700 mb-3">
              برای دریافت راهنمای استفاده از سیستم کلیک کنید
            </p>
            <button class="w-full px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm rounded-lg transition-colors">
              مشاهده راهنما
            </button>
          </div>

          <button
            @click="handleLogout"
            class="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-50 hover:bg-red-100 text-red-700 rounded-lg transition-colors"
          >
            <LogOut class="w-5 h-5" />
            <span class="font-medium">خروج از سیستم</span>
          </button>
        </div>
      </div>
    </aside>
  </div>
</template>

<script setup lang="ts">
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import {
  FileText,
  LayoutDashboard,
  Upload,
  Users,
  BarChart3,
  Folder,
  HelpCircle,
  LogOut,
  X,
  UserCircle,
  FolderTree,
  GitBranch,
  Shield,
  Activity
} from 'lucide-vue-next';

defineProps<{
  isOpen: boolean;
}>();

defineEmits<{
  close: [];
}>();

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

const isActive = (path: string) => {
  if (path === '/') {
    return route.path === path;
  }
  return route.path.startsWith(path);
};

const handleLogout = async () => {
  await authStore.logout();
  router.push({ name: 'login' });
};
</script>
