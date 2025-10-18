export interface User {
  id: string;
  username: string;
  fullName: string;
  email: string;
  role: 'admin' | 'user';
  department?: string;
}

export interface Document {
  id: string;
  title: string;
  description?: string;
  file_name: string;
  file_size: number;
  file_type: string;
  file_path: string;
  category_id?: string;
  uploaded_by: string;
  uploaded_at: string;
  updated_at: string;
  version: number;
  status: 'draft' | 'pending' | 'approved' | 'rejected';
  tags?: string[];
}

export interface DocumentCategory {
  id: string;
  name: string;
  description?: string;
  parent_id?: string;
  created_at: string;
}

export interface DocumentVersion {
  id: string;
  document_id: string;
  version: number;
  file_path: string;
  uploaded_by: string;
  uploaded_at: string;
  changes_description?: string;
}

export interface Comment {
  id: string;
  document_id: string;
  user_id: string;
  content: string;
  created_at: string;
}

export interface ActivityLog {
  id: string;
  user_id: string;
  action: string;
  entity_type: string;
  entity_id: string;
  created_at: string;
}
