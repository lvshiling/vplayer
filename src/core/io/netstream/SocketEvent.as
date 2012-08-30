package core.io.netstream
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class SocketEvent extends Event
	{
		public var maintype:int,subtype:int;
		public var response:Response;
		public var byteArray:ByteArray;
		
		public function SocketEvent(maintype:int, subtype:int, response:Response,bytes:ByteArray = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.maintype = maintype;
			this.subtype = subtype;
			this.response = response;
			this.byteArray = bytes;
			super(maintype+'_'+subtype, bubbles, cancelable);
		}
	}
}