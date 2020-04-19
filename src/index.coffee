
handlebars = require 'handlebars'
{is_object_literal} = require 'mixme'

module.exports = (context, options = {}) ->
  # Default templated engine
  options.render ?= (source, proxy) ->
    template = handlebars.compile source
    template proxy, options.handlebars
  options.partial ?= undefined
  # Tracking graph traversal
  visits = []
  visiting = []
  # Work on properties
  _get = (keys) ->
    value = context
    for key, i in keys
      value = value[key]
    value
  _set = (keys, value) ->
    search = context
    for key, i in keys
      if i < keys.length - 1
      then search = search[key]
      else search[key] = value
  _render = (keys, value) ->
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
  # Clone the context by recursively converting it into proxies
  proxify = (obj, keys, partial) ->
    proxies = {}
    for key, value of obj
      continue unless is_object_literal value
      continue if partial? and not partial[key]
      proxies[key] = proxify value, [keys..., key], (
        if partial? and is_object_literal partial[key] then partial[key] else undefined
      )
    new Proxy obj,
      get: (target, key, receiver) ->
        return _get [keys..., key] if partial? and not partial[key]
        value = _get [keys..., key]
        if is_object_literal value
          proxies[key]
        else if typeof value is 'string'
          _render [keys..., key], value
        else
          value
  proxy = proxify context, [], options.partial
  # Trigger templating on every properties
  init = (search, keys, partial) ->
    for key, value of search
      continue if partial? and not partial[key]
      # String interpreted as a template
      if typeof value is 'string'
        _render [keys..., key], value
      else
        init search[key], [keys..., key], (
          if partial? and is_object_literal partial[key] then partial[key] else undefined
        )
  init context, [], options.partial if options.compile
  # Return the result
  proxy
