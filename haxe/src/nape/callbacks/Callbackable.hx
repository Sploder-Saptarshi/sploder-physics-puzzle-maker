package nape.callbacks;









class Callbackable {
	public var cbType:Int;
	
	
	
	public var cbHasPreBegin  :Bool;
	public var cbHasPreSolve  :Bool;
	
	
	
	public var cbHasBegin     :Bool;
	public var cbHasEnd       :Bool;
	public var cbHasSenseBegin:Bool;
	public var cbHasSenseEnd  :Bool;
	public var cbHasPostSolve :Bool;
}
