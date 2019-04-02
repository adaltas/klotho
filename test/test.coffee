
templated = require '../src'

describe 'test', ->
  
  describe 'initialize', ->

    it 'parent level', ->
      templated
        key_inject: 'value inject'
        key_assert: '{{key_inject}}'
      .key_assert.should.eql 'value inject'

    it 'child level', ->
      templated
        key_inject: 'value inject'
        parent: key_assert: '{{key_inject}}'
      .parent.key_assert.should.eql 'value inject'

  describe 'inject', ->

    it 'parent level', ->
      templated
        key_1: 'value 1'
        key_assert: '{{key_1}}, {{key_2}}'
        key_2: 'value 2'
      .key_assert.should.eql 'value 1, value 2'

    it 'child level', ->
      templated
        parent_1: key_1: 'value 1'
        key_assert: '{{parent_1.key_1}}, {{parent_2.key_2}}'
        parent_2: key_2: 'value 2'
      .key_assert.should.eql 'value 1, value 2'
    
    it 'idirect references', ->
      templated
        key_assert: '{{level_parent_1.level_key_1}}'
        level_parent_1: level_key_1: 'value 1, {{level_parent_2.level_key_2}}'
        level_parent_2: level_key_2: 'value 2'
        parent_2: key_2: 'value 2'
      .key_assert.should.eql 'value 1, value 2'
  
  describe 'conflict', ->
    
    it 'direct circular references', ->
      ( ->
        templated
          key_1: '{{key_2}}'
          key_2: '{{key_1}}'
        .key_assert.should.eql 'value 1, value 2'
      ).should.throw 'Circular Reference: graph is ["key_1"] -> ["key_2"] -> ["key_1"]'
        
    it 'indirect circular references', ->
      ( ->
        templated
          key_1: '{{key_2}}'
          key_pivot: '{{key_1}}'
          key_2: '{{key_pivot}}'
        .key_assert.should.eql 'value 1, value 2'
      ).should.throw 'Circular Reference: graph is ["key_1"] -> ["key_2"] -> ["key_pivot"] -> ["key_1"]'
      
