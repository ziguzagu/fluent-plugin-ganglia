# fluent-plugin-ganglia

Plugin to output values to Ganglia.

## Usage

### gmond is configured with multicast

When gmond is configured with multicast and bind_hostname as below:

```
udp_send_channel {
    mcast_join    = 239.2.11.71
    bind_hostname = yes
    port          = 8640
    ...
}
```

You should specify mcast_join ip address to `host` and set `bind_hostname` true:

```
<match metrics>
  type          ganglia
  host          239.2.11.71
  port          8649
  group         metric_group
  name_keys     metrics.field1,metrics.field2
  bind_hostname true
</match>
```

### gmond is configured with unicast

When gmond is configured with unicast, you should specify `host` and `port` with same value of gmond.conf:

```
<match metrics>
  type              ganglia
  host              192.0.2.100
  port              8649
  group             metric_group
  name_key_pattern  ^field
</match>
```

## Configuration

* type
  * required "ganglia"
* name_keys or name_key_pattern
  * required
  * specify key name by `name_keys` or regexp pattern of keys by `name_key_pattern`
* add_key_prefix
  * string to add key prefix
* host
  * host to send metric (default=127.0.0.1)
* post
  * port of host to send metric (default=8649)
* value_type
  * type of value
  * same as gmetric --type
* units
  * unit of value
  * same as gemtric --units
* group
  * metric group
  * same as gemtric --group
* title
  * metric title
  * same as gemtric --title
* tmax
  * maximum time in seconds between gmetric calls. (default=60)
  * same as gemtric --tmax
* dmax
  * lifetime in seconds of this metric. (default=0)
  * same as gemtric --dmax
* slope
  * Either zero|positive|negative|both. (default=both)
  * same as gemtric --slope
* spoof
  * IP address and name of host/device we are spoofing. (default=nil)
  * same as gmetric --spooof
* bind_hostname
  * whether upd_send_channel.bind_hostname is yes(true) or no(fale). (default=false)

## License

Apache License, Version 2.0

## Copyright

Copyright (c) 2013 Hiroshi Sakai
