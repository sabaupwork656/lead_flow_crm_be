require "test_helper"

class Api::AuthControllerTest < ActionDispatch::IntegrationTest
  test "signup creates owner and workspace" do
    post "/api/auth/signup", params: {
      name: "Demo Owner",
      email: "demo-owner@example.com",
      password: "password123",
      workspace_name: "Demo Workspace"
    }

    assert_response :created
    body = JSON.parse(response.body)
    assert body["token"].present?
    assert_equal "Demo Workspace", body["workspace"]["name"]
  end
end
