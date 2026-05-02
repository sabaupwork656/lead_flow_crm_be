module Api
  class WorkspacesController < ApplicationController
    before_action :owner!, only: [:update]

    def show
      render json: { workspace: current_workspace, user: serialize_user(current_user) }
    end

    def update
      current_workspace.update!(workspace_params)
      render json: { workspace: current_workspace }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    private

    def workspace_params
      params.require(:workspace).permit(:name, :business_type, :plan)
    end
  end
end
