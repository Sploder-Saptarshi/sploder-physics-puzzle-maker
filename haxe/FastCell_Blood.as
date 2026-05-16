package haxe
{

    public class FastCell_Blood extends Object
    {
        public var next:FastCell_Blood;
        public var elt:Blood;

        public function FastCell_Blood(param1:Blood = , param2:FastCell_Blood = ) : void
        {
            elt = param1;
            next = param2;
            return;
        }// end function

    }
}
