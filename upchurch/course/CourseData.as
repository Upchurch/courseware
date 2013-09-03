package course
{
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.media.SoundMixer;
	import flash.net.*;
	
	import mx.collections.XMLListCollection;
	
	import utils.Glossary;
	import utils.SoundPlayer;
	
	public class CourseData extends EventDispatcher
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
		private var _pages:Array = new Array();
		private var _certification:Array;
		private var _glossary:Glossary;
		public var glossaryXML:XMLList;
		private var _complete:int = new int(0);
		private var _page:PageData;
		private var _mute:Boolean = new Boolean( false );
		private var _sound:SoundPlayer = new SoundPlayer();
		
		// Constructor
		public function CourseData ( file:String = '' ):void 
		{
			//loadCourse( file );
		}
		
		// Methods
		public function loadCourse( file:String ):void 
		{
			var xml_url:URLRequest = new URLRequest( file );
			var loader:URLLoader = new URLLoader( xml_url );
			loader.addEventListener( "complete", handleComplete );
		}
		
		private function handleComplete( event:Event ):void {
			try 
			{
				trace( "Could load the CourseData XML file: ");
				var xml_file:XML = new XML( event.target.data );
				parseContent( xml_file.content );
				delete xml_file.content;
				parseGlossary( xml_file.glossary );
				delete xml_file.glossary;
				parseSettings( xml_file );
			} catch ( e:TypeError) {
				trace( "Could not load the CourseData XML file: ");
				trace( e.message );
			}
		}
		
		/*
		parseContent parses the informaiton in the <content> tags into the
		_sections and _pages arrays.  It ignores any child of <content> that
		is not either <chapter>, <review>, or <cert> 
		*/
		private function parseContent( content:XMLList ):void 
		{
			for ( var i:int = 0; i < content.children().length(); i++ ) 
			{
				var nodeName:String = content.child(i).name();
				nodeName = nodeName.toLowerCase();
				if ( nodeName == "chapter" || nodeName == "review" || nodeName == "cert" ) 
				{
					parseSection( i, nodeName, content.child(i) );
				}
			}
			checkComplete( new Event( "content" ) );
		}
		private function parseSection( order:int, nodeName:String, node:XMLList ):void 
		{
			var section:Object = new Object()
			section.type = nodeName;
			section.properties = new Array("type","properties","propertyCount");
			section.propertyCount = int(3);
			for each ( var attribute:XML in node.attributes() ) 
			{
				section[attribute.name().toString()] = attribute.toString();
				section.properties.push( attribute.name().toString() );
				section.propertyCount++;
			}
			_sections[order] = section;
			_pages[order] = new Array(node.children().length());
			for ( var i:int = 0; i < node.children().length(); i++ ) 
			{
				if ( node.child(i).name().toString().toLowerCase() == "settings" ) 
				{
					parseSectionSetting( order, node.child(i) );
					delete node.settings;
				} 
				else 
				{
					parsePage( order, i, node.child(i) );
				}
			}
		}
		private function parseSectionSetting( order:Number, node:XMLList ):void 
		{
			for ( var i:int = 0; i < node.children().length(); i++ ) 
			{
				_sections[order][node.child(i).name().toString().toLowerCase()] = node.child(1).toString();
			}
		}
		private function parsePage( order:int, page:int, node:XMLList ):void 
		{
			var thisPage:Object = new Object();
			thisPage.properties = new Array("properties","propertyCount","type");
			thisPage.propertyCount = new int(3);
			for each ( var attribute:XML in node.attributes() ) 
			{
				thisPage[attribute.name().toString()] = attribute.toString();
				thisPage.properties.push( attribute.name().toString() );
				thisPage.propertyCount++;
			}
			for ( var i:int = 0; i < node.children().length(); i++ ) 
			{
				thisPage[node.child(i).name().toString().toLowerCase()] = node.child(i).toString();
				thisPage.properties.push( node.child(i).name().toString().toLowerCase() );
				thisPage.propertyCount++;
			}
			_pages[order][page] = thisPage;
			/*For testing purposes only *
			for ( i = 0; i < _pages[order][page].propertyCount; i++ ) 
			{
				trace( _pages[order][page].properties[i] + ": " + _pages[order][page][_pages[order][page].properties[i]] );
			}
			//*/
		}
		
		/*
		parseGlossary parses the information in the <glossary> tags into the Glossary
		object.
		*/
		private function parseGlossary( glossary:XMLList ):void 
		{
			this.glossaryXML = glossary;
			_glossary = new Glossary( glossary );
			_glossary.addEventListener( Glossary.COMPLETE, checkComplete );
			//checkComplete( new Event( "glossary" ) );
		}
		
		/*
		parseSettings distributes the information remaining in the course XML file (after
		<content> and <glossary> are removed to) the appropriate properties.  Any tag 
		that is not specifically mentioned below (such as comments) is ignored. 
		*/
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
			checkComplete( new Event( "settings" ) );
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
		public function pageCount( section:int ):int
		{
			return _pages[section].length;
		}
		public function get sectionCount():int
		{
			return _sections.length;
		}
		
		/* 
		The following funcitons are pass through functions for the _glossary object.
		*/
		public function get glossary():Glossary
		{
			return _glossary;
		}
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
		
		/*
		createMenu returns a formated XML that can be used as a dataprovider for 
		certain UI components.
		*/
		public function createMenu():XMLListCollection
		{
			var menu_list:XMLList = new XMLList( <items label="Menu" />);
			for( var i:int = 0; i < _sections.length; i++ )
			{
				menu_list.appendChild( <item /> );
				menu_list.item[i].@label = _sections[i].label;
				for( var j:int = 0; j < _pages[i].length; j++ )
				{
					menu_list.item[i].appendChild( <item /> );
					menu_list.item[i].item[j].@label = _pages[i][j].label;
					menu_list.item[i].item[j].@data = String( i + "," + j );		
				}
			}
			return new XMLListCollection( menu_list );
		}
		
		/*
		getPage receives a page number from the UI and collects all necessary
		information into a single PageData object, which is accessable to the 
		UI to update the content.
		*/
		public function getPage( data:String ):void
		{
			// Stop all previous sounds.
			SoundMixer.stopAll();
			_sound.unLoad();
			_page = new PageData();
			// parse and set page address
			var array:Array = data.split( "," );
			_page._sectionNum = array[0];
			_page._pageNum = array[1];
			_page._section = _sections[_page._sectionNum].label;
			// set state
			if ( _page._sectionNum == 0 && _page._pageNum == 0 )
			{
				_page._isFirstPage = true;
				_page._isLastPage = false;
			} 
			else if ( _page._sectionNum == _sections.length - 1 && _page._pageNum == _pages[_page._sectionNum].length - 1 )
			{
				_page._isFirstPage = false;
				_page._isLastPage = true;
			} 
			else
			{
				_page._isFirstPage = false;
				_page._isLastPage = false;
			}
			// load page data from _pages object array
			var object:Object = _pages[_page._sectionNum][_page._pageNum];
			for( var i:int = 0; i < object.properties.length; i++ )
			{
				switch( object.properties[i].toString().toLowerCase() )
				{
					case "type":
						_page._type = object.type;
						break;
					case "label":
						_page._label = object.label;
						break;
					case "file":
						_page._file = object.file;
						break;
					case "soundfile":
						_page._voiceOver = object.soundFile;
						break;
					case "random":
						_page.random = object.random;
						break;
					case "pool":
						_page._pool = object.pool;
						break;
					case "question":
						_page._question = object.question;
						break;
					case "correctanswer":
						_page.answer = object.correctanswer;
						break;
					case "rightanswerreply":
						_page._replyCorrect = object.rightanswerreply;
						break;
					case "wronganswerreply":
						_page._replyIncorrect = object.wronganswerreply;
						break;
					default:
						var property:String = object.properties[i];
						if ( property.indexOf( "choice" ) > -1 )
						{
							_page.choices = object[property];
						}
				}
			}
			_sound = new SoundPlayer( _page._voiceOver, !_mute ); 
			// send page change event
			updatePage();
		}
		public function nextPage():void
		{
			if ( !_page._isLastPage ) 
			{
				if ( _page._pageNum < _pages[_page._sectionNum].length - 1 )
				{
					_page._pageNum++;
				}
				else 
				{
					_page._pageNum = 0;
					_page._sectionNum++;
				}
				getPage( _page._sectionNum + "," + _page._pageNum );
			}
		}
		public function previousPage():void
		{
			if ( !_page._isFirstPage )
			{
				if ( _page._pageNum > 0 )
				{
					_page._pageNum--;
				}
				else
				{
					_page._sectionNum--;
					_page._pageNum = _pages[_page._sectionNum].length - 1 ;
				}
				getPage( _page._sectionNum + "," + _page._pageNum );
			}
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
		public function get page():PageData
		{
			return _page;
		}
		
		// Events
		public static var COMPLETE:String = "complete";
		public static var PAGE_CHANGED:String = "page_changed";

		/*
		checkComplete waits until all of the various parts of the course xml
		has been parsed until it dispatches the COMPLETE event. 
		*/
		private function checkComplete( event:Event ):void 
		{
			_complete++;
			if ( event.type == "glossary" )
			{
				dispatchEvent( new Event( Glossary.COMPLETE ) );
			}
			if ( _complete == 2 ) 
			{
				dispatchEvent( new Event( CourseData.COMPLETE ) );
			}
		}
		
		/*
		updatePage acknowledges that the page has been changed and notifies the
		UI to update the UI and content accordingly.
		*/
		private function updatePage():void
		{
			trace( "PAGE_CHANGED dispatched" );
			dispatchEvent( new Event( CourseData.PAGE_CHANGED ) );
		}
	}
}