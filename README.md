# retrier

A Retry block handler for easy retries in your code when things are janky

# How Do I Use it

You can create simple retry blocks like this;

```ruby
      maximum_attempts = 3
      wait_ms = 500  # 1/2 second
      interval = 2   # every other time
      try(maximum_attempts) {
        # something that might fail...
      }.error{ |e|
        # do this if we get an error/exception, even if we still have tries
      }.wait(wait_ms, interval) { 
        # run this block between attempts, only runs if we didn't succeed
        # wait_ms is the number of milliseconds to wait
        # interval is used to determine if we should run the block
        #   each time we wait is counted (@wait_count),
        #   if the number of waits mod the interval is zero
        #   the block is run, otherwise it is skipped.
        #   
        #   The default interval is 1 (run every time)
        #
        #   The wait_count is passed into the block with each execution
      }.success{
        # do this if we succeed, and only if we succeed
      }.go
```

> Note: Execution of the blocks does not start until you call `go`


# How do I build it

Pretty typical Ruby project

* pull the repo

* install Bundler

* run `bundle`

* run `rspec`

