class AddActiveToSubjects < ActiveRecord::Migration[5.1]
  def change
    add_column :subjects, :active, :boolean, default: true
  end
end
