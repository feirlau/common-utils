package content
{
    public interface IContent
    {
        function get contentId():String;
        
        function get closePolicy():String;
        function set closePolicy(v:String):void;
    }
}