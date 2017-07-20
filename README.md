# retrier

A Retry block handler for easy retries in your code when things are janky

# How Do I Use it

You can create simple retry blocks like this;

```ruby
      maximum_attempts = 3
      try(maximum_attempts) {
        # something that might fail...
      }.error{ |e|
        # do this if we get an error/exception, even if we still have tries
      }.success{
        # do this if we succeed, and only if we succeed
      }.go
```

# How do I build it

Pretty typical Ruby project

* pull the repo

* install Bundler

* run `bundle`

* run `rspec`

