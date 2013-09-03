package documentation
{
	public class Section
	{
		// Properties
		private var _label:String;
		private var _content:XMLList;
		private var _steps:Array = new Array();
		
		// Constructor
		public function Section( content:XMLList ):void
		{
			init( content );
		}
		
		// Methods
		public function init( content:XMLList ):void
		{
			_label = content.text;
			content.text = null;
			_content = content;
			parseSection( _content );
			
		}
		private function parseSection( content:XMLList ):void
		{
			var stepInt:int = new int(1); 
			for( var i:int = 0; i < content.children().length(); i++ )
			{
				var nodeType:String = new String( content.child(i).name() );
				var stepNum:String = new String( nodeType )
				nodeType = nodeType.toLowerCase();
				//trace( nodeType );
				switch ( nodeType )
				{
					case "step":
						stepNum = String( stepInt );
						stepInt++;
						break;
					case "note":
						break;
					case "trainer":
						break;
					case "safety:":
						break;
				}
				if ( nodeType == "step" ){
					stepNum = String( stepInt );
					stepInt++;
				}
				_steps.push( new Step( "", stepNum,  content.child(i) ) );
			}
			
		}
		
		public function get label():String
		{
			return _label;
		}
	}
}