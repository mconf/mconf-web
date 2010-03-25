package org.jivesoftware.xiff.logging
{
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	public final class LoggerFactory
	{
		{
			configureDefault();
		}
		
		public static function configureDefault():void
		{
			var logTarget:TraceTarget = new TraceTarget();
			logTarget.filters = ["org.jivesoftware.*"];
			logTarget.level = LogEventLevel.DEBUG;
			logTarget.includeTime = true;
			logTarget.includeLevel = true;

			Log.addTarget(logTarget);
		}
		
		public static function getLogger(category:String):ILogger
		{
			return Log.getLogger(category);
		}
	}
}