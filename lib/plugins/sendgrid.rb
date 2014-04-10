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

    PROVIDER_NAME = 'sendgrid'

    attr_accessor :_from
    attr_accessor :_to
    attr_accessor :_subject
    attr_accessor :_body
    attr_accessor :_template
    attr_accessor :_locals

    def run(last_response=nil, step_responses=nil)

      self.configure(last_response, step_responses)

      _to = self._to
      _from = self._from
      _subject = self._subject

      if self._template
        _body = self._template
      else
        _body = self._body
      end

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

    def body(body)
      self._body = body
    end

    def template(template, locals)
      self._template = template
      self._locals = locals
    end

  end

  Pushover::Job.register_provider(Sendgrid::PROVIDER_NAME, Sendgrid)
end
