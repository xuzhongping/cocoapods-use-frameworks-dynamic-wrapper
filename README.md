# cocoapods-use-frameworks-dynamic-wrapper

The CocoaPods plugin can automatically fix static framework transitive dependencies problems.

## Installation

    $ gem install cocoapods-use-frameworks-dynamic-wrapper

## Usage

```ruby
plugin 'cocoapods-use-frameworks-dynamic-wrapper'

target :ExampleTarget do
  use_frameworks! :dynamic_wrapper => true

  pod 'SomePod'
end
```

