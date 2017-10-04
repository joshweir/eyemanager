# Eyemanager

Ruby wrapper for the [Eye process monitoring tool command line interface](https://github.com/kostya/eye#commands).

## Installation

Firstly install sigar: 

    $ gem install sigar -- --with-cppflags="-fgnu89-inline"

Then,
Add this line to your application's Gemfile:

```ruby
gem 'eyemanager'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sigar -- --with-cppflags="-fgnu89-inline"
    $ gem install eyemanager

## Usage

### Start

This: 

```ruby
EyeManager.start config: 'eye.test.rb', application: 'test'
```

is equivelant to: 

```bash
eye load eye.test.rb
eye start test
```

### Stop

This: 

```ruby
EyeManager.stop application: 'test', process: 'sample'
EyeManager.stop application: 'test2', group: 'samples', process: 'sample'  
```

is equivelant to: 

```bash
eye stop test:sample
eye stop test:samples:sample
```

### Status

This: 

```ruby
EyeManager.status application: 'test', process: 'sample'
```

will retrieve the state of the `test` application's `sample` process.

If your process is within a `group` block, ensure to include the `group`:

```ruby
EyeManager.stop application: 'test2', group: 'samples', process: 'sample'
```

### List Eye Apps

List the applications being monitored by Eye:

```ruby
EyeManager.list_apps
# -> ['app1', 'app2']
```

uses:

```bash
eye i -j
```

to extract the `applications` being currently monitored.

### Destroy

Stop Eye processes and quit Eye:

```ruby
EyeManager.destroy
```

equivelant to:

```bash
eye q -s
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshweir/eyemanager.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

