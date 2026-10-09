Class {
	#name : #SPRelation,
	#superclass : #Object,
	#instVars : [
		'kind',
		'name',
		'cardinality',
		'to',
		'from'
	],
	#category : #Spinoza
}

{ #category : #accessing }
SPRelation >> cardinality [

	^ cardinality
]

{ #category : #accessing }
SPRelation >> cardinality: aString [
	aString = nil ifTrue: [ self error: 'Cannot be nil' . ].
	cardinality := aString 
]

{ #category : #accessing }
SPRelation >> from [
	^ from
]

{ #category : #accessing }
SPRelation >> initialize [

	super initialize.
	from := Set new.
	to := Set new
]

{ #category : #accessing }
SPRelation >> isIncoming [
 	 ^ self isOutgoing not 
]

{ #category : #testing }
SPRelation >> isIsA [
	^ kind isIsA
]

{ #category : #accessing }
SPRelation >> isOutgoing [
 	 ^ false 
]

{ #category : #testing }
SPRelation >> isToMany [

	^ cardinality asLowercase = #many
]

{ #category : #accessing }
SPRelation >> kind [
	^ kind
]

{ #category : #accessing }
SPRelation >> kind: aSPRelationKind [ 
	kind := aSPRelationKind
]

{ #category : #accessing }
SPRelation >> name [
	^ name
]

{ #category : #accessing }
SPRelation >> name: aString [

	name := aString
]

{ #category : #accessing }
SPRelation >> to [
	^ to
]
