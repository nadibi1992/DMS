import { supabase } from '@/config/supabase';
import type { Document, DocumentVersion, DocumentCategory } from '@/types';

export interface DocumentMetadata {
  author?: string;
  subject?: string;
  keywords?: string[];
  language?: string;
  documentDate?: string;
  expiryDate?: string;
  confidentialityLevel?: 'public' | 'internal' | 'confidential' | 'secret';
  customFields?: Record<string, any>;
}

export interface CreateDocumentData {
  title: string;
  description?: string;
  category_id: string;
  status: 'draft' | 'pending';
  tags?: string[];
  metadata?: DocumentMetadata;
  file: File;
}

export interface UploadDocumentVersionData {
  document_id: string;
  file: File;
  changes_description: string;
}

export const documentService = {
  async getCategories(): Promise<DocumentCategory[]> {
    const { data, error } = await supabase
      .from('document_categories')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async uploadDocument(data: CreateDocumentData): Promise<Document> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const filePath = `documents/${user.id}/${Date.now()}_${data.file.name}`;

    const { error: uploadError } = await supabase.storage
      .from('documents')
      .upload(filePath, data.file);

    if (uploadError) throw uploadError;

    const documentData = {
      title: data.title,
      description: data.description,
      file_name: data.file.name,
      file_size: data.file.size,
      file_type: data.file.type,
      file_path: filePath,
      category_id: data.category_id,
      uploaded_by: user.id,
      status: data.status,
      tags: data.tags || [],
      version: 1,
      metadata: data.metadata || {}
    };

    const { data: document, error: insertError } = await supabase
      .from('documents')
      .insert(documentData)
      .select()
      .single();

    if (insertError) {
      await supabase.storage.from('documents').remove([filePath]);
      throw insertError;
    }

    const versionData = {
      document_id: document.id,
      version: 1,
      file_path: filePath,
      uploaded_by: user.id,
      changes_description: 'نسخه اولیه'
    };

    await supabase.from('document_versions').insert(versionData);

    await supabase.from('activity_logs').insert({
      user_id: user.id,
      action: 'document_created',
      entity_type: 'document',
      entity_id: document.id,
      details: { title: document.title }
    });

    return document;
  },

  async uploadNewVersion(data: UploadDocumentVersionData): Promise<DocumentVersion> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const { data: currentDoc, error: docError } = await supabase
      .from('documents')
      .select('version, file_name')
      .eq('id', data.document_id)
      .single();

    if (docError) throw docError;

    const newVersion = currentDoc.version + 1;
    const filePath = `documents/${user.id}/${Date.now()}_v${newVersion}_${data.file.name}`;

    const { error: uploadError } = await supabase.storage
      .from('documents')
      .upload(filePath, data.file);

    if (uploadError) throw uploadError;

    const { error: updateError } = await supabase
      .from('documents')
      .update({
        version: newVersion,
        file_path: filePath,
        file_name: data.file.name,
        file_size: data.file.size,
        file_type: data.file.type,
        updated_at: new Date().toISOString()
      })
      .eq('id', data.document_id);

    if (updateError) {
      await supabase.storage.from('documents').remove([filePath]);
      throw updateError;
    }

    const versionData = {
      document_id: data.document_id,
      version: newVersion,
      file_path: filePath,
      uploaded_by: user.id,
      changes_description: data.changes_description
    };

    const { data: version, error: versionError } = await supabase
      .from('document_versions')
      .insert(versionData)
      .select()
      .single();

    if (versionError) throw versionError;

    await supabase.from('activity_logs').insert({
      user_id: user.id,
      action: 'version_uploaded',
      entity_type: 'document',
      entity_id: data.document_id,
      details: { version: newVersion, changes: data.changes_description }
    });

    return version;
  },

  async getDocument(id: string): Promise<Document> {
    const { data, error } = await supabase
      .from('documents')
      .select(`
        *,
        category:document_categories(id, name),
        uploader:users!documents_uploaded_by_fkey(id, full_name, username)
      `)
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  },

  async getDocumentVersions(documentId: string): Promise<DocumentVersion[]> {
    const { data, error } = await supabase
      .from('document_versions')
      .select(`
        *,
        uploader:users!document_versions_uploaded_by_fkey(id, full_name, username)
      `)
      .eq('document_id', documentId)
      .order('version', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async updateDocumentStatus(documentId: string, status: Document['status'], comment?: string): Promise<void> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const { error } = await supabase
      .from('documents')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', documentId);

    if (error) throw error;

    await supabase.from('document_workflow_history').insert({
      document_id: documentId,
      user_id: user.id,
      action: status,
      comment: comment
    });

    await supabase.from('activity_logs').insert({
      user_id: user.id,
      action: `document_${status}`,
      entity_type: 'document',
      entity_id: documentId,
      details: { status, comment }
    });
  },

  async downloadDocument(filePath: string, fileName: string): Promise<void> {
    const { data, error } = await supabase.storage
      .from('documents')
      .download(filePath);

    if (error) throw error;

    const url = URL.createObjectURL(data);
    const link = document.createElement('a');
    link.href = url;
    link.download = fileName;
    link.click();
    URL.revokeObjectURL(url);
  }
};
