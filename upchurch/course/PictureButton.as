package course
{
	import flash.display.SimpleButton;

	public class PictureButton extends SimpleButton
	{
		// Properties
		private var _pictureURL:String;
		private var _embed:String;
		
		// Constructor
		public function PictureButton( url:String ):void
		{
			load( url );
		}
		
		// Methods
		public function load( url:String ):void
		{
			_pictureURL = url;
			_embed = new String( "@Embed['" + _pictureURL + "')" );
			//setStyle( "upSkin", _embed );
			//setStyle( "overSkin", _embed );
			//setStyle( "downSkin", _embed );
		}
	}
}