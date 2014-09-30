function CountAggregator() {
    this.name = "count";
}
CountAggregator.prototype.getValue = function(preValue, curValue) {
    var value = 1;
    var preValue = parseInt(preValue);
    if(!isNaN(preValue)) {
        value += preValue;
    }
    return value;
}

function NumberSumAggregator() {
    this.name = "number_sum";
}
NumberSumAggregator.prototype.getValue = function(preValue, curValue) {
    var value = 0;
    var preValue = parseFloat(preValue);
    if(!isNaN(preValue)) {
        value += preValue;
    }
    var curValue = parseFloat(curValue);
    if(!isNaN(curValue)) {
        value += curValue;
    }
    return value;
}

function NumberMaxAggregator() {
    this.name = "number_max";
}
NumberMaxAggregator.prototype.getValue = function(preValue, curValue) {
    var value = NaN;
    var preValue = parseFloat(preValue);
    var curValue = parseFloat(curValue);
    if(isNaN(preValue) && isNaN(curValue)) {
    	value = NaN;
    } else if(isNaN(preValue)) {
    	value = curValue;
    } else if(isNaN(curValue)) {
    	value = preValue;
    } else if(preValue < curValue) {
    	value = curValue;
    } else {
    	value = preValue;
    }
    return value;
}

function NumberMinAggregator() {
    this.name = "number_min";
}
NumberMinAggregator.prototype.getValue = function(preValue, curValue) {
    var value = NaN;
    var preValue = parseFloat(preValue);
    var curValue = parseFloat(curValue);
    if(isNaN(preValue) && isNaN(curValue)) {
        value = NaN;
    } else if(isNaN(preValue)) {
        value = curValue;
    } else if(isNaN(curValue)) {
        value = preValue;
    } else if(preValue > curValue) {
        value = curValue;
    } else {
        value = preValue;
    }
    return value;
}