<template>
  <header class="bg-white shadow-sm h-20 flex items-center justify-between px-6 border-b border-gray-200">
    <button
      @click="$emit('toggle-sidebar')"
      class="lg:hidden p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
    >
      <Menu class="w-6 h-6" />
    </button>

    <div class="flex-1 max-w-2xl mx-auto hidden md:block">
      <div class="relative">
        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
          <Search class="h-5 w-5 text-gray-400" />
        </div>
        <input
          type="text"
          placeholder="جستجو در اسناد..."
          class="block w-full pr-10 pl-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
      </div>
    </div>

    <div class="flex items-center gap-4">
      <button class="relative p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors">
        <Bell class="w-6 h-6" />
        <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
      </button>

      <router-link
        to="/profile"
        class="hidden md:flex items-center gap-3 pr-4 border-r border-gray-200 hover:bg-gray-50 rounded-lg p-2 transition-colors"
      >
        <div class="text-right">
          <p class="text-sm font-medium text-gray-900">{{ authStore.user?.fullName }}</p>
          <p class="text-xs text-gray-600">{{ authStore.user?.role === 'admin' ? 'مدیر سیستم' : 'کاربر' }}</p>
        </div>
        <div class="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-700 rounded-full flex items-center justify-center text-white font-bold">
          {{ authStore.user?.fullName.charAt(0) }}
        </div>
      </router-link>
    </div>
  </header>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth';
import { Menu, Search, Bell } from 'lucide-vue-next';

defineEmits<{
  toggleSidebar: [];
}>();

const authStore = useAuthStore();
</script>
