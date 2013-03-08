class Fluent::GangliaTestInput < Fluent::Input
  Fluent::Plugin.register_input('ganglia_test', self)
  config_param :port
  config_param :host
  config_param :name_keys
  config_param :name_key_pattern
  config_param :add_key_prefix
  config_param :value_type
  config_param :units
  config_param :group
  config_param :title
  config_param :tmax
  config_param :dmax
  config_param :slope
  config_param :spoof
  config_param :bind_hostname
end

class Fluent::GangliaTestOutput < Fluent::Output
  Fluent::Plugin.register_output('ganglia_test', self)
  config_param :port
  config_param :host
  config_param :name_keys
  config_param :name_key_pattern
  config_param :add_key_prefix
  config_param :value_type
  config_param :units
  config_param :group
  config_param :title
  config_param :tmax
  config_param :dmax
  config_param :slope
  config_param :spoof
  config_param :bind_hostname
end
