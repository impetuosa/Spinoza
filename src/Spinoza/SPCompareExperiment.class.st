Class {
	#name : #SPCompareExperiment,
	#superclass : #SPExperiment,
	#instVars : [
		'model',
		'ontology',
		'logStream',
		'relationsStream'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPCompareExperiment class >> compare: aModelFileReference with: anOntologyFileReference logging: aFilePath [

	^ self
		  compare: aModelFileReference
		  with: anOntologyFileReference
		  streamingOn: aFilePath asFileReference writeStream
		  successOn:
			  (aFilePath copyReplaceAll: '.txt' with: '.relations.txt')
				  asFileReference writeStream
]

{ #category : #'as yet unclassified' }
SPCompareExperiment class >> compare: aModelFileReference with: anOntologyFileReference streamingOn: aStream successOn: anOtherStream [

	^ self new
		  logStream: aStream;
		  logRelationsStream: anOtherStream;
		  compare: aModelFileReference asFileReference
		  with: anOntologyFileReference asFileReference
]

{ #category : #verification }
SPCompareExperiment >> compare: aModelFileReference with: anOntologyFileReference [
	ontology := self loadOntology: anOntologyFileReference.
	model := self loadModel: aModelFileReference.
	model language useOntologicalConstraintWith: ontology.
	self processModel
]

{ #category : #verification }
SPCompareExperiment >> hasTypeFor: entity [

	^ (ontology typesFor: entity) isNotEmpty
]

{ #category : #verification }
SPCompareExperiment >> loadModel: aPath [

	^ MOModel loadFrom: aPath
]

{ #category : #verification }
SPCompareExperiment >> loadOntology: aPath [

	^ SPOntology loadFrom: aPath
]

{ #category : #verification }
SPCompareExperiment >> logAcceptedEntity: entity [

	| estr |
	estr := entity className.

	logStream
		nextPutAll: estr;
		nextPutAll: ';';
		nextPutAll: 'A';
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logAcceptedRelation: entity val: val slot: s [

	| estr vstr sstr |
	estr := entity className.
	vstr := val className.
	sstr := s asString.
	relationsStream
		nextPutAll: estr;
		nextPutAll: ';';
		nextPutAll: vstr;
		nextPutAll: ';';
		nextPutAll: sstr;
		nextPutAll: ';';
		nextPutAll: 'A';
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logRejectedEntity: entity [

	| estr |
	estr := entity className.

	logStream
		nextPutAll: estr;
		nextPutAll: ';';
		nextPutAll: 'R';
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logRejectedRelation: entity val: val slot: s [

	| estr vstr sstr |
	estr := entity className.
	vstr := val className.
	sstr := s asString.
	relationsStream
		nextPutAll: estr;
		nextPutAll: ';';
		nextPutAll: vstr;
		nextPutAll: ';';
		nextPutAll: sstr;
		nextPutAll: ';';
		nextPutAll: 'R';
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logRelationsStream: aStream [

	relationsStream := aStream.
	aStream
		nextPutAll: 'Entity;Value;Slot;Status';
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logStream: aStream [

	logStream := aStream.

	aStream
		nextPutAll: 'EntityClass;Status';
		nextPutAll:  OSPlatform current lineEnding
]

{ #category : #accessing }
SPCompareExperiment >> model: aMOModel [ 
	model := aMOModel
]

{ #category : #accessing }
SPCompareExperiment >> ontology: aSPOntology [ 
	ontology := aSPOntology
]

{ #category : #verification }
SPCompareExperiment >> processEntity: entity [

	| val s relations |
	"
		ontology typeFor: entity.
	entity class allSlots do: [ :s | 
		ontology can: entity use: (s read: entity) with: s ].
	"
	(self hasTypeFor: entity)
		ifTrue: [ self logAcceptedEntity: entity ]
		ifFalse: [ self logRejectedEntity: entity ].
	entity fixture do: [ :assoc | 
		assoc value
			ifTrue: [ 
				self
					logAcceptedRelation: entity
					val: (assoc key read: entity)
					slot: assoc key ]
			ifFalse: [ 
				self
					logRejectedRelation: entity
					val: (assoc key read: entity)
					slot: assoc key ] ]
]

{ #category : #verification }
SPCompareExperiment >> processModel [

	model entities do: [ :entity | self processEntity: entity ].
	logStream close.
	relationsStream close.
]

{ #category : #verification }
SPCompareExperiment >> successStream [

	^ relationsStream
]
