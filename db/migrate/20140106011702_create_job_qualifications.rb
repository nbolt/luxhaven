class CreateJobQualifications < ActiveRecord::Migration
  def change
    create_table :job_qualifications do |t|
      t.string :text
      t.integer :about_id
      t.integer :skills_id
      t.integer :responsibilities_id

      t.timestamps
    end
  end
end
