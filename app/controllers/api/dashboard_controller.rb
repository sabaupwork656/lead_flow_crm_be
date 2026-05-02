module Api
  class DashboardController < ApplicationController
    def summary
      leads = visible_leads
      total = leads.count
      won = leads.where(status: "Won").count
      lost = leads.where(status: "Lost").count
      pipeline_value = leads.where.not(status: ["Won", "Lost"]).sum(:estimated_value).to_f

      render json: {
        metrics: {
          total_leads: total,
          new_leads: leads.where(status: "New").count,
          won_leads: won,
          lost_leads: lost,
          total_pipeline_value: pipeline_value,
          conversion_rate: total.positive? ? ((won.to_f / total) * 100).round(1) : 0,
          upcoming_follow_ups: leads.where(next_follow_up_at: Time.current..7.days.from_now).count
        },
        leads_by_status: Lead::STATUSES.map { |status| { status: status, count: leads.where(status: status).count } },
        monthly_leads: monthly_leads(leads),
        won_vs_lost: [{ name: "Won", value: won }, { name: "Lost", value: lost }],
        upcoming_follow_ups: leads.includes(:assigned_to).where(next_follow_up_at: Time.current..14.days.from_now).order(:next_follow_up_at).limit(6).map { |lead| serialize_lead(lead) },
        recent_activity: current_workspace.activity_logs.includes(:user, :lead).order(created_at: :desc).limit(10).map { |log| serialize_activity(log) }
      }
    end

    private

    def visible_leads
      scope = current_workspace.leads
      current_user.staff? ? scope.where(assigned_to: current_user) : scope
    end

    def monthly_leads(leads)
      6.downto(0).map do |offset|
        date = offset.months.ago.beginning_of_month
        range = date..date.end_of_month
        { month: date.strftime("%b"), leads: leads.where(created_at: range).count }
      end
    end
  end
end
