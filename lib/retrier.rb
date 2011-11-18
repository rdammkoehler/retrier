
module Scratch
  module Retrier
    def try attempts, options = {}
      success_blk = options[:success]
      error_blk = options[:error]
      waiter = options[:waiter]
      wait_time = options[:wait_time]
      wait_blk = options[:wait_blk]
      attempts.times do
        begin
          yield
          success_blk.call if success_blk
          break
        rescue Exception => e
          error_blk.call(e) if error_blk
          waiter.wait(wait_time) { wait_blk.call if wait_blk } if waiter
        end
      end
    end
  end
end
