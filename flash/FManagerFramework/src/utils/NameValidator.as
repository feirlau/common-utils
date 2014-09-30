package utils
{
	import mx.events.ValidationResultEvent;
	import mx.validators.RegExpValidator;
	import mx.validators.Validator;

	public class NameValidator extends Validator
	{
		public var expression:String;
		public var noMatchError:String;
		private var regValidator:RegExpValidator = new RegExpValidator();
		private var results:Array;
		
		public function NameValidator()
		{
			super();
			regValidator.flags = "m";
			expression = "^[^+\\-]+$";
			noMatchError = resourceManager.getString('fmf_info','error.noMatchNameError');
			required = true;
			requiredFieldError= resourceManager.getString('fmf_info','error.noMatchNameError');
		}
		
		// Define the doValidation() method.
        override protected function doValidation(value:Object):Array {
            // Clear results Array.
            results = [];
            // Call base class doValidation().
            results = super.doValidation(value);
            // Return if there are errors.
            if (results.length > 0) {
                return results;
            }
            regValidator.expression = expression;
            regValidator.noMatchError = noMatchError;
            var tmpResult:ValidationResultEvent = regValidator.validate(value);
            if(tmpResult.type == ValidationResultEvent.INVALID) {
                results = tmpResult.results;
                return results;
            }
            return results;
        }
        
        override protected function resourcesChanged():void {
        	super.resourcesChanged();
        	expression = "^[^+\\-]+$";
            noMatchError = resourceManager.getString('fmf_info','error.noMatchNameError');
            required = true;
            requiredFieldError= resourceManager.getString('fmf_info','error.noMatchNameError');
        }
	}
}