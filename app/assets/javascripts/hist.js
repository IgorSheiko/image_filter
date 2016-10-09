var intervalCount = 255;
function hist(array) {
    var intervals = histogram(array);
   var data = google.visualization.arrayToDataTable(intervals);
   var chart = new google.visualization.ColumnChart(document.getElementById('chart'));
   chart.draw(data);
}

function histogram (array) {
	var intervalCount = 255;
    var min = array.sort()[0];
    var max = array.sort()[array.length-1];

    var radius = max - min;
    var delta = radius / intervalCount;


    var intervals = createMatrix();
    var border = min;

    for (var i = 1; i < intervalCount + 1; i++ ) {
      intervals[i][0] = ( border.toString() + " - " + (border+delta).toString() )
      intervals[i][1] = matchInterval(array, border, border + delta);
      border = border + delta;
    }
    return intervals;
}

  function createMatrix() {
    var res = []
    for ( var i = 0; i < intervalCount + 1; i ++) {
      res[i] = [];
    }
    res[0][0] = 'Interval';
    res[0][1] = 'Points';
    return res;
  }

    function matchInterval(array, min, max) {
    var result = 0;
    for (i = 0; i < array.length; i++) {
      if (array[i] >= min && array[i] <= max) {
        result++;
      }
    }
    return result;
  }