require 'spec_helper'

describe Pushover::Sendgrid do

  describe '#configure' do

    it 'should set various params' do

      step = Pushover::Sendgrid.new do
        to 'josh@keen.io'
        from 'depths@hell.com'
        subject 'time is up'
        body 'use code 3:16 for high leniency'
      end

      step.configure

      step._to.should == 'josh@keen.io'
      step._from.should == 'depths@hell.com'
      step._subject.should == 'time is up'
      step._body.should == 'use code 3:16 for high leniency'

    end

  end

  describe 'run' do

    it 'should send some email' do

      Mail.stub(:deliver)

      step = Pushover::Sendgrid.new do |response|
        to 'josh@keen.io'
        from 'alerts+pushover@keen.io'
        subject "There were #{response} Pageviews Today!"
        body 'hey wats up'
      end

      step.run(365)

    end

  end

end
