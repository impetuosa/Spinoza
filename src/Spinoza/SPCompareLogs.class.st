Class {
	#name : #SPCompareLogs,
	#superclass : #SPExperiment,
	#instVars : [
		'info',
		'logs'
	],
	#category : #Spinoza
}

{ #category : #accessing }
SPCompareLogs class >> process [

	| logs parts table points values |
	logs := self new.
	logs process.

	parts := logs info keys sort: #yourself asSortFunction.

	table := 'table.csv' asFileReference writeStream.
	points := (#( AcceptedEntity AcceptedRelations RejectedEntity
	              RejectedRelations ) asOrderedCollection sort: #yourself asSortFunction)
		          asOrderedCollection.
	points remove: #name.

	parts do: [ :model | 
		parts do: [ :ontology | 
			points do: [ :v | 
				values := (logs info at: model) at: ontology.
				table
					nextPutAll: model;
					nextPutAll: ';';
					nextPutAll: ontology;
					nextPutAll: ';'.
				table
					nextPutAll: v;
					nextPutAll: ';';
					nextPutAll: (values at: v) asString;
					nextPutAll: ';'.
				table nextPutAll: OSPlatform current lineEnding ] ] ].

	table close
]

{ #category : #initialization }
SPCompareLogs >> aggregationFor: model and: ontology [

	^ (info at: model ifAbsentPut: [ Dictionary new ])
		  at: ontology
		  ifAbsentPut: [ Dictionary new ]
]

{ #category : #initialization }
SPCompareLogs >> ensure: success and: failures [

	self assert:
		(failures basename copyReplaceAll: '.txt' with: '.relations.txt')
		= success basename
]

{ #category : #accessing }
SPCompareLogs >> info [
	^ info
]

{ #category : #initialization }
SPCompareLogs >> initialize [

	super initialize.
	logs := ('logs' asFileReference entries collect: #asFileReference) 
		        sort: #basename asSortFunction.
	info := Dictionary new .
]

{ #category : #initialization }
SPCompareLogs >> normname: aName [

	aName asLowercase = #pet ifTrue: [ ^ #petstore ].
	aName asLowercase = #argouml ifTrue: [ ^ #argo ].
	^ aName
]

{ #category : #initialization }
SPCompareLogs >> process [

	logs pairsDo: [ :relations :typings | 
		self process: relations and: typings ]
]

{ #category : #initialization }
SPCompareLogs >> process: relations and: typings [

	| model ontology aggregation |
	self ensure: relations and: typings.

	model := '-' split: typings basenameWithoutExtension.
	ontology := self normname: model second.
	model := self normname: model first.

	aggregation := self aggregationFor: model and: ontology.


	self processTypings: typings into: aggregation.
	self processRelations: relations into: aggregation
]

{ #category : #initialization }
SPCompareLogs >> processRelations: failures into: aggregation [

	| stream line |
	stream := failures readStream.

	stream upToAll: OSPlatform current lineEnding.
	aggregation at: #AcceptedRelations put: 0.
	aggregation at: #RejectedRelations put: 0.


	[ stream atEnd ] whileFalse: [ 
		line := stream upToAll: OSPlatform current lineEnding.
		(line endsWith: ';A' caseSensitive: false)
			ifTrue: [ 
				aggregation
					at: #AcceptedRelations
					put: (aggregation at: #AcceptedRelations) + 1 ]
			ifFalse: [ 
				(line endsWith: ';R' caseSensitive: false)
					ifTrue: [ 
						aggregation
							at: #RejectedRelations
							put: (aggregation at: #RejectedRelations) + 1 ]
					ifFalse: [ self error: 'Cannot process this ' ] ] ].
	stream close
]

{ #category : #initialization }
SPCompareLogs >> processTypings: failures into: aggregation [

	| stream line |
	stream := failures readStream.

	stream upToAll: OSPlatform current lineEnding.
	aggregation at: #AcceptedEntity put: 0.
	aggregation at: #RejectedEntity put: 0.


	[ stream atEnd ] whileFalse: [ 
		line := stream upToAll: OSPlatform current lineEnding.
		(line endsWith: ';A' caseSensitive: false)
			ifTrue: [ 
				aggregation
					at: #AcceptedEntity
					put: (aggregation at: #AcceptedEntity) + 1 ]
			ifFalse: [ 
				(line endsWith: ';R' caseSensitive: false)
					ifTrue: [ 
						aggregation
							at: #RejectedEntity
							put: (aggregation at: #RejectedEntity) + 1 ]
					ifFalse: [ self error: 'Cannot process this ' ] ] ].
	stream close
]
