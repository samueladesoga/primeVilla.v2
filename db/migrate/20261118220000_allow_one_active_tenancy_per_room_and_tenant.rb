# Before the model validations were added, a room (or a tenant) could end up with
# more than one active tenancy, e.g. when a new tenant was assigned after the old
# one moved out early without the old tenancy being ended. That made the
# dashboard show more occupied rooms than exist (22 / 21).
#
# This ends the older duplicates, keeping the tenancy that started most recently
# in each room (and for each tenant), then adds unique indexes so the database
# itself refuses a second active tenancy from now on.
class AllowOneActiveTenancyPerRoomAndTenant < ActiveRecord::Migration[8.1]
  class Tenancy < ActiveRecord::Base
    self.table_name = "tenancies"
  end

  def up
    end_duplicate_active_tenancies(:room_id)
    end_duplicate_active_tenancies(:user_id)

    add_index :tenancies, :room_id, unique: true, where: "is_active = 1", name: "index_tenancies_one_active_per_room"
    add_index :tenancies, :user_id, unique: true, where: "is_active = 1", name: "index_tenancies_one_active_per_user"
  end

  def down
    remove_index :tenancies, name: "index_tenancies_one_active_per_user"
    remove_index :tenancies, name: "index_tenancies_one_active_per_room"
    # Ended duplicates are left ended: they were never valid as active tenancies.
  end

  private
    def end_duplicate_active_tenancies(column)
      duplicated = Tenancy.where(is_active: true).group(column).having("COUNT(*) > 1").pluck(column)

      duplicated.each do |value|
        kept, *older = Tenancy.where(is_active: true, column => value).order(start_date: :desc, id: :desc).to_a

        older.each do |tenancy|
          tenancy.update_columns(is_active: false, end_date: moved_out_on(tenancy, kept))
          say "Ended tenancy ##{tenancy.id} (#{column} #{value}); kept ##{kept.id} active", true
        end
      end
    end

    # The older tenancy ended no later than the kept one started, as long as that
    # still leaves it ending after its own start date.
    def moved_out_on(tenancy, kept)
      return tenancy.end_date if tenancy.end_date.nil? || kept.start_date.nil? || tenancy.start_date.nil?

      candidate = [ tenancy.end_date, kept.start_date ].min
      candidate > tenancy.start_date ? candidate : tenancy.end_date
    end
end
