<template>
  <div v-if="loading" class="flex items-center justify-center h-96">
    <div class="text-gray-600">در حال بارگذاری...</div>
  </div>

  <div v-else-if="document" class="space-y-6">
    <div class="flex items-center gap-4">
      <button
        @click="router.back()"
        class="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
      >
        <ArrowRight class="w-6 h-6" />
      </button>
      <div class="flex-1">
        <h1 class="text-3xl font-bold text-gray-900">{{ document.title }}</h1>
        <p class="text-gray-600 mt-1">مشاهده و مدیریت جزئیات سند</p>
      </div>
      <div class="flex items-center gap-2">
        <button
          @click="handleDownload"
          class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
        >
          <Download class="w-5 h-5" />
          دانلود
        </button>
        <button
          v-if="canUploadVersion"
          @click="showVersionModal = true"
          class="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors"
        >
          <Upload class="w-5 h-5" />
          نسخه جدید
        </button>
      </div>
    </div>

    <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4" v-if="document.status === 'pending' && authStore.isAdmin">
      <p class="text-yellow-800 font-medium mb-3">این سند در انتظار بررسی و تایید است</p>
      <div class="flex gap-2">
        <button
          @click="handleApprove"
          :disabled="isProcessing"
          class="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors disabled:opacity-50"
        >
          <Check class="w-5 h-5" />
          تایید سند
        </button>
        <button
          @click="handleReject"
          :disabled="isProcessing"
          class="flex items-center gap-2 px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg transition-colors disabled:opacity-50"
        >
          <X class="w-5 h-5" />
          رد سند
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold text-gray-900">اطلاعات سند</h2>
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

          <div class="space-y-4">
            <div v-if="document.description">
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

            <div v-if="document.metadata">
              <h3 class="text-sm font-medium text-gray-700 mb-2">متادیتا</h3>
              <div class="grid grid-cols-2 gap-3 bg-gray-50 rounded-lg p-4">
                <div v-if="document.metadata.author">
                  <p class="text-xs text-gray-600">نویسنده</p>
                  <p class="text-sm font-medium text-gray-900">{{ document.metadata.author }}</p>
                </div>
                <div v-if="document.metadata.subject">
                  <p class="text-xs text-gray-600">موضوع</p>
                  <p class="text-sm font-medium text-gray-900">{{ document.metadata.subject }}</p>
                </div>
                <div v-if="document.metadata.language">
                  <p class="text-xs text-gray-600">زبان</p>
                  <p class="text-sm font-medium text-gray-900">{{ getLanguageLabel(document.metadata.language) }}</p>
                </div>
                <div v-if="document.metadata.confidentialityLevel">
                  <p class="text-xs text-gray-600">محرمانگی</p>
                  <p class="text-sm font-medium text-gray-900">{{ getConfidentialityLabel(document.metadata.confidentialityLevel) }}</p>
                </div>
                <div v-if="document.metadata.documentDate">
                  <p class="text-xs text-gray-600">تاریخ سند</p>
                  <p class="text-sm font-medium text-gray-900">{{ document.metadata.documentDate }}</p>
                </div>
                <div v-if="document.metadata.expiryDate">
                  <p class="text-xs text-gray-600">تاریخ انقضا</p>
                  <p class="text-sm font-medium text-gray-900">{{ document.metadata.expiryDate }}</p>
                </div>
              </div>
              <div v-if="document.metadata.keywords && document.metadata.keywords.length > 0" class="mt-3">
                <p class="text-xs text-gray-600 mb-2">کلمات کلیدی</p>
                <div class="flex flex-wrap gap-2">
                  <span
                    v-for="keyword in document.metadata.keywords"
                    :key="keyword"
                    class="px-2 py-1 bg-gray-200 text-gray-700 rounded text-xs"
                  >
                    {{ keyword }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">نسخه‌های سند</h2>
          <div v-if="versions.length > 0" class="space-y-3">
            <div
              v-for="version in versions"
              :key="version.id"
              class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                  <FileText class="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">نسخه {{ version.version }}</p>
                  <p class="text-xs text-gray-600">{{ formatDate(version.uploaded_at) }}</p>
                  <p v-if="version.changes_description" class="text-xs text-gray-500">{{ version.changes_description }}</p>
                </div>
              </div>
              <button
                @click="downloadVersion(version)"
                class="px-3 py-1 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded text-sm transition-colors"
              >
                دانلود
              </button>
            </div>
          </div>
          <p v-else class="text-gray-600 text-center py-4">هیچ نسخه‌ای یافت نشد</p>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">نظرات و بازخوردها</h2>
          <div v-if="comments.length > 0" class="space-y-4 mb-4">
            <div
              v-for="comment in comments"
              :key="comment.id"
              class="flex gap-3 p-3 bg-gray-50 rounded-lg"
            >
              <div class="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-medium flex-shrink-0">
                {{ comment.user.full_name.charAt(0) }}
              </div>
              <div class="flex-1">
                <div class="flex items-center justify-between mb-1">
                  <p class="text-sm font-medium text-gray-900">{{ comment.user.full_name }}</p>
                  <p class="text-xs text-gray-600">{{ formatDate(comment.created_at) }}</p>
                </div>
                <p class="text-sm text-gray-700">{{ comment.content }}</p>
              </div>
              <button
                v-if="comment.user_id === authStore.user?.id"
                @click="deleteComment(comment.id)"
                class="p-1 text-red-600 hover:bg-red-50 rounded transition-colors"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>
          <p v-else class="text-gray-600 text-center py-4 mb-4">هنوز نظری ثبت نشده است</p>

          <div class="border-t border-gray-200 pt-4">
            <textarea
              v-model="newComment"
              rows="3"
              placeholder="نظر یا بازخورد خود را بنویسید..."
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
            ></textarea>
            <button
              @click="addComment"
              :disabled="!newComment.trim() || isAddingComment"
              class="mt-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ isAddingComment ? 'در حال ارسال...' : 'ارسال نظر' }}
            </button>
          </div>
        </div>
      </div>

      <div class="space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">مشخصات فایل</h2>
          <div class="space-y-3">
            <div>
              <p class="text-sm text-gray-600">نام فایل</p>
              <p class="text-sm font-medium text-gray-900 break-all">{{ document.file_name }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">حجم فایل</p>
              <p class="text-sm font-medium text-gray-900">{{ formatFileSize(document.file_size) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">نوع فایل</p>
              <p class="text-sm font-medium text-gray-900">{{ document.file_type }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">دسته‌بندی</p>
              <p class="text-sm font-medium text-gray-900">{{ (document as any).category?.name || 'نامشخص' }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">نسخه فعلی</p>
              <p class="text-sm font-medium text-gray-900">{{ document.version }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">بارگذاری شده توسط</p>
              <p class="text-sm font-medium text-gray-900">{{ (document as any).uploader?.full_name || 'نامشخص' }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">تاریخ بارگذاری</p>
              <p class="text-sm font-medium text-gray-900">{{ formatDate(document.uploaded_at) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">آخرین ویرایش</p>
              <p class="text-sm font-medium text-gray-900">{{ formatDate(document.updated_at) }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">فعالیت‌های اخیر</h2>
          <div v-if="activities.length > 0" class="space-y-3">
            <div
              v-for="activity in activities"
              :key="activity.id"
              class="flex gap-3"
            >
              <div
                :class="getActivityColor(activity.action)"
                class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
              >
                <div class="w-2 h-2 rounded-full bg-current"></div>
              </div>
              <div class="flex-1">
                <p class="text-sm text-gray-900">{{ activity.action }}</p>
                <p class="text-xs text-gray-600">{{ formatDate(activity.created_at) }}</p>
              </div>
            </div>
          </div>
          <p v-else class="text-gray-600 text-center py-4">هیچ فعالیتی ثبت نشده است</p>
        </div>
      </div>
    </div>

    <VersionUploadModal
      :is-open="showVersionModal"
      :document-id="documentId"
      @close="showVersionModal = false"
      @uploaded="handleVersionUploaded"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { ArrowRight, Download, Upload, FileText, Check, X, Trash2 } from 'lucide-vue-next';
import { documentService } from '@/services/documents';
import { commentService } from '@/services/comments';
import type { Document, DocumentVersion, ActivityLog } from '@/types';
import type { CommentWithUser } from '@/services/comments';
import VersionUploadModal from '@/components/document/VersionUploadModal.vue';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

const documentId = route.params.id as string;
const document = ref<Document | null>(null);
const versions = ref<DocumentVersion[]>([]);
const comments = ref<CommentWithUser[]>([]);
const activities = ref<ActivityLog[]>([]);
const loading = ref(true);
const newComment = ref('');
const isAddingComment = ref(false);
const isProcessing = ref(false);
const showVersionModal = ref(false);

const canUploadVersion = computed(() => {
  return document.value && (
    document.value.uploaded_by === authStore.user?.id ||
    authStore.isAdmin
  );
});

onMounted(async () => {
  await loadData();
});

const loadData = async () => {
  loading.value = true;
  try {
    [document.value, versions.value, comments.value] = await Promise.all([
      documentService.getDocument(documentId),
      documentService.getDocumentVersions(documentId),
      commentService.getDocumentComments(documentId)
    ]);
  } catch (error) {
    console.error('Failed to load document:', error);
    alert('خطا در بارگذاری اطلاعات سند');
  } finally {
    loading.value = false;
  }
};

const handleDownload = async () => {
  if (!document.value) return;
  try {
    await documentService.downloadDocument(document.value.file_path, document.value.file_name);
  } catch (error) {
    console.error('Download failed:', error);
    alert('خطا در دانلود فایل');
  }
};

const downloadVersion = async (version: DocumentVersion) => {
  try {
    await documentService.downloadDocument(version.file_path, `v${version.version}_${document.value?.file_name}`);
  } catch (error) {
    console.error('Download failed:', error);
    alert('خطا در دانلود نسخه');
  }
};

const handleApprove = async () => {
  if (!document.value) return;
  const comment = prompt('توضیحات تایید (اختیاری):');
  if (comment === null) return;

  isProcessing.value = true;
  try {
    await documentService.updateDocumentStatus(documentId, 'approved', comment);
    document.value.status = 'approved';
    await loadData();
  } catch (error) {
    console.error('Approval failed:', error);
    alert('خطا در تایید سند');
  } finally {
    isProcessing.value = false;
  }
};

const handleReject = async () => {
  if (!document.value) return;
  const comment = prompt('دلیل رد (الزامی):');
  if (!comment || !comment.trim()) {
    alert('لطفا دلیل رد سند را وارد کنید');
    return;
  }

  isProcessing.value = true;
  try {
    await documentService.updateDocumentStatus(documentId, 'rejected', comment);
    document.value.status = 'rejected';
    await loadData();
  } catch (error) {
    console.error('Rejection failed:', error);
    alert('خطا در رد سند');
  } finally {
    isProcessing.value = false;
  }
};

const addComment = async () => {
  if (!newComment.value.trim()) return;

  isAddingComment.value = true;
  try {
    await commentService.addComment(documentId, newComment.value);
    newComment.value = '';
    comments.value = await commentService.getDocumentComments(documentId);
  } catch (error) {
    console.error('Failed to add comment:', error);
    alert('خطا در ارسال نظر');
  } finally {
    isAddingComment.value = false;
  }
};

const deleteComment = async (commentId: string) => {
  if (!confirm('آیا از حذف این نظر اطمینان دارید؟')) return;

  try {
    await commentService.deleteComment(commentId);
    comments.value = comments.value.filter(c => c.id !== commentId);
  } catch (error) {
    console.error('Failed to delete comment:', error);
    alert('خطا در حذف نظر');
  }
};

const handleVersionUploaded = async () => {
  await loadData();
};

const formatDate = (dateString: string): string => {
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('fa-IR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date);
};

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 بایت';
  const k = 1024;
  const sizes = ['بایت', 'کیلوبایت', 'مگابایت'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
};

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    draft: 'پیش‌نویس',
    pending: 'در انتظار تایید',
    approved: 'تایید شده',
    rejected: 'رد شده'
  };
  return labels[status] || status;
};

const getLanguageLabel = (lang: string) => {
  const labels: Record<string, string> = {
    fa: 'فارسی',
    en: 'انگلیسی',
    ar: 'عربی'
  };
  return labels[lang] || lang;
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

const getActivityColor = (action: string) => {
  if (action.includes('created') || action.includes('uploaded')) {
    return 'bg-blue-100 text-blue-600';
  } else if (action.includes('approved')) {
    return 'bg-green-100 text-green-600';
  } else if (action.includes('rejected')) {
    return 'bg-red-100 text-red-600';
  } else if (action.includes('comment')) {
    return 'bg-purple-100 text-purple-600';
  }
  return 'bg-gray-100 text-gray-600';
};
</script>
