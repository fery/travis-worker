require 'test_helper'

class ReporterHttpConfigTest < Test::Unit::TestCase
  include Travis

  attr_reader :job, :reporter, :now

  def setup
    super
    @job = Job::Config.new(Hashie::Mash.new(INCOMING_PAYLOADS['build:gem-release']))
    job.stubs(:puts) # silence output
    job.stubs(:read).returns(:foo => :bar)

    @reporter = Reporter::Http.new(job.build)
    job.observers << reporter

    @now = Time.now
    Time.stubs(:now).returns(now)
  end

  test 'queues a :finished message' do
    within_em_loop do
      job.work!
      message = reporter.messages[0]
      assert_equal :finish, message.type
      assert_equal '/builds/1', message.target
      assert_equal({ :_method => :put, :msg_id => 1, :build => { :config => { :foo => :bar } } }, message.data)
    end
  end
end


