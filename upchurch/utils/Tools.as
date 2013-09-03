package utils
{
	public class Tools
	{
		public function Tools():void
		{
			/*
			var test:Array = new Array()
			for( var i:int = 1; i < 11; i++ )
			{
				test.push( i );
			}
			test = randomizeArray( test );
			trace( test.toString() );
			*/
		}
		public function getRandom( min:int, max:int ):int 
		{
			return Math.round( Math.random() * (max-min) ) + min;
		}
		
		public function arraySwitch( array:Array, element1:int, element2:int ):Array 
		{
			var object:Object = new Object();
			object.element1 = array[element1];
			object.element2 = array[element2];
			array[element1] = object.element2;
			array[element2] = object.element1;
			return array;
		}
		
		public function randomizeArray( array:Array ):Array
		{
			var elementToExtract:int;
			var tempArray:Array = new Array();
			var limit:int = array.length;
			for( var i:int = 0; i < limit; i++ )
			{
				elementToExtract = getRandom( 0, array.length - 1 );
				array = arraySwitch( array, elementToExtract, array.length - 1 );
				tempArray.push( array.pop() );
			}
			return tempArray;
		}
		
		public function findAndReplace( text:String, find:String, replace:String ):String 
		{
			return text.split( find ).join( replace );
		}
	}
}