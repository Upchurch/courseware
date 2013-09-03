package documentation
{
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.*;
	
	import utils.FAQ;
	import utils.Glossary;
	import utils.SoundPlayer;
	
	public class DocData extends EventDispatcher
	{
		// Properties
		private var _client:String;
		private var _id:String;
		private var _title:String;
		private var _css:String;
		private var _version:String;
		private var _language:String;
		private var _copyright:String;
		private var _help:String;
		private var _sections:Array = new Array();
		private var _glossary:Glossary;
		private var _faq:FAQ;
		private var _mute:Boolean = new Boolean( false );
		private var _sound:SoundPlayer;
		
		public function DocData( file:String )
		{
			loadDoc( file );
		}
		
		// Methods
		public function loadDoc( file:String ):void 
		{
			var xml_url:URLRequest = new URLRequest( file );
			var loader:URLLoader = new URLLoader( xml_url );
			loader.addEventListener( "complete", handleComplete );
		}
		private function handleComplete( event:Event ):void {
			try 
			{
				trace( "Could load the XML file: ");
				var xml_file:XML = new XML( event.target.data );
				parseContent( xml_file.content );
				delete xml_file.content;
				parseGlossary( xml_file.glossary );
				delete xml_file.glossary;
				parseFAQ( xml_file.faq );
				delete xml_file.faq;
				parseSettings( xml_file );
			} catch ( e:TypeError) {
				trace( e.message );
				trace( e.getStackTrace() );
			}
		}
		private function parseSettings( setting:XML ):void
		{
			_client = new String( setting.client );
			_id = new String( setting.id );
			_title = new String( setting.title );
			_css = new String( setting.style );
			_version = new String( setting.version );
			_language = new String( setting.language );
			_copyright = new String( setting.copyright );
			_help = new String( setting.help );
		}
		private function parseGlossary( glossary:XMLList ):void
		{
			_glossary = new Glossary( glossary );
		}
		private function parseFAQ( faq:XMLList ):void
		{
			_faq = new FAQ( faq );
		}
		private function parseContent( content:XMLList ):void
		{
			for ( var i:int = 0; i < content.children().length(); i++ ) 
			{
				var nodeName:String = content.child(i).name();
				nodeName = nodeName.toLowerCase();
				trace( "nodeName: " + nodeName );
				if ( nodeName == "section" ) 
				{
					var label:String = content.child(i).text;
					_sections[ label ] = new Section( content.child(i) );
				}
			}
			trace( "_sections: " + _sections.toString() );
		}
		
		
		// Getters/Setters
		public function get client():String 
		{
			return _client;
		}
		public function get id():String 
		{
			return _id;
		}
		public function get title():String
		{
			return _title;
		}
		public function get css():String 
		{
			return _css;
		}
		public function get version():String 
		{
			return _version;
		}
		public function get language():String 
		{
			return _language;
		}
		public function get copyrightText():String
		{
			return _copyright;
		}
		public function get help():String
		{
			return _help;
		}
		/*  
		The following funcitons are pass through functions for the _glossary object.
		*/
		public function getTerms():Array
		{
			return _glossary.terms;
		}
		public function termsStartingWith( character:String ):Array
		{
			return _glossary.termsStartingWith( character );
		}
		public function definitionOf( term:String ):String
		{
			return _glossary.definitionOf( term );
		}
		public function openHelp():void
		{
			ExternalInterface.call( "openWindow", _help );
		}
		
		// Sound & Autoplay Functions
		public function playAudio( dud:String ):void {
			_sound.play();
		}
		private function stopAudio():void {
			_sound.stop();
		}
		public function toggleMute():void
		{
			if ( _mute == true )
			{
				_mute = false;
				_sound.pause();
			}
			else 
			{
				_mute = true;
				_sound.pause();
			}
		}

	}
}