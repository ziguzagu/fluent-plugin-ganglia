class Fluent::GangliaOutput < Fluent::Output
  Fluent::Plugin.register_output('ganglia', self)

  def initialize
    super
    require "eventmachine" ## XXX: for fix error in gmetric
    require "gmetric"
  end

  config_param :host, :string, :default => '127.0.0.1'
  config_param :port, :integer
  config_param :name_keys, :string, :default => nil
  config_param :name_key_pattern, :string, :default => nil
  config_param :add_key_prefix, :string, :default => nil
  config_param :value_type, :string,  :default => 'uint32'
  config_param :units, :string, :default => ''
  config_param :group, :string, :default => ''
  config_param :title, :string, :default => ''
  config_param :tmax, :integer, :default => 60
  config_param :dmax, :integer, :default => 0
  config_param :spoof, :string, :default => ''

  def configure(conf)
    super

    if @port.nil?
      raise Fluent::ConfigError, "missing port"
    end

    if @name_keys.nil? and @name_key_pattern.nil?
      raise Fluent::ConfigError, "missing both of name_keys and name_key_pattern"
    end
    if not @name_keys.nil? and not @name_key_pattern.nil?
      raise Fluent::ConfigError, "cannot specify both of name_keys and name_key_pattern"
    end
    if @name_keys
      @name_keys = @name_keys.split(/ *, */)
    end
    if @name_key_pattern
      @name_key_pattern = Regexp.new(@name_key_pattern)
    end
  end

  def start
    super
  end

  def shutdown
    super
  end

  def send(tag, name, value, time)
    if @add_key_prefix
      name = "#{@add_key_prefix} #{name}"
    end
    begin
      $log.debug("ganglia: #{name}: #{value}, ts: #{time}")
      Ganglia::GMetric.send(@host, @port, {
        :name  => name,
        :units => @units,
        :type  => @value_type,
        :value => value.to_s,
        :tmax  => @tmax,
        :dmax  => @dmax,
        :title => @title,
        :group => @group,
        :spoof => @spoof ? 1 : 0,
        :hostname => @spoof,
      })
      status = true
    rescue IOError, EOFError, SystemCallError
      $log.warn "Ganglia::GMetric.send raises exception: #{$!.class}, '#{$!.message}'"
    end
    unless status
      $log.warn "failed to send to ganglia via gmond: #{@host}:#{@port}, '#{name}': #{value}"
    end
  end

  def emit(tag, es, chain)
    if @name_keys
      es.each {|time,record|
        @name_keys.each {|name|
          if record[name]
            send(tag, name, record[name], time)
          end
        }
      }
    else # for name_key_pattern
      es.each {|time,record|
        record.keys.each {|key|
          if @name_key_pattern.match(key) and record[key]
            send(tag, key, record[key], time)
          end
        }
      }
    end
    chain.next
  end
end
