data1 = [
    {country: "China", year: "2009", field:"Software", quarter: "Q1", value: "1"},
    {country: "China", year: "2009", field:"Cars", quarter: "Q1", value: "1"},
    {country: "China", year: "2009", field:"Cars", quarter: "Q2", value: "2"},
    {country: "China", year: "2009", field:"Software", quarter: "Q2", value: "2"},
    {country: "China", year: "2009", field:"Software", quarter: "Q3", value: "4"},
    {country: "China", year: "2009", field:"Software", quarter: "Q3", value: "3"},
    {country: "China", year: "2009", field:"Cars", quarter: "Q3", value: "3"},
    {country: "China", year: "2009", field:"Cars", quarter: "Q4", value: "8"},
    
    {country: "United States", year: "2009", field:"Cars", quarter: "Q1", value: "1"},
    {country: "United States", year: "2009", field:"Software", quarter: "Q1", value: "1"},
    {country: "United States", year: "2009", field:"Software", quarter: "Q2", value: "2"},
    {country: "United States", year: "2009", field:"Cars", quarter: "Q2", value: "2"},
    {country: "United States", year: "2009", field:"Cars", quarter: "Q2", value: "2"},
    {country: "United States", year: "2009", field:"Cars", quarter: "Q3", value: "4"},
    {country: "United States", year: "2009", field:"Software", quarter: "Q3", value: "3"},
    {country: "United States", year: "2009", field:"Software", quarter: "Q4", value: "8"},
    
    {country: "China", year: "2010", field:"Cars", quarter: "Q1", value: "1"},
    {country: "China", year: "2010", field:"Software", quarter: "Q1", value: "1"},
    {country: "China", year: "2010", field:"Cars", quarter: "Q2", value: "2"},
    {country: "China", year: "2010", field:"Cars", quarter: "Q2", value: "2"},
    {country: "China", year: "2010", field:"Software", quarter: "Q3", value: "4"},
    {country: "China", year: "2010", field:"Cars", quarter: "Q3", value: "3"},
    {country: "China", year: "2010", field:"Cars", quarter: "Q4", value: "8"},
    
    {country: "United States", year: "2010", field:"Software", quarter: "Q1", value: "1"},
    {country: "United States", year: "2010", field:"Software", quarter: "Q1", value: "1"},
    {country: "United States", year: "2010", field:"Cars", quarter: "Q2", value: "2"},
    {country: "United States", year: "2010", field:"Cars", quarter: "Q2", value: "2"},
    {country: "United States", year: "2010", field:"Software", quarter: "Q3", value: "4"},
    {country: "United States", year: "2010", field:"Cars", quarter: "Q3", value: "3"},
    
    {country: "Japan", year: "2010",  field:"Cars", quarter: "Q3", value: "3"},
    
    {country: "Germany", year: "2010", field:"Cars", quarter: "Q2", value: "10"},
];

function onLoad() {
	var aggregator = new NumberSumAggregator();
	var measurer = new Measurer('value', 'value', aggregator);
	var columnAxes = new Array();
	//columnAxes.push(new Axis("country", "country"));
	//columnAxes.push(new Axis("year", "year"));
	columnAxes.push(new Axis("quarter", "quarter"));
	columnAxes.push(new Axis("field", "field"));
	var rowAxes = new Array();
	rowAxes.push(new Axis("country", "country"));
	rowAxes.push(new Axis("year", "year"));
	//rowAxes.push(new Axis("quarter", "quarter"));
	//rowAxes.push(new Axis("field", "field"));
	var dataVector = new DataVector(data1, columnAxes, rowAxes, measurer);
	var pivotTable = new PivotTable("tableOne", dataVector);
	dataVector.updateData();
	pivotTable.display();
	var selectionPlugin = new SelectionPlugin(pivotTable);
}

window.onload = onLoad;