<template>
  <div
    :class="getColorClasses()"
    class="rounded-xl shadow-sm p-6 transition-transform hover:scale-105"
  >
    <div class="flex items-center justify-between mb-4">
      <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
        <component :is="getIcon()" class="w-6 h-6 text-white" />
      </div>
      <span v-if="trend" class="text-sm font-medium text-white bg-white bg-opacity-20 px-2 py-1 rounded-full">
        {{ trend }}
      </span>
    </div>
    <p class="text-3xl font-bold text-white mb-1">{{ formatValue(value) }}</p>
    <p class="text-sm text-white text-opacity-90">{{ title }}</p>
  </div>
</template>

<script setup lang="ts">
import { FileText, Clock, CheckCircle, Users } from 'lucide-vue-next';

const props = defineProps<{
  title: string;
  value: number;
  icon: string;
  color: string;
  trend?: string;
}>();

const getColorClasses = () => {
  const colors = {
    blue: 'bg-gradient-to-br from-blue-500 to-blue-600',
    yellow: 'bg-gradient-to-br from-yellow-500 to-yellow-600',
    green: 'bg-gradient-to-br from-green-500 to-green-600',
    purple: 'bg-gradient-to-br from-purple-500 to-purple-600',
    red: 'bg-gradient-to-br from-red-500 to-red-600',
  };
  return colors[props.color as keyof typeof colors] || colors.blue;
};

const getIcon = () => {
  const icons = {
    FileText,
    Clock,
    CheckCircle,
    Users,
  };
  return icons[props.icon as keyof typeof icons] || FileText;
};

const formatValue = (value: number) => {
  return value.toLocaleString('fa-IR');
};
</script>
