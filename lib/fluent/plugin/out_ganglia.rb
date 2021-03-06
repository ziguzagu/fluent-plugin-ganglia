class Fluent::GangliaOutput < Fluent::Output
  Fluent::Plugin.register_output('ganglia', self)

  HOSTNAME = Socket.gethostname
  HOSTADDR = IPSocket.getaddress(HOSTNAME)

  ## Define 'log' method to support log method for v0.10.42 or earlier
  unless method_defined?(:log)
    define_method("log") { $log }
  end

  def initialize
    super
    require "gmetric"
    require "socket"
  end

  config_param :port,             :integer, :default => 8649
  config_param :host,             :string,  :default => '127.0.0.1'
  config_param :name_keys,        :string,  :default => nil
  config_param :name_key_pattern, :string,  :default => nil
  config_param :add_key_prefix,   :string,  :default => nil
  config_param :value_type,       :string,  :default => 'uint32'
  config_param :units,            :string,  :default => ''
  config_param :group,            :string,  :default => ''
  config_param :title,            :string,  :default => ''
  config_param :tmax,             :integer, :default => 60
  config_param :dmax,             :integer, :default => 0
  config_param :slope,            :string,  :default => 'both'
  config_param :spoof,            :string,  :default => nil
  config_param :bind_hostname,    :bool,    :default => false

  def configure(conf)
    super

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
      log.debug("ganglia: #{name}: #{value}, ts: #{time}")
      gmetric = Ganglia::GMetric.pack(
        :name     => name,
        :value    => value.to_s,
        :type     => @value_type,
        :units    => @units,
        :tmax     => @tmax,
        :dmax     => @dmax,
        :title    => @title,
        :group    => @group,
        :slope    => @slope,
        :spoof    => @spoof ? 1 : 0,
        :hostname => @spoof ? @spoof : HOSTNAME,
      )
      conn = UDPSocket.new
      conn.bind(HOSTADDR, 0) if @bind_hostname
      conn.send gmetric[0], 0, @host, @port
      conn.send gmetric[1], 0, @host, @port
      conn.close
      status = true
    rescue IOError, EOFError, SystemCallError
      log.warn "Ganglia::GMetric.send raises exception: #{$!.class}, '#{$!.message}'"
    end
    unless status
      log.warn "failed to send to ganglia: #{@host}:#{@port}, '#{name}': #{value}"
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
