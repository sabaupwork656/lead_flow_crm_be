require "csv"

module Api
  class LeadsController < ApplicationController
    before_action :set_lead, only: [:show, :update, :destroy]
    before_action :owner_or_manager!, only: [:destroy, :import]

    def index
      leads = visible_leads.includes(:assigned_to).order(created_at: :desc)
      leads = leads.where(status: params[:status]) if params[:status].present?
      leads = leads.where("name ILIKE :q OR company_name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      render json: { leads: leads.map { |lead| serialize_lead(lead) }, statuses: Lead::STATUSES, priorities: Lead::PRIORITIES }
    end

    def show
      render json: { lead: serialize_lead(@lead, detailed: true), team: current_workspace.users.map { |user| serialize_user(user) } }
    end

    def create
      lead = current_workspace.leads.new(lead_params)
      lead.assigned_to ||= current_user if current_user.staff?
      authorize_staff_assignment!(lead)
      return if performed?

      lead.save!
      log_activity(lead, "lead_created")

      render json: { lead: serialize_lead(lead) }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    def update
      authorize_staff_assignment!(@lead)
      return if performed?

      previous = @lead.slice("status", "assigned_to_id", "next_follow_up_at")
      @lead.update!(lead_params)
      write_change_logs(@lead, previous)

      render json: { lead: serialize_lead(@lead.reload, detailed: true) }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    def destroy
      @lead.destroy
      render json: { message: "Lead deleted" }
    end

    def export
      csv = CSV.generate(headers: true) do |out|
        out << %w[name email phone company_name source status estimated_value priority assigned_to next_follow_up_at]
        visible_leads.includes(:assigned_to).find_each do |lead|
          out << [lead.name, lead.email, lead.phone, lead.company_name, lead.source, lead.status, lead.estimated_value, lead.priority, lead.assigned_to&.name, lead.next_follow_up_at]
        end
      end

      send_data csv, filename: "leadflow-leads-#{Date.current}.csv", type: "text/csv"
    end

    def import
      file = params[:file]
      return render json: { error: "CSV file is required" }, status: :unprocessable_entity unless file

      imported = 0
      CSV.foreach(file.path, headers: true) do |row|
        lead = current_workspace.leads.create!(
          name: row["name"],
          email: row["email"],
          phone: row["phone"],
          company_name: row["company_name"],
          source: row["source"],
          status: row["status"].presence || "New",
          estimated_value: row["estimated_value"].presence || 0,
          priority: row["priority"].presence || "Medium",
          assigned_to: current_user
        )
        log_activity(lead, "lead_created", { source: "csv_import" })
        imported += 1
      end

      render json: { message: "Imported #{imported} leads", imported: imported }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    private

    def visible_leads
      scope = current_workspace.leads
      current_user.staff? ? scope.where(assigned_to: current_user) : scope
    end

    def set_lead
      @lead = visible_leads.find(params[:id])
    end

    def lead_params
      params.require(:lead).permit(:name, :email, :phone, :company_name, :source, :status, :estimated_value, :priority, :assigned_to_id, :next_follow_up_at, :notes_summary)
    end

    def authorize_staff_assignment!(lead)
      return unless current_user.staff?
      return if lead.assigned_to_id.blank? || lead.assigned_to_id == current_user.id

      render json: { error: "Staff can only manage assigned leads" }, status: :forbidden
    end

    def write_change_logs(lead, previous)
      log_activity(lead, "status_changed", { from: previous["status"], to: lead.status }) if previous["status"] != lead.status
      log_activity(lead, "lead_assigned", { assigned_to_id: lead.assigned_to_id }) if previous["assigned_to_id"] != lead.assigned_to_id
      log_activity(lead, "follow_up_changed", { from: previous["next_follow_up_at"], to: lead.next_follow_up_at }) if previous["next_follow_up_at"] != lead.next_follow_up_at
    end

    def log_activity(lead, action, metadata = {})
      current_workspace.activity_logs.create!(lead: lead, user: current_user, action: action, metadata: metadata)
    end
  end
end
