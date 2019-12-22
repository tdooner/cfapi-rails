class BackfillBrigadeSlugs < ActiveRecord::Migration[5.2]
  def change
    Brigade.all.each(&:save)
  end
end
