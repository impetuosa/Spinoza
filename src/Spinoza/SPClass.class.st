Class {
	#name : #SPClass,
	#superclass : #Object,
	#instVars : [
		'name',
		'definitions',
		'relations',
		'properties'
	],
	#category : #Spinoza
}

{ #category : #visiting }
SPClass >> acceptInstance: anOtherObject ontology: ontology [

	^ anOtherObject isNil or: [ 
		  (ontology typesFor: anOtherObject) anySatisfy: [ :t | 
			  t isOfType: self ] ]
]

{ #category : #visiting }
SPClass >> acceptInstanceOrError: anOtherObject ontology: ontology [

	^ (ontology typesFor: anOtherObject) anySatisfy: [ :t | 
		  t isOfType: self ]
]

{ #category : #adding }
SPClass >> addIncomingRelation: aSPIncomingRelation [

	relations add: aSPIncomingRelation
]

{ #category : #adding }
SPClass >> addOutgoingRelation: aSPOutgoingRelation [ 
	relations add: aSPOutgoingRelation
]

{ #category : #'as yet unclassified' }
SPClass >> allCommonUsefulToAs: aSPOutgoingRelation [

	^ (self outgoingRelations
		   detect: [ :r | 
			   r name = aSPOutgoingRelation name and: [ 
				   r kind = aSPOutgoingRelation kind ] ]
		   ifFound: [ :a | a commonUsefulTo2 ]
		   ifNone: [ {  } ]) asOrderedCollection , (self parent
		   ifNil: [ {  } ]
		   ifNotNil: [ :p | p allCommonUsefulToAs: aSPOutgoingRelation ])
]

{ #category : #accessing }
SPClass >> equivalentTo: anOtherClass [

	(anOtherClass isKindOf: SPClass) ifFalse: [ ^ false ].
	^ definitions asSet = anOtherClass definitions asSet
]

{ #category : #'as yet unclassified' }
SPClass >> incomingRelations [

	^ relations select: [ :r | r isIncoming ]
]

{ #category : #accessing }
SPClass >> initialize [

	super initialize.
	definitions := OrderedCollection new.
	relations := OrderedCollection new.
	properties := Dictionary new
]

{ #category : #testing }
SPClass >> isOfType: aSPClass [

	self = aSPClass ifTrue: [ ^ true ].
	self isThing ifTrue: [ ^ false ].
	^ self supertype isOfType: aSPClass
]

{ #category : #accessing }
SPClass >> isPromotedClass [

	^ self class environment
		  at: name asSymbol
		  ifPresent: [ false ]
		  ifAbsent: [ true ]
]

{ #category : #testing }
SPClass >> isThing [

	^ name = #Thing
]

{ #category : #accessing }
SPClass >> lastMeanignfulParent [

	self parents ifEmpty: [ ^ self ].

	(name beginsWith: #MO) ifTrue: [ 
		^ (#( MOLanguageObject MODeclaration MONamedDeclaration
		      MOAnchoredDeclaration Thing ) includes: self parents anyOne name)
			  ifTrue: [ self ]
			  ifFalse: [ self parents anyOne lastMeanignfulParent ] ].
	^ self parents anyOne name = #Thing
		  ifTrue: [ self ]
		  ifFalse: [ self parents anyOne lastMeanignfulParent ]
]

{ #category : #accessing }
SPClass >> name [ 
	 ^ name 
]

{ #category : #accessing }
SPClass >> name: aString [ 
	name := aString
]

{ #category : #'as yet unclassified' }
SPClass >> outgoingNonRepeatedRelations [

	| alreadyDone |
	alreadyDone := self parents flatCollect: #outgoingRelations.
	self outgoingRelations do: [ :rel | 
		alreadyDone
			detect: [ :ad | ad name = rel name and: [ ad kind = rel kind ] ]
			ifFound: [ :ad | ad to removeAllFoundIn: rel to ] ].


	^ self outgoingRelations select: [ :a | a to isNotEmpty ]
]

{ #category : #'as yet unclassified' }
SPClass >> outgoingRelations [

	^ relations select: [ :r | r isOutgoing ]
]

{ #category : #accessing }
SPClass >> parent [

	^ self parents ifEmpty: [ nil ] ifNotEmpty: [ :p | p anyOne ]
]

{ #category : #accessing }
SPClass >> parents [

	^ (self outgoingRelations
		  select: [ :a | a kind isKindOf ])
		  flatCollect: #to
]

{ #category : #accessing }
SPClass >> printOn: aStream [

	aStream
		nextPutAll: 'class: ';
		nextPutAll: name
]

{ #category : #'as yet unclassified' }
SPClass >> relationFor: aMODeclaresSlot [

	| r |
	r := self outgoingRelations select: [ :or | 
		     or name = aMODeclaresSlot name ].
	self assert: r size = 1.
	^ r first
]

{ #category : #'as yet unclassified' }
SPClass >> supertype [

	| isA |
	isA := (self outgoingRelations detect: [ :a | a isIsA ]) to.
	^ isA ifEmpty: [ nil ] ifNotEmpty: [ isA anyOne ]
]

{ #category : #accessing }
SPClass >> types: aSPClass [ 
	self shouldBeImplemented.
]
