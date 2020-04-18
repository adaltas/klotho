
handlebars = require 'handlebars'
{is_object_literal} = require 'mixme'

module.exports = (context, options = {}) ->
  # Default templated engine
  options.render ?= (source, proxy) ->
    template = handlebars.compile source
    template proxy, options.handlebars
  # Tracking graph traversal
  visits = []
  visiting = []
  # Work on properties
  _get = (keys) ->
    value = context
    for key, i in keys
      value = value[key]
    return null if is_object_literal value
    return value unless typeof value is 'string'
    keys_as_string = JSON.stringify(keys)
    # Update context with new value if not already visited
    unless keys_as_string in visits
      if keys_as_string in visiting
        throw Error "Circular Reference: graph is #{[visiting..., [visiting[0]]].join ' -> '}"
      visiting.push keys_as_string
      value = options.render value, proxy
      visiting.pop()
      _set keys, value
      visits.push keys_as_string
    value
  _set = (keys, value) ->
    search = context
    for key, i in keys
      if i < keys.length - 1
      then search = search[key]
      else search[key] = value
  # Clone the context by recursively converting it into proxies
  proxify = (obj, keys) ->
    proxies = []
    for k, v of obj
      continue unless is_object_literal v
      proxies[k] = proxify v, [keys..., k]
    new Proxy obj,
      get: (target, name, receiver) ->
        value = _get [keys..., name]
        if value?
        then value
        else proxies[name]
  proxy = proxify context, []
  # Trigger templating on every properties
  init = (search, keys) ->
    for key, value of search
      # Value is a string, thus a template
      if typeof value is 'string'
        _get [keys..., key]
      else
        init search[key], [keys..., key]
  init context, []
  # Return the result
  context
