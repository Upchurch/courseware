 package course
{
	import flash.display.DisplayObjectContainer;
	import mx.controls.SWFLoader;
	import utils.SoundPlayer;
	import utils.Tools;
	
	public class PageData
	{
		// Properties
		private var _tools:Tools = new Tools();
		
		// standard page
		public var _type:String;
		public var _label:String;
		public var _section:String;
		public var _file:String;
		public var _voiceOver:String;
		public var _sectionNum:int;
		public var _pageNum:int;
		private var _sound:SoundPlayer;
		
		// question types
		public var _pool:int;
		public var _random:Boolean = new Boolean( true );
		public var _question:String;
		public var _choices:Array = new Array();
		public var _answer:Array = new Array();
		public var _replyCorrect:String;
		public var _replyIncorrect:String;
		
		// states
		public var _isFirstPage:Boolean = new Boolean( false );
		public var _isLastPage:Boolean = new Boolean( false );
		
		// Methods
		public function set choices( value:String ):void
		{
			_choices.push( value );
		}
		public function set random( value:String ):void
		{
			if ( value == "false" )
			{
				_random = new Boolean( false );
			}
		}
		public function randomizeChoices():void
		{
			if ( _random )
			{
				_choices = _tools.randomizeArray( _choices );
			}
		}
		private function choiceCount():int
		{
			return _choices.count;
		}
		
		public function set answer( value:String ):void
		{
			var tempAnswer:Array = value.split(",");
			if ( tempAnswer.toString().toLowerCase() == "true" || tempAnswer.toString().toLowerCase() == "false" )
			{
				_answer.push( tempAnswer.toString() )
			} 
			else if ( _type.toLowerCase() == "flipcard" )
			{
				_answer = new Array( value );
			}
			else
			{
				for ( var i:int = 0; i < tempAnswer.length; i++ )
				{
					_answer.push( _choices[Number( tempAnswer[i] - 1 )] );
				}
			}
		}
		public function get sectionNumber():int
		{
			return _sectionNum + 1;
		}
		public function get pageNumber():int
		{
			return _pageNum + 1;
		}
		public function display():DisplayObjectContainer
		{
			if ( _type == null )
			{
				var swf:SWFLoader = new SWFLoader();
				swf.percentHeight = 100;
				swf.percentWidth = 100;
				swf.load( _file );
				return swf;
			}
			else 
			{
				switch( _type.toLowerCase() )
				{
					case "truefalse" :
					case "tf" :
					case "true_false" :
					case "t/f" :
						_type = "trueFalse";
						break;
					case "singleanswer" :
					case "samc" :
					case "single_answer" :
					case "single answer" :
					case "single" :
						_type = "singleAnswer";
						break;
					case "pictureanswer" :
					case "pamc" :
					case "picture_answer" :
					case "picture answer" :
					case "picture" :
						_type = "pictureAnswer";
						break;
					case "flipcard" :
					case "fc" :
					case "flip_card" :
					case "flip card" :
					case "flip" :
						_type = "flipCard";
						break;
					case "multipleanswer" :
					case "mamc" :
					case "multiple_answer" :
					case "multiple answer" :
					case "multiple" :
						_type = "multipleAnswer";
						break;
					case "fillblank" :
					case "fb" :
					case "fillintheblank" :
					case "fitb" :
					case "fill_in_the_blank" :
						_type = "fillblank";
						break;
				}
				randomizeChoices();
				var question:Question = new Question();
				question.type = _type.toLowerCase();
				question.question = _question;
				question.choices = _choices;
				question.answer = _answer;
				question.replyCorrect = _replyCorrect;
				question.replyIncorrect = _replyIncorrect;
				question.construct();
				return question;
			}
			return new DisplayObjectContainer();
		}
		public function get voiceOver():String 
		{
			return _voiceOver;
		}
	}
}