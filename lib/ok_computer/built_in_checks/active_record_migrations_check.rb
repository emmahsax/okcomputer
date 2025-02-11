module OkComputer
  class ActiveRecordMigrationsCheck < Check
    # Public: Check if migrations are pending or not
    def check
      return mark_message(page_load_message) if check_on_page_load?

      error_if_pending_migrations(Rails.version)

      mark_message "NO pending migrations"
    rescue ActiveRecord::PendingMigrationError
      mark_failure
      mark_message "Pending migrations"
    end

    private

    # this check is only valid if config.active_record.migration_error is set to false rather than :page_load
    # :page_load adds a Middleware check that throws an error before the call reaches ok_computer
    # we only run this check when :page_load is set if there are no pending migrations
    # :page_load is the default in development, otherwise this is false
    # see https://github.com/rails/rails/blob/d39db5d1891f7509cde2efc425c9d69bbb77e670/activerecord/lib/active_record/railtie.rb#L103
    def check_on_page_load?
      Rails.configuration.active_record.migration_error
    end

    def error_if_pending_migrations(version_string)
      if Gem::Version.new(version_string) >= Gem::Version.new("7.1")
        ActiveRecord::Migration.check_all_pending!
      else
        ActiveRecord::Migration.check_pending!
      end
    end

    def page_load_message
      "NOTE: pending migrations are checked on page_load"
    end
  end
end
