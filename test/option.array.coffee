
templated = require '../src'

describe 'option.array', ->
  
  it 'desactivated by default', ->
    templated
      key_inject: 'value inject'
      key_assert: ['{{key_inject}}']
    .key_assert[0].should.eql '{{key_inject}}'
  
  it 'simple element', ->
    templated
      key_inject: 'value inject'
      key_assert: ['{{key_inject}}']
    ,
      array: true
    .key_assert[0].should.eql 'value inject'
      
  it 'array in object in array', ->
    templated
      key_inject: 'value inject'
      key_assert: [a: ['{{key_inject}}']]
    ,
      array: true
    .key_assert[0].a[0].should.eql 'value inject'
      
  it 'with compile', ->
    templated
      key_inject: 'value inject'
      key_assert: ['{{key_inject}}']
    ,
      array: true
      compile: true
    .should.eql
      key_inject: 'value inject'
      key_assert: [ 'value inject' ]
