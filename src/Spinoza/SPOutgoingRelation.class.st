Class {
	#name : #SPOutgoingRelation,
	#superclass : #SPRelation,
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPOutgoingRelation >> commonUsefulTo [

	| ret |
	self kind isKindOf ifTrue: [ ^ to ].
	to size > 1 ifFalse: [ ^ to ].

	ret := (to groupedBy: [ :a | a parents ]) size = 1
		       ifTrue: [ { to anyOne parents anyOne } asSet ]
		       ifFalse: [ 
		       (to collect: [ :t | t lastMeanignfulParent ]) asSet ].

	ret removeAllFoundIn: (from parent allCommonUsefulToAs: self).
	^ ret
]

{ #category : #'as yet unclassified' }
SPOutgoingRelation >> commonUsefulTo2 [

	| ret |
	self kind isKindOf ifTrue: [ ^ to ].
	to size > 1 ifFalse: [ ^ to ].

	ret := (to groupedBy: [ :a | a parents ]) size = 1
		       ifTrue: [ { to anyOne parents anyOne } ]
		       ifFalse: [ 
		       (to collect: [ :t | t lastMeanignfulParent ]) asSet ].
	^ ret
]

{ #category : #accessing }
SPOutgoingRelation >> from: aSPClass [

	from := aSPClass
]

{ #category : #accessing }
SPOutgoingRelation >> isOutgoing [

	^ true
]

{ #category : #accessing }
SPOutgoingRelation >> printOn: aStream [

	aStream nextPutAll: 'OUT ';
		nextPutAll: kind name;
		nextPutAll: ' ';
		nextPutAll: (' | ' join: (to collect: [ :a | a name ]))
]
