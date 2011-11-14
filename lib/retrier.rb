
module Scratch
  class Retrier
    def try attempts, on_success = nil, on_error = nil, waiter = nil, wait_time = 0, wait_blk = proc {}
      puts "sup"
      [0..attempts].each do |try|
        puts "try: #{try}"
        begin
          puts "pre-yield"
          yield
          puts "post-yield\npre-success"
          on_success.call if ! on_success.nil?
          puts "post-success"
        rescue Exception => e
          puts "#{e}\n\n#{e.backtrace.join("\n")}"
          puts "pre-error"
          on_error.class if ! on_error.nil?
          puts "post_error"
          puts "pre-wait"
          waiter.wait(wait_time) { wait_blk } if ! waiter.nil?
          puts "post-wait"
        end
      end
    end
  end
end
