package utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	
	public class SoundPlayer extends EventDispatcher
	{
		// Properties
		private var _url:String;
		private var _playWhenLoaded:Boolean;
		private var _loopTimes:int;
		private var _position:Number;
		private var _sound:Sound = new Sound();
		private var _channel:SoundChannel;
		private var _status:String; // "loading", "playing", "stopped", or "paused" 
		
		// Constructor
		public function SoundPlayer( url:String = null, playWhenLoaded:Boolean = false, loopTimes:int = 1 ):void
		{
			loadSound( url, playWhenLoaded, loopTimes );
			_sound.addEventListener( Event.COMPLETE, onLoad );
		}
		
		// Methods
		public function loadSound( url:String = null, playWhenLoaded:Boolean = false, loopTimes:int = 1 ):void
		{
			
			_url = url;
			_playWhenLoaded = playWhenLoaded;
			_loopTimes = loopTimes;
			if ( _url != null )
			{
				try
				{
					_sound = new Sound( new URLRequest( _url ) );
				} 
				catch ( e:TypeError) 
				{
					trace( e.message );
				}
			}
			_status = "loading";
		}
		public function get status():String
		{
			return _status;
		}
		private function onLoad( event:Event ):void
		{
			loadComplete();
			if ( _playWhenLoaded ) 
			{
				play();
			}
			else
			{
				_status = "paused";
			}
		}
		public function unLoad():void
		{
			_playWhenLoaded = false;
		}
		public function play( position:Number = NaN ):void{
			if ( _status != "playing" )
			{
				if( isNaN(position) ){
 		   			_position = 0;
    			    _channel = _sound.play( 0, _loopTimes );      
    			} 
    			else 
    			{
    				trace( "position: " + _position );
    				_position = position;
        			_channel = _sound.play( _position, _loopTimes );
    			}
			}
			_status = "playing";
		} 
		public function stop():void
		{
			_status = "stopped";
			_position = 0;
			_channel.stop();
		}
		public function stopAll():void
		{
			SoundMixer.stopAll();
		}
		public function rewind():void
		{
			stop();
		}
		public function pause():void
		{
			if ( _status == "paused" )
			{
				play( _position );
			}
			else if ( _status == "playing" )
			{
				_status = "paused";
				_position = _channel.position;
				_channel.stop();
			}
		}
		
		// Events
		public static var LOAD_COMPLETE:String = "load_complete";
		private function loadComplete():void
		{
			dispatchEvent( new Event( SoundPlayer.LOAD_COMPLETE ) );
		}
		public static var PLAY_COMPLETE:String = "play_complete";
		private function playComplete():void
		{
			dispatchEvent( new Event( SoundPlayer.PLAY_COMPLETE ) );
		}
	}
}