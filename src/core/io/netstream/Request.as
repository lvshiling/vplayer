package core.io.netstream
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class Request
	{
		protected var maintype:int;
		
		protected var subtype:int;
		
		protected var bytes:ByteArray;
		
		public function Request(maintype:int, subtype:int)
		{
			this.maintype= maintype;
			this.subtype = subtype;
			bytes = new ByteArray;
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeByte(maintype);
			bytes.writeByte(subtype);
		}
		
		public function send():void
		{
			NetSocket.getInstance().send(bytes);
		}
		
		protected function writeString(bytes:ByteArray, str:String, len:uint, charset:String = "gb2312" /* utf-8 */):void
		{
			var pos:int = bytes.position;
			bytes.writeMultiByte(str,charset);
			bytes.length = bytes.position = pos + len;
		}
	}
}