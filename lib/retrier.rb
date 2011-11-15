
module Scratch
  class Retrier
    def try attempts, success_blk = proc {}, error_blk = proc {}, waiter = nil, wait_time = 0, wait_blk = proc {}
      (1..attempts).each do |try_count|
        begin
          yield if block_given?
          success_blk.call
          break
        rescue Exception => e
          error_blk.call e
          waiter.wait(wait_time) { wait_blk.call } if ! waiter.nil?
        end
      end
    end
  end
end
