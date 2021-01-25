
templated = require '../src'
{merge} = require 'mixme'

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

  describe 'proxy', ->
    
    it 'set then retrieve values', ->
      # Note we used to have a bug where getting an object will result to
      # undefined after it was set
      obj = templated {toto: {}}
      obj.a_string = 'a value'
      obj.an_object = {}
      obj.a_string.should.eql 'a value'
      obj.an_object.should.eql {}

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

  describe 'option partial', ->
  
    it 'root', ->
      context = templated
        key_1: 'value 1, {{key_3}}'
        key_2: 'value 2, {{key_3}}'
        key_3: 'value 3, {{key_4}}'
        key_4: 'value 4'
      , partial: key_1: true
      context.key_1.should.eql 'value 1, value 3, {{key_4}}'
      context.key_2.should.eql 'value 2, {{key_3}}'
            
    it 'child', ->
      context = templated
        parent:
          key_1: 'value 1, {{key_3}}'
          key_2: 'value 2, {{key_3}}'
        key_3: 'value 3, {{key_4}}'
        key_4: 'value 4'
      , partial: parent: key_1: true
      context.parent.key_1.should.eql 'value 1, value 3, {{key_4}}'
      context.parent.key_2.should.eql 'value 2, {{key_3}}'
            
    it 'cascade in child', ->
      context = templated
        parent:
          child: key_1: 'value 1, {{key_3}}'
          key_2: 'value 2, {{key_3}}'
        key_3: 'value 3, {{key_4}}'
        key_4: 'value 4'
      , partial: parent: child: true
      context.parent.child.key_1.should.eql 'value 1, value 3, {{key_4}}'
      context.parent.key_2.should.eql 'value 2, {{key_3}}'
            
    it 'with compile', ->
      context = templated
        parent: key_1: 'value 1, {{key_3}}'
        key_2: 'value 2, {{key_3}}'
        key_3: 'value 3, {{key_4}}'
        key_4: 'value 4'
      , compile: true, partial: parent: key_1: true
      context.parent.key_1.should.eql 'value 1, value 3, {{key_4}}'
      context.key_2.should.eql 'value 2, {{key_3}}'
      
