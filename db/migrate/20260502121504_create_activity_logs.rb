class CreateActivityLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_logs do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :lead, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :activity_logs, [:workspace_id, :created_at]
  end
end
