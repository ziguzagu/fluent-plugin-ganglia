require 'helper'

class GangliaOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    port           8649
    add_key_prefix test
    name_keys      foo, bar, baz
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::GangliaOutput, tag).configure(conf)
  end

  def test_write
#    d = create_driver
#    d.emit({"foo" => "test value of foo"})
#    d.emit({"bar" => "test value of bar"})
#    d.emit({"baz" => rand * 10 }) 
  end
end
