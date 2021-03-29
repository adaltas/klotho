
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
  visiting = []
  # Work on properties
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
    if keys_as_string in visiting
      throw Error "Circular Reference: graph is #{[visiting..., [visiting[0]]].join ' -> '}"
    visiting.push keys_as_string
    value = options.render value, proxy
    visiting.pop()
    _set keys, value
    value
  # Clone the context by recursively converting it into proxies
  proxify = (source, keys, partial) ->
    new Proxy source,
      get: (target, key) ->
        # Retrieve the value from context
        value = target[key]
        # Return value without rendering if key is filtered by partial
        return value if partial? and not partial[key]
        if (options.array and Array.isArray(value)) or is_object_literal(value)
          proxify value, [keys..., key], (
            if partial? and is_object_literal(partial[key]) then partial[key] else undefined
          )
        else if typeof value is 'string'
          _render [keys..., key], value
        else
          value
      # Returned object if modified after being proxyfied
      set: (target, key, value) ->
        target[key] = value
        true
  if options.mutate
    for key, value of context
      continue if options.partial? and not options.partial[key]
      if (options.array and Array.isArray(value)) or is_object_literal(value)
        partial = options.partial
        partial = if partial? and is_object_literal(partial[key]) then partial[key] else undefined
        context[key] = proxify value, [key], partial
      # else
      #   context[key] = value
    proxy = context
  else
    proxy = proxify context, [], options.partial
  # Trigger templating on every properties
  compile = (search, keys, partial) ->
    for key, value of search
      continue if partial? and not partial[key]
      # String interpreted as a template
      if typeof value is 'string'
        _render [keys..., key], value
      else if (options.array and Array.isArray(value)) or is_object_literal value
        # Note, array goes here as well and call `compile` with the full array
        # compile then loop through the array with `for` resulting
        # in the key as the index converted to a string
        childPartial = if partial? and is_object_literal(partial[key]) then partial[key] else undefined
        compile search[key], [keys..., key], childPartial
  if options.compile
    compile context, [], options.partial
    return context
  # Return the result
  proxy
