package controller;

import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;

public class Dijkstra {

    private static double deg2rad(double deg) {
        return deg * (Math.PI / 180);
    }

    private static double getDistanceFromLatLonInKm(String city1, String city2) {
        double lon1 = getCityGeometry(city1)[0];
        double lat1 = getCityGeometry(city1)[1];
        double lon2 = getCityGeometry(city2)[0];
        double lat2 = getCityGeometry(city2)[1];
        final double R = 6371; // Radius of the earth in km
        double dLat = deg2rad(lat2 - lat1);  // deg2rad below
        double dLon = deg2rad(lon2 - lon1);
        double a =
                Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
                                Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double d = R * c; // Distance in km
        return d;
    }

    private static double[] getCityGeometry(String city) {
        // Implement this method to retrieve the geometry (longitude and latitude) of a city
        // Return the geometry as an array [longitude, latitude]
        // Example implementation:
        // double[] geometry = new double[2];
        // // Retrieve the geometry using city name or other identifier
        // geometry[0] = longitude; // Assign the longitude value
        // geometry[1] = latitude; // Assign the latitude value
        // return geometry;

        // Placeholder implementation
        return new double[]{0.0, 0.0};
    }

    private static Map<String, Map<String, Double>> createGraph() {
        Map<String, Map<String, Double>> graph = new HashMap<>();

        Map<String, Double> londonDistances = new HashMap<>();
        londonDistances.put("newyork", getDistanceFromLatLonInKm("london", "new york"));
        londonDistances.put("oslo", getDistanceFromLatLonInKm("london", "oslo"));
        londonDistances.put("paris", getDistanceFromLatLonInKm("london", "paris"));
        londonDistances.put("lisbon", getDistanceFromLatLonInKm("london", "lisbon"));
        graph.put("london", londonDistances);

        Map<String, Double> newYorkDistances = new HashMap<>();
        newYorkDistances.put("london", getDistanceFromLatLonInKm("new york", "london"));
        newYorkDistances.put("rabat", getDistanceFromLatLonInKm("new york", "rabat"));
        graph.put("newyork", newYorkDistances);

        // Add distances for other cities to the graph similarly

        return graph;
    }

    private static Map<String, Object> dijkstra(Map<String, Map<String, Double>> graph, String start, String destination) {
        PriorityQueue<QueueElement> queue = new PriorityQueue<>();

        Map<String, Double> distances = new HashMap<>();
        Map<String, String> previous = new HashMap<>();

        for (String city : graph.keySet()) {
            distances.put(city, Double.POSITIVE_INFINITY);
        }
        distances.put(start, 0.0);

        queue.add(new QueueElement(start, 0.0));

        while (!queue.isEmpty()) {
            QueueElement currentElement = queue.poll();
            String currentCity = currentElement.city;

            if (currentCity.equals(destination)) {
                break;
            }

            Map<String, Double> neighbors = graph.get(currentCity);
            for (String neighbor : neighbors.keySet()) {
                double distance = distances.get(currentCity) + neighbors.get(neighbor);

                if (distance < distances.get(neighbor)) {
                    distances.put(neighbor, distance);
                    previous.put(neighbor, currentCity);

                    queue.add(new QueueElement(neighbor, distance));
                }
            }
        }

        String[] path = buildShortestPath(previous, start, destination);

        Map<String, Object> result = new HashMap<>();
        result.put("path", path);
        result.put("distance", distances.get(destination));

        return result;
    }

    private static String[] buildShortestPath(Map<String, String> previous, String start, String destination) {
        // Build the shortest path from start to destination
        // Implement this method to construct the shortest path as an array of cities
        // Return the shortest path as an array

        // Placeholder implementation
        return new String[]{start, destination};
    }

    private static class QueueElement implements Comparable<QueueElement> {
        private String city;
        private double priority;

        public QueueElement(String city, double priority) {
            this.city = city;
            this.priority = priority;
        }

        @Override
        public int compareTo(QueueElement other) {
            return Double.compare(this.priority, other.priority);
        }
    }

    public static void main(String[] args) {
        String cityorigid = "london";
        String citydestid = "paris";

        Map<String, Map<String, Double>> graph = createGraph();

        Map<String, Object> result = dijkstra(graph, cityorigid, citydestid);

        System.out.println("Shortest path: " + result.get("path"));
        System.out.println("Distance: " + result.get("distance"));
    }
}
