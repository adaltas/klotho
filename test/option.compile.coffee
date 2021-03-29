
templated = require '../src'
stream = require 'stream'

describe 'option.compile', ->
  
  it 'with string', ->
    templated
      key_inject: 'value inject'
      key_assert: '{{key_inject}}'
    ,
      compile: true
    .should.eql
      key_inject: 'value inject'
      key_assert: 'value inject'
        
  it 'get object property', ->
    ws = new stream.Writable()
    res = templated
      ws: ws
      key_assert: '{{ws._writableState.defaultEncoding}}'
    ,
      compile: true
    res.key_assert.should.eql 'utf8'
    
  it 'alter literal object', ->
    obj = new Object()
    obj.key_inject = 'value inject'
    obj.key_assert = '{{obj.key_inject}}'
    res = templated
      obj: obj
    ,
      compile: true
    res.obj.key_inject.should.eql 'value inject'
    res.obj.key_assert.should.eql 'value inject'
    
  it 'alter null object', ->
    obj = Object.create(null)
    obj.key_inject = 'value inject'
    obj.key_assert = '{{obj.key_inject}}'
    res = templated
      obj: obj
    ,
      compile: true
    res.obj.key_inject.should.eql 'value inject'
    res.obj.key_assert.should.eql 'value inject'
        
  it 'dont alter custom objects', ->
    obj = Object.create(String.prototype)
    obj.key_inject = 'value inject'
    obj.key_assert = '{{obj.key_inject}}'
    res = templated
      obj: obj
    ,
      compile: true
    res.obj.key_inject.should.eql 'value inject'
    res.obj.key_assert.should.eql '{{obj.key_inject}}'
