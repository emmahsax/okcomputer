module OkComputer
  # Verifies if the mail server configured for ActionMailer is responding.
  class ActionMailerCheck < PingCheck

    attr_accessor :klass, :timeout, :host, :port

    def initialize(klass = ActionMailer::Base, timeout = 5)
      self.klass = klass
      self.timeout = timeout
      host = klass.smtp_settings[:address]
      port = klass.smtp_settings[:port] || 25
      super(host, port, timeout)
    end

    # Public: Return the status of the check
    def check
      case klass.delivery_method
      when :smtp
        begin
          tcp_socket_request
          mark_message "#{klass} check to #{host}:#{port} successful"
        rescue => e
          mark_message "#{klass} at #{host}:#{port} is not accepting connections: '#{e}'"
          mark_failure
        end
      when :sendmail
        begin
          location = klass.sendmail_settings[:location]
          if File.executable?(location)
            mark_message "#{klass} sendmail executable #{location} can be executed"
          else
            mark_message "#{klass} sendmail executable #{location} is not executable"
            mark_failure
          end
        rescue => e
          mark_message "#{klass} error checking sendmail executable: '#{e}'"
          mark_failure
        end
      when :test
        mark_message "#{klass} is in test mode"
      else
        mark_message "unknown delivery method #{klass.delivery_method}"
        mark_failure
      end
    end
  end
end
