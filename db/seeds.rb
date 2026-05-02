ActivityLog.destroy_all
Note.destroy_all
Lead.destroy_all
User.destroy_all
Workspace.destroy_all

workspace = Workspace.create!(name: "BluePeak Home Services", business_type: "Home Services", plan: "Growth")

owner = workspace.users.create!(name: "Ava Morgan", email: "admin@leadflowcrm.com", password: "password123", role: "owner")
manager = workspace.users.create!(name: "Marcus Reed", email: "manager@leadflowcrm.com", password: "password123", role: "manager")
staff = workspace.users.create!(name: "Nina Patel", email: "staff@leadflowcrm.com", password: "password123", role: "staff")
team = [owner, manager, staff]

statuses = Lead::STATUSES
priorities = Lead::PRIORITIES
sources = ["Google Ads", "Website", "Referral", "Facebook", "Thumbtack", "Yelp", "Cold Outreach"]
companies = [
  "Harbor Point Apartments", "Oakline Dental", "Riverbend Realty", "Summit Storage", "Evergreen HOA",
  "Northstar Fitness", "Canyon Creek Homes", "Metro Legal Group", "BrightPath School", "Valley Auto",
  "Cedar Ridge Church", "Atlas Property Group", "FreshStart Kitchens", "Pioneer Builders", "Sunrise Salon",
  "Keystone Rentals", "Urban Nest", "Ridgeway Clinic", "Willow Lane Retail", "Bayside Condos",
  "PrimeCare Medical", "Liberty Warehouse", "Aster Agency", "Lakeside Market", "Horizon Offices"
]

companies.each_with_index do |company, index|
  lead = workspace.leads.create!(
    name: ["Sarah Collins", "David Kim", "Monica Lee", "James Walker", "Priya Shah", "Leo Brooks"].sample,
    email: "lead#{index + 1}@example.com",
    phone: "555-01#{format('%02d', index)}",
    company_name: company,
    source: sources[index % sources.length],
    status: statuses[index % statuses.length],
    estimated_value: [950, 1800, 2400, 3900, 5200, 8700, 12500].sample,
    priority: priorities[index % priorities.length],
    assigned_to: team[index % team.length],
    next_follow_up_at: (index - 5).days.from_now.change(hour: [9, 11, 14, 16].sample),
    notes_summary: "Needs a clear estimate, fast follow-up, and timeline confirmation."
  )

  workspace.activity_logs.create!(lead: lead, user: lead.assigned_to || owner, action: "lead_created", metadata: { source: lead.source })

  if index.even?
    note = lead.notes.create!(user: manager, body: "Discovery call completed. Client asked for pricing, availability, and insurance details.")
    workspace.activity_logs.create!(lead: lead, user: manager, action: "note_added", metadata: { note_id: note.id })
  end

  if ["Contacted", "Qualified", "Proposal Sent", "Won", "Lost"].include?(lead.status)
    workspace.activity_logs.create!(lead: lead, user: lead.assigned_to || owner, action: "status_changed", metadata: { from: "New", to: lead.status })
  end
end

puts "Seeded LeadFlow CRM demo workspace with #{Workspace.count} workspace, #{User.count} users, #{Lead.count} leads."
