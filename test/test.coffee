
templated = require '../src'
{merge} = require 'mixme'

describe 'templated', ->
  
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
        
    it 'access twice the same key', ->
      # Note, fix a bug where the rendering only occured the first time
      res = templated
        keys:
          key_inject: 'value inject'
          key_assert: '{{keys.key_inject}}'
      res.keys.key_assert.should.eql 'value inject'
      res.keys.key_assert.should.eql 'value inject'

    it 'value of various types', ->
      res = templated
        templates:
          a_boolean_true: '{{values.a_boolean_true}}'
          a_boolean_false: '{{values.a_boolean_false}}'
          a_number: '{{values.a_number}}'
          a_null: '{{values.a_null}}'
          an_object: '{{{values.an_object}}}'
          a_string: '{{values.a_string}}'
          an_undefined: '{{values.an_undefined}}'
        values:
          a_boolean_true: true
          a_boolean_false: false
          a_number: 3.14
          a_null: null
          an_object: {a: 'b', toString: -> JSON.stringify @}
          a_string: 'a string'
          an_undefined: undefined
      , compile: true
      .templates.should.eql
        a_string: 'a string'
        a_boolean_true: 'true'
        a_boolean_false: 'false'
        a_number: '3.14'
        a_null: ''
        an_object: '{"a":"b"}'
        an_undefined: ''

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
    
    it 'indirect references', ->
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
