
templated = require '../src'

describe 'api.conflict', ->
  
  it 'direct circular references', ->
    ( ->
      templated
        key_1: '{{key_2}}'
        key_2: '{{key_1}}'
      .key_1
    ).should.throw 'Circular Reference: graph is ["key_1"] -> ["key_2"] -> ["key_1"]'
      
  it 'indirect circular references', ->
    ( ->
      templated
        key_1: '{{key_2}}'
        key_pivot: '{{key_1}}'
        key_2: '{{key_pivot}}'
      .key_1
    ).should.throw 'Circular Reference: graph is ["key_1"] -> ["key_2"] -> ["key_pivot"] -> ["key_1"]'
