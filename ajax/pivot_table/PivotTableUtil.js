PivotTableUtil = {};

PivotTableUtil.ID_SEPARATOR = "::";

/**
 * Used to join the arguments with PivotTableUtil.ID_SEPARATOR.
 */
PivotTableUtil.getId = function() {
    var tmpArray = new Array();
    for(var i=0; i<arguments.length; i++) {
        tmpArray.push(arguments[i]);
    }
    return tmpArray.join(PivotTableUtil.ID_SEPARATOR);
}

/**
 * Used to split the id string separated with PivotTableUtil.ID_SEPARATOR to an array.
 * @param id, a id string separated with PivotTableUtil.ID_SEPARATOR.
 */
PivotTableUtil.splitId = function(id) {
    var tmpArray = new Array();
    if(id) {
        tmpArray = id.split(PivotTableUtil.ID_SEPARATOR);
    }
    return tmpArray;
}

/**
 * Remove an item from a array.
 * @param items, the array to lookup.
 * @param item, the item to be removed.
 * @return boolean, true, if found and removed; else false.
 */
PivotTableUtil.removeItem = function(items, item) {
	var tmpResult = false;
	if(items && item) {
		for(var i=items.length-1; i>=0; i--) {
		    if(items[i] == item) {
		        items.splice(i, 1);
		        tmpResult = true;
		    }
		}
	}
    return tmpResult;
}

/**
 * Check if the array contains the item.
 * @param items, the array to lookup.
 * @param item, the item to find.
 * @return boolean, true, if found; else false.
 */
PivotTableUtil.containItem = function(items, item) {
	var tmpResult = false;
    if(items && item) {
        for(var i in items) {
            if(items[i] == item) {
                tmpResult = true;
                break;
            }
        }
    }
    return tmpResult;
}

/**
 * Unselect current selection, such as the selected text.
 */
PivotTableUtil.cleanSelection = function() {
	 if(document.selection) {
	 	// For IE
		document.selection.empty();
	} else if(window.getSelection()) {
		// For others
		var selection = window.getSelection();
		selection.removeAllRanges();
	}
}