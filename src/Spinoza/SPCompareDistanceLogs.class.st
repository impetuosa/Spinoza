Class {
	#name : #SPCompareDistanceLogs,
	#superclass : #SPExperiment,
	#instVars : [
		'info',
		'logs'
	],
	#category : #Spinoza
}

{ #category : #accessing }
SPCompareDistanceLogs class >> process [

	| logs parts table values |
	logs := self new.
	logs process.

	parts := logs info keys sort: #yourself asSortFunction.

	table := 'classesToChange.csv' asFileReference writeStream.

	parts do: [ :model | 
		parts do: [ :ontology | 
			values := (logs info at: model) at: ontology.
			values keysAndValuesDo: [ :className :amount | 
				table
					nextPutAll: model;
					nextPutAll: ';';
					nextPutAll: ontology;
					nextPutAll: ';'.
				table
					nextPutAll: className;
					nextPutAll: ';';
					nextPutAll: amount asString;
					nextPutAll: ';'.
				table nextPutAll: OSPlatform current lineEnding ] ] ].

	table close
]

{ #category : #initialization }
SPCompareDistanceLogs >> aggregationFor: model and: ontology [

	^ (info at: model ifAbsentPut: [ 
		   Dictionary new
			   at: #name put: model;
			   yourself ]) at: ontology ifAbsentPut: [ 
		  Dictionary new
			  at: #name put: ontology;
			  yourself ]
]

{ #category : #initialization }
SPCompareDistanceLogs >> ensure: success and: failures [

	self assert: failures basename , '.relations.txt' = success basename
]

{ #category : #accessing }
SPCompareDistanceLogs >> info [
	^ info
]

{ #category : #initialization }
SPCompareDistanceLogs >> initialize [

	super initialize.
	logs := ('logs' asFileReference entries collect: #asFileReference) 
		        sort: #basename asSortFunction.
	info := Dictionary new .
]

{ #category : #initialization }
SPCompareDistanceLogs >> normname: aName [

	aName asLowercase = #pet ifTrue: [ ^ #petstore ].
	aName asLowercase = #argouml ifTrue: [ ^ #argo ].
	^ aName
]

{ #category : #initialization }
SPCompareDistanceLogs >> process [

	logs pairsDo: [ :relations :typings | 
		self process: relations and: typings ]
]

{ #category : #initialization }
SPCompareDistanceLogs >> process: relations and: typings [

	| model ontology aggregation |
	self ensure: relations and: typings.

	model := '-' split: typings basenameWithoutExtension.
	ontology := self normname: model second.
	model := self normname: model first.
	

	aggregation := self aggregationFor: model and: ontology.


	self processTypings: typings into: aggregation
	"	self processRelations: relations into: aggregation"
]

{ #category : #initialization }
SPCompareDistanceLogs >> processRelations: failures into: aggregation [

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
SPCompareDistanceLogs >> processTypings: failures into: aggregation [

	| stream line className |
	stream := failures readStream.

	stream upToAll: OSPlatform current lineEnding.

	[ stream atEnd ] whileFalse: [ 
		line := stream upToAll: OSPlatform current lineEnding.
		(line endsWith: ';R' caseSensitive: false) ifTrue: [ 
			className := line readStream upToAll: ';R'.
			aggregation
				at: className
				put: (aggregation at: className ifAbsentPut: 0) + 1 ] ].
	stream close
]
