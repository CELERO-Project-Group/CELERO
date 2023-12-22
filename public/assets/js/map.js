
// TODO if there is already coordinates it should pin a mark on the map
function map_location_chooser() {
    var map = L.map('map').setView([47.5348, 7.6419], 8);
    map.fitWorld().zoomIn();

    map.on('resize', function (e) {
        map.fitWorld({ reset: true }).zoomIn();
    });
    mapLink =
        '<a href="http://openstreetmap.org">OpenStreetMap</a>';
    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);


    // OnClick Marker
    var marker = null; // Variable to store the marker

    // OnClick Marker
    map.on('click', function (e) {
        var lat = e.latlng.lat;
        var lng = e.latlng.lng;

        // Remove the existing marker, if any
        if (marker) {
            map.removeLayer(marker);
        }

        // Add a new marker at the clicked position
        marker = L.marker([lat, lng]).addTo(map).on('click', function (e) {
            map.removeLayer(marker); // Remove the marker on its own click
        });

        //store the coordinates and export it
        markerLat = lat;
        markerLng = lng;

        // Update the input fields with the marker coordinates
        document.getElementById('latId').value = markerLat;
        document.getElementById('longId').value = markerLng;

        document.getElementById('lat').value = markerLat;
        document.getElementById('long').value = markerLng;
    });

}