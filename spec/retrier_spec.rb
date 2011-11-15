require 'rspec'
require 'retrier'

describe "retrier" do

  class Waiter
    def wait wt
      yield
    end
  end

  before :each do
    @success_ct = 0
    @error_ct = 0
    @wait_ct = 0
  end

  let(:retrier) {
    Scratch::Retrier.new
  }
  let(:success) { 
    proc { 
      @success_ct += 1 
    }
  }
  let(:error) {
    proc { |e|
      @error_ct += 1 
    }
  }
  let(:waiter) {
    Waiter.new
  }
  let(:wait_time) {
    1
  }
  let(:waiter_block) {
    proc { 
      @wait_ct += 1 
    }
  }

  it "runs the given block" do
    runs = 0
    
    retrier.try(1, success, error, waiter, wait_time, waiter_block) {
      runs += 1
    }
    
    runs.should eq 1
  end
  
  it "runs on_success if things worked out" do
    retrier.try(5, success, error, waiter, wait_time, waiter_block) {
    }
    
    @success_ct.should eq 1
  end

  it "doesn't complain about not receiving a block" do
    retrier.try(1, success, error, waiter, wait_time, waiter_block)
    
    @error_ct.should eq 0
  end

  it "only needs a try count" do
    runs = 0

    retrier.try(1) { runs += 1 }

    runs.should eq 1
  end

  it "runs on_error if things didn't work out" do
    retrier.try(5, success, error, waiter, wait_time, waiter_block) {
      raise "blah"
    }

    @error_ct.should eq 5
  end

  it "uses waiter if things didn't work out" do
    retrier.try(5, success, error, waiter, wait_time, waiter_block) {
      raise "blah"
    }

    @wait_ct.should eq 5
  end

  it "error_blk recieves the Exception from the try" do
    ex = "fooie"
    received_ex = ""
    retrier.try(2, success, proc { |e| received_ex = e }, waiter, wait_time, waiter_block) {
      raise ex
    } 
    received_ex.message.should eq ex
  end

end
