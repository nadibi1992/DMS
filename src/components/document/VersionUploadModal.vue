<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
    @click.self="emit('close')"
  >
    <div class="bg-white rounded-xl shadow-xl max-w-lg w-full p-6">
      <h2 class="text-xl font-bold text-gray-900 mb-4">بارگذاری نسخه جدید</h2>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            فایل جدید
            <span class="text-red-500">*</span>
          </label>
          <input
            ref="fileInput"
            type="file"
            @change="handleFileSelect"
            required
            class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500 p-2"
          />
          <p v-if="selectedFile" class="text-xs text-gray-600 mt-1">
            {{ formatFileSize(selectedFile.size) }}
          </p>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            توضیحات تغییرات
            <span class="text-red-500">*</span>
          </label>
          <textarea
            v-model="changesDescription"
            rows="4"
            required
            placeholder="توضیح دهید چه تغییراتی در این نسخه اعمال شده است"
            class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 resize-none"
          ></textarea>
        </div>

        <div class="flex gap-2 justify-end pt-4">
          <button
            type="button"
            @click="emit('close')"
            :disabled="isSubmitting"
            class="px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors disabled:opacity-50"
          >
            انصراف
          </button>
          <button
            type="submit"
            :disabled="!canSubmit || isSubmitting"
            class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50"
          >
            {{ isSubmitting ? 'در حال بارگذاری...' : 'بارگذاری نسخه جدید' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

const props = defineProps<{
  isOpen: boolean;
  documentId: string;
}>();

const emit = defineEmits<{
  close: [];
  uploaded: [];
}>();

const selectedFile = ref<File | null>(null);
const changesDescription = ref('');
const isSubmitting = ref(false);
const fileInput = ref<HTMLInputElement | null>(null);

const canSubmit = computed(() => {
  return selectedFile.value && changesDescription.value.trim();
});

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files[0]) {
    selectedFile.value = target.files[0];
  }
};

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 بایت';
  const k = 1024;
  const sizes = ['بایت', 'کیلوبایت', 'مگابایت'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
};

const handleSubmit = async () => {
  if (!canSubmit.value || !selectedFile.value) return;

  isSubmitting.value = true;

  try {
    const { documentService } = await import('@/services/documents');
    await documentService.uploadNewVersion({
      document_id: props.documentId,
      file: selectedFile.value,
      changes_description: changesDescription.value
    });

    emit('uploaded');
    emit('close');

    selectedFile.value = null;
    changesDescription.value = '';
    if (fileInput.value) {
      fileInput.value.value = '';
    }
  } catch (error) {
    console.error('Version upload failed:', error);
    alert('خطا در بارگذاری نسخه جدید');
  } finally {
    isSubmitting.value = false;
  }
};
</script>
