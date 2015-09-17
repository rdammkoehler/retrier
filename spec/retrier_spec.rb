require 'spec_helper'

describe "retrier" do

  before :each do
    @run_ct = 0
    @success_ct = 0
    @error_ct = 0
    @wait_ct = 0
  end

  let(:no_op) {
    proc {}
  }

  let(:retrier) {
    Object.new.extend NOradLTD::Retrier
  }

  let(:run_blk) {
    proc {
      @run_ct += 1
    }
  }

  let(:success_blk) { 
    proc { 
      @success_ct += 1 
    }
  }

  let(:error_blk) {
    proc { |e|
      @error_ct += 1 
    }
  }

  let(:wait_blk) {
    proc { 
      @wait_ct += 1 
    }
  }

  it "runs the given block" do
    
    retrier.try(1) {
      run_blk.call
    }.go
    
    expect(@run_ct).to eq 1
  end
  
  it "runs on_success if things worked out" do
    retrier.try(5) {}.success { 
      success_blk.call 
    }.go
    
    expect(@success_ct).to eq 1
  end

  it "only needs a try count" do
    retrier.try(1) { 
      run_blk.call
    }.go

    expect(@run_ct).to eq 1
  end

  it "runs on_error if things didn't work out" do
    retrier.try(5) {
      raise "blah"
    }.error { |e| 
      error_blk.call e 
    }.go

    expect(@error_ct).to eq 5
  end

  it "uses waiter if things didn't work out" do
    retrier.try(5) {
      raise "blah"
    }.wait(0) { |wc|
      wait_blk.call wc
    }.go

    expect(@wait_ct).to eq 5
  end

  it "error_blk recieves the exception from the try" do
    ex = "fooie"
    received_ex = ""
    
    retrier.try(1) {
      raise "fooie"
    }.error { |e|
      received_ex = e.message
    }.go

    expect(received_ex).to eq ex
  end

  it "error_blk doesn't have to be called every time" do
    retrier.try(3) {
      raise "foo"
    }.wait(0,2) { |wc|
      wait_blk.call wc
    }.go

    expect(@wait_ct).to eq 1
  end
    
  it "error_blk runs on each error along with wait" do
    retrier.try(2) {
      raise "foo"
    }.wait(0) { |wc|
      wait_blk.call wc
    }.error{ |e| 
      error_blk.call e
    }.go

    expect(@wait_ct).to eq 2
    expect(@error_ct).to eq 2
  end

  it "doesn't run wait_blk if wait_count mod wait_interval != 0" do
    retrier.try(5) {}.wait(0,10) { |wc| wait_blk.call wc }.go

    expect(@wait_ct).to eq 0
  end

  it "can alternately be constructed directly" do
    blk = proc { 
      run_blk.call
      raise "foo"
    }

    retrier = NOradLTD::Retrier::RetryBuilder.new 5, blk

    retrier.wait(0) { |wc|
      wait_blk.call
    }

    retrier.success { 
      success_blk.call
    }

    retrier.error { |e|
      error_blk.call
    }

    retrier.go

    expect(@run_ct).to eq 5
    expect(@wait_ct).to eq 5
    expect(@success_ct).to eq 0
    expect(@error_ct).to eq 5
  end

  it "can also be mixed in" do

    class CanHazRetrier
      include NOradLTD::Retrier
    end

    chr = CanHazRetrier.new
    chr.try(1) { run_blk.call }.go

    expect(@run_ct).to eq 1
  end

  class Samurai
    include NOradLTD::Retrier

    def initialize  name, kaishakunin, kaishakunin_blk = nil
      @name = name
      @kaishakunin = kaishakunin
      @kaishakunin_blk = kaishakunin_blk || proc { @kaishakunin.decapitate(self) }
      @head_count = 1
    end

    def seppuku
      puts "#{self} commits seppuku"
      me = self
      try(1) { 
        next :dead
      }.error{ |e| 
        @kaishakunin.kaishakunin.decapitate(me)
        @kaishakunin.seppuku
      }.success{ 
        begin
          @kaishakunin_blk.call if @kaishakunin
        rescue Exception => e
          puts "#{@kaishakunin} is shamed, #{me} was not decaptated"
          raise e
        end
      }.go
       return :dead
    end

    def decapitate victim
      puts "#{self} honors #{victim}"
      victim.head_count = 0
      return :dead
    end

    def kaishakunin
      return @kaishakunin
    end

    def head_count= newct
      @head_count = newct
    end

    def head_count 
      @head_count
    end

    def to_s
      return @name
    end

  end

  it "can be be internalized as a mixin" do
    oda_nobunaga = Samurai.new "oda_nobunaga", nil
    expect(oda_nobunaga.seppuku).to eq :dead
  end

  it "can still have success blocks" do
    hiroyasu_koga = Samurai.new "hiroyasu_koga", nil
    masakatsu_morita = Samurai.new "masakatsu_morita", hiroyasu_koga
    yukio_mishima = Samurai.new "yukio_mishima", masakatsu_morita, proc { raise "decapitation failure" }

    expect(yukio_mishima.seppuku).to eq :dead
    expect(yukio_mishima.head_count).to eq 0
    expect(masakatsu_morita.head_count).to eq 0
    expect(hiroyasu_koga.head_count).to eq 1
    puts "honor is maintained"
  end


end
