package utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.*;
	
	public class FAQ extends EventDispatcher
	{
		// Properties
		private var _faq:XMLList;
		private var _questions:Array = new Array();
		private var _answers:Object = new Object();
		private var _include:Array = new Array();
		private var _count:int = new int(0);
		
		public function FAQ( xml:XMLList )
		{
			loadFAQ( xml );
		}
		
		// Methods
		public function loadFAQ( xml:XMLList ):void
		{
			_faq = xml;
			for each ( var element:XML in this._faq.elements() ) 
			{
				if (element.name() == "include") 
				{
					this._include.push(element);
				}
			}
			delete this._faq["include"];
			// Note: The above notation is used because "include" is a protected keyword.
			if (this._include.length > 0) 
			{
				loadInclude();
			}
			else 
			{
				setAnswers();
			}
		}
		
		private function loadInclude():void {
			trace( "Load Include" );
			if ( this._count >= this._include.length ) 
			{
				setAnswers();
			} 
			else 
			{
				trace( "load external faq file " + _count + ": " + _include[_count] );
				var request:URLRequest = new URLRequest( _include[_count] );
				var loader:URLLoader = new URLLoader( request );
				loader.addEventListener( "complete", handleComplete );
				_count++;
			}
		}
		private function handleComplete( event:Event ):void {
			try {
				var xml:XML = new XML(event.target.data);
				for each ( var element:XML in xml.elements() ) {
					this._faq.prependChild( "<item question='" + element.@term + "'>" + element + "</item>" );
				}
			} catch ( e:TypeError) {
				trace( "Could not load FAQ  XML file: " + _include[_count]);
				trace( e.message );
			}  finally {
				loadInclude();
			}
			
		}
		private function setAnswers():void {
			trace( "Set Answers" );
			for each ( var element:XML in this._faq.elements() ) 
			{
				var question:String = element.@question;
				this._questions.push( question );
				this._answers[ question.toLowerCase() ] = element;
			}
			this._questions.sort();
			faqComplete();
		}
		public function get questions():Array {
			return this._questions;
		}
		public function answerFor( question:String ):String {
			return this._answers[ question.toLowerCase() ];
		}
		
		// Events
		public static var COMPLETE:String = "complete";
		
		/*
		faqComplete dispatches the COMPLETE event. 
		*/
		private function faqComplete():void 
		{
			trace( "FAQ.COMPLETE has been dispatched" );
			dispatchEvent( new Event( FAQ.COMPLETE ) );
		}
	}
}