function SelectionPlugin(pivotTable) {
    this.pivotTable = pivotTable;
    this.selectedItems = [];
    this.selectedItem = null;
    self_ = this
    document.getElementById(this.pivotTable.divId).onclick = function(env) {
    	self_.onclick(env);
    };
}

SelectionPlugin.SELECTION_STYLE = "selection";

SelectionPlugin.prototype.onclick = function(e) {
	var env = e || event;
	var target = env.target || env.srcElement;
    var tmpName = target.getAttribute("name") || "";
    var tmpAttrs = PivotTableUtil.splitId(tmpName);
    if(tmpAttrs==null || tmpAttrs.length==0) {
    	return;
    }
    PivotTableUtil.cleanSelection();
    if(tmpAttrs[0] == PivotTable.CELL_ID_PREFIX) {
    	var tmpItem = PivotTableUtil.getId(tmpAttrs[1], tmpAttrs[2]);
    	if(env.ctrlKey) {
	    	if(this.itemSelected(tmpItem)) {
	    		this.deselectItem(tmpItem);
	    	} else {
	    		this.selectItem(tmpItem);
	    		this.selectedItem = tmpItem;
	    	}
    	} else if(env.shiftKey && this.selectedItem) {
			this.selectRange(this.selectedItem, tmpItem);
    	} else {
    		var tmpFound = false;
    		for(var i=this.selectedItems.length-1; i>=0 ;i--) {
    			if(this.selectedItems[i] == tmpItem) {
    				tmpFound = true;
    			} else {
    				this.deselectItem(this.selectedItems[i]);
    			}
    		}
    		if(!tmpFound) {
	    		this.selectItem(tmpItem);
    		}
    		this.selectedItem = tmpItem;
    	}
    }
}
SelectionPlugin.prototype.selectRange = function(fromItem, toItem) {
	var fromIndex = PivotTableUtil.splitId(fromItem);
	var toIndex = PivotTableUtil.splitId(toItem);
	var fromRow = Math.min(fromIndex[0], toIndex[0]);
	var toRow = Math.max(fromIndex[0], toIndex[0]);
	var fromColumn = Math.min(fromIndex[1], toIndex[1]);
	var toColumn = Math.max(fromIndex[1], toIndex[1]);
	var preSelectedItems = this.selectedItems.concat();
	var toSelectedItems = new Array();
	for(var i=fromRow; i<=toRow; i++) {
		for(var j=fromColumn; j<=toColumn; j++) {
			var tmpItem = PivotTableUtil.getId(i, j);
			toSelectedItems.push(tmpItem);
			PivotTableUtil.removeItem(preSelectedItems, tmpItem);
		}
	}
	for(var i in preSelectedItems) {
		this.deselectItem(preSelectedItems[i]);
	}
	for(var i in toSelectedItems) {
		this.selectItem(toSelectedItems[i]);
	}
}

SelectionPlugin.prototype.selectItem = function(item) {
	if(!PivotTableUtil.containItem(this.selectedItems, item)) {
		this.selectedItems.push(item);
	}
	var cell = this.getItemCell(item);
	this.selectCell(cell);
}
SelectionPlugin.prototype.deselectItem = function(item) {
    PivotTableUtil.removeItem(this.selectedItems, item);
    if(this.selectedItem == item) {
    	this.selectedItem = null;
    }
    var cell = this.getItemCell(item);
    this.deselectCell(cell);
}
SelectionPlugin.prototype.itemSelected = function(item) {
	if(item == null) return false;
    return PivotTableUtil.containItem(this.selectedItems, item);
}

SelectionPlugin.prototype.selectCell = function(cell) {
	if(cell == null) return;
	var classList = cell.className?cell.className.split(" "):[];
    if(!PivotTableUtil.containItem(classList, SelectionPlugin.SELECTION_STYLE)) {
        classList.push(SelectionPlugin.SELECTION_STYLE);
        cell.className = classList.join(" ");
    }
}
SelectionPlugin.prototype.deselectCell = function(cell) {
	if(cell == null) return;
	var classList = cell.className?cell.className.split(" "):[];
	PivotTableUtil.removeItem(classList, SelectionPlugin.SELECTION_STYLE);
    cell.className = classList.join(" ");
}
SelectionPlugin.prototype.cellSelected = function(cell) {
	if(cell == null) return false;
	var classList = cell.className?cell.className.split(" "):[];
    return PivotTableUtil.containItem(classList, SelectionPlugin.SELECTION_STYLE);
}

SelectionPlugin.prototype.getItemCell = function(item) {
	var cellId = PivotTableUtil.getId(PivotTable.CELL_ID_PREFIX, item, this.pivotTable.id);
	var cell = document.getElementById(cellId);
	return cell;
}