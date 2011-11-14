require 'rspec'
require 'retrier'

describe "retrier" do

  class Spy
    attr_reader :called
    def initialize
      @called = 0
    end
    def called
      @called +=1
    end
  end

  class Successor < Spy
    def success
      called
    end
  end

  class Erroror < Spy
    def error
      called
    end
  end

  class Waiter < Spy
    def wait wt
      called
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
  let(:error) {
    Erroror.new
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
    retrier.try 5, success, error, waiter, wait_time, waiter_block {
      puts "OK"
    }
    
    successor.called.should eq 1
    erroror.called.should eq 0
    waiter.called.should eq 0
  end

  it "runs on_error if things didn't work out" do
    retrier.try 5, success, error, waiter, wait_time, waiter_block {
      raise "blah"
    }

    successor.called.should eq 0
    erroror.called.should eq 1
    waiter.called.should eq 1
  end

  it "uses waiter if things didn't work out" do
    retrier.try 5, success, error, waiter, wait_time, waiter_block {
      raise "blah"
    }

    successor.called.should eq 0
    erroror.called.should eq 1
    waiter.called.should eq 1
  end

end
