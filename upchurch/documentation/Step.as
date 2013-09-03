package documentation
{
	import flash.display.DisplayObject;
	
	import mx.containers.Box;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Text;

	public class Step
	{
		// Properties
		private var _text:String; // Text of the element
		private var _type:String; // Type of element (step, note, etc.)
		private var _order:Array; // Order in which child elements appear
		private var _parent:String; // Label inhereted by the parent
		private var _label:String; // Label of the parent + label for this step
		private var _hasChildren:Boolean = new Boolean( false );
		
		// Constructor
		public function Step( parentNum:String, stepNum:String, content:XMLList )
		{
			init( parentNum, stepNum, content );
		}
		
		// Methods
		public function init( parentNum:String, stepNum:String, content:XMLList ):void
		{
			_parent = parentNum;
			_text = content.text;
			_type = content.name();
			switch ( stepNum.toLowerCase() )
			{
				case "note":
				case "trainer":
				case "safety":
				case "ts":
				case "key":
				case "tool":
				case "computer":
				case "caution":
				case "warning":
					_label = stepNum.toLowerCase();
					break;
				default:
					_label = _parent + "." + stepNum;
					break;
			}
			_order = new Array();
			//_type = content.name().toLowerCase();
			if( content.children().length() > 0 )
			{
				var stepInt:int = new int(1); 
				for( var i:int = 0; i < content.children().length(); i++ ) 
				{
					_hasChildren = true;
					var nodeType:String = new String( content.child(i).name() );
					var stepNum:String = new String( nodeType )
					nodeType = nodeType.toLowerCase();
					//trace( nodeType );
					if ( nodeType == "step" ){
						stepNum = String( stepInt );
						stepInt++;
					}
					_order.push( new Step( _label, stepNum, content.child(i) ) );
				}
			}
		}
		public function display():DisplayObject
		{
			var container:VBox = new VBox();
			{
				var step:HBox = new HBox();
				step.addChild( createLabel() );
				step.addChild( createText() );
				container.addChild( step );
			}
			{
				var children:HBox = new HBox();
				children.id = "sub_something";  // need to codify
				children.height = 0;
				{
					var indentSpacer:Box = new Box();
					indentSpacer.width = 20;
					children.addChild( indentSpacer );
				}
				{
					var childVBox:VBox = new VBox();
					// add children steps here
					children.addChild( childVBox ); 
				}
				container.addChild( children );
			}
			return container;
		}
		private function createLabel():DisplayObject
		{
			return new DisplayObject;
		}
		private function createText():DisplayObject 
		{
			return new Text;
		}
	}
}

/* Notes:
 safety, troubleshooting, visual inspection, notes, trainer note, key note, hearing,
 tool, computer icon, book (for definitions), caution, danger */