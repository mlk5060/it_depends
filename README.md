# It Depends!

What dependency injection framework should you use for Ruby? **It Depends!**

After spending a lot of my professional life with Spring Boot, I sorely missed [dependency
injection](https://en.wikipedia.org/wiki/Dependency_injection) when I moved to Ruby. Other 
offerings out there didn't come close to the SpringBoot experience, so I decided to roll 
my own :)

Dependency injection is great. It enables you to satisfy the D (hey now!) in 
[SOLID](https://en.wikipedia.org/wiki/Dependency_inversion_principle) so that you can decouple 
your code from hard-coded classes to make them more composable, and make testing much less 
specific to the web of objects you may have coupled yourself too! Its not just good for Java, 
its good for any object-orientated language. Try it and see!

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
### app/service/guitar/dimebag_darrell.rb

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
  module Bass
    class BootsyCollins
      
      def call
        puts 'WE WANT THE FUNK!'
      end

    end
  end
end

### app/service/band/default.rb

# depend_on_me(id: 'greatest_band_ever', type: 'awesome_band_service')
module Service
  module Band
    class Default
    
      def initialize(sandblasted_skin_service, the_one_and_only, every_funkin_service)
        @guitarist = sandblasted_skin_service
        @singer = the_one_and_only
        @bassists = every_funkin_service
      end

      def shred!
        @guitarist.call # 'GETCHA PULL!'
      end

      def wail!
        @singer.call # 'I AM THE ONE AND ONLY!'
      end

      def slap!
        @bassists.each(:call) # 'FUNKY D!'
                              # 'WE WANT THE FUNK!'
      end

    end
  end
end
```

I mean, how awesome would this band be? Any way, what's happening here? To declare that
a class is a dependency, or requires other dependencies, we need to mark it.
That's what the `# depends_on_me` magic comment is all about! More about it below:

- The `id` parameter in the magic comment is intended to act as a unique identifier for 
your dependency. If you specify two classes with the same `id` value, you're gonna have 
a bad time.

- The `type` parameter in the magic comment is intended to allow you to group dependencies 
together. This unlocks the power of *polymorphism*; use it wisely! There's no
uniqueness validation for a `type` value, you can specify duplicates all over the place,
but with great power comes great responsibility. More on that in a moment...

- Note that the `id` and `type` values do not relate to a file's location or the namespace
defined in the file itself. This is intentional and prevents hard-coded dependencies; thank 
me later when you get to refactoring ;)

How do you specify that your dependency has dependencies? Glad you asked:

- If you want to declare a dependency using a `type` value, just specify the `type` value as
an `initialize` parameter. This is like using an interface for an `@Autowired` constructor in
Spring Boot. The concept is demonstrated by the `sandblasted_skin_service` parameter for 
`Service::Band::Default.initialize()` above. Remember when I said "More on that in a moment..."
above? Well, if **It Depends!** finds more than one dependency with that `type` value when it
tries to resolve your `initialize` parameter, you're gonna have a bad time.

- If you want to declare a specific dependency (this is akin to hard-coding another class, but
I know you won't abuse it...) you can use an `id` value. To do so, pre-pend the `id`
value of the intended dependency with `the_` and use the resulting value as an `initialize` 
parameter. This is demonstrated by `the_one_and_only` parameter for 
`Service::Band::Default.initialize()` above.

- If you want the **POWAH** of polymorphism, you can get all dependencies tagged with a particular 
`type` value! This was one of the coolest features I found in Spring Boot, but its not immediately
obvious that its available. So, I'm giving you the goods explicitly here! To do this, in *It Depends!*,
pre-prend the intended `type` value with `every_` and use the resulting value as an `initialize` 
parameter. This is demonstrated by the `every_funkin_service` parameter for 
`Service::Band::Default.initialize()` above. BOOM, HEADSHOT!

### Important Notes

- **It Depends!** doesn't like dependency cycles. If it finds one, you're gonna have a bad time.
- **It Depends!** uses [Zeitwerk](https://github.com/fxn/zeitwerk) as a code loader, so make sure
you have a file structure that matches your namespace declarations. Shame on you if you don't already!
- **It Depends!** looks recursively through the directory you specify to `ItDepends.setup`
for classes to work with so.
- **It Depends!** will try to resolve **all** of your `initialize` parameters as dependencies. So,
if you have an `initialize` parameter that isn't a dependency, move it to another class, 
*s'il vous plais*!

### How do I actually use this library then?

So far, I've used **It Depends!** in Rack applications so, in your `config.ru` invoke 
`ItDepends.setup(path_to_your_app_directory)` at the appropriate time. This will return
a hash of all the classes with their namespace as a key, and the actual object as a value,
should you need it.

**Note:** `path_to_your_app_directory` should be a string that defines the absolute path 
to your application directory where dependencies need to be resolved. Directories in this 
path need to be separated using Linux path separators, i.e. `/`, and there should be no 
trailing path separators!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mlk5060/it_depends.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
