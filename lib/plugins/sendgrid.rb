require 'mail'

Mail.defaults do
  delivery_method :smtp, { :address   => 'smtp.sendgrid.net',
                           :port      => 587,
                           :domain    => ENV['SENDGRID_DOMAIN'],
                           :user_name => ENV['SENDGRID_USERNAME'],
                           :password  => ENV['SENDGRID_PASSWORD'],
                           :authentication => 'plain',
                           :enable_starttls_auto => true }
end

module Pushover

  class Sendgrid < Step

    PLUGIN_NAME = 'sendgrid'

    attr_accessor :_from
    attr_accessor :_to
    attr_accessor :_subject
    attr_accessor :_body
    attr_accessor :_preview

    def run(last_response=nil, step_responses=nil)

      self.configure(last_response, step_responses)

      # print the message if its just a preview
      return print_preview if self._preview

      _to = self._to
      _from = self._from
      _subject = self._subject
      _body = self._body

      Mail.deliver do
        to _to
        from _from
        subject _subject
        text_part do
          body _body
        end
        html_part do
          content_type 'text/html; charset=UTF-8'
          body _body
        end
      end
    end

    def configure(last_response=nil, step_responses=nil)
      self.instance_exec(last_response, step_responses, &block)
    end

    def from(from)
      self._from = from
    end

    def to(to)
      self._to = to
    end

    def subject(subject)
      self._subject = subject
    end

    def preview(preview)
      self._preview = preview
    end

    def body(*args)
      if args.length == 1
        self._body = args.first
      else
        self._body = template *args
      end
    end

    private

    def print_preview
      puts <<MESSAGE
To: #{self._to}
From: #{self._from}
Subject: #{self._subject}

      #{self._body}
MESSAGE
    end

  end

  Pushover::Job.register_plugin(Sendgrid::PLUGIN_NAME, Sendgrid)
end
