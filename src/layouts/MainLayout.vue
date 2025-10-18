<template>
  <div class="min-h-screen bg-gray-50" dir="rtl">
    <Sidebar :isOpen="sidebarOpen" @close="sidebarOpen = false" />

    <div class="lg:mr-64">
      <Header @toggle-sidebar="sidebarOpen = !sidebarOpen" />

      <main class="p-6">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { RouterView } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import Sidebar from '@/components/layout/Sidebar.vue';
import Header from '@/components/layout/Header.vue';

const authStore = useAuthStore();
const sidebarOpen = ref(false);

onMounted(() => {
  authStore.initAuth();
});
</script>
