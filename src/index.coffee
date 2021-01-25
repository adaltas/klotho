
handlebars = require 'handlebars'
{is_object_literal} = require 'mixme'

module.exports = (context, options = {}) ->
  # Default templated engine
  options.render ?= (source, proxy) ->
    template = handlebars.compile source
    template proxy, options.handlebars
  options.partial ?= undefined
  # options.array ?= false
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
  # Render a template, the resulting `value` is placed in `keys`
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
  proxify = (source, keys, partial) ->
    proxies
    if (Array.isArray(source) and options.array) or is_object_literal source
      # We can both store properties and indexes
      # This is the same as `proxies = []`
      proxies = {}
      # Note, we can both traverse object and array
      # this is the same as `for value, index in array`
      for key, value of source
        continue if partial? and not partial[key]
        if Array.isArray(value) and options.array
          proxies[key] = proxify value, [keys..., key], (
            if partial? and is_object_literal(partial[key]) then partial[key] else undefined
          )
        else if is_object_literal value
          proxies[key] = proxify value, [keys..., key], (
            if partial? and is_object_literal(partial[key]) then partial[key] else undefined
          )
    else
      throw Error 'Unsupported'
    new Proxy source,
      get: (target, key) ->
        # Retrieve the value from context
        value = _get [keys..., key]
        # Return value without rendering if key is filtered by partial
        return value if partial? and not partial[key]
        if Array.isArray(value) and options.array
          proxies[key]
        else if is_object_literal value
          proxies[key]
        else if typeof value is 'string'
          _render [keys..., key], value
        else
          value
      # Returned object if modified after being proxyfied
      set: (target, key, value) ->
        proxies[key] = value
        target[key] = value
  proxy = proxify context, [], options.partial
  # Trigger templating on every properties
  init = (search, keys, partial) ->
    for key, value of search
      continue if partial? and not partial[key]
      # String interpreted as a template
      if typeof value is 'string'
        _render [keys..., key], value
      else
        # Note, array goes here as well and call `init` with the full array
        # init then loop through the array with `for` resulting
        # in the key as the index converted to a string
        init search[key], [keys..., key], (
          if partial? and is_object_literal partial[key] then partial[key] else undefined
        )
  init context, [], options.partial if options.compile
  # Return the result
  proxy
