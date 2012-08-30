package core.io.netstream
{
	import flash.utils.ByteArray;

	public class Response
	{
		public var maintype:uint;
		
		public var subtype:uint;
		
		protected var bytes:ByteArray;
		
		
		public function Response()
		{
		}
		
		public function read(bytes:ByteArray):void
		{
			this.bytes = bytes;
			maintype = bytes.readUnsignedByte();
			subtype = bytes.readUnsignedByte();
			decode();
		}
		
		protected function decode():void
		{
		}
		
		protected function readString(bytes:ByteArray, len:uint, charset:String = "gb2312"):String
		{
			return bytes.readMultiByte(len, charset);
		}
	}
}