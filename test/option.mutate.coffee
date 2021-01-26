
templated = require '../src'

describe 'option.mutate', ->
  
  it 'does not mutate by default', ->
    source =
      keys:
        key_inject: 'value inject'
        key_assert: '{{keys.key_inject}}'
    templated source, mutate: false
    source.keys.key_assert.should.eql '{{keys.key_inject}}'
      
  it 'work on the input reference', ->
    source =
      keys:
        key_inject: 'value inject'
        key_assert: '{{keys.key_inject}}'
    templated source, mutate: true
    source.keys.should.eql
      key_inject: 'value inject'
      key_assert: '{{keys.key_inject}}'
    source.keys.key_assert.should.eql 'value inject'
      
  it 'access twice the same key', ->
    # Note, fix a bug where the rendering only occured the first time
    source =
      keys:
        key_inject: 'value inject'
        key_assert: '{{keys.key_inject}}'
    templated source, mutate: true
    source.keys.key_assert.should.eql 'value inject'
    source.keys.key_assert.should.eql 'value inject'
      
  it 'with partial', ->
    source =
      keys:
        key_inject: 'value inject'
        key_1: '{{keys.key_inject}}'
        key_2: '{{keys.key_inject}}'
    templated source,
      mutate: true
      partial: keys:
        key_1: true
        key_2: false
    source.keys.should.eql
      key_inject: 'value inject'
      key_1: '{{keys.key_inject}}'
      key_2: '{{keys.key_inject}}'
    source.keys.key_1.should.eql 'value inject'
    source.keys.key_2.should.eql '{{keys.key_inject}}'
  
  describe 'get undefined', ->
    
    it 'on object', ->
      source =
        keys:
          key_inject: 'value inject'
          key_assert: '{{keys.key_inject}}'
      templated source, mutate: true
      should(source.keys.key_undefined).be.exactly undefined
    
    it 'on array', ->
      source =
        keys: [
          'value inject'
          '{{keys.key_inject}}'
        ]
      templated source, mutate: true, array: true
      should(source.keys[2]).be.exactly undefined
