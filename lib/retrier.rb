
module Scratch
  class Retrier
    def try attempts, on_success = nil, on_error = nil, waiter = nil, wait_time = 0, wait_blk = proc {}
      [0..attempts].each do |try|
        begin
          yield
          on_success.call if ! on_success.nil?
        rescue Exception => e
          waiter.wait wait_time { wait_blk } if ! on_waiter.nil?
        end
      end
    end
  end
end
