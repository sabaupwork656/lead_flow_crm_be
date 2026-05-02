module Api
  class ActivityLogsController < ApplicationController
    def index
      logs = current_workspace.activity_logs.includes(:user, :lead).order(created_at: :desc).limit(50)
      render json: { activity_logs: logs.map { |log| serialize_activity(log) } }
    end
  end
end
