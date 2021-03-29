
templated = require '../src'

describe 'option.mutate', ->
  
  it 'does not mutate by default', ->
    source =
      keys:
        key_inject: 'value inject'
        key_assert: '{{keys.key_inject}}'
    templated source, mutate: false
    source.keys.key_assert.should.eql '{{keys.key_inject}}'
  
  it 'on 1st mutated level', ->
    source =
      keys:
        key_inject: 'value inject'
        key_assert: '{{keys.key_inject}}'
    templated source, mutate: true
    source.keys.should.eql
      key_inject: 'value inject'
      key_assert: '{{keys.key_inject}}'
    source.keys.key_assert.should.eql 'value inject'
  
  it 'on 2nd mutated level', ->
    source =
      root:
        keys:
          key_inject: 'value inject'
          key_assert: '{{root.keys.key_inject}}'
    templated source, mutate: true
    source.root.keys.should.eql
      key_inject: 'value inject'
      key_assert: '{{root.keys.key_inject}}'
    source.root.keys.key_assert.should.eql 'value inject'
      
  it 'access twice the same key', ->
    # Note, fix a bug where the rendering only occured the first time
    source =
      keys:
        key_inject: 'value inject'
        key_assert: '{{keys.key_inject}}'
    templated source, mutate: true
    source.keys.key_assert.should.eql 'value inject'
    source.keys.key_assert.should.eql 'value inject'

  describe 'with `partial` option', ->
        
    it 'at root level', ->
      source =
        key_inject: child: 'value inject'
        key_1: child: '{{key_inject.child}}'
        key_2: child: '{{key_inject.child}}'
      res = templated source,
        mutate: true
        partial:
          key_1: true
          key_2: false
      source.key_1.child.should.eql 'value inject'
      source.key_2.child.should.eql '{{key_inject.child}}'
      
    it 'in children of root level', ->
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
  
  describe 'get', ->

    it 'undefined on array', ->
      source =
        root:
          keys: [
            'value inject'
            'got {{root.keys.[0]}}'
          ]
      templated source, mutate: true, array: true
      source.root.keys[0].should.eql 'value inject'
      source.root.keys[1].should.eql 'got value inject'
    
    it 'undefined on object', ->
      source =
        keys:
          key_inject: 'value inject'
          key_assert: '{{keys.key_inject}}'
      templated source, mutate: true
      should(source.keys.key_undefined).be.exactly undefined
    
    it 'undefined on array', ->
      source =
        keys: [
          'value inject'
          '{{keys.key_inject}}'
        ]
      templated source, mutate: true, array: true
      should(source.keys[2]).be.exactly undefined
