require 'spec_helper'

describe "examples of using retrier" do

  class Samurai
    include NOradLTD::Retrier

    def initialize  name, kaishakunin, kaishakunin_blk = nil
      @name = name
      @kaishakunin = kaishakunin
      @kaishakunin_blk = kaishakunin_blk || proc { @kaishakunin.decapitate(self) }
      @head_count = 1
    end

    def seppuku
      puts "\t\t#{self} commits seppuku"
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
          puts "\t\t#{@kaishakunin} is shamed, #{me} was not decaptated"
          raise e
        end
      }.go
       return :dead
    end

    def decapitate victim
      puts "\t\t#{self} honors #{victim}"
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

  it "can still have error and success blocks" do
    hiroyasu_koga = Samurai.new "hiroyasu_koga", nil
    masakatsu_morita = Samurai.new "masakatsu_morita", hiroyasu_koga
    yukio_mishima = Samurai.new "yukio_mishima", masakatsu_morita, proc { raise "decapitation failure" }

    expect(yukio_mishima.seppuku).to eq :dead
    expect(yukio_mishima.head_count).to eq 0
    expect(masakatsu_morita.head_count).to eq 0
    expect(hiroyasu_koga.head_count).to eq 1
    puts "\t\thonor is maintained"
  end

  class Engineer < NOradLTD::Retrier::RetryBuilder
  end

  it "can be used through extension" do
  	xct = 0
  	engineer = Engineer.new 1, proc { xct += 1 }
  	engineer.go

  	expect(xct).to be(1)
  end

  it "can be used with lambdas" do
  	xct = 0
  	engineer = Engineer.new 1, lambda { xct += 1 }
  	engineer.go

  	expect(xct).to be(1)
  end

end