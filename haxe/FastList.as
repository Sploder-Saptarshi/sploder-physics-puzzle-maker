package haxe
{

    public class FastList extends Object
    {
        public var head:FastCell;

        public function FastList() : void
        {
            return;
        }// end function

        public function toString() : String
        {
            var _loc_1:Array = [];
            var _loc_2:* = head;
            while (_loc_2 != null)
            {
                
                _loc_1.push(_loc_2.elt);
                _loc_2 = _loc_2.next;
            }
            return "{" + _loc_1.join(",") + "}";
        }// end function

        public function remove(param1:Object) : Boolean
        {
            var _loc_2:* = null;
            var _loc_3:* = head;
            while (_loc_3 != null)
            {
                
                if (_loc_3.elt == param1)
                {
                    if (_loc_2 == null)
                    {
                        head = _loc_3.next;
                    }
                    else
                    {
                        _loc_2.next = _loc_3.next;
                    }
                    break;
                }
                _loc_2 = _loc_3;
                _loc_3 = _loc_3.next;
            }
            return _loc_3 != null;
        }// end function

        public function pop() : Object
        {
            var _loc_1:* = head;
            if (_loc_1 == null)
            {
                return null;
            }
            else
            {
                head = _loc_1.next;
                return _loc_1.elt;
            }
        }// end function

        public function iterator() : Object
        {
            var l:* = head;
            return {hasNext:function () : Boolean
            {
                return l != null;
            }// end function
            , next:function () : Object
            {
                var _loc_1:* = l;
                l = _loc_1.next;
                return _loc_1.elt;
            }// end function
            };
        }// end function

        public function isEmpty() : Boolean
        {
            return head == null;
        }// end function

        public function first() : Object
        {
            return head == null ? (null) : (head.elt);
            return;
        }// end function

        public function add(param1:Object) : void
        {
            head = new FastCell(param1, head);
            return;
        }// end function

    }
}
