Class {
	#name : #SPOntologyExtractor,
	#superclass : #Object,
	#instVars : [
		'traversed',
		'classes',
		'classUsageCounter',
		'relationKinds',
		'relations',
		'queue',
		'tracker',
		'n',
		'm'
	],
	#classInstVars : [
		'extracted'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> construct: modelName AndSave: model ontology: aFileReference [

	| extractor |
	0 to: 500 by: 50 do: [ :n | 
		0.00 to: 0.01 by: 0.005 do: [ :m | 
			extractor := SPOntologyExtractor n: n m: m.
			extractor processModel: model.
			extractor processProperties.
			(extractor constructOntology: modelName) saveAs:
				aFileReference
				/ (modelName , n asString , '_' , m asString , '.ston') ] ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> contribute: model toLanguageOntology: aFileReference [

	| extractor |
	extractor := SPOntologyExtractor loadFrom: aFileReference.
	extractor processModel: model.
	aFileReference ensureDelete.
	extractor saveAs: aFileReference
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> extractFor: aModel [

	^ SPOntologyExtractor new extractFromModel: aModel
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> extracted [

	^ extracted ifNil: [ extracted := Dictionary new ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> factorialExample [

	| factorial integer parameter invocaiton fac extracor ontology |
	factorial := MOModel newMicrosoftAccess.

	factorial name: #factorial.

	factorial writer writeLibrary: [ :a | 
		a name: #VBA.
		integer := a writePrimitiveType: [ :t | t name: #Integer ] ].
	factorial writer writeProject: [ :e | 
		e name: #FactorialProject.
		e writeDeclarationUnit: [ :unit | 
			unit writeModule: [ :module | 
				module name: #FactorialModule.
				fac := module writeFunction: [ :function | 
					       function returnTypeReference:
						       ((function typeReferenceNamed: #Integer)
							        referee: integer;
							        yourself).
					       function selector: #factorial.
					       parameter := function writeParameter: [ :p | 
						                    p name: #i.
						                    p typeReference:
							                    ((p typeReferenceNamed: #Integer)
								                     referee: integer;
								                     yourself) ].
					       function writeBlock: [ :fnbody | 
						       fnbody writeStatement: [ :st | 
							       st
								       if: [ :condition | 
									       condition
										       operateBoolean: [ :ls | 
											       (ls variableReferenceNamed: #i)
												       referee: parameter;
												       yourself ]
										       operator: #=
										       with: [ :rs | rs numericLiteral: 0 ] ]
								       ifTrue: [ :ifBlock | 
									       ifBlock writeStatement: [ :str | 
										       str return: [ :exp | exp numericLiteral: 1 ] ] ]
								       ifFalse: [ :elseBlock | 
									       elseBlock writeStatement: [ :estm | 
										       estm return: [ :exp | 
											       exp
												       operate: [ :ls | 
													       (ls variableReferenceNamed: #i)
														       referee: parameter;
														       yourself ]
												       operator: #*
												       with: [ :rs | 
													       invocaiton := rs
														                     invocation: #factorial
														                     arguments: [ :argWr | 
															                     { (argWr
																                      operate: [ :arls | 
																	                      (arls variableReferenceNamed:
																			                       #i)
																		                      referee: parameter;
																		                      yourself ]
																                      operator: #-
																                      with: [ :arrs | 
																                      arrs numericLiteral: 1 ]) } ] ] ] ] ] ] ] ] ] ] ].
	factorial writer populateAnchorOn: factorial root.
	invocaiton referee: fac.

	extracor := self new.

	extracor processModel: factorial.
	extracor processProperties.
	ontology := extracor constructOntology: #Factorial.
	ontology drawRoassal.
	^ { 
		  ontology.
		  factorial }
]

{ #category : #private }
SPOntologyExtractor class >> loadFrom: aString [

	| instance |
	aString asFileReference exists ifFalse: [ ^ self new ].
	instance := STON fromStream: aString asFileReference readStream.
	self assert: (instance isKindOf: self).
	
	^ instance
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> n: anN m: anM [

	^ self new
		  nparameter: anN;
		  mparameter: anM;
		  yourself
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> processModelReference: aFileReference [

	| model ontofr ontolang modelName languageName |
	modelName := ('.' split: aFileReference basename) third.
	languageName := ('.' split: aFileReference basename) first.
	model := MOModel loadFrom: aFileReference.

	('/Users/sbragagn/git-repositories/ontologies/' asFileReference
	 / languageName) ensureCreateDirectory.
	ontofr := ('/Users/sbragagn/git-repositories/ontologies/'
		           asFileReference / languageName / modelName)
		          ensureCreateDirectory.

	ontolang := ('/Users/sbragagn/git-repositories/ontologies/'
	             , (languageName , '.ston')) asFileReference.
	self construct: modelName AndSave: model ontology: ontofr.
"	self contribute: model toLanguageOntology: ontolang"
]

{ #category : #public }
SPOntologyExtractor >> classFor: anObject [

	anObject ifNil: [ ^ self thing ].
	^ self classForClass: anObject class
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> classForClass: aClass [

	| class superClass |
	({ 
		 Object.
		 ProtoObject } includes: aClass) ifTrue: [ ^ self thing ].

	class := classes at: aClass ifAbsentPut: [ 
		         class := SPClass new name: aClass name.
		         superClass := self classForClass: aClass superclass.
		         self
			         relateClass: class
			         withClass: superClass
			         kind: #'Is A'
			         name: #'Kind Of'
			         cardinality: #one.
		         class ].
	classUsageCounter
		at: class
		put: (classUsageCounter at: class ifAbsent: [ 0 ]) + 1.
	^ class
]

{ #category : #accessing }
SPOntologyExtractor >> classes [
	^ classes values 
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> constructOntology: name [

	^ SPOntology new
		  classes: classes;
		  relations: relations;
		  name: name;
		  n: n m: m;
		  yourself
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> initialize [

	super initialize.
	classes := Dictionary new.
	classUsageCounter := Dictionary new.
	relationKinds := Dictionary new.
	relations := OrderedCollection new.
	traversed := Dictionary new.
	queue := OrderedCollection new.
	tracker := Dictionary new.
]

{ #category : #accessing }
SPOntologyExtractor >> model [

	^ classes values detect: [ :a | a name = #MOModel ]
]

{ #category : #accessing }
SPOntologyExtractor >> mparameter [

	^ m
]

{ #category : #accessing }
SPOntologyExtractor >> mparameter: aValue [ 

	 m := aValue.
]

{ #category : #'instance creation' }
SPOntologyExtractor >> newIncomingRelationOfKind: aString [

	| rel |
	rel := SPIncomingRelation new
		       kind: (self relationKind: aString);
		       yourself.
	relations add: rel.
	^ rel
]

{ #category : #'instance creation' }
SPOntologyExtractor >> newOutgoingRelationOfKind: aString [

	| rel |
	rel := SPOutgoingRelation new
		       kind: (self relationKind: aString);
		       yourself.
	relations add: rel.
	^ rel
]

{ #category : #accessing }
SPOntologyExtractor >> nparameter [

	^ n
]

{ #category : #accessing }
SPOntologyExtractor >> nparameter: aValue [ 

	 n := aValue.
]

{ #category : #visiting }
SPOntologyExtractor >> processMOProperty: aMODeclarationStructuralRelation many: isMany [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

	self
		relateClass: from
		withClass: to
		kind: #'Expresses ' , (isMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (isMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).
				
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> processModel: aMOModel [

	self
		relate: aMOModel
		with: aMOModel root
		kind: #'Has A'
		name: #Root
		cardinality: #one.

	self processNode: aMOModel root.

	self queueUp: aMOModel declarations.

	[ queue isEmpty ] whileFalse: [ self processNode: queue removeFirst ]
]

{ #category : #'equivalence classes' }
SPOntologyExtractor >> processNode: anObject [

	(traversed includesKey: anObject) ifTrue: [ ^ self ].
	anObject isNil ifTrue: [ ^ self ].
	traversed at: anObject put: anObject.
	anObject isCollection ifTrue: [ 
		^ anObject do: [ :a | self processNode: a ] ].
	(anObject allOntologicalRelations groupedBy: #relationName) do: [ 
		:rel | 
		self processRelations: rel ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> processProperties [

	tracker keysAndValuesDo: [ :key :val | 
		val keysAndValuesDo: [ :classTo :valuesSample | 
			(self
				 resolvePropertyFrom: key first
				 to: classTo
				 sampled: valuesSample
				 relationNamed: key third) do: [ :realClass | 
				self
					relateClass: key first
					withClass: realClass
					kind: #'Is Described by ' , (key second
							 ifTrue: [ #Many ]
							 ifFalse: [ #One ])
					name: key third
					cardinality: (key second
							 ifTrue: [ #Many ]
							 ifFalse: [ #One ]) ] ] ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> processRelations: aCollection [

	aCollection do: [ :r | 
		r acceptVisitor: self ]
]

{ #category : #visiting }
SPOntologyExtractor >> queueUp: anObj [

	anObj ifNil: [ ^ self ].
	anObj isMOModel ifTrue: [ ^ self ].
	self assert: anObj isMOObject.
	anObj isCollection
		ifTrue: [ queue addAll: anObj ]
		ifFalse: [ queue add: anObj ].

]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> relate: aDeclaration with: anOtherDeclaration kind: aString name: aName cardinality: oneOrMany [

	^ self
		  relateClass: (self classFor: aDeclaration)
		  withClass: (self classFor: anOtherDeclaration)
		  kind: aString
		  name: aName
		  cardinality: oneOrMany
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> relateClass: aDeclaration withClass: anOtherDeclaration kind: aString name: aName cardinality: oneOrMany [

	| relation |
	
	relation := aDeclaration outgoingRelations
		            detect: [ :a | 
		            a kind name = aString and: [ a name = aName ] ]
		            ifNone: [ 
			            relation := self newOutgoingRelationOfKind: aString.
			            relation name: aName.
			            relation cardinality: oneOrMany.
			            aDeclaration addOutgoingRelation: relation.
			            relation from: aDeclaration.
			            relation ].
	relation cardinality ifNil: [ relation cardinality: oneOrMany ].
	self assert: relation cardinality = oneOrMany.

	relation to add: anOtherDeclaration.
	relation := anOtherDeclaration incomingRelations
		            detect: [ :a | 
		            a kind name = aString and: [ a name = aName ] ]
		            ifNone: [ 
			            relation := self newIncomingRelationOfKind: aString.
			            relation name: aName.
			            anOtherDeclaration addIncomingRelation: relation.
			            relation to: anOtherDeclaration.
			            relation ].
	relation cardinality ifNil: [ relation cardinality: oneOrMany ].
	self assert: relation cardinality = oneOrMany.
	relation from add: aDeclaration
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> relationKind: aString [

	^ relationKinds at: aString ifAbsentPut: [ 
		  SPRelationKind new
			  name: aString;
			  yourself ]
]

{ #category : #accessing }
SPOntologyExtractor >> resolvePropertyFrom: aFrom to: aSPClass sampled: aCollection relationNamed: aRelationName [

	| packageName class |
	" We treat no literals. "
	aFrom supertype name = #MOLiteral ifTrue: [ ^ { aSPClass } ].
	class := self class environment at: aSPClass name.
	
	" We treat no values related with booleans. "
	({ 
		 Boolean.
		 True.
		 False } includes: class) ifTrue: [ ^ { aSPClass } ].
		
	packageName := class package name.
	
	
	" We treat no entities from the model"
	(packageName beginsWith: #Moxing) ifTrue: [ ^ { aSPClass } ].
	
	
	" If the size of the collection of possible values is less than N we do nothing "
	aCollection size < self nparameter ifTrue: [ ^ { aSPClass } ].
	
	" If the size of the ratio of variaty of possible different values is less than M we do nothing "
	(aCollection asSet size / aCollection size) asFloat < self mparameter ifFalse: [ 
		^ { aSPClass } ].
	
	" Create or get all the possible values classes "
	^ aCollection asSet collect: [ :a | 
		  self
			  subclassOf: aSPClass
			  named: a asString capitalized
			  relationNamed: aRelationName ].
		
	



]

{ #category : #saving }
SPOntologyExtractor >> saveAs: aString [

	| stream travs |
	aString asFileReference ensureDelete.
	stream := aString asFileReference writeStream.
	[ 
	travs := traversed.
	traversed := Dictionary new.

	STON put: self onStream: stream.
	stream
		flush;
		close ] ensure: [ traversed := travs ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> subclassOf: aClass named: aName [

	| class superClass |

	class := classes at: (aName, aClass name)  ifAbsentPut: [ 
		         class := SPClass new name: aName capitalized.
		         superClass := aClass.
		         self
			         relateClass: class
			         withClass: superClass
			         kind: #'Is A'
			         name: #'Kind Of'
			         cardinality: #one.
		         class ].
	classUsageCounter
		at: class
		put: (classUsageCounter at: class ifAbsent: [ 0 ]) + 1.
		
	^ class
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> subclassOf: aClass named: aName relationNamed: aRelationName [

	| class superClass |
	
	aClass name asClass .
	
	class := classes at: aName , aClass name ifAbsentPut: [ 
		         class := SPPromotedClass new name: aName capitalized.
		         superClass := self
			                       subclassOf: aClass
			                       named: aRelationName.
		         self
			         relateClass: class
			         withClass: superClass
			         kind: #'Is A'
			         name: #'Kind Of'
			         cardinality: #one.
		         class ].
	classUsageCounter
		at: class
		put: (classUsageCounter at: class ifAbsent: [ 0 ]) + 1.

	^ class
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> thing [

	^ classes at: Object ifAbsentPut: [ 
		  SPClass new
			  name: #Thing;
			  yourself ]
]

{ #category : #visiting }
SPOntologyExtractor >> visitDeclaresRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.
	self
		relateClass: from
		withClass: to
		kind: #'Defines ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #A ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).

	self queueUp: aMODeclarationStructuralRelation to
]

{ #category : #visiting }
SPOntologyExtractor >> visitExpressesRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

"	aMODeclarationStructuralRelation relationName = #read ifTrue: [ 
		to name = #MOAssignment ifTrue: [ self halt ] ]."
	self
		relateClass: from
		withClass: to
		kind: #'Expresses ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).


	self queueUp: aMODeclarationStructuralRelation to
]

{ #category : #visiting }
SPOntologyExtractor >> visitParentRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.
	self
		relateClass: from
		withClass: to
		kind: #'Is Defined By A'
		name: aMODeclarationStructuralRelation relationName
		cardinality: #one
]

{ #category : #visiting }
SPOntologyExtractor >> visitPropertyRelation: aMODeclarationStructuralRelation [

	| from to set col isMany |
	aMODeclarationStructuralRelation to ifNil: [ ^ self ].
	isMany := false.

	(aMODeclarationStructuralRelation to isCollection and: [ 
		 aMODeclarationStructuralRelation to isString not ]) ifTrue: [ 
		aMODeclarationStructuralRelation to
			ifEmpty: [ ^ self ]
			ifNotEmpty: [ isMany := true ] ].

	aMODeclarationStructuralRelation to isMOObject ifTrue: [ 
		^ self
			  processMOProperty: aMODeclarationStructuralRelation
			  many: isMany ].



	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

	set := tracker
		       at: { 
				       from.
				       (aMODeclarationStructuralRelation isToMany or: [ isMany ]).
				       aMODeclarationStructuralRelation relationName }
		       ifAbsentPut: [ Dictionary new ].
	col := set at: to ifAbsentPut: [ OrderedCollection new ].

	isMany
		ifTrue: [ 
			(#( indexes modifiers metadata ) includes:
				 aMODeclarationStructuralRelation relationName) ifFalse: [ 
				self halt ].
			col addAll: aMODeclarationStructuralRelation to ]
		ifFalse: [ col add: aMODeclarationStructuralRelation to ]
]

{ #category : #visiting }
SPOntologyExtractor >> visitRefereeRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

	self
		relateClass: from
		withClass: to
		kind: #'Referee Is ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).
	self queueUp: aMODeclarationStructuralRelation to
]

{ #category : #visiting }
SPOntologyExtractor >> visitRefersRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

	self
		relateClass: from
		withClass: to
		kind: #'Refers To ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).
	self queueUp: aMODeclarationStructuralRelation to
]

{ #category : #visiting }
SPOntologyExtractor >> visitStatesRelation: aMODeclarationStructuralRelation [ 
| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.
	self
		relateClass: from
		withClass: to
		kind: #'States ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #A ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).

	self queueUp: aMODeclarationStructuralRelation to
]
