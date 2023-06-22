<!DOCTYPE html>
<%@page import="java.util.concurrent.TimeUnit"%>
<%@page import="java.awt.desktop.ScreenSleepEvent"%>
<html>
<head>
<meta charset="UTF-8">
<title>Liaisons</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ" crossorigin="anonymous">
<!-- Styles -->
<style>
#chartdiv {
  width: 100%;
  height: 600px;
}
</style>

<!-- Resources -->
<script src="https://cdn.amcharts.com/lib/5/index.js"></script>
<script src="https://cdn.amcharts.com/lib/5/map.js"></script>
<script src="https://cdn.amcharts.com/lib/5/geodata/worldLow.js"></script>
<script src="https://cdn.amcharts.com/lib/5/themes/Animated.js"></script>

<!-- Chart code -->
<script>
am5.ready(function() {

// Create root element
// https://www.amcharts.com/docs/v5/getting-started/#Root_element
var root = am5.Root.new("chartdiv");

// Set themes
// https://www.amcharts.com/docs/v5/concepts/themes/
root.setThemes([
  am5themes_Animated.new(root)
]);

// Create the map chart
// https://www.amcharts.com/docs/v5/charts/map-chart/
var chart = root.container.children.push(
  am5map.MapChart.new(root, {
    panX: "translateX",
    panY: "translateY",
    projection: am5map.geoMercator()
  })
);

// Add labels and controls
var cont = chart.children.push(
  am5.Container.new(root, {
    layout: root.horizontalLayout,
    x: 20,
    y: 40
  })
);

cont.children.push(
  am5.Label.new(root, {
    centerY: am5.p50,
    text: "Map"
  })
);

var switchButton = cont.children.push(
  am5.Button.new(root, {
    themeTags: ["switch"],
    centerY: am5.p50,
    icon: am5.Circle.new(root, {
      themeTags: ["icon"]
    })
  })
);

switchButton.on("active", function () {
  if (!switchButton.get("active")) {
    chart.set("projection", am5map.geoMercator());
    chart.set("panX", "translateX");
    chart.set("panY", "translateY");
  } else {
    chart.set("projection", am5map.geoOrthographic());
    chart.set("panX", "rotateX");
    chart.set("panY", "rotateY");
  }
});

cont.children.push(
  am5.Label.new(root, {
    centerY: am5.p50,
    text: "Globe"
  })
);

// Create main polygon series for countries
// https://www.amcharts.com/docs/v5/charts/map-chart/map-polygon-series/
var polygonSeries = chart.series.push(
  am5map.MapPolygonSeries.new(root, {
    geoJSON: am5geodata_worldLow
  })
);

var graticuleSeries = chart.series.push(am5map.GraticuleSeries.new(root, {}));
graticuleSeries.mapLines.template.setAll({
  stroke: root.interfaceColors.get("alternativeBackground"),
  strokeOpacity: 0.08
});

// Create line series for trajectory lines
// https://www.amcharts.com/docs/v5/charts/map-chart/map-line-series/
var lineSeries = chart.series.push(am5map.MapLineSeries.new(root, {}));
lineSeries.mapLines.template.setAll({
  stroke: root.interfaceColors.get("alternativeBackground"),
  strokeOpacity: 0.6
});

// Create point series for markers
// https://www.amcharts.com/docs/v5/charts/map-chart/map-point-series/
var originSeries = chart.series.push(
  am5map.MapPointSeries.new(root, { idField: "id" })
);

originSeries.bullets.push(function () {
  var circle = am5.Circle.new(root, {
    radius: 7,
    tooltipText: "{title}\n{geometry.coordinates}",
    cursorOverStyle: "pointer",
    tooltipY: 0,
    fill: am5.color(0xffba00),
    stroke: root.interfaceColors.get("background"),
    strokeWidth: 2
  }); 

  circle.events.on("click", function (e) {
    selectOrigin(e.target.dataItem.get("id"));
  });
  return am5.Bullet.new(root, {
    sprite: circle
  });
});

// destination series
var destinationSeries = chart.series.push(am5map.MapPointSeries.new(root, {}));

destinationSeries.bullets.push(function () {
  var circle = am5.Circle.new(root, {
    radius: 5,
    tooltipText: "{title}\n{geometry.coordinates}",
    tooltipY: 0,
    fill: am5.color(0xffba00),
    stroke: root.interfaceColors.get("background"),
    strokeWidth: 2
  });

  return am5.Bullet.new(root, {
    sprite: circle
  });
});

var originCities = [
  {
      id: "athens",
      title: "Athens",
      geometry: { type: "Point", coordinates: [23.7166, 37.9792] },
      destinations : ['madrid','rabat'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
    },
  {
    id: "london",
    title: "London",
    destinations: ['new york','oslo','paris','lisbon'],
    geometry: { type: "Point", coordinates: [-0.1262, 51.5002] },
    zoomLevel: 2.74,
    zoomPoint: { longitude: -20.1341, latitude: 49.1712 }
  },
  {
    id: "oslo",
      title: "Oslo",
      geometry: { type: "Point", coordinates: [10.7387, 59.9138] },
      destinations : ['lisbon','moscow'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
  },
  {
    id: "lisbon",
      title: "Lisbon",
      geometry: { type: "Point", coordinates: [-9.1355, 38.7072] },
      destinations : ['oslo','london'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
  },
  {
      id: "moscow",
      title: "Moscow",
      geometry: { type: "Point", coordinates: [37.6176, 55.7558] },
      destinations : ['kiev'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
  },
  {
      id: "madrid",
      title: "Madrid",
      geometry: { type: "Point", coordinates: [-3.7033, 40.4167] },
      destinations : ['rabat','oslo','paris'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
  },
  {
      id: "stockholm",
      title: "Stockholm",
      geometry: { type: "Point", coordinates: [18.0645, 59.3328] },
      destinations : ['madrid','lisbon'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
    }, {
      id: "kiev",
      title: "Kiev",
      geometry: { type: "Point", coordinates: [30.5367, 50.4422] },
      destinations : ['moscow','stockholm'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
    }, {
      id: "paris",
      title: "Paris",
      geometry: { type: "Point", coordinates: [2.3510, 48.8567] },
      destinations : ['rabat','madrid','rabat','london'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
    }, {
      id: "new york",
      title: "New York",
      geometry: { type: "Point", coordinates: [-74, 40.43] },
      destinations : ['rabat','london'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
    },{
      id:"rabat",
      title:"Rabat",
      geometry:{type:"Point", coordinates:[-6.8704,33.9905] },
      destinations : ['new york','madrid','paris'],
      zoomLevel: 4.92,
    zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
    
    },{
        id: "tunis",
        title: "Tunis",
        geometry:{type:"Point", coordinates:[10.1761,36.8117] },
        destinations : ['algiers','athens','rabat'],
        zoomLevel: 4.92,
        zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
      
      },{
        id : "algiers",
        title: "Algiers",
        geometry:{type:"Point", coordinates:[3.0597,36.7755] },
        destinations : ['madrid','paris','athens','tunis'],
        zoomLevel: 4.92,
        zoomPoint: { longitude: 15.4492, latitude: 50.2631 }
    }
];

var destinationCities = [
  
  {
    id: "athens",
    title: "Athens",
    geometry: { type: "Point", coordinates: [23.7166, 37.9792] }
  },
  {
    id: "oslo",
    title: "Oslo",
    geometry: { type: "Point", coordinates: [10.7387, 59.9138] }
  },
  {
    id: "lisbon",
    title: "Lisbon",
    geometry: { type: "Point", coordinates: [-9.1355, 38.7072] }
  },
  {
    id: "moscow",
    title: "Moscow",
    geometry: { type: "Point", coordinates: [37.6176, 55.7558] }
  },
  {
    id: "madrid",
    title: "Madrid",
    geometry: { type: "Point", coordinates: [-3.7033, 40.4167] }
  },
  {
    id: "stockholm",
    title: "Stockholm",
    geometry: { type: "Point", coordinates: [18.0645, 59.3328] }
  },
  {
    id: "kiev",
    title: "Kiev",
    geometry: { type: "Point", coordinates: [30.5367, 50.4422] }
  },
  {
    id: "paris",
    title: "Paris",
    geometry: { type: "Point", coordinates: [2.351, 48.8567] }
  },
  {
    id: "new york",
    title: "New York",
    geometry: { type: "Point", coordinates: [-74, 40.43] }
  }
];

originSeries.data.setAll(originCities);
destinationSeries.data.setAll(destinationCities);

function selectOrigin(id) {
  currentId = id;
  var dataItem = originSeries.getDataItemById(id);
  var dataContext = dataItem.dataContext;
  chart.zoomToGeoPoint(dataContext.zoomPoint, dataContext.zoomLevel, true);

  var destinations = dataContext.destinations;
  var lineSeriesData = [];
  var originLongitude = dataItem.get("longitude");
  var originLatitude = dataItem.get("latitude");
  
  am5.array.each(destinations, function (did) {
    var destinationDataItem = destinationSeries.getDataItemById(did);

    if (!destinationDataItem) {
      destinationDataItem = originSeries.getDataItemById(did);
    }

    lineSeriesData.push({
      
      geometry: {
        type: "LineString",
        coordinates: [
          [originLongitude, originLatitude],
          [
            destinationDataItem.get("longitude"),
            destinationDataItem.get("latitude")
          ]
        ]
      }
    });
    

  });
  lineSeries.data.setAll(lineSeriesData);
  
}

var currentId = "london";

destinationSeries.events.on("datavalidated", function () {
  selectOrigin(currentId);
});

// Make stuff animate on load
chart.appear(1000, 100);

}); // end am5.ready()
</script>
<!-- HTML -->
  <button class="btn  btn-primary" onclick="window.location.href='./';"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-left" viewBox="0 0 16 16">
  <path fill-rule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"/>
</svg>Retour</button> 
<div id="chartdiv"></div>