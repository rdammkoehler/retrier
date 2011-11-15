require 'rspec'
require 'retrier'

describe "retrier" do

  class Spy
    attr_accessor :calls
    def initialize
      @calls = 0
    end
    def called sym
      puts sym
      @calls +=1
    end
  end

  class Successor < Spy
    def success
      called :success
    end
  end

  class Erroror < Spy
    def error
      called :error
    end
  end

  class Waiter < Spy
    def wait wt
      called :wait
    end
  end

  let(:retrier) {
    Scratch::Retrier.new
  }
  let(:successor) {
    Successor.new
  }
  let(:success) { 
    successor.method('success')
  }
  let(:erroror) {
    Erroror.new
  }
  let(:error) {
    erroror.method('error')
  }
  let(:waiter) {
    Waiter.new
  }
  let(:wait_time) {
    1
  }
  let(:waiter_block) {
    proc { "wait blk" }
  }
  
  it "runs on_success if things worked out" do
    runs = 0
    retrier.try(5, success, error, waiter, wait_time, waiter_block) {
      runs += 1
      puts "OK"
    }
    
    runs.should eq 1
    successor.calls.should eq 1
    error.calls.should eq 0
    waiter.calls.should eq 0
  end

  it "runs on_error if things didn't work out" do
    retrier.try(5, success, error, waiter, wait_time, waiter_block) {
      raise "blah"
    }

    successor.calls.should eq 0
    error.calls.should eq 1
    waiter.calls.should eq 1
  end

  it "uses waiter if things didn't work out" do
    retrier.try(5, success, error, waiter, wait_time, waiter_block) {
      raise "blah"
    }

    successor.calls.should eq 0
    error.calls.should eq 1
    waiter.calls.should eq 1
  end

end
