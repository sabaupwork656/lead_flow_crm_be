class LeadImportJob < ApplicationJob
  queue_as :default

  def perform(workspace_id, user_id, rows)
    workspace = Workspace.find(workspace_id)
    user = User.find(user_id)

    rows.each do |attrs|
      lead = workspace.leads.create!(attrs.merge(assigned_to: user))
      workspace.activity_logs.create!(lead: lead, user: user, action: "lead_created", metadata: { source: "csv_import" })
    end
  end
end
