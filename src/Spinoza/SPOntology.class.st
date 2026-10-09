Class {
	#name : #SPOntology,
	#superclass : #Object,
	#instVars : [
		'classes',
		'relations',
		'name',
		'nm'
	],
	#classInstVars : [
		'magact'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPOntology class >> loadFrom: aString [

	| instance |
	instance := STON fromStream: aString asFileReference readStream.
	self assert: (instance isKindOf: self).

	^ instance
]

{ #category : #'as yet unclassified' }
SPOntology class >> magact: aSPOntology [

	magact := aSPOntology
]

{ #category : #'as yet unclassified' }
SPOntology >> can: anObject use: anOtherObject with: aSlot [

	| type relation |
	({ #anchor. #refereeAnchor } includes: aSlot name) ifTrue: [ 
		^ anOtherObject isNil or: [ anOtherObject class = MOAnchor ] ].
	aSlot name = #constraints ifTrue: [ ^ true ].
	aSlot name = #language ifTrue: [ 
		^ anOtherObject isNil or: [ anOtherObject isKindOf: MOLanguage ] ].
	aSlot name = #name ifTrue: [ 
		^ anOtherObject isNil or: [ anOtherObject isKindOf: String ] ].

	[ type := self typeFor: anObject ]
		on: Error
		do: [ :e | 
			self error: ('Object of Type {1} cannot be represented ' format:
					 { anObject className }) ].

	[ relation := type relationFor: aSlot ]
		on: Error
		do: [ :e | 
			(aSlot isNoneValue: anOtherObject) ifTrue: [ ^ true ].
			self error:
				('Object of Type {1} does not register any relation {2} of kind {3} ' 
					 format: { 
							 anObject className.
							 aSlot name.
							 aSlot className }) ].


	^ relation acceptInstanceOrError: anOtherObject ontology: self
]

{ #category : #'as yet unclassified' }
SPOntology >> classes [

	^ classes
]

{ #category : #accessing }
SPOntology >> classes: aCollection [ 
	classes := aCollection
]

{ #category : #'as yet unclassified' }
SPOntology >> drawRoassal [

	| ellipses lines int processed line canvas color |
	ellipses := Dictionary new.
	lines := OrderedCollection new.

	self classes do: [ :c | 
		ellipses at: c ifAbsentPut: [ 
			| el |
			el := RSEllipse new
				      model: c;
				      yourself.

			el color: Color transparent.
			el withBorder.
			el border width: 4.
			el borderColor: Color black.
			el width: 10.
			el radius:
				((c name copyReplaceAll: 'MO' with: '') size * 4 max: 20).
			int := RSLabeled new.
			int text: [ c name copyReplaceAll: 'MO' with: '' ].
			int location middle.
			el addInteraction: int.
			el ] ].

	processed := Set new.

	self classes do: [ :p | 
		(processed includes: p) ifFalse: [ 
			processed add: p.
			p outgoingRelations
				select: [ :r | r kind name = #'Is A' ]
				thenDo: [ :rel | 
					rel to do: [ :to | 
						line := RSLine new
							        width: 4;
							        withBorderAttachPoint;
							        from: (ellipses at: p);
							        to: (ellipses at: to);
							        dashArray: #( 5 );
							        model: rel kind;
							        markerEnd: (RSShapeFactory arrow
									         size: 20;
									         color: Color black;
									         yourself);
							        yourself.
						"int := RSLabeled new.
int location middle.
line addInteraction: int."
						lines add: line ] ] ] ].
	canvas := RSCanvas new.
	canvas addAll: ellipses values , lines.
	canvas nodes @ RSDraggable.
	RSForceBasedLayout new
		charge: -2000;
		gravity: 0.001;
		on: canvas nodes.
	canvas @ RSCanvasController.


	lines := OrderedCollection new.
	color := RSColorPalette diverging rdylbu3.
	processed := Set new.

	self classes do: [ :p | 
		(processed includes: p) ifFalse: [ 
			processed add: p.
			p outgoingRelations
				reject: [ :r | r kind name = #'Is A' ]
				thenDo: [ :rel | 
					rel commonUsefulTo
						reject: [ :to | 
							(to name beginsWith: #MO) not or: [ 
								#( MOAnchor MOLanguage MOLanguageObject #MOAccess #MOHtml
								   #MOJava #MOSmalltalk #MOTypeScript #MOPharo #MOVisualWorks
								   #MOAngularTypeScript ) includes: to name ] ]
						thenDo: [ :to | 
							line := RSBezier new
								        controlPointsController:
									        RSDirectedBezierCPAPController new;
								        width: 4;
								        color: (color scale: rel kind);
								        withBorderAttachPoint;
								        from: (ellipses at: p);
								        to: (ellipses at: to);
								        model: rel;
								        markerEnd: (RSShapeFactory arrow
										         size: 20;
										         color: (color scale: rel kind);
										         yourself);
								        yourself.
							int := RSLabeled new.
							int location middle.
							int text: [ :a | a name ].
							line addInteraction: int.

							lines add: line ] ] ] ].
	canvas addAll: lines.

	^ canvas open setLabel: name
]

{ #category : #'as yet unclassified' }
SPOntology >> drawRoassal2 [

	| ellipses lines int processed line canvas color |
	ellipses := Dictionary new.
	lines := OrderedCollection new.

	self classes do: [ :c | 
		ellipses at: c ifAbsentPut: [ 
			| el |
			el := RSEllipse new
				      model: c;
				      yourself.

			el color: Color transparent.
			el withBorder.
			el border width: 4.
			el borderColor: Color black.
			el width: 10.
			el radius: (c name copyReplaceAll: 'MO' with: '') size * 4.
			int := RSLabeled new.
			int text: [ c name copyReplaceAll: 'MO' with: '' ].
			int location middle.
			el addInteraction: int.
			el ] ].

	processed := Set new.

	self classes do: [ :p | 
		(processed includes: p) ifFalse: [ 
			processed add: p.
			p outgoingRelations
				select: [ :r | r kind name = #'Is A' ]
				thenDo: [ :rel | 
					rel to do: [ :to | 
						line := RSLine new
							        width: 4;
							        withBorderAttachPoint;
							        from: (ellipses at: p);
							        to: (ellipses at: to);
							        dashArray: #( 5 );
							        model: rel kind;
							        markerEnd: (RSShapeFactory arrow
									         size: 20;
									         color: Color black;
									         yourself);
							        yourself.
						"int := RSLabeled new.
int location middle.
line addInteraction: int."
						lines add: line ] ] ] ].
	canvas := RSCanvas new.
	canvas addAll: ellipses values , lines.
	canvas nodes @ RSDraggable.
	RSForceBasedLayout new
		charge: -2000;
		gravity: 0.001;
		on: canvas nodes.
	canvas @ RSCanvasController.
 

	lines := OrderedCollection new.
	color := RSColorPalette diverging rdylbu3.
	processed := Set new.

	self classes do: [ :p | 
		(processed includes: p) ifFalse: [ 
			processed add: p.
		(	p outgoingRelations
				reject: [ :r | r kind name = #'Is A'  ]) select: [ : a | a name asLowercase  =#visibility  ]
				thenDo: [ :rel | 
					rel commonUsefulTo
						reject: [ :to | 
							(to name beginsWith: #MO) or: [ 
								#( MOAnchor MOLanguage MOLanguageObject #MOAccess #MOHtml #MOJava #MOSmalltalk #MOTypeScript #MOPharo #MOVisualWorks #MOAngularTypeScript ) includes: to name ] ]
						thenDo: [ :to | 
							line := RSBezier new
								        controlPointsController:
									        RSDirectedBezierCPAPController new;
								        width: 4;
								        color: (color scale: rel kind);
								        withBorderAttachPoint;
								        from: (ellipses at: p);
								        to: (ellipses at: to);
								        model: rel;
								        markerEnd: (RSShapeFactory arrow
										         size: 20;
										         color: (color scale: rel kind);
										         yourself);
								        yourself.
							int := RSLabeled new.
							int location middle.
							int text: [ :a | a name ].
							line addInteraction: int.

							lines add: line ] ] ] ].
	canvas addAll: lines.

	^ canvas open setLabel: name
]

{ #category : #accessing }
SPOntology >> m [

	^ nm second
]

{ #category : #types }
SPOntology >> n: n m: m [

	nm := { 
		      n.
		      m }
]

{ #category : #accessing }
SPOntology >> name [
	^ name
]

{ #category : #accessing }
SPOntology >> name: aString [ 
	name := aString
]

{ #category : #accessing }
SPOntology >> nm [
	^ nm
]

{ #category : #'as yet unclassified' }
SPOntology >> promotedClasses [

	^ classes values select: #isPromotedClass
]

{ #category : #'as yet unclassified' }
SPOntology >> relations [

	^ relations
]

{ #category : #accessing }
SPOntology >> relations: aCollection [ 
	relations := aCollection
]

{ #category : #saving }
SPOntology >> saveAs: aString [

	| stream |
	aString asFileReference ensureDelete.
	stream := aString asFileReference writeStream.

	STON put: self onStream: stream.
	stream
		flush;
		close
]

{ #category : #types }
SPOntology >> typeFor: anObjectModel [

	^ (anObjectModel class package name beginsWith: 'Moxing')
		  ifTrue: [ 
		  classes values detect: [ :v | v name = anObjectModel className ] ]
		  ifFalse: [ 
			  classes values
				  detect: [ :v | 
				  v name asLowercase = anObjectModel asString asLowercase ]
				  ifNone: [ 
				  classes values detect: [ :v | v name = anObjectModel className ] ] ]
]

{ #category : #types }
SPOntology >> typesFor: anObjectModel [

	^ ((anObjectModel class package name beginsWith: 'Moxing') or: [ 
		   anObjectModel isCollection and: [ anObjectModel isString not ] ])
		  ifTrue: [ 
		  classes values select: [ :v | v name = anObjectModel className ] ]
		  ifFalse: [ 
			  (classes values select: [ :v | 
				   v name asLowercase = anObjectModel asString asLowercase ])
			  ,
			  (classes values select: [ :v | v name = anObjectModel className ]) ]
]
