require "test_helper"

class LeadTest < ActiveSupport::TestCase
  test "requires a supported status and priority" do
    workspace = Workspace.create!(name: "Test Co")
    user = workspace.users.create!(name: "Owner", email: "owner@example.com", password: "password123", role: "owner")
    lead = workspace.leads.new(name: "Jane Lead", status: "Archived", priority: "Urgent", assigned_to: user)

    assert_not lead.valid?
    assert_includes lead.errors[:status], "is not included in the list"
    assert_includes lead.errors[:priority], "is not included in the list"
  end
end
