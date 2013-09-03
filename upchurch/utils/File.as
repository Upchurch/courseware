package utils
{
	public class File
	{
		// Properties
		private var _url:String;
		private var _fullName:String;
		private var _fileName:String;
		private var _path:String;
		private var _isLocal:Boolean;
		private var _extension:String;
		private var _hasParam:Boolean;
		private var _urlParams:String;
		private var _paramArray:Array;
		
		// Constructor
		public function File(fileURL:String):void {
			this._url = fileURL;
			this._hasParam = (this._url.indexOf("?") > -1) ? true : false;
			this._isLocal = (this._url.indexOf("\\") > -1) ? true : false;
			var tempArray:Array = new Array();
			if (this._hasParam) {
				var urlArray:Array = this._url.split("?");
				this._fullName = String(urlArray[0]);
				this._urlParams = String(urlArray[1]);
				var pairArray:Array = this._urlParams.split("&");
				for (var i:int = 0; i < pairArray.length; i++) {
					var pair:Array = pairArray[i].split("=");
					var name:String = new String(pair[0]);
					var value:String = new String(pair[1]);
					this._paramArray[name.toLowerCase()] = value;
				}
			} else {
				this._fullName = String(this._url);
				this._urlParams = "none";
				this._paramArray = new Array(0);
			}
			if (this._isLocal) {
				tempArray = this._fullName.split("\\");
				this._fileName = String(tempArray.pop());
				this._path = tempArray.join("\\") + "\\";
			} else {
				tempArray = this._fullName.split("/");
				this._fileName = String(tempArray.pop());
				this._path = tempArray.join("/") + "/";
			}
			tempArray = this._fileName.split(".");
			this._extension = String(tempArray.pop());
			this._fileName = tempArray.join(".");
		}
		
		// Methods
		public function getParam(name:String):String {
			return this._paramArray[name.toLowerCase()];
		}
		public function get url():String{
			return this._url;
		}
		public function get file():String{
			return this._fileName + "." + this._extension;
		}
		public function get name():String{
			return this._fileName;
		}
		public function get path():String{
			return this._path;
		}
		public function get type():String {
			return this._extension;
		}
	}
}