# It Depends!

What dependency injection framework should you use for Ruby? **It Depends!**

After spending a lot of my professional life with Spring Boot, I sorely missed dependency
injection when I moved to Ruby. Other offerings out there didn't come close to the Spring
Boot experience, so I decided to recreate it :)

Dependency injection is great: you can decouple yourself from hard-coded classes to make 
your classes more composable, and make testing much less specific to the web of objects
you may have coupled yourself too! Its not just good for Java, its good for any 
object-orientated language. Try it and see!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'it_depends'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install it_depends

## Usage

You need some magic, i.e. a magic comment on the first line of any `.rb` file, and some nifty
`initialize` method parameter names. Here's an example of a web of classes that should be loaded up 
with some dependencies expressed. It will illustrate the main concepts of **It Depends!**

Please note that 3 hashes `###` indicate the start of a new `.rb` file :)

```ruby
### app/service/guitar/default.rb

# depend_on_me(id: 'dimebag', type: 'sandblasted_skin_service')
module Service
  module Guitar
    class DimebagDarrell
      
      def call
        puts 'GETCHA PULL!'
      end

    end
  end
end

### app/service/singer/chesney_hawkes.rb

# depend_on_me(id: 'one_and_only', type: 'cant_take_that_away_from_me_service')
module Service
  module Singer
    class ChesneyHawkes
      
      def call
        puts 'I AM THE ONE AND ONLY!'
      end

    end
  end
end

### app/service/bass/victor_wooten.rb

# depend_on_me(id: 'victor_mfkn_wooten', type: 'funkin_service')

module Service
  module Bass
    class VictorWooten
      
      def call
        puts 'FUNKY D!'
      end

    end
  end
end

### app/service/bass/bootsy_collins.rb

# depend_on_me(id: 'boots', type: 'funkin_service')

module Service
  module Funkin
    class BootsyCollins
      
      def call
        puts 'WE WANT THE FUNK!'
      end

    end
  end
end

### app/service/band/the_greatest_ever.rb

# depend_on_me(id: '', type: 'awesome_service')

module Service
  module Band
    class Default
    
      def initialize(sandblasted_skin_service, the_one_and_only, every_funkin_service)
        @guitarist = sandblasted_skin_service
        @singer = the_one_and_only
        @bassists = every_funkin_service
      end

    def shred!
      puts @guitarist.call # 'GETCHA PULL!'
    end

    def wail!
      puts @singer.call # 'I AM THE ONE AND ONLY!'
    end

    def slap!
      puts @bassists.map { | bassist | bassist.call } # ['FUNKY D!', 'WE WANT THE FUNK!']
    end
  end
end
```

I mean, how awesome would this band be? Any way, what's happening here? Well, to say that
a class can be used as a dependency, or requires dependency injection, we need to mark it.
That's what the `# depends_on_me` magic comment is all about! More about it below:

- The `id:` parameter in the magic comment is intended to act as a unique identifier for 
your class when the dependency tree is being calculated. If you specify two classes with 
the same `id:` value, you're gonna have a bad time.

- The `type:` parameter in the magic comment is intended to allow you to group related 
classes together. This unlocks the power of *polymorphism*; use it wisely! There's no
uniqueness validation for a `type:` value, you can specify duplicates all over the place,
but with great power comes great responsibility. More on that in a moment...

- Note that the `id:` and `type:` values do not relate to the file's location or classes' 
namespace. This is intentional; thank me later ;)

How do you specify dependencies? Glad you asked:

- If you want to pull in a dependency using a `type` value, just specify the `type` value as
an `initialize` parameter for the class that requires a class with this `type` as a dependency. 
This is demonstrated by the `sandblasted_skin_service` parameter for 
`Service::Band::Default.initialize()` above. Note that, if **It Depends!** finds more than one 
dependency with that `type` value, you're gonna have a bad time.

- If you want to pull in a dependency using an `id` value, pre-pend the intended classes' `id`
value with `the_` and use the resulting value as an `initialize` parameter for the class that 
requires that class as a dependency. This is demonstrated by the `the_one_and_only` parameter
for `Service::Band::Default.initialize()` above.

- If you can't make your mind up and you want all classes tagged with a particular `type` value,
pre-prend the intended `type` value with `every_` and use the resulting value as an `initialize` 
parameter for the class that requires that class as a dependency. This is demonstrated by the 
`the_every_funkin_service` parameter for `Service::Band::Default.initialize()` above. HELLO, 
POLYMORPHISM!

### Important Notes

- **It Depends!** doesn't like dependency cycles. If it finds one, you're gonna have a bad time.
- **It Depends!** uses [Zeitwerk|https://github.com/fxn/zeitwerk] as a code loader, so make sure
you have a file structure that matches your namespace declarations. Shame on you if you don't already!
- **It Depends!** looks recursively through an `app` directory at the top-level of your project 
for classes to work with so, you know, move your required files into that directory (or create it, if
you don't have it already).  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mlk5060/it_depends.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
