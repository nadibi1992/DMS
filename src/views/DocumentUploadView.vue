<template>
  <div class="space-y-6">
    <div class="flex items-center gap-4">
      <button
        @click="router.back()"
        class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
      >
        <ArrowRight class="w-6 h-6" />
      </button>
      <div>
        <h1 class="text-3xl font-bold text-gray-900">بارگذاری سند جدید</h1>
        <p class="text-gray-600 mt-1">اطلاعات سند را وارد کنید و فایل را بارگذاری نمایید</p>
      </div>
    </div>

    <form @submit.prevent="handleSubmit" class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">اطلاعات سند</h2>

          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                عنوان سند
                <span class="text-red-500">*</span>
              </label>
              <input
                v-model="form.title"
                type="text"
                required
                placeholder="عنوان سند را وارد کنید"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                توضیحات
              </label>
              <textarea
                v-model="form.description"
                rows="4"
                placeholder="توضیحات تکمیلی درباره سند"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
              ></textarea>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  دسته‌بندی
                  <span class="text-red-500">*</span>
                </label>
                <select
                  v-model="form.category"
                  required
                  class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">انتخاب کنید</option>
                  <option value="contracts">قراردادها</option>
                  <option value="reports">گزارشات</option>
                  <option value="minutes">صورتجلسات</option>
                  <option value="financial">مالی</option>
                  <option value="hr">پرسنلی</option>
                  <option value="other">سایر</option>
                </select>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  وضعیت
                </label>
                <select
                  v-model="form.status"
                  class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                >
                  <option value="draft">پیش‌نویس</option>
                  <option value="pending">ارسال برای تایید</option>
                </select>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                برچسب‌ها
              </label>
              <div class="flex gap-2 mb-2">
                <input
                  v-model="tagInput"
                  @keyup.enter="addTag"
                  type="text"
                  placeholder="برچسب جدید (Enter برای افزودن)"
                  class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <button
                  type="button"
                  @click="addTag"
                  class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
                >
                  افزودن
                </button>
              </div>
              <div v-if="form.tags.length > 0" class="flex flex-wrap gap-2">
                <span
                  v-for="(tag, index) in form.tags"
                  :key="index"
                  class="inline-flex items-center gap-1 px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm"
                >
                  {{ tag }}
                  <button
                    type="button"
                    @click="removeTag(index)"
                    class="hover:text-blue-900"
                  >
                    <X class="w-4 h-4" />
                  </button>
                </span>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">بارگذاری فایل</h2>

          <div
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleFileDrop"
            :class="isDragging ? 'border-blue-500 bg-blue-50' : 'border-gray-300'"
            class="border-2 border-dashed rounded-lg p-8 text-center transition-colors"
          >
            <input
              ref="fileInput"
              type="file"
              @change="handleFileSelect"
              accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx"
              class="hidden"
            />

            <div v-if="!selectedFile">
              <Upload class="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <p class="text-lg font-medium text-gray-900 mb-2">
                فایل را اینجا رها کنید یا
                <button
                  type="button"
                  @click="$refs.fileInput.click()"
                  class="text-blue-600 hover:text-blue-700"
                >
                  انتخاب کنید
                </button>
              </p>
              <p class="text-sm text-gray-600">
                فرمت‌های مجاز: PDF, Word, Excel, PowerPoint
              </p>
              <p class="text-sm text-gray-600">
                حداکثر حجم: 10 مگابایت
              </p>
            </div>

            <div v-else class="flex items-center justify-between bg-gray-50 rounded-lg p-4">
              <div class="flex items-center gap-3">
                <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                  <FileText class="w-6 h-6 text-blue-600" />
                </div>
                <div class="text-right">
                  <p class="text-sm font-medium text-gray-900">{{ selectedFile.name }}</p>
                  <p class="text-xs text-gray-600">{{ formatFileSize(selectedFile.size) }}</p>
                </div>
              </div>
              <button
                type="button"
                @click="removeFile"
                class="p-2 bg-red-100 hover:bg-red-200 text-red-700 rounded transition-colors"
              >
                <Trash2 class="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">راهنما</h2>
          <div class="space-y-3 text-sm text-gray-600">
            <div class="flex gap-2">
              <Info class="w-5 h-5 text-blue-600 flex-shrink-0" />
              <p>عنوان سند باید واضح و توصیفی باشد</p>
            </div>
            <div class="flex gap-2">
              <Info class="w-5 h-5 text-blue-600 flex-shrink-0" />
              <p>دسته‌بندی مناسب انتخاب کنید تا جستجو آسان‌تر شود</p>
            </div>
            <div class="flex gap-2">
              <Info class="w-5 h-5 text-blue-600 flex-shrink-0" />
              <p>برچسب‌ها به یافتن سریع‌تر اسناد کمک می‌کنند</p>
            </div>
            <div class="flex gap-2">
              <Info class="w-5 h-5 text-blue-600 flex-shrink-0" />
              <p>فایل‌های با فرمت استاندارد بارگذاری کنید</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">پیش‌نمایش</h2>
          <div class="space-y-3 text-sm">
            <div>
              <p class="text-gray-600">عنوان</p>
              <p class="font-medium text-gray-900">{{ form.title || 'عنوان وارد نشده' }}</p>
            </div>
            <div>
              <p class="text-gray-600">دسته‌بندی</p>
              <p class="font-medium text-gray-900">{{ getCategoryLabel(form.category) }}</p>
            </div>
            <div>
              <p class="text-gray-600">وضعیت</p>
              <p class="font-medium text-gray-900">{{ getStatusLabel(form.status) }}</p>
            </div>
            <div v-if="selectedFile">
              <p class="text-gray-600">فایل</p>
              <p class="font-medium text-gray-900">{{ selectedFile.name }}</p>
            </div>
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <button
            type="submit"
            :disabled="!canSubmit || isSubmitting"
            class="w-full flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Check class="w-5 h-5" />
            <span v-if="!isSubmitting">بارگذاری سند</span>
            <span v-else>در حال بارگذاری...</span>
          </button>
          <button
            type="button"
            @click="router.back()"
            class="w-full px-4 py-3 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors"
          >
            انصراف
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { ArrowRight, Upload, FileText, Trash2, X, Check, Info } from 'lucide-vue-next';

const router = useRouter();

const form = ref({
  title: '',
  description: '',
  category: '',
  status: 'draft',
  tags: [] as string[]
});

const selectedFile = ref<File | null>(null);
const fileInput = ref<HTMLInputElement | null>(null);
const isDragging = ref(false);
const tagInput = ref('');
const isSubmitting = ref(false);

const canSubmit = computed(() => {
  return form.value.title && form.value.category && selectedFile.value;
});

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files[0]) {
    selectedFile.value = target.files[0];
  }
};

const handleFileDrop = (event: DragEvent) => {
  isDragging.value = false;
  if (event.dataTransfer?.files && event.dataTransfer.files[0]) {
    selectedFile.value = event.dataTransfer.files[0];
  }
};

const removeFile = () => {
  selectedFile.value = null;
  if (fileInput.value) {
    fileInput.value.value = '';
  }
};

const addTag = () => {
  if (tagInput.value.trim() && !form.value.tags.includes(tagInput.value.trim())) {
    form.value.tags.push(tagInput.value.trim());
    tagInput.value = '';
  }
};

const removeTag = (index: number) => {
  form.value.tags.splice(index, 1);
};

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 بایت';
  const k = 1024;
  const sizes = ['بایت', 'کیلوبایت', 'مگابایت', 'گیگابایت'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
};

const getCategoryLabel = (category: string) => {
  const labels: Record<string, string> = {
    contracts: 'قراردادها',
    reports: 'گزارشات',
    minutes: 'صورتجلسات',
    financial: 'مالی',
    hr: 'پرسنلی',
    other: 'سایر'
  };
  return labels[category] || 'انتخاب نشده';
};

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    draft: 'پیش‌نویس',
    pending: 'در انتظار تایید'
  };
  return labels[status] || status;
};

const handleSubmit = async () => {
  if (!canSubmit.value) return;

  isSubmitting.value = true;

  setTimeout(() => {
    isSubmitting.value = false;
    router.push({ name: 'documents' });
  }, 2000);
};
</script>
