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
        <p class="text-gray-600 mt-1">اطلاعات کامل سند را وارد کنید</p>
      </div>
    </div>

    <form @submit.prevent="handleSubmit" class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">اطلاعات اصلی</h2>

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
                placeholder="عنوان واضح و توصیفی وارد کنید"
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
                placeholder="توضیحات تکمیلی و جزئیات سند"
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
                  v-model="form.category_id"
                  required
                  class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">انتخاب کنید</option>
                  <option
                    v-for="category in categories"
                    :key="category.id"
                    :value="category.id"
                  >
                    {{ category.name }}
                  </option>
                </select>
                <p v-if="selectedCategory" class="text-xs text-gray-600 mt-1">
                  {{ selectedCategory.description }}
                </p>
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
          <h2 class="text-lg font-semibold text-gray-900 mb-4">متادیتا</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نویسنده
              </label>
              <input
                v-model="form.metadata.author"
                type="text"
                placeholder="نام نویسنده سند"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                موضوع
              </label>
              <input
                v-model="form.metadata.subject"
                type="text"
                placeholder="موضوع اصلی سند"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                زبان
              </label>
              <select
                v-model="form.metadata.language"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="">انتخاب کنید</option>
                <option value="fa">فارسی</option>
                <option value="en">انگلیسی</option>
                <option value="ar">عربی</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                سطح محرمانگی
              </label>
              <select
                v-model="form.metadata.confidentialityLevel"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="public">عمومی</option>
                <option value="internal">داخلی</option>
                <option value="confidential">محرمانه</option>
                <option value="secret">سری</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                تاریخ سند
              </label>
              <input
                v-model="form.metadata.documentDate"
                type="date"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                تاریخ انقضا
              </label>
              <input
                v-model="form.metadata.expiryDate"
                type="date"
                class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              کلمات کلیدی
            </label>
            <input
              v-model="keywordInput"
              @keyup.enter="addKeyword"
              type="text"
              placeholder="کلمه کلیدی (Enter برای افزودن)"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            <div v-if="form.metadata.keywords.length > 0" class="flex flex-wrap gap-2 mt-2">
              <span
                v-for="(keyword, index) in form.metadata.keywords"
                :key="index"
                class="inline-flex items-center gap-1 px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm"
              >
                {{ keyword }}
                <button
                  type="button"
                  @click="removeKeyword(index)"
                  class="hover:text-gray-900"
                >
                  <X class="w-4 h-4" />
                </button>
              </span>
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
              accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.jpg,.jpeg,.png"
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
                فرمت‌های مجاز: PDF, Word, Excel, PowerPoint, تصاویر، متن
              </p>
              <p class="text-sm text-gray-600">
                حداکثر حجم: 50 مگابایت
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
                  <p class="text-xs text-gray-500">{{ selectedFile.type }}</p>
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

          <div v-if="uploadProgress > 0 && uploadProgress < 100" class="mt-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm text-gray-600">در حال بارگذاری...</span>
              <span class="text-sm font-medium text-gray-900">{{ uploadProgress }}%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                :style="{ width: uploadProgress + '%' }"
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
              ></div>
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
              <p>دسته‌بندی مناسب را از لیست انتخاب کنید</p>
            </div>
            <div class="flex gap-2">
              <Info class="w-5 h-5 text-blue-600 flex-shrink-0" />
              <p>متادیتا به مدیریت بهتر اسناد کمک می‌کند</p>
            </div>
            <div class="flex gap-2">
              <Info class="w-5 h-5 text-blue-600 flex-shrink-0" />
              <p>برچسب‌ها جستجو را آسان‌تر می‌کنند</p>
            </div>
            <div class="flex gap-2">
              <Info class="w-5 h-5 text-blue-600 flex-shrink-0" />
              <p>سطح محرمانگی را با دقت انتخاب کنید</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">خلاصه سند</h2>
          <div class="space-y-3 text-sm">
            <div>
              <p class="text-gray-600">عنوان</p>
              <p class="font-medium text-gray-900">{{ form.title || 'عنوان وارد نشده' }}</p>
            </div>
            <div>
              <p class="text-gray-600">دسته‌بندی</p>
              <p class="font-medium text-gray-900">
                {{ selectedCategory?.name || 'انتخاب نشده' }}
              </p>
            </div>
            <div>
              <p class="text-gray-600">وضعیت</p>
              <p class="font-medium text-gray-900">{{ getStatusLabel(form.status) }}</p>
            </div>
            <div v-if="form.metadata.confidentialityLevel">
              <p class="text-gray-600">محرمانگی</p>
              <p class="font-medium text-gray-900">
                {{ getConfidentialityLabel(form.metadata.confidentialityLevel) }}
              </p>
            </div>
            <div v-if="selectedFile">
              <p class="text-gray-600">فایل</p>
              <p class="font-medium text-gray-900 truncate">{{ selectedFile.name }}</p>
              <p class="text-xs text-gray-500">{{ formatFileSize(selectedFile.size) }}</p>
            </div>
            <div v-if="form.tags.length > 0">
              <p class="text-gray-600">تعداد برچسب‌ها</p>
              <p class="font-medium text-gray-900">{{ form.tags.length }}</p>
            </div>
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <button
            type="submit"
            :disabled="!canSubmit || isSubmitting"
            class="w-full flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
          >
            <Check class="w-5 h-5" />
            <span v-if="!isSubmitting">بارگذاری سند</span>
            <span v-else>در حال بارگذاری...</span>
          </button>
          <button
            type="button"
            @click="router.back()"
            :disabled="isSubmitting"
            class="w-full px-4 py-3 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            انصراف
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { ArrowRight, Upload, FileText, Trash2, X, Check, Info } from 'lucide-vue-next';
import { documentService } from '@/services/documents';
import type { DocumentCategory } from '@/types';
import type { DocumentMetadata } from '@/services/documents';

const router = useRouter();

const form = ref({
  title: '',
  description: '',
  category_id: '',
  status: 'draft' as 'draft' | 'pending',
  tags: [] as string[],
  metadata: {
    author: '',
    subject: '',
    keywords: [] as string[],
    language: 'fa',
    documentDate: '',
    expiryDate: '',
    confidentialityLevel: 'internal' as 'public' | 'internal' | 'confidential' | 'secret'
  } as DocumentMetadata
});

const categories = ref<DocumentCategory[]>([]);
const selectedFile = ref<File | null>(null);
const fileInput = ref<HTMLInputElement | null>(null);
const isDragging = ref(false);
const tagInput = ref('');
const keywordInput = ref('');
const isSubmitting = ref(false);
const uploadProgress = ref(0);

const selectedCategory = computed(() =>
  categories.value.find(c => c.id === form.value.category_id)
);

const canSubmit = computed(() => {
  return form.value.title && form.value.category_id && selectedFile.value && !isSubmitting.value;
});

onMounted(async () => {
  try {
    categories.value = await documentService.getCategories();
  } catch (error) {
    console.error('Failed to load categories:', error);
    alert('خطا در بارگذاری دسته‌بندی‌ها');
  }
});

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files[0]) {
    const file = target.files[0];
    if (file.size > 50 * 1024 * 1024) {
      alert('حجم فایل نباید بیشتر از 50 مگابایت باشد');
      return;
    }
    selectedFile.value = file;
  }
};

const handleFileDrop = (event: DragEvent) => {
  isDragging.value = false;
  if (event.dataTransfer?.files && event.dataTransfer.files[0]) {
    const file = event.dataTransfer.files[0];
    if (file.size > 50 * 1024 * 1024) {
      alert('حجم فایل نباید بیشتر از 50 مگابایت باشد');
      return;
    }
    selectedFile.value = file;
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

const addKeyword = () => {
  if (keywordInput.value.trim() && !form.value.metadata.keywords.includes(keywordInput.value.trim())) {
    form.value.metadata.keywords.push(keywordInput.value.trim());
    keywordInput.value = '';
  }
};

const removeKeyword = (index: number) => {
  form.value.metadata.keywords.splice(index, 1);
};

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 بایت';
  const k = 1024;
  const sizes = ['بایت', 'کیلوبایت', 'مگابایت', 'گیگابایت'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
};

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    draft: 'پیش‌نویس',
    pending: 'در انتظار تایید'
  };
  return labels[status] || status;
};

const getConfidentialityLabel = (level: string) => {
  const labels: Record<string, string> = {
    public: 'عمومی',
    internal: 'داخلی',
    confidential: 'محرمانه',
    secret: 'سری'
  };
  return labels[level] || level;
};

const handleSubmit = async () => {
  if (!canSubmit.value || !selectedFile.value) return;

  isSubmitting.value = true;
  uploadProgress.value = 0;

  const progressInterval = setInterval(() => {
    if (uploadProgress.value < 90) {
      uploadProgress.value += 10;
    }
  }, 200);

  try {
    await documentService.uploadDocument({
      title: form.value.title,
      description: form.value.description,
      category_id: form.value.category_id,
      status: form.value.status,
      tags: form.value.tags,
      metadata: form.value.metadata,
      file: selectedFile.value
    });

    uploadProgress.value = 100;
    clearInterval(progressInterval);

    setTimeout(() => {
      router.push({ name: 'documents' });
    }, 500);
  } catch (error) {
    clearInterval(progressInterval);
    uploadProgress.value = 0;
    console.error('Upload failed:', error);
    alert('خطا در بارگذاری سند. لطفا دوباره تلاش کنید.');
  } finally {
    isSubmitting.value = false;
  }
};
</script>
