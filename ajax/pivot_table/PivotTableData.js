/**
 * Used to identify a column or row header.
 * @param name, the bucket name, that's the text displayed in the header.
 * @param field, the field used to get the name.
 * @param axis, the axis the bucket belongs to.
 * @param axidIndex, the index of the bucket in the axis bucket list.
 */
function Bucket(name, field, axis, axisIndex) {
	// Properties
	this.name = name;
	this.axis = axis;
	this.field = field;
	this.axisIndex = axisIndex;
	this.dataList = new Array();
}

/**
 * Used to identify a column or row axis. Each column or row may contains multi axes.
 * @param name, the axis name.
 * @param field, the field used to get bucket from data.
 */
function Axis(name, field) {
    this.name = name;
    this.field = field;
    this.bucketList = new Array();
}
/**
 * Create a new bucket and add it to the axis's bucket list.
 * @param name, the bucket name, usually it is the value of the field.
 * @param field, the bucket field.
 */
Axis.prototype.makeNewBucket = function(name, field) {
    var newBucket = new Bucket(name, field, this);
    this.bucketList.push(newBucket);
    newBucket.axisIndex = (this.bucketList.length - 1);
    return newBucket;
}

/**
 * Used to get the value of a cell in the pivot table using a special aggregator.
 * @param name, the measurer name.
 * @param field, the field used to get the value from an data item.
 * @param aggregator, the aggregator to get the value, @see PivotTableAggregator.
 */
function Measurer(name, field, aggregator) {
	this.name = name;
	this.field = field;
	this.aggregator = aggregator;
}
/**
 * Get the measured value of the items.
 * @param items, a data array used to measure.
 */
Measurer.prototype.getValue = function(items) {
	var value = null;
	for(var i in items) {
		var item = items[i];
		value = this.aggregator.getValue(value,  item[this.field]);
	}
	if(value == null) {
		value = "";
	}
	return value;
}

/**
 * Data structure used to create pivot table.
 * @param dataList, data list to analyze and display.
 * @param columnAxes, column axes.
 * @param rowAxes, row axes.
 * @param measurer, measureer to get the value of a cell.
 */
function DataVector(dataList, columnAxes, rowAxes, measurer) {
	this.dataList = dataList;
	this.columnAxes = columnAxes;
	this.rowAxes = rowAxes;
	this.measurer = measurer;
	this.valueVector = new Array();
}
/**
 * Clear pre data and regenerate the axes and values.
 */
DataVector.prototype.updateData = function() {
	this.updateAxes();
	this.updateValues();
}
/**
 * Update row and column axes and their bucket list.
 */
DataVector.prototype.updateAxes = function() {
	this.cleanAxes();
	for(var i in this.dataList) {
        var item = this.dataList[i];
        var columnIndex = 0;
        for(var j in this.columnAxes) {
            var columnAxis = this.columnAxes[j];
            if(!item.hasOwnProperty(columnAxis.field)) {
            	continue;
            }
            var found = false;
            for(var k in columnAxis.bucketList) {
                if(item[columnAxis.field] == columnAxis.bucketList[k].name) {
                    found = true;
                    break;
                }
            }
            if(!found) {
                bucket = columnAxis.makeNewBucket(item[columnAxis.field], columnAxis.field);
            }
        }
        for(var j in this.rowAxes) {
            var rowAxis = this.rowAxes[j];
            if(!item.hasOwnProperty(rowAxis.field)) {
                continue;
            }
            var found = false;
            for(var k in rowAxis.bucketList) {
                if(item[rowAxis.field] == rowAxis.bucketList[k].name) {
                    found = true;
                    break;
                }
            }
            if(!found) {
                bucket = rowAxis.makeNewBucket(item[rowAxis.field], rowAxis.field);
            }
        }
    }
}
/**
 * Clear row and column axes' bucket list.
 */
DataVector.prototype.cleanAxes = function() {
	for(var i in this.columnAxes) {
        var columnAxis = this.columnAxes[i];
        columnAxis.bucketList = new Array();
	}
	for(var i in this.rowAxes) {
        var rowAxis = this.rowAxes[i];
        rowAxis.bucketList = new Array();
	}
}

/**
 * Update items and values of each cell.
 */
DataVector.prototype.updateValues = function() {
	this.valueVector = new Array();
	for(var i in this.dataList) {
        var item = this.dataList[i];
        var rowIndex = 0;
        var preCount = 1;
        var found = (this.rowAxes.length == 0);
        for(var j=this.rowAxes.length-1; j>=0; j--) {
            var rowAxis = this.rowAxes[j];
            for(var k in rowAxis.bucketList) {
                if(item[rowAxis.field] == rowAxis.bucketList[k].name) {
                    rowIndex += k * preCount;
                    found = true;
                    break;
                }
            }
            preCount = preCount * rowAxis.bucketList.length;
        }
        if(!found) {
        	continue;
        }
        var columnIndex = 0;
        preCount = 1;
        found = (this.columnAxes.length == 0);
        for(var j=this.columnAxes.length-1; j>=0; j--) {
            var columnAxis = this.columnAxes[j];
            for(var k in columnAxis.bucketList) {
                if(item[columnAxis.field] == columnAxis.bucketList[k].name) {
                    columnIndex += k * preCount;
                    found = true;
                    break;
                }
            }
            preCount = preCount * columnAxis.bucketList.length;
        }
        if(!found) {
            continue;
        }
        if(!this.valueVector[rowIndex]) {
            this.valueVector[rowIndex] = new Array();
        }
        if(!this.valueVector[rowIndex][columnIndex]) {
            this.valueVector[rowIndex][columnIndex] = new Array();
        }
        this.valueVector[rowIndex][columnIndex].push(item);
    }
}
/**
 * Get the value of a cell.
 * @param rowIndex, row index of the cell.
 * @param columnIndex, column index of the cell.
 */
DataVector.prototype.getValueAt = function(rowIndex, columnIndex) {
	var result = "";
	var items = new Array();
	if(this.valueVector[rowIndex]) {
	    items = this.valueVector[rowIndex][columnIndex];
    }
    return this.measurer.getValue(items);
}

