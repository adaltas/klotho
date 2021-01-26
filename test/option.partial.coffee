
templated = require '../src'

describe 'option.partial', ->

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
        
  it 'child with array index', ->
    context = templated
      key_1: 'value 1'
      key_2: [
        { key_2_1: 'value 2 1, {{key_1}}' }
      ,
        { key_2_2: 'value 2 2, {{key_1}}' }
      ]
    ,
      partial: key_2: 1: key_2_2: true
      array: true
    context.key_2[0].key_2_1.should.eql 'value 2 1, {{key_1}}'
    context.key_2[1].key_2_2.should.eql 'value 2 2, value 1'
        
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
        
  it 'cascade in child with array index', ->
    context = templated
      key_1: 'value 1'
      key_2: [
        { key_2_1: 'value 2 1, {{key_1}}' }
      ,
        { key_2_2: 'value 2 2, {{key_1}}' }
      ]
    ,
      partial: key_2: 1: true
      array: true
    context.key_2[0].key_2_1.should.eql 'value 2 1, {{key_1}}'
    context.key_2[1].key_2_2.should.eql 'value 2 2, value 1'
        
  it 'with compile', ->
    context = templated
      parent: key_1: 'value 1, {{key_3}}'
      key_2: 'value 2, {{key_3}}'
      key_3: 'value 3, {{key_4}}'
      key_4: 'value 4'
    , compile: true, partial: parent: key_1: true
    context.parent.key_1.should.eql 'value 1, value 3, {{key_4}}'
    context.key_2.should.eql 'value 2, {{key_3}}'
  
