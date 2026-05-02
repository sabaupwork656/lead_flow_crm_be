require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email and authenticates" do
    workspace = Workspace.create!(name: "Test Co")
    user = workspace.users.create!(name: "Owner", email: "OWNER@Example.COM", password: "password123", role: "owner")

    assert_equal "owner@example.com", user.email
    assert user.authenticate("password123")
  end
end
