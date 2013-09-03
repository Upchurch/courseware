package utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.*;
	
	import mx.collections.ArrayCollection;
	
	public class Glossary extends EventDispatcher
	{
		// Properties
		private var _glossary:XMLList;
		private var _term:Array = new Array();
		private var _definition:Object = new Object();
		private var _include:Array = new Array();
		private var _count:int = new int(0);
		
		// Constructor
		public function Glossary( xml:XMLList = null ):void 
		{
			if(xml != null) 
			{
				loadGlossary( xml );
			}
		}
		
		// Methods
		public function loadGlossary( xml:XMLList ):void
		{
			_glossary = xml;
			for each ( var element:XML in this._glossary.elements() ) 
			{
				if (element.name() == "include") 
				{
					this._include.push( element );
				}
			}
			delete this._glossary["include"];
			// Note: The above notation is used because "include" is a protected keyword.
			if (this._include.length > 0) 
			{
				loadInclude();
			}
			else 
			{
				setDefinitions();
			}
		}
		
		private function loadInclude():void 
		{
			trace( "Load Include" );
			if ( this._count >= this._include.length ) 
			{
				trace( "Load Complete, now Set Definitions" );
				setDefinitions();
			} 
			else 
			{
				trace( "load external glossary file " + _count + ": " + _include[_count] );
				var request:URLRequest = new URLRequest( _include[_count] );
				var loader:URLLoader = new URLLoader( request );
				loader.addEventListener( "complete", handleComplete );
				_count++;
			}
		}
		
		private function handleComplete( event:Event ):void 
		{
			try {
				var xml:XML = new XML(event.target.data);
				trace( "Parse Glossary XML" );
				//trace( xml.toXMLString() );
				for each ( var element:XML in xml.elements() ) 
				{
					this._glossary.prependChild( "<item term='" + element.@term + "'>" + element + "</item>" );
					//trace( element.term  + ": " + element );
				}
			} catch ( e:TypeError) {
				trace( "Could not load Glossary XML file: " + _include[_count]);
				trace( e.message );
			}  finally {
				loadInclude();
			}
		}
		private function setDefinitions():void 
		{
			trace( "Set Definitions" );
			for each ( var element:XML in this._glossary.elements() ) 
			{
				var term:String = element.@term;
				this._term.push( term );
				this._definition[ term.toLowerCase() ] = element;
			}
			this._term.sort();
			glossaryComplete();
		}
		public function get terms():Array 
		{
			return this._term;
		}
		public function get definitions():Object
		{
			return this._definition;
		}
		public function setGlossary( terms:Array, definitions:Object ):void
		{
			this._term = terms;
			this._definition = definitions;
		}	
		public function termsStartingWith ( character:String ):Array 
		{
			var char:String = character.charAt(0);
			char = char.toLowerCase();
			var array:Array = new Array();
			for ( var i:int = 0; i < this._term.length; i++) {
				var term:String = this._term[i];
				term = term.toLowerCase();
				if (term.charAt(0) == char) {
					array.push( this._term[i] );
				}
			}
			return array;
		}
		public function termsStartingWithCharCode ( num:int ):Array
		{
			var termList:Array
			if ( num == 0 )
			{
				termList = this.terms;
			}
			else
			{
				termList = this.termsStartingWith( String.fromCharCode( num ) );
			}
			return termList;
		}
		public function definitionOf( term:String ):String 
		{
			return this._definition[ term.toLowerCase() ];
		}
		public function createLetterList():ArrayCollection
		{
			var list:Array = new Array( {label:"All", data:0} );
			var start:String = "A";
			var end:String = "Z";
			for ( var i:int = start.charCodeAt(); i <= end.charCodeAt(); i++ )
			{
				if( this.termsStartingWith( String.fromCharCode( i ) ).length > 0 )
				{
					list.push( {label:String.fromCharCode( i ),data:i} );
				}
			} 
			return new ArrayCollection( list );
		}
		
		
		// Events
		public static var COMPLETE:String = "complete";
		
		/*
		glossaryComplete dispatches the COMPLETE event. 
		*/
		private function glossaryComplete():void 
		{
			trace( "Glossary.COMPLETE has been dispatched" );
			dispatchEvent( new Event( Glossary.COMPLETE ) );
		}
	}
}