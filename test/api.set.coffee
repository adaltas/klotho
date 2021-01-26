
templated = require '../src'
{merge} = require 'mixme'

describe 'api.set', ->
  
  it 'set then retrieve values on root', ->
    # Note we used to have a bug where getting an object will result to
    # undefined after it was set
    obj = templated key: {}
    obj.a_null = null
    should(obj.a_null).be.exactly(null)
    obj.an_undefined = undefined
    should(obj.an_undefined).be.exactly(undefined)
    obj.a_string = 'a value'
    obj.a_string.should.eql 'a value'
    obj.a_number = .5
    obj.a_number.should.eql .5
    obj.a_boolean_true = false
    obj.a_boolean_true.should.eql false
    obj.a_boolean_false = false
    obj.a_boolean_false.should.eql false
    obj.an_object = {}
    obj.an_object.should.eql {}
    obj.an_array = ['value']
    obj.an_array.should.eql ['value']
      
  it 'set then retrieve values on child', ->
    # Note we used to have a bug where getting an object will result to
    # undefined after it was set
    obj = templated key: {}
    obj.key.a_null = null
    should(obj.key.a_null).be.exactly(null)
    obj.key.an_undefined = undefined
    should(obj.key.an_undefined).be.exactly(undefined)
    obj.key.a_string = 'a value'
    obj.key.a_string.should.eql 'a value'
    obj.key.a_number = .5
    obj.key.a_number.should.eql .5
    obj.key.a_boolean_true = false
    obj.key.a_boolean_true.should.eql false
    obj.key.a_boolean_false = false
    obj.key.a_boolean_false.should.eql false
    obj.key.an_object = {}
    obj.key.an_object.should.eql {}
    obj.key.an_array = ['value']
    obj.key.an_array.should.eql ['value']
      
  it 'set templates', ->
    # Note we used to have a bug where getting an object will result to
    # undefined after it was set
    obj = templated
      key_inject: 'value inject'
      key_object: {}
      key_array: []
    ,
      array: true
    obj.a_template = '{{key_inject}}'
    obj.a_template.should.eql 'value inject'
    obj.key_object.a_template = '{{key_inject}}'
    obj.key_object.a_template.should.eql 'value inject'
    obj.key_array.push '{{key_inject}}'
    obj.key_array[0].should.eql 'value inject'
      
  it 'set element in proxy array', ->
    ## Fix error
    # `TypeError: 'set' on proxy: trap returned falsish for property '1'`
    # when `proxy.set` does not return true
    obj = templated
      key_inject: 'value inject'
      key_assert: [a: ['{{key_inject}}']]
    ,
      array: true
    obj.key_assert.push b: {}
    obj.key_assert.should.eql [
      { a: ['{{key_inject}}'] }
      { b: {} }
    ]
    obj.key_assert[0].a.push 'ok'
    obj.key_assert[0].a.should.eql [
      '{{key_inject}}'
      'ok'
    ]
