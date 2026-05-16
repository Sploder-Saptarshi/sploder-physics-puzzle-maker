package haxe
{
    import flash.*;

    public class FastCell extends Object
    {
        public var next:FastCell;
        public var elt:Object;

        public function FastCell(param1:Object = , param2:FastCell = ) : void
        {
            if (Boot.skip_constructor)
            {
                return;
            }
            elt = param1;
            next = param2;
            return;
        }// end function

    }
}
