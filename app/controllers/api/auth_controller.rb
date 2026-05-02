module Api
  class AuthController < ApplicationController
    skip_before_action :authenticate_user!, only: [:signup, :login]

    def signup
      workspace = Workspace.new(name: params[:workspace_name].presence || "#{params[:name]}'s Company", business_type: params[:business_type], plan: "Growth")
      user = workspace.users.build(name: params[:name], email: params[:email], password: params[:password], role: "owner")

      ActiveRecord::Base.transaction do
        workspace.save!
        user.save!
      end

      render_session(user, :created)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    def login
      user = User.find_by(email: params[:email].to_s.downcase)

      if user&.authenticate(params[:password])
        render_session(user)
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def me
      render json: { user: serialize_user(current_user), workspace: current_workspace }
    end

    private

    def render_session(user, status = :ok)
      render json: {
        token: JsonWebToken.encode(user_id: user.id),
        user: serialize_user(user),
        workspace: user.workspace
      }, status: status
    end
  end
end
