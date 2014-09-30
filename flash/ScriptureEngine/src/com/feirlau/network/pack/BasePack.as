package com.lily.game.net.pack {
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
    public class BasePack {
        public static const HEAD_SIZE:int = 6;
        public var id:uint = 0;
        public var size:int = 0;
        
        public function BasePack(id:uint) {
            this.id = id;
        }
        
        public function getBytes():ByteArray {
            var bytes:ByteArray = new ByteArray();
            bytes.endian = Endian.LITTLE_ENDIAN;
            bytes.position = 2;
            bytes.writeUnsignedInt(id);
            toBytes(bytes);
            bytes.position = 0;
            size = bytes.length - HEAD_SIZE;
            bytes.writeShort(size);
            return bytes;
        }
        protected function toBytes(bytes:ByteArray):void {
            // implements to write request bytes to it
        }
        
        public function setBytes(bytes:ByteArray):void {
            bytes.position = HEAD_SIZE;
            fromBytes(bytes);
        }
        protected function fromBytes(bytes:ByteArray):void {
            // implements to read response bytes from it
        }
    }
}
