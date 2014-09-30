PivotTable.TABLE_ID_PREFIX = "PivotTable_";
PivotTable.COLUMN_ID_PREFIX = "PivotTableColumn";
PivotTable.ROW_ID_PREFIX = "PivotTableRow";
PivotTable.CELL_ID_PREFIX = "PivotTableCell";

/**
 * Cache for all created pivot tables
 */
PivotTable.listOfPivotTables = new Array();

/**
 * Create PivotTable instance.
 * @param divId, the div used to show the table.
 * @param dataVector, the data vector of DataVector instance, the data to create the pivot table.
 */
function PivotTable(divId, dataVector) {
    // Properties
    this.divId = divId;
    var tmpId = PivotTable.TABLE_ID_PREFIX + divId;
    this.id = tmpId.replace(":", ".")
    this.dataVector = dataVector;
    this.rowAxes = dataVector.rowAxes;
    this.columnAxes = dataVector.columnAxes;
    this.rowIndex = 0;
    this.columnIndex = 0;
    
    PivotTable.listOfPivotTables[this.id] = this;
}

/**
 * Create the pivot table and add it to div to display it.
 */
PivotTable.prototype.display = function() {
    var tableDiv = document.getElementById(this.divId);
    var arrayOfStrings = new Array();
    
    // Add HTML to start table
    arrayOfStrings.push("<table class=\"pivotTable\">");
    arrayOfStrings.push("<tbody>");
    
    // Start the top row of column headers
    arrayOfStrings.push("<tr>");                                                                
    
    // Create the special upper-left cell
    var rowspanValue = Math.max(this.columnAxes.length, 1);
    var colspanValue = Math.max(this.rowAxes.length, 1);
    arrayOfStrings.push("<th name=\"" + this.id + "\" id=\"" + this.id + "\" rowspan=\"" + rowspanValue + "\" colspan=\"" + colspanValue + "\">"); 
    arrayOfStrings.push("PivotTable");
    arrayOfStrings.push("</th>");
    
    this.columnIndex = 0;
    // Create all the column headers
    if(this.columnAxes.length == 0) {
    	var tmpName = PivotTableUtil.getId(PivotTable.COLUMN_ID_PREFIX, this.columnIndex, 1);
        arrayOfStrings.push("<th name=\"" + tmpName + "\">" + "value" + "</th>");    
    } else {
        for(var column = 0; column < this.columnAxes.length; column++) {
            if(column > 0) {
                arrayOfStrings.push("<tr>");
            }
            this.columnIndex = 0;
            // Create header cells for this row of column headers
            var numRepeats = 1;
            for(var i = 0; i < column; i++) {
                numRepeats = this.columnAxes[i].bucketList.length * numRepeats; 
            }
            for(var repeat = 0; repeat < numRepeats; repeat++) {
                for(var x = 0; x < this.columnAxes[column].bucketList.length; x++) { 
                    var numberOfSpannedColumnsForEachHeaderColumn = 1;
                    for (var i = (column + 1); i < this.columnAxes.length; i++) {
                        numberOfSpannedColumnsForEachHeaderColumn = this.columnAxes[i].bucketList.length * numberOfSpannedColumnsForEachHeaderColumn; 
                    }
                    var tmpName = PivotTableUtil.getId(PivotTable.COLUMN_ID_PREFIX, this.columnIndex, numberOfSpannedColumnsForEachHeaderColumn);
                    arrayOfStrings.push("<th name=\"" + tmpName + "\" colspan=\"" + numberOfSpannedColumnsForEachHeaderColumn + "\">" + this.columnAxes[column].bucketList[x].name + "</th>"); 
                    this.columnIndex++;
                }
            }
            arrayOfStrings.push("</tr>");
        }
    }
    
    this.rowIndex = 0;
    this.columnIndex = 0;
    // Create all the data rows
    this.addRowsToArrayOfStrings(arrayOfStrings, 0, false);

    // add HTML to close table
    arrayOfStrings.push("</tbody>");
    arrayOfStrings.push("</table>");
    
    // take all the HTML and put it in the document
    // elementMainArea.appendChild(outerDiv);
    var finalString = arrayOfStrings.join("");
    tableDiv.innerHTML = finalString;
}

/**
 * Add rows to the table, include row header and row data.
 * @param arrayOfStrings, the pivot table html string.
 * @param rowAxisIndex, the current row axis index to deal with.
 * @param inside, cycle invoke or invoke at outside.
 **/
PivotTable.prototype.addRowsToArrayOfStrings = function(arrayOfStrings, rowAxisIndex, inside) {
    if(!rowAxisIndex) rowAxisIndex = 0;
    if(this.rowAxes.length == 0) {
        arrayOfStrings.push("<tr>");
        var tmpName = PivotTableUtil.getId(PivotTable.ROW_ID_PREFIX, this.rowIndex, 1);
        arrayOfStrings.push("<th name=\"" + tmpName + "\">" + "value" + "</th>");
        this.columnIndex = 0;
        this.addCellsToArrayOfStrings(arrayOfStrings, 0);
        arrayOfStrings.push("</tr>");
    } else {
        for(var z = 0; z < this.rowAxes[rowAxisIndex].bucketList.length; z++) {
            if(!inside || z > 0) arrayOfStrings.push("<tr>");
            var numberOfRowsToSpan = 1;
            for(var i = (rowAxisIndex + 1); i < this.rowAxes.length; i++) {
                numberOfRowsToSpan = this.rowAxes[i].bucketList.length * numberOfRowsToSpan; 
            }
            var tmpName = PivotTableUtil.getId(PivotTable.ROW_ID_PREFIX, this.rowIndex, numberOfRowsToSpan);
            arrayOfStrings.push("<th name=\"" + tmpName + "\" rowspan=\"" + numberOfRowsToSpan + "\">" + this.rowAxes[rowAxisIndex].bucketList[z].name + "</th>");
            var nestedRowIndex = rowAxisIndex + 1;
            if(nestedRowIndex < this.rowAxes.length) {
                this.addRowsToArrayOfStrings(arrayOfStrings, nestedRowIndex, true);
            } else {
            	this.columnIndex = 0;
                this.addCellsToArrayOfStrings(arrayOfStrings, 0);
                arrayOfStrings.push("</tr>");
                this.rowIndex++;
            }
        }
    }
}


/**
 * Add row item to the table.
 * @param arrayOfString, the pivot table html string.
 * @param columnAxisIndex, the column axis index to deal with.
 **/
PivotTable.prototype.addCellsToArrayOfStrings = function(arrayOfStrings, columnAxisIndex) {
    if(!columnAxisIndex) columnAxisIndex = 0;
    if(this.columnAxes.length == 0) {
        var cellValue = this.dataVector.getValueAt(this.rowIndex, this.columnIndex);
        var evenOddText = this.isCurrentEven() ? "even" : "odd";
        var tmpName = PivotTableUtil.getId(PivotTable.CELL_ID_PREFIX, this.rowIndex, this.columnIndex, this.id);
        arrayOfStrings.push("<td name=\"" + tmpName + "\" id=\"" + tmpName + "\" class=\"" + evenOddText + "\">" + cellValue + "</td>");
    } else {
        for(var x = 0; x < this.columnAxes[columnAxisIndex].bucketList.length; x++) {
            nestedColumnIndex = columnAxisIndex + 1;
            if(nestedColumnIndex < this.columnAxes.length) {
                this.addCellsToArrayOfStrings(arrayOfStrings, nestedColumnIndex);
            } else {
                var cellValue = this.dataVector.getValueAt(this.rowIndex, this.columnIndex);
                var evenOddText = this.isCurrentEven() ? "even" : "odd";
                var tmpName = PivotTableUtil.getId(PivotTable.CELL_ID_PREFIX, this.rowIndex, this.columnIndex, this.id);
                arrayOfStrings.push("<td name=\"" + tmpName + "\" id=\"" + tmpName + "\" class=\"" + evenOddText + "\">" + cellValue + "</td>");
                this.columnIndex++;
            }
        }
    }
}

/**
 * a flag to set the item style to identify the item group clearly.
 */
PivotTable.prototype.isCurrentEven = function() {
	var isEven = true;
	var tmpRow = 0;
	var rowTotal = 1;
	for(var i=1; i<this.rowAxes.length; i++) {
		rowTotal *= this.rowAxes[i].bucketList.length;
	}
	tmpRow = Math.floor(this.rowIndex/rowTotal);
	var tmpColumn = 0;
	var columnTotal = 1;
    for(var i=1; i<this.columnAxes.length; i++) {
        columnTotal *= this.columnAxes[i].bucketList.length;
    }
    if(columnTotal > 1) {
        tmpColumn = Math.floor(this.columnIndex/columnTotal);
    }
	isEven = ((tmpRow + tmpColumn)%2 == 0);
	return isEven;
}