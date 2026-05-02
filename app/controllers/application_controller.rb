class ApplicationController < ActionController::API
  before_action :authenticate_user!

  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate_user!
    header = request.headers["Authorization"].to_s
    token = header.split.last
    payload = JsonWebToken.decode(token)
    @current_user = User.includes(:workspace).find(payload["user_id"])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound, NoMethodError
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def current_workspace
    current_user.workspace
  end

  def owner_or_manager!
    return if current_user.owner? || current_user.manager?

    render json: { error: "You do not have permission to perform this action" }, status: :forbidden
  end

  def owner!
    return if current_user.owner?

    render json: { error: "Only workspace owners can perform this action" }, status: :forbidden
  end

  def serialize_user(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.created_at
    }
  end

  def serialize_lead(lead, detailed: false)
    payload = {
      id: lead.id,
      name: lead.name,
      email: lead.email,
      phone: lead.phone,
      company_name: lead.company_name,
      source: lead.source,
      status: lead.status,
      estimated_value: lead.estimated_value.to_f,
      priority: lead.priority,
      assigned_to_id: lead.assigned_to_id,
      assigned_to: lead.assigned_to && serialize_user(lead.assigned_to),
      next_follow_up_at: lead.next_follow_up_at,
      notes_summary: lead.notes_summary,
      created_at: lead.created_at,
      updated_at: lead.updated_at
    }

    if detailed
      payload[:notes] = lead.notes.includes(:user).order(created_at: :desc).map { |note| serialize_note(note) }
      payload[:activity_logs] = lead.activity_logs.includes(:user).order(created_at: :desc).map { |log| serialize_activity(log) }
    end

    payload
  end

  def serialize_note(note)
    {
      id: note.id,
      body: note.body,
      user: serialize_user(note.user),
      created_at: note.created_at
    }
  end

  def serialize_activity(log)
    {
      id: log.id,
      action: log.action,
      metadata: log.metadata,
      lead_id: log.lead_id,
      lead_name: log.lead&.name,
      user: serialize_user(log.user),
      created_at: log.created_at
    }
  end

  def not_found
    render json: { error: "Record not found" }, status: :not_found
  end
end
