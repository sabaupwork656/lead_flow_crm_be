module Api
  class TeamController < ApplicationController
    before_action :owner!, only: [:create]

    def index
      render json: { team: current_workspace.users.order(:role, :name).map { |user| serialize_user(user) } }
    end

    def create
      user = current_workspace.users.create!(team_params.merge(password: params[:password].presence || "password123"))
      current_workspace.activity_logs.create!(user: current_user, action: "team_member_created", metadata: { member_id: user.id, role: user.role })

      render json: { user: serialize_user(user), temporary_password: params[:password].presence || "password123" }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    private

    def team_params
      params.require(:user).permit(:name, :email, :role)
    end
  end
end
