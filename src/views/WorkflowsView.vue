<template>
  <div class="space-y-6">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">مدیریت گردش کار</h1>
        <p class="text-gray-600 mt-1">تنظیم و مدیریت گردش کارهای اسناد</p>
      </div>
      <button
        @click="openAddModal"
        class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
      >
        <Plus class="w-5 h-5" />
        افزودن گردش کار جدید
      </button>
    </div>

    <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-lg">
      {{ error }}
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div class="mb-6">
        <div class="relative">
          <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
            <Search class="h-5 w-5 text-gray-400" />
          </div>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="جستجو در گردش کارها..."
            class="block w-full pr-10 pl-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      <div v-if="loading" class="text-center py-12">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>

      <div v-else class="space-y-4">
        <div
          v-for="workflow in filteredWorkflows"
          :key="workflow.id"
          class="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-all"
        >
          <div class="flex items-start justify-between mb-4">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <h3 class="text-lg font-bold text-gray-900">{{ workflow.name }}</h3>
                <span
                  :class="workflow.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ workflow.is_active ? 'فعال' : 'غیرفعال' }}
                </span>
              </div>
              <p v-if="workflow.description" class="text-sm text-gray-700 mb-3">
                {{ workflow.description }}
              </p>
              <div class="flex items-center gap-4 text-xs text-gray-600">
                <span v-if="workflow.category_name">
                  <Folder class="w-4 h-4 inline ml-1" />
                  {{ workflow.category_name }}
                </span>
                <span>{{ formatDate(workflow.created_at) }}</span>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <button
                @click="viewWorkflowSteps(workflow)"
                class="p-2 text-blue-600 hover:bg-blue-50 rounded transition-colors"
                title="مشاهده مراحل"
              >
                <List class="w-5 h-5" />
              </button>
              <button
                @click="editWorkflow(workflow)"
                class="p-2 text-green-600 hover:bg-green-50 rounded transition-colors"
                title="ویرایش"
              >
                <Edit class="w-5 h-5" />
              </button>
              <button
                @click="toggleWorkflowStatus(workflow)"
                class="p-2 text-yellow-600 hover:bg-yellow-50 rounded transition-colors"
                :title="workflow.is_active ? 'غیرفعال کردن' : 'فعال کردن'"
              >
                <Power class="w-5 h-5" />
              </button>
              <button
                @click="deleteWorkflow(workflow)"
                class="p-2 text-red-600 hover:bg-red-50 rounded transition-colors"
                title="حذف"
              >
                <Trash2 class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div v-if="workflow.steps && workflow.steps.length > 0" class="mt-4 pt-4 border-t border-gray-200">
            <p class="text-sm font-semibold text-gray-700 mb-3">مراحل گردش کار:</p>
            <div class="flex flex-wrap gap-2">
              <div
                v-for="(step, index) in workflow.steps"
                :key="step.id"
                class="flex items-center gap-2 px-3 py-2 bg-gray-50 rounded-lg text-sm"
              >
                <span class="font-semibold text-gray-900">{{ index + 1 }}.</span>
                <span class="text-gray-700">{{ step.step_name }}</span>
                <span class="text-xs text-gray-500">({{ step.group_name }})</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="!loading && filteredWorkflows.length === 0" class="text-center py-12">
        <GitBranch class="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <p class="text-gray-600">هیچ گردش کاری یافت نشد</p>
      </div>
    </div>

    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">
              {{ editingWorkflow ? 'ویرایش گردش کار' : 'افزودن گردش کار جدید' }}
            </h2>
            <button
              @click="closeModal"
              class="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <X class="w-6 h-6" />
            </button>
          </div>
        </div>

        <form @submit.prevent="handleSubmit" class="p-6 space-y-4">
          <div v-if="formError" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
            {{ formError }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              نام گردش کار
              <span class="text-red-500">*</span>
            </label>
            <input
              v-model="workflowForm.name"
              type="text"
              required
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              توضیحات
            </label>
            <textarea
              v-model="workflowForm.description"
              rows="3"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              دسته‌بندی مرتبط
            </label>
            <select
              v-model="workflowForm.category_id"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option :value="null">همه دسته‌بندی‌ها</option>
              <option
                v-for="cat in categories"
                :key="cat.id"
                :value="cat.id"
              >
                {{ cat.name }}
              </option>
            </select>
          </div>

          <div class="flex items-center gap-2">
            <input
              v-model="workflowForm.is_active"
              type="checkbox"
              id="is_active"
              class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            />
            <label for="is_active" class="text-sm font-medium text-gray-700">
              گردش کار فعال است
            </label>
          </div>

          <div class="pt-4 border-t border-gray-200">
            <label class="block text-sm font-medium text-gray-700 mb-3">
              مراحل گردش کار
            </label>

            <div class="space-y-3 mb-4">
              <div
                v-for="(step, index) in workflowForm.steps"
                :key="index"
                class="flex items-start gap-2 p-3 bg-gray-50 rounded-lg"
              >
                <span class="text-sm font-semibold text-gray-600 mt-2">{{ index + 1 }}.</span>
                <div class="flex-1 grid grid-cols-1 md:grid-cols-2 gap-2">
                  <input
                    v-model="step.step_name"
                    type="text"
                    placeholder="نام مرحله"
                    class="px-3 py-2 border border-gray-300 rounded-lg text-sm"
                  />
                  <select
                    v-model="step.assigned_group_id"
                    class="px-3 py-2 border border-gray-300 rounded-lg text-sm"
                  >
                    <option value="">انتخاب گروه</option>
                    <option
                      v-for="group in groups"
                      :key="group.id"
                      :value="group.id"
                    >
                      {{ group.name }}
                    </option>
                  </select>
                  <select
                    v-model="step.action_type"
                    class="px-3 py-2 border border-gray-300 rounded-lg text-sm"
                  >
                    <option value="review">بررسی</option>
                    <option value="approve">تایید</option>
                    <option value="reject">رد</option>
                    <option value="edit">ویرایش</option>
                  </select>
                  <div class="flex items-center gap-2">
                    <input
                      v-model="step.is_required"
                      type="checkbox"
                      :id="`required-${index}`"
                      class="w-4 h-4 text-blue-600 border-gray-300 rounded"
                    />
                    <label :for="`required-${index}`" class="text-xs text-gray-700">
                      اجباری
                    </label>
                  </div>
                </div>
                <button
                  type="button"
                  @click="removeStep(index)"
                  class="p-2 text-red-600 hover:bg-red-50 rounded"
                >
                  <X class="w-4 h-4" />
                </button>
              </div>
            </div>

            <button
              type="button"
              @click="addStep"
              class="w-full px-4 py-2 border-2 border-dashed border-gray-300 rounded-lg text-gray-600 hover:border-blue-500 hover:text-blue-600 transition-colors"
            >
              + افزودن مرحله
            </button>
          </div>

          <div class="flex items-center gap-2 pt-4 border-t border-gray-200">
            <button
              type="submit"
              :disabled="saving"
              class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ saving ? 'در حال پردازش...' : (editingWorkflow ? 'ذخیره تغییرات' : 'افزودن گردش کار') }}
            </button>
            <button
              type="button"
              @click="closeModal"
              :disabled="saving"
              class="flex-1 px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              انصراف
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { supabase } from '@/config/supabase';
import { useAuthStore } from '@/stores/auth';
import { Search, Plus, Folder, Edit, Trash2, X, GitBranch, List, Power } from 'lucide-vue-next';

const authStore = useAuthStore();

const searchQuery = ref('');
const showModal = ref(false);
const editingWorkflow = ref<any>(null);
const loading = ref(true);
const error = ref<string | null>(null);
const saving = ref(false);
const formError = ref<string | null>(null);

const workflowForm = ref({
  name: '',
  description: '',
  category_id: null as string | null,
  is_active: true,
  steps: [] as any[]
});

const workflows = ref<any[]>([]);
const categories = ref<any[]>([]);
const groups = ref<any[]>([]);

const filteredWorkflows = computed(() => {
  if (!searchQuery.value) return workflows.value;

  const query = searchQuery.value.toLowerCase();
  return workflows.value.filter(wf =>
    wf.name.toLowerCase().includes(query) ||
    (wf.description && wf.description.toLowerCase().includes(query))
  );
});

const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('fa-IR').format(date);
};

async function fetchWorkflows() {
  loading.value = true;
  error.value = null;

  try {
    const { data: workflowsData, error: workflowsError } = await supabase
      .from('workflows')
      .select(`
        *,
        category:document_categories(name),
        steps:workflow_steps(
          *,
          group:user_groups(name)
        )
      `)
      .order('created_at', { ascending: false });

    if (workflowsError) throw workflowsError;

    workflows.value = (workflowsData || []).map(wf => ({
      ...wf,
      category_name: wf.category?.name,
      steps: (wf.steps || []).map((s: any) => ({
        ...s,
        group_name: s.group?.name
      })).sort((a: any, b: any) => a.step_order - b.step_order)
    }));
  } catch (err: any) {
    error.value = err.message || 'خطا در بارگذاری گردش کارها';
  } finally {
    loading.value = false;
  }
}

async function fetchCategories() {
  try {
    const { data, error: fetchError } = await supabase
      .from('document_categories')
      .select('*')
      .order('name');

    if (fetchError) throw fetchError;
    categories.value = data || [];
  } catch (err) {
    console.error('Error fetching categories:', err);
  }
}

async function fetchGroups() {
  try {
    const { data, error: fetchError } = await supabase
      .from('user_groups')
      .select('*')
      .order('name');

    if (fetchError) throw fetchError;
    groups.value = data || [];
  } catch (err) {
    console.error('Error fetching groups:', err);
  }
}

const openAddModal = () => {
  showModal.value = true;
  formError.value = null;
};

const viewWorkflowSteps = (workflow: any) => {
  alert(`مراحل گردش کار "${workflow.name}":\n\n` +
    workflow.steps.map((s: any, i: number) =>
      `${i + 1}. ${s.step_name} - ${s.group_name} (${s.action_type})`
    ).join('\n')
  );
};

const editWorkflow = (workflow: any) => {
  editingWorkflow.value = workflow;
  workflowForm.value = {
    name: workflow.name,
    description: workflow.description || '',
    category_id: workflow.category_id || null,
    is_active: workflow.is_active,
    steps: workflow.steps.map((s: any) => ({
      step_name: s.step_name,
      assigned_group_id: s.assigned_group_id,
      action_type: s.action_type,
      is_required: s.is_required
    }))
  };
  showModal.value = true;
  formError.value = null;
};

async function toggleWorkflowStatus(workflow: any) {
  const newStatus = !workflow.is_active;
  const action = newStatus ? 'فعال' : 'غیرفعال';

  if (!confirm(`آیا از ${action} کردن گردش کار "${workflow.name}" اطمینان دارید؟`)) {
    return;
  }

  try {
    const { error: updateError } = await supabase
      .from('workflows')
      .update({ is_active: newStatus })
      .eq('id', workflow.id);

    if (updateError) throw updateError;

    workflow.is_active = newStatus;
  } catch (err: any) {
    alert('خطا در تغییر وضعیت گردش کار: ' + err.message);
  }
}

async function deleteWorkflow(workflow: any) {
  if (!confirm(`آیا از حذف گردش کار "${workflow.name}" اطمینان دارید؟`)) {
    return;
  }

  try {
    const { error: deleteError } = await supabase
      .from('workflows')
      .delete()
      .eq('id', workflow.id);

    if (deleteError) throw deleteError;

    workflows.value = workflows.value.filter(wf => wf.id !== workflow.id);
  } catch (err: any) {
    alert('خطا در حذف گردش کار: ' + err.message);
  }
}

const addStep = () => {
  workflowForm.value.steps.push({
    step_name: '',
    assigned_group_id: '',
    action_type: 'review',
    is_required: true
  });
};

const removeStep = (index: number) => {
  workflowForm.value.steps.splice(index, 1);
};

const closeModal = () => {
  showModal.value = false;
  editingWorkflow.value = null;
  workflowForm.value = {
    name: '',
    description: '',
    category_id: null,
    is_active: true,
    steps: []
  };
  formError.value = null;
};

async function handleSubmit() {
  saving.value = true;
  formError.value = null;

  try {
    if (editingWorkflow.value) {
      const { error: updateError } = await supabase
        .from('workflows')
        .update({
          name: workflowForm.value.name,
          description: workflowForm.value.description || null,
          category_id: workflowForm.value.category_id,
          is_active: workflowForm.value.is_active
        })
        .eq('id', editingWorkflow.value.id);

      if (updateError) throw updateError;

      await supabase
        .from('workflow_steps')
        .delete()
        .eq('workflow_id', editingWorkflow.value.id);

      if (workflowForm.value.steps.length > 0) {
        const stepsToInsert = workflowForm.value.steps.map((step, index) => ({
          workflow_id: editingWorkflow.value.id,
          step_order: index + 1,
          step_name: step.step_name,
          assigned_group_id: step.assigned_group_id,
          action_type: step.action_type,
          is_required: step.is_required
        }));

        const { error: stepsError } = await supabase
          .from('workflow_steps')
          .insert(stepsToInsert);

        if (stepsError) throw stepsError;
      }

      await fetchWorkflows();
    } else {
      const { data: workflowData, error: insertError } = await supabase
        .from('workflows')
        .insert({
          name: workflowForm.value.name,
          description: workflowForm.value.description || null,
          category_id: workflowForm.value.category_id,
          is_active: workflowForm.value.is_active,
          created_by: authStore.user?.id
        })
        .select()
        .single();

      if (insertError) throw insertError;

      if (workflowForm.value.steps.length > 0) {
        const stepsToInsert = workflowForm.value.steps.map((step, index) => ({
          workflow_id: workflowData.id,
          step_order: index + 1,
          step_name: step.step_name,
          assigned_group_id: step.assigned_group_id,
          action_type: step.action_type,
          is_required: step.is_required
        }));

        const { error: stepsError } = await supabase
          .from('workflow_steps')
          .insert(stepsToInsert);

        if (stepsError) throw stepsError;
      }

      await fetchWorkflows();
    }

    closeModal();
  } catch (err: any) {
    formError.value = err.message || 'خطا در ذخیره اطلاعات';
  } finally {
    saving.value = false;
  }
}

onMounted(() => {
  fetchWorkflows();
  fetchCategories();
  fetchGroups();
});
</script>
