package core.io.netstream
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * 
	 * @author Stefan Lu
	 * 
	 */
	public class NetSocket extends EventDispatcher
	{
		private static var _instance:NetSocket;
		
		private var socket:Socket;
		
		private var host:String;
		
		private var packLen:uint = 0;
		
		private var packHead:uint = 0;
		
		private var rspdList:Vector.<Vector.<Class>> = new Vector.<Vector.<Class>>;
		
		private var callback:Function;
		
		private var COMPRESS:uint = 0x40000000;
		
		public function NetSocket()
		{
		}
		
		public static function getInstance():NetSocket
		{
			if(!_instance){
				_instance = new NetSocket;
			}
			
			return _instance;
		}
		
		public static function regResponseClass(maintype:uint, subtype:uint, responseClass:Class):void
		{
			//
		}
		
		public static function addEvent(type:int, callback:Function):void
		{
			//
		}
		
		public static function delEvent(type:int, callback:Function):void
		{
		
		}
		/**
		 * 
		 * @param host
		 * @param port
		 * @param callback
		 * 
		 */		
		public function connect(host:String, port:int, callback:Function):void
		{
			this.socket = new Socket;
			socket.objectEncoding = ObjectEncoding.DEFAULT;
			socket.endian = Endian.LITTLE_ENDIAN;
			socket.connect(host, port);
			this.callback = callback;
			socket.addEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(Event.CONNECT, connectHandler);
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		public function close():void
		{
			try{
				socket.close();
			}catch(e:*){
				//log	
			}
			
			socket.removeEventListener(Event.CLOSE, closeHandler);
			socket.removeEventListener(Event.CONNECT, connectHandler);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			socket = null;
			callback = null;
		}
		
		public function isConnected():Boolean
		{
			if(!socket) return false;
			return socket.connected;
		}
		
		private function connectHandler(event:Event):void
		{
			//
			if(callback){
				callback(true);
			}
		}
		
		private function closeHandler(event:Event):void
		{
		
		}
		
		
		private function ioErrorHandler(event:Event):void
		{
			//
			if(callback){
				callback(false);
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			//
			if(callback){
				callback(false);
			}
		}
		
		private function socketDataHandler(event:ProgressEvent):void
		{
			read();
		}
		
		
		private function read():void
		{
			if(!packLen){
				if(socket.bytesAvailable < 4) 
					return;
				packHead = socket.readUnsignedInt();
				if(packHead & COMPRESS){
					packLen = packHead ^ COMPRESS;
				}else{
					packLen = packHead;
				}
			}
			if(packLen > socket.bytesAvailable)
				return;
			
			var bytesArray:ByteArray = new ByteArray();
			socket.readBytes(bytesArray, 0, packLen);
			if(packHead & COMPRESS)
				bytesArray.uncompress();
			dispathBytes(bytesArray);
			packLen = 0;
			
			if(socket.bytesAvailable > 0)
				read();
		}
		
		private function dispathBytes(byteArray:ByteArray):void
		{
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.position = 0;
			var maintype:uint = byteArray.readUnsignedByte();
			var subtype:uint = byteArray.readUnsignedByte();
			byteArray.position = 0;
			
			var rspdClass:Class = rspdList[maintype][subtype];
			var rspd:Response;
			
			if(rspdClass){
				rspd = new rspdClass;	
				rspd.read(byteArray);
				dispatchEvent(new SocketEvent(maintype,subtype,rspd,byteArray));
			}else{
				//
			}
			byteArray.clear();
		}
		
		public function send(bytes:ByteArray):void
		{
			var rawlen:uint = bytes.length;
			bytes.position = 0;
			var packHeadBytes:ByteArray = new ByteArray;
			packHeadBytes.endian = Endian.LITTLE_ENDIAN;
			if(rawlen > 32){
				bytes.compress();
				packHeadBytes.writeUnsignedInt(bytes.length + COMPRESS);
			}else{
				packHeadBytes.writeUnsignedInt(rawlen);
			}
			bytes.position = 0;
			packHeadBytes.writeBytes(bytes);
			try{
				socket.writeBytes(packHeadBytes);
				socket.flush();
			}catch(e:*){
			
			}
			
			bytes.clear();
		}
		
		private function regResponseClass(maintype:int, subtype:int, ResponseClass:Class):void
		{
			rspdList[maintype][subtype] = ResponseClass;
		}
		
		private function addEvent(maintype:int,subtype:int,callback:Function):void
		{
			addEventListener(maintype+'_'+subtype, callback);
		}
		
		private function delEvent(maintype:int,subtype:int,callback:Function):void
		{
			removeEventListener(maintype+'_'+subtype, callback);
		}
	}
}