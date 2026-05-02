class CreateWorkspaces < ActiveRecord::Migration[7.1]
  def change
    create_table :workspaces do |t|
      t.string :name, null: false
      t.string :business_type
      t.string :plan, null: false, default: "Growth"

      t.timestamps
    end
  end
end
