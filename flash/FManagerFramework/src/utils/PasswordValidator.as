package utils
{
	import mx.events.ValidationResultEvent;
	import mx.validators.RegExpValidator;
	import mx.validators.StringValidator;
	import mx.validators.Validator;

	public class PasswordValidator extends Validator
	{
		public var expression:String;
		public var noMatchError:String;
		public var minLength:int;
		public var tooShortError:String;
		private var regValidator:RegExpValidator = new RegExpValidator();
		private var strValidator:StringValidator = new StringValidator();
		private var results:Array;
		
		public function PasswordValidator()
		{
			super();
			regValidator.flags = "m";
			expression = "^(([^+\\-]*[a-zA-Z][^+\\-]*[0-9][^+\\-]*)|([^+\\-]*[0-9][^+\\-]*[a-zA-Z][^+\\-]*))$";
			noMatchError = resourceManager.getString('fmf_info','error.noMatchPwdError');
			minLength = 6;
			tooShortError = resourceManager.getString('fmf_info','error.noMatchPwdError');
			required = true;
			requiredFieldError= resourceManager.getString('fmf_info','error.noMatchPwdError');
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
            strValidator.minLength = minLength;
            strValidator.tooShortError = tooShortError;
            var tmpResult:ValidationResultEvent = strValidator.validate(value);
            if(tmpResult.type == ValidationResultEvent.INVALID) {
            	results = tmpResult.results;
            	return results;
            }
            regValidator.expression = expression;
            regValidator.noMatchError = noMatchError;
            tmpResult = regValidator.validate(value);
            if(tmpResult.type == ValidationResultEvent.INVALID) {
                results = tmpResult.results;
                return results;
            }
            return results;
        }
        
        override protected function resourcesChanged():void {
        	super.resourcesChanged();
        	expression = "^(([^+\\-]*[a-zA-Z][^+\\-]*[0-9][^+\\-]*)|([^+\\-]*[0-9][^+\\-]*[a-zA-Z][^+\\-]*))$";
            noMatchError = resourceManager.getString('fmf_info','error.noMatchPwdError');
            minLength = 6;
            tooShortError = resourceManager.getString('fmf_info','error.noMatchPwdError');
            required = true;
            requiredFieldError= resourceManager.getString('fmf_info','error.noMatchPwdError');
        }
	}
}