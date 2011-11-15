
module Scratch
  class Retrier
    def try attempts, on_success = nil, on_error = nil, waiter = nil, wait_time = 0, wait_blk = proc {}
      (1..attempts).each do |try_count|
        begin
          yield if block_given?
          on_success.call if ! on_success.nil?
          break
        rescue Exception => e
          on_error.call if ! on_error.nil?
          waiter.wait(wait_time) { wait_blk } if ! waiter.nil?
        end
      end
    end
  end
end
