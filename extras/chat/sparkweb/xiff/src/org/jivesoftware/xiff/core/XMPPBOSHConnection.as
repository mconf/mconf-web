package org.jivesoftware.xiff.core
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.logging.ILogger;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.jivesoftware.xiff.events.ConnectionSuccessEvent;
	import org.jivesoftware.xiff.events.DisconnectionEvent;
	import org.jivesoftware.xiff.events.IncomingDataEvent;
	import org.jivesoftware.xiff.events.LoginEvent;
	import org.jivesoftware.xiff.events.OutgoingDataEvent;
	import org.jivesoftware.xiff.logging.LoggerFactory;
	import org.jivesoftware.xiff.util.Callback;
	
	public class XMPPBOSHConnection extends XMPPConnection
	{
		private static const logger:ILogger = LoggerFactory.getLogger("org.jivesoftware.xiff.core.XMPPBOSHConnection");
		
		private static const HTTP_PORT:int = 7070;
		private static const HTTPS_PORT:int = 7443;
		private static const BOSH_VERSION:String = "1.6";
		
		private static const headers:Object = {
			"post": [],
			"get": ['Cache-Control', 'no-store', 'Cache-Control', 'no-cache', 'Pragma', 'no-cache']
		};
		
		private const responseTimer:Timer = new Timer(0.0, 1);
		
		private var requestCount:int = 0;
		private var requestQueue:Array = [];
		private var responseQueue:Array = [];
		private var isDisconnecting:Boolean = false;
		private var sid:String;
		private var rid:Number;
		
		private var pollingEnabled:Boolean = false;
		private var lastPollTime:Date = null;
		
		private var inactivity:uint;
		private var boshPollingInterval:uint = 10000;
		
		private var pauseEnabled:Boolean = false;
		private var maxPause:uint;
		private var pauseTimer:Timer;
		
		private var streamRestarted:Boolean;
		
		// These attributes can be configured from outside after creating the instance
		private var _secure:Boolean;
		private var _port:Number;
		private var _maxConcurrentRequests:uint;
		private var _hold:uint;
		private var _wait:uint;
		private var _boshPath:String;
		
		public function XMPPBOSHConnection(secure:Boolean = false):void
		{
			super();
			this.secure = secure;
			this.hold = 1;
			this.wait = 20;
			this.maxConcurrentRequests = 2;
			this.boshPollingInterval = 10000;
			this.boshPath = "http-bind/";
		}
		
		public override function connect(streamType:String=null):Boolean
		{
			logger.debug("BOSH connect()");
			
			var attrs:Object = {
				"xml:lang": "en",
	            "xmlns": "http://jabber.org/protocol/httpbind",
	            "xmlns:xmpp": "urn:xmpp:xbosh",
	            "xmpp:version": "1.0",
	            "hold": hold,
	            "rid": nextRID,
	            "secure": secure,
	            "wait": wait,
	            "ver": BOSH_VERSION,
	            "to": domain
	        }
	        
	        var result:XMLNode = new XMLNode(1, "body");
	        result.attributes = attrs;
	        sendRequests(result);
	
	        return true;
		}
		
		public function set maxConcurrentRequests(value:uint):void
		{
			_maxConcurrentRequests = value;
		}
		
		public function get maxConcurrentRequests():uint
		{
			return _maxConcurrentRequests;
		}
		
		public function set hold(value:uint):void
		{
			_hold = value;
		}
		
		public function get hold():uint
		{
			return _hold;
		}
		
		public function set wait(value:uint):void
		{
			_wait = value;
		}
		
		public function get wait():uint
		{
			return _wait;
		}
		
		public function set secure(flag:Boolean):void
		{
			logger.debug("set secure: {0}", flag);
			_secure = flag;			
			port = _secure ? HTTPS_PORT : HTTP_PORT;
		}
		
		public function get secure():Boolean
		{
			return _secure;
		}
		
		public override function set port(portnum:Number):void
		{
			logger.debug("set port: {0}", portnum);
			_port = portnum;
		}
		
		public override function get port():Number
		{
			return _port;
		}
		
		public function set boshPath(value:String):void
		{
			_boshPath = value;
		}
		
		public function get boshPath():String
		{
			return _boshPath;
		}
		
		public function get httpServer():String
		{
			return (secure ? "https" : "http") + "://" + server + ":" + port + "/" + boshPath;
		}
		
		public override function disconnect():void
		{
			if(active)
			{
				var data:XMLNode = createRequest();
				data.attributes.type = "terminate";
				sendRequests(data);
				active = false;
				loggedIn = false;
				dispatchEvent(new DisconnectionEvent());
			}
		}
		
		public function processConnectionResponse(responseBody:XMLNode):void
		{
			dispatchEvent(new ConnectionSuccessEvent());
			
			var attributes:Object = responseBody.attributes;
			
			sid = attributes.sid;
	        wait = attributes.wait;
	        
	        if(attributes.polling)
	        {
	        	boshPollingInterval = attributes.polling * 1000;
	        }
	        if(attributes.inactivity)
	        {
	        	inactivity = attributes.inactivity * 1000;
	        }
	        if(attributes.maxpause)
	        {
	            maxPause = attributes.maxpause * 1000;
	            pauseEnabled = true;
	        }
	        if(attributes.requests)
	        {
	            maxConcurrentRequests = attributes.requests;
	        }
	        
	        logger.debug("Polling interval: {0}", boshPollingInterval);
	        logger.debug("Inactivity timeout: {0}", inactivity);
	        logger.debug("Max requests: {0}", maxConcurrentRequests);
	        logger.debug("Max pause: {0}", maxPause);
	        
	        active = true;
	        
	        addEventListener(LoginEvent.LOGIN, handleLogin);
	        responseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, processResponse);
		}
		
		private function processResponse(event:TimerEvent=null):void
		{
			// Read the data and send it to the appropriate parser
			var currentNode:XMLNode = responseQueue.shift();
			var nodeName:String = currentNode.nodeName.toLowerCase();
			
			switch( nodeName )
			{
				case "stream:features":
					handleStreamFeatures( currentNode );
					streamRestarted = false; //avoid triggering the old server workaround
					break;
								
				case "stream:error":
					handleStreamError( currentNode );
					break;
					
				case "iq":
					handleIQ( currentNode );
					break;
					
				case "message":
					handleMessage( currentNode );
					break;
					
				case "presence":
					handlePresence( currentNode );
					break;
					
				case "success":
					handleAuthentication( currentNode );
					break;

				case "failure":
					handleAuthentication( currentNode );
					break;
				default:
					dispatchError( "undefined-condition", "Unknown Error", "modify", 500 );
					break;
			}
			
			resetResponseProcessor();
		}
	    
	    protected override function restartStream():void
	    {
	    	var data:XMLNode = createRequest();
			data.attributes["xmpp:restart"] = "true";
			data.attributes["xmlns:xmpp"] = "urn:xmpp:xbosh";
			data.attributes["xml:lang"] = "en";
			data.attributes["to"] = domain;
			sendRequests(data);
	        streamRestarted = true;
	    }
	    
	    /**
	    * returns true if pause request is sent
	    */
	    public function pauseSession(seconds:uint):Boolean
	    {
	    	logger.debug("Pausing session for {0} seconds", seconds);
	    	
	    	var pauseDuration:uint = seconds * 1000;
	    	if(!pauseEnabled || pauseDuration > maxPause || pauseDuration <= boshPollingInterval)
	    		return false;
	    	
	    	pollingEnabled = false;
	    	
	    	var data:XMLNode = createRequest();
			data.attributes["pause"] = seconds;
			sendRequests(data);
			
			pauseTimer = new Timer(pauseDuration - 2000, 1);
			pauseTimer.addEventListener(TimerEvent.TIMER, handlePauseTimeout);
			pauseTimer.start();
			
			return true;
	    }
	    
	    private function handlePauseTimeout(e:TimerEvent):void
	    {
	    	logger.debug("handlePauseTimeout");
	    	pollingEnabled = true;
	    	pollServer();
	    }
		
		private function resetResponseProcessor():void
		{
			if(responseQueue.length > 0)
			{
				responseTimer.reset();
				responseTimer.start();
			}
		}

		private function httpResponse(req:XMLNode, isPollResponse:Boolean, evt:ResultEvent):void
		{
			requestCount--;
			var rawXML:String = evt.result as String;
			
			logger.info("INCOMING {0}", rawXML);
			
			var xmlData:XMLDocument = new XMLDocument();
			xmlData.ignoreWhite = this.ignoreWhite;
			xmlData.parseXML(rawXML);
			var bodyNode:XMLNode = xmlData.firstChild;
			
			var event:IncomingDataEvent = new IncomingDataEvent();
			event.data = xmlData;
			dispatchEvent(event);
			
			if(streamRestarted && !bodyNode.hasChildNodes())
			{
				streamRestarted = false;
				bindConnection();
			}
			
			if(bodyNode.attributes["type"] == "terminate")
			{
				dispatchError("BOSH Error", bodyNode.attributes["condition"], "", -1);
				active = false;
			}
			
			if(bodyNode.attributes["sid"] && !loggedIn)
			{
				processConnectionResponse(bodyNode);
				
				var featuresFound:Boolean = false;
				for each(var child:XMLNode in bodyNode.childNodes)
				{
					if(child.nodeName == "stream:features")
						featuresFound = true;
				}
				if(!featuresFound)
				{
					pollingEnabled = true;
	    			pollServer();
				}
			}
			
			for each(var childNode:XMLNode in bodyNode.childNodes)
			{
				responseQueue.push(childNode);
			}
			
			resetResponseProcessor();
			
			//if we have no outstanding requests, then we're free to send a poll at the next opportunity
			if(requestCount == 0 && !sendQueuedRequests())
				pollServer();
		}
		
		private function httpError(req:XMLNode, isPollResponse:Boolean, evt:FaultEvent):void
		{
			disconnect();
			dispatchError("Unknown HTTP Error", evt.fault.rootCause.text, "", -1);
		}
		
		protected override function sendXML(body:*):void
		{
			sendQueuedRequests(body);
		}
		
		private function sendQueuedRequests(body:*=null):Boolean
		{
			if(body)
				requestQueue.push(body);
			else if(requestQueue.length == 0)
				return false;
				
			return sendRequests();
		}
		
		//returns true if any requests were sent
		private function sendRequests(data:XMLNode = null, isPoll:Boolean = false):Boolean
		{
			if(requestCount >= maxConcurrentRequests)
				return false;
			
			requestCount++;
			
			if(!data)
			{
				if(isPoll)
				{
					data = createRequest();
				}
				else
				{
					var temp:Array = [];
					for(var i:uint = 0; i < 10 && requestQueue.length > 0; i++)
					{
						temp.push(requestQueue.shift());
					}
					data = createRequest(temp);
				}
			}
			
			//build the http request
	        var request:HTTPService = new HTTPService();
	        request.method = "post";
	        request.headers = headers[request.method];
	        request.url = httpServer;
	        request.resultFormat = HTTPService.RESULT_FORMAT_TEXT;
	        request.contentType = "text/xml";
	        
	        var responseCallback:Callback = new Callback(this, httpResponse, data, isPoll);
	        var errorCallback:Callback = new Callback(this, httpError, data, isPoll);
	        
	        request.addEventListener(ResultEvent.RESULT, responseCallback.call, false);
	        request.addEventListener(FaultEvent.FAULT, errorCallback.call, false);
	        
			request.send(data);

			var event:OutgoingDataEvent = new OutgoingDataEvent();
			event.data = data;
			dispatchEvent(event);
			
			if(isPoll) {
				lastPollTime = new Date();
				logger.info("Polling");
			}
			
			logger.info("OUTGOING {0}", data);
			
			return true;
		}
    	
    	private function pollServer():void 
    	{
    		//We shouldn't poll if the connection is dead, if we had requests to send instead, or if there's already one in progress
    		if(!isActive() || !pollingEnabled || sendQueuedRequests() || requestCount > 0)
    			return;
    		
    		//this should be safe since sendRequests checks to be sure it's not over the concurrent requests limit, and we just ensured that the queue is empty by calling sendQueuedRequests()
    		sendRequests(null, true);
    	}
    	
    	private function get nextRID():Number
    	{
    		if(!rid)
    			rid = Math.floor(Math.random() * 1000000);
    		return ++rid;
    	}
    	
    	private function createRequest(bodyContent:Array=null):XMLNode
    	{
    		var attrs:Object = {
    			"xmlns": "http://jabber.org/protocol/httpbind",
				"rid": nextRID,
				"sid": sid
    		}
    		var req:XMLNode = new XMLNode(1, "body");
    		if(bodyContent)
    			for each(var content:XMLNode in bodyContent)
    					req.appendChild(content);
    		
    		req.attributes = attrs;
    		
    		return req;
    	}
	    
	    private function handleLogin(e:LoginEvent):void
	    {
	    	pollingEnabled = true;
	    	pollServer();
	    }
	    
		//do nothing, we use polling instead
		public override function sendKeepAlive():void {}
	}
}
