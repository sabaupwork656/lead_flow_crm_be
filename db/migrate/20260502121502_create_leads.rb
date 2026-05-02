class CreateLeads < ActiveRecord::Migration[7.1]
  def change
    create_table :leads do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :company_name
      t.string :source
      t.string :status, null: false, default: "New"
      t.decimal :estimated_value, precision: 12, scale: 2, default: 0
      t.string :priority, null: false, default: "Medium"
      t.datetime :next_follow_up_at
      t.text :notes_summary

      t.timestamps
    end

    add_index :leads, [:workspace_id, :status]
    add_index :leads, [:workspace_id, :next_follow_up_at]
  end
end
