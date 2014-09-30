package org.feirlau.loader {
    public interface ILoaderProgress {
        function setProgress(label:String, completed:Number, total:Number):void;
    }
}
