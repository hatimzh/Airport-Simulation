<!DOCTYPE html>
<!-- Styles -->
<%@page import="java.util.concurrent.TimeUnit"%>
<%@page import="java.awt.desktop.ScreenSleepEvent"%>
<head><title>mouvement d'avion</title></head>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ" crossorigin="anonymous">
<style>
  #chartdiv {
    width: 100%;
    height: 500px;
  }
  </style>
  
  <!-- Resources -->
  <script src="https://cdn.amcharts.com/lib/5/index.js"></script>
  <script src="https://cdn.amcharts.com/lib/5/map.js"></script>
  <script src="https://cdn.amcharts.com/lib/5/geodata/worldLow.js"></script>
  <script src="https://cdn.amcharts.com/lib/5/themes/Animated.js"></script>
  <script src="PriorityQueue.js"></script>
  
  <!-- Chart code -->
  <script>

  //input :
  cityorigid="<%= request.getParameter("start")%>";//'moscow';
  citydestid="<%=request.getParameter("destination")%>";//'rabat';
  
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
  var chart = root.container.children.push(am5map.MapChart.new(root, {
    panX: "translateX",
    panY: "translateY",
    projection: am5map.geoMercator()
  }));
  
  var cont = chart.children.push(am5.Container.new(root, {
    layout: root.horizontalLayout,
    x: 20,
    y: 40
  }));
  
  
  // Add labels and controls
  cont.children.push(am5.Label.new(root, {
    centerY: am5.p50,
    text: "Map"
  }));
  
  var switchButton = cont.children.push(am5.Button.new(root, {
    themeTags: ["switch"],
    centerY: am5.p50,
    icon: am5.Circle.new(root, {
      themeTags: ["icon"]
    })
  }));
  
  switchButton.on("active", function() {
    if (!switchButton.get("active")) {
      chart.set("projection", am5map.geoMercator());
      chart.set("panX", "translateX");
      chart.set("panY", "translateY");
    }
    else {
      chart.set("projection", am5map.geoOrthographic());
      chart.set("panX", "rotateX");
      chart.set("panY", "rotateY");
    }
  });
  
  cont.children.push(am5.Label.new(root, {
    centerY: am5.p50,
    text: "Globe"
  }));
  
  // Create main polygon series for countries
  // https://www.amcharts.com/docs/v5/charts/map-chart/map-polygon-series/
  var polygonSeries = chart.series.push(am5map.MapPolygonSeries.new(root, {
    geoJSON: am5geodata_worldLow
  }));
  
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
  
  // destination series
  var citySeries = chart.series.push(
    am5map.MapPointSeries.new(root, {})
  );
  
  citySeries.bullets.push(function() {
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
  
  // arrow series
  var arrowSeries = chart.series.push(
    am5map.MapPointSeries.new(root, {})
  );
  
  arrowSeries.bullets.push(function() {
    var arrow = am5.Graphics.new(root, {
      fill: am5.color(0x000000),
      stroke: am5.color(0x000000),
      draw: function (display) {
        display.moveTo(0, -3);
        display.lineTo(8, 0);
        display.lineTo(0, 3);
        display.lineTo(0, -3);
      }
    });
  
    return am5.Bullet.new(root, {
      sprite: arrow
    });
  });
  var itt=0;
  var cities = [
    {
      id: "london",
      title: "London",
      geometry: { type: "Point", coordinates: [-0.1262, 51.5002] },
      destinations : ['new york','oslo','paris','lisbon']
    },
     {
      id: "athens",
      title: "Athens",
      geometry: { type: "Point", coordinates: [23.7166, 37.9792] },
      destinations : ['madrid','rabat']
    }, {
      id: "oslo",
      title: "Oslo",
      geometry: { type: "Point", coordinates: [10.7387, 59.9138] },
      destinations : ['lisbon','moscow']
    }, {
      id: "lisbon",
      title: "Lisbon",
      geometry: { type: "Point", coordinates: [-9.1355, 38.7072] },
      destinations : ['oslo','london']
    }, {
      id: "moscow",
      title: "Moscow",
      geometry: { type: "Point", coordinates: [37.6176, 55.7558] },
      destinations : ['kiev']
    }, {
      id: "madrid",
      title: "Madrid",
      geometry: { type: "Point", coordinates: [-3.7033, 40.4167] },
      destinations : ['rabat','oslo','paris']
    }, {
      id: "stockholm",
      title: "Stockholm",
      geometry: { type: "Point", coordinates: [18.0645, 59.3328] },
      destinations : ['madrid','lisbon']
    }, {
      id: "kiev",
      title: "Kiev",
      geometry: { type: "Point", coordinates: [30.5367, 50.4422] },
      destinations : ['moscow','stockholm']
    }, {
      id: "paris",
      title: "Paris",
      geometry: { type: "Point", coordinates: [2.3510, 48.8567] },
      destinations : ['rabat','madrid','rabat','london']
    }, {
      id: "new york",
      title: "New York",
      geometry: { type: "Point", coordinates: [-74, 40.43] },
      destinations : ['rabat','london']
    },{
        id:"rabat",
        title:"Rabat",
        geometry:{type:"Point", coordinates:[-6.8704,33.9905] },
        destinations : ['new york','madrid','paris','tunis']
      
      },{
          id: "tunis",
          title: "Tunis",
          geometry:{type:"Point", coordinates:[10.1761,36.8117] },
          destinations : ['algiers','athens','rabat']
        
        },{
          id : "algiers",
          title: "Algiers",
          geometry:{type:"Point", coordinates:[3.0597,36.7755] },
          destinations : ['madrid','paris','athens','tunis']
      }//zyada cities :
    
  ];
  
  citySeries.data.setAll(cities);

  // get coordinates :
  function getCityGeometry(cityId) {
    // Find the city object with the given id
    var city = cities.find(function(city) {
      return city.id === cityId;
    });

    // Return the geometry object if the city is found
    if (city) {
      return city.geometry.coordinates;
    }

    // Return null if the city is not found
    return null;
    }

    //distance btween 2 cities :
    function deg2rad(deg) {
      return deg * (Math.PI/180)
    }
    
    function getDistanceFromLatLonInKm(City1,City2) {
      lon1=getCityGeometry(City1)[0];lat1=getCityGeometry(City1)[1];
      lon2=getCityGeometry(City2)[0];lat2=getCityGeometry(City2)[1];
      const R = 6371; // Radius of the earth in km
      const dLat = deg2rad(lat2 - lat1);  // deg2rad below
      const dLon = deg2rad(lon2 - lon1);
      const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      const d = R * c; // Distance in km
      return d;
    }

    // Dijkstra function to find the shortest path
function dijkstra(graph, start, destination) {
  // Create an empty priority queue to store the nodes to visit
  var queue = new PriorityQueue();

  // Create an empty object to store the distances
  var distances = {};

  // Create an empty object to store the previous nodes
  var previous = {};

  // Initialize the distances with Infinity and set the start node distance to 0
  for (var city in graph) {
    distances[city] = Infinity;
  }
  distances[start] = 0;

  // Enqueue the start node with priority 0
  queue.enqueue(start, 0);

  // While the queue is not empty
  while (!queue.isEmpty()) {
    // Dequeue the node with the highest priority
    var currentCity = queue.dequeue().element;

    // If the current node is the destination, break the loop
    if (currentCity === destination) {
      break;
    }

    // Get the neighbors of the current node
    var neighbors = graph[currentCity];

    // Iterate through each neighbor
    for (var neighbor in neighbors) {
      // Calculate the new distance from the start node to the neighbor
      var distance = distances[currentCity] + neighbors[neighbor];

      // If the new distance is shorter than the current distance, update it
      if (distance < distances[neighbor]) {
        distances[neighbor] = distance;
        previous[neighbor] = currentCity;

        // Enqueue the neighbor with the new distance as priority
        queue.enqueue(neighbor, distance);
      }
    }
  }

  // Build the shortest path from start to destination
  var path = [];
  var current = destination;
  while (current !== start) {
    path.unshift(current);
    current = previous[current];
  }
  path.unshift(start);

  // Return the shortest path and distance
  return {
    path: path,
    distance: distances[destination],
  };
}
    //fin dijkstra function.
    
      //Dijkstra graphe:
      var graph = {
	  london: {
		    newyork: getDistanceFromLatLonInKm("london", "new york"),
		    oslo: getDistanceFromLatLonInKm("london", "oslo"),
		    paris: getDistanceFromLatLonInKm("london", "paris"),
		    lisbon: getDistanceFromLatLonInKm("london", "lisbon"),
		  },
		  newyork: {
		    london: getDistanceFromLatLonInKm("new york", "london"),
		    rabat: getDistanceFromLatLonInKm("new york", "rabat"),
		  },
		  oslo: {
		    lisbon: getDistanceFromLatLonInKm("oslo", "lisbon"),
		    moscow: getDistanceFromLatLonInKm("oslo", "moscow"),
		  },
		  lisbon: {
		    oslo: getDistanceFromLatLonInKm("lisbon", "oslo"),
		    london: getDistanceFromLatLonInKm("lisbon", "london"),
		    stockholm: getDistanceFromLatLonInKm("lisbon", "stockholm"),
		  },
		  moscow: {
		    kiev: getDistanceFromLatLonInKm("moscow", "kiev"),
		  },
		  madrid: {
		    rabat: getDistanceFromLatLonInKm("madrid", "rabat"),
		    oslo: getDistanceFromLatLonInKm("madrid", "oslo"),
		    paris: getDistanceFromLatLonInKm("madrid", "paris"),
		    stockholm: getDistanceFromLatLonInKm("madrid", "stockholm"),
		  },
		  rabat: {
		    athens: getDistanceFromLatLonInKm("rabat", "athens"),
		    madrid: getDistanceFromLatLonInKm("rabat", "madrid"),
		    newyork: getDistanceFromLatLonInKm("rabat", "new york"),
		    paris: getDistanceFromLatLonInKm("rabat", "paris"),
		    tunis:getDistanceFromLatLonInKm("rabat", "tunis"),
		  },
		  kiev: {
		    moscow: getDistanceFromLatLonInKm("kiev", "moscow"),
		    stockholm: getDistanceFromLatLonInKm("kiev", "stockholm"),
		  },
		  paris: {
		    rabat: getDistanceFromLatLonInKm("paris", "rabat"),
		    madrid: getDistanceFromLatLonInKm("paris", "madrid"),
		    london: getDistanceFromLatLonInKm("paris", "london"),
		  },
		  stockholm: {
		    madrid: getDistanceFromLatLonInKm("stockholm", "madrid"),
		    lisbon: getDistanceFromLatLonInKm("stockholm", "lisbon"),
		    kiev: getDistanceFromLatLonInKm("stockholm", "kiev"),
		  },
		  tunis:{
		    rabat :getDistanceFromLatLonInKm("tunis","rabat"),
		    athens :getDistanceFromLatLonInKm("tunis","athens"),
		    algiers :getDistanceFromLatLonInKm("tunis","algiers"),
		  },
		  algiers:{
		    tunis:getDistanceFromLatLonInKm("algiers","tunis"),
		    madrid:getDistanceFromLatLonInKm("algiers","madrid"),
		    paris:getDistanceFromLatLonInKm("algiers","paris"),
		    athens:getDistanceFromLatLonInKm("algiers","athens"),
	
		  }
		};



    // fin graphe
    var start = cityorigid;
    var destination = citydestid;

    var result = dijkstra(graph, start, destination);

  //function get destination :
  function getdest(cityId) {
    // Find the city object with the given id
      var city = cities.find(function(city) {
        return city.id === cityId;
      });

      // Return the geometry object if the city is found
      if (city) {
        return city.destinations;
      }

      // Return null if the city is not found
      return null;
      }


    
  // prepare line series data

  var destinations = getdest(cityorigid);
  // London coordinates
  var originLongitude =getCityGeometry(cityorigid)[0];//-0.1262;//-6.8704;
  var originLatitude = getCityGeometry(cityorigid)[1];//51.5002;//33.9905;

  {
  am5.array.each(destinations, function (did) {
    
    var destinationDataItem = citySeries.getDataItemById(did);
    var lineDataItem = lineSeries.pushDataItem({ geometry: { type: "LineString", coordinates: [[originLongitude, originLatitude], [destinationDataItem.get("longitude"), destinationDataItem.get("latitude")]] } });
    // airplane:
    let planeSeries = chart.series.push(am5map.MapPointSeries.new(root, {}));
    
    let plane = am5.Graphics.new(root, {
      svgPath:
        "m2,106h28l24,30h72l-44,-133h35l80,132h98c21,0 21,34 0,34l-98,0 -80,134h-35l43,-133h-71l-24,30h-28l15,-47",
      scale: 0.06,
      centerY: am5.p50,
      centerX: am5.p50,
      fill: am5.color(0x000000),
      tooltipText : result.path.join(" -> ")
    });
    
    planeSeries.bullets.push(function() {
      var container = am5.Container.new(root, {});
      container.children.push(plane);
      return am5.Bullet.new(root, { sprite: container });
    });
    
    let planeDataItem = planeSeries.pushDataItem({
      lineDataItem: lineSeries.pushDataItem({ geometry: { type: "LineString", coordinates: [[originLongitude, originLatitude], getCityGeometry(result.path[1])] } }),
      positionOnLine: 0,
      autoRotate: true
    });
    planeDataItem.dataContext = {};
    
    planeDataItem.animate({
      key: "positionOnLine",
      to: 1,
      duration: <%= request.getParameter("duration")%>000,
      loops: 1,
      easing: am5.ease.yoyo(am5.ease.linear)
    });
    
    walo(1);
    
    arrowSeries.pushDataItem({
      lineDataItem: lineDataItem,
      positionOnLine: 0.5,
      autoRotate: true
    });
    //functions :
    function chemin(i){
      arrowSeries.pushDataItem({
        lineDataItem: lineSeries.pushDataItem({ geometry: { type: "LineString", coordinates: [getCityGeometry(result.path[i]),getCityGeometry(result.path[i+1])] } }),
        positionOnLine: 0.5,
        autoRotate: true
        });
        planeSeries.pushDataItem({
        lineDataItem: lineSeries.pushDataItem({ geometry: { type: "LineString", coordinates: [getCityGeometry(result.path[i+1]),getCityGeometry(result.path[i])] } })
        ,positionOnLine: planeDataItem.dataContext.prevPosition,
        autoRotate: true
        });
        
        
    }
    function walo(x){
	  
	  planeDataItem.on("positionOnLine", (value) => {
	    
	  if (planeDataItem.dataContext.prevPosition < value ) {
	    
	    plane.set("rotation", 0);
	  }
	  
	  if (planeDataItem.dataContext.prevPosition > value ) {
		  
		  for(var i=1; i<result.path.length-1; i++){
		        chemin(i);
		      }
	    plane.set("rotation", -180);
	    
	  }
	  
	  planeDataItem.dataContext.prevPosition = value;
	  
	  });
	  
	}
    
    
  })
  }

  console.log('walo ',itt);
  polygonSeries.events.on("datavalidated", function () {
    chart.zoomToGeoPoint({ longitude: -0.1262, latitude: 51.5002 }, 3);
  })
  
  
  // Make stuff animate on load
  chart.appear(1000, 100);

  }); // end am5.ready()
  </script>
  <button class="btn  btn-primary" onclick="window.location.href='./';"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-left" viewBox="0 0 16 16">
  <path fill-rule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"/>
</svg>Retour</button> 
  <!-- HTML -->
  <div id="chartdiv"></div>
  