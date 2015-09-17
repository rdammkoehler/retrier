module Scratch
  module Retrier

    class RetryBuilder

      def initialize attempts, block_proc
        @attempts = attempts
        @block_proc = block_proc
        @wait_count = 0
      end

      def success &success_blk
        @success_blk = success_blk
        return self
      end

      def error &error_blk
        @error_blk = error_blk
        return self
      end

      def wait milliseconds, interval = 1, &wait_blk
        @wait_milliseconds = milliseconds
        @wait_interval = interval
        @wait_blk = wait_blk
        return self
      end

      def go
        @attempts.times do
          begin
            @block_proc.call
            @success_blk.call if @success_blk
            break
          rescue Exception => e
            @error_blk.call(e) if @error_blk
            if @wait_blk
              decimal_seconds = @wait_milliseconds / 1000.0
              sleep decimal_seconds
              @wait_count += 1
              if @wait_count % @wait_interval == 0
                @wait_blk.call @wait_count 
              end
            end
          end
        end
      end

    end

    def try attempts, &block
      RetryBuilder.new attempts, block
    end

  end
end
