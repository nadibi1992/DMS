import { supabase } from '@/config/supabase';
import type { Comment } from '@/types';

export interface CommentWithUser extends Comment {
  user: {
    id: string;
    full_name: string;
    username: string;
  };
}

export const commentService = {
  async getDocumentComments(documentId: string): Promise<CommentWithUser[]> {
    const { data, error } = await supabase
      .from('comments')
      .select(`
        *,
        user:users!comments_user_id_fkey(id, full_name, username)
      `)
      .eq('document_id', documentId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async addComment(documentId: string, content: string): Promise<Comment> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const { data, error } = await supabase
      .from('comments')
      .insert({
        document_id: documentId,
        user_id: user.id,
        content
      })
      .select()
      .single();

    if (error) throw error;

    await supabase.from('activity_logs').insert({
      user_id: user.id,
      action: 'comment_added',
      entity_type: 'document',
      entity_id: documentId,
      details: { comment_id: data.id }
    });

    return data;
  },

  async deleteComment(commentId: string): Promise<void> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('User not authenticated');

    const { error } = await supabase
      .from('comments')
      .delete()
      .eq('id', commentId)
      .eq('user_id', user.id);

    if (error) throw error;
  }
};
