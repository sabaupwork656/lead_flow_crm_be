module Api
  class NotesController < ApplicationController
    def create
      lead = visible_leads.find(params[:lead_id])
      note = lead.notes.create!(user: current_user, body: params.require(:note).permit(:body)[:body])
      current_workspace.activity_logs.create!(lead: lead, user: current_user, action: "note_added", metadata: { note_id: note.id })

      render json: { note: serialize_note(note), activity_logs: lead.activity_logs.includes(:user).order(created_at: :desc).map { |log| serialize_activity(log) } }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    private

    def visible_leads
      scope = current_workspace.leads
      current_user.staff? ? scope.where(assigned_to: current_user) : scope
    end
  end
end
