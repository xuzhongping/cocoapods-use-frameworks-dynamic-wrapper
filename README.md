# cocoapods-use-frameworks-dynamic-wrapper

A description of cocoapods-use-frameworks-dynamic-wrapper.

## Installation

    $ gem install cocoapods-use-frameworks-dynamic-wrapper

## Usage

```ruby
plugin 'cocoapods-use-frameworks-dynamic-wrapper'

target :ExampleTarget do
  use_frameworks! :dynamic-wrapper => true

  pod 'SomePod'
end
```

