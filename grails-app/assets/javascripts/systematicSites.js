'use strict';

var SystematicSiteViewModel = function (mapContainerId, site, mapOptions) {
    var self = $.extend(this, new Documents());

    // var pointOfInterestIcon = ALA.MapUtils.createIcon("https://maps.google.com/mapfiles/marker_yellow.png");
    // var pointOfInterestMarkers = new L.FeatureGroup();
    // var latSubscriber = null;
    // var lngSubscriber = null;

    self.site = ko.observable({
        name: ko.observable(),
        siteId: ko.observable(),
        externalId: ko.observable(),
        type: ko.observable(),
        area: ko.observable(),
        description: ko.observable(),
        notes: ko.observable(),
        projects: ko.observableArray(),
        extent: ko.observable({
            source: ko.observable(),
            geometry:  ko.observable({
                decimalLatitude: ko.observable(),
                decimalLongitude: ko.observable(),

                type: ko.observable(),
                radius: ko.observable(),
                areaKmSq: ko.observable(),
                coordinates: ko.observable(),
                centre: ko.observable(),

                bbox: ko.observable(),
                pid: ko.observable(),
                name: ko.observable(),
                layerName: ko.observable()
            })
        })
    });
    self.pointsOfInterest = ko.observableArray();
    self.transectParts = ko.observableArray();
    self.showPointAttributes = ko.observable(false);
    self.allowPointsOfInterest = ko.observable(mapOptions.allowPointsOfInterest || false);
    self.displayAreaInReadableFormat = null;

    self.site().extent().geometry().areaKmSq.subscribe(function(val){
        self.site().area(val)
    });

    self.loadSite = function (site) {
        var siteModel = self.site();
        siteModel.name(exists(site, "name"));
        siteModel.siteId(exists(site, "siteId"));
        siteModel.type(exists(site, "type"));
        siteModel.area(exists(site, "area"));
        siteModel.description(exists(site, "description"));
        siteModel.notes(exists(site, "notes"));
        siteModel.projects(site.projects || []);

        if (site.extent) {
            self.site().extent().source(exists(site.extent, "source"));
            self.loadGeometry(site.extent.geometry || {});
        } else {
            self.site().extent().source('');
            self.loadGeometry({});
        }

        if(self.site().extent().geometry().areaKmSq()){
            self.site().area(self.site().extent().geometry().areaKmSq())
        }

        if (!_.isEmpty(site.poi)) {
            site.poi.forEach(function (poi) {
                createPointOfInterest(poi, self.hasPhotoPointDocuments(poi))
            });
        }

        // systematic
        if (!_.isEmpty(site.transectParts)) {
            site.transectParts.forEach(function (transectPart) {
                createTransectPart(transectPart, self.hasPhotoPointDocuments(transectPart))
            });
        }

        self.displayAreaInReadableFormat = ko.computed(function(){
            if(self.site().area()){
                return convertKMSqToReadableUnit(self.site().area())
            }
        });
    };

    self.hasPhotoPointDocuments = function (poi) {
        if (!self.site.documents) {
            return;
        }
        var hasDoc = false;
        $.each(self.site.documents, function (i, doc) {
            if (doc.poiId === poi.poiId) {
                hasDoc = true;
                return false;
            }
        });
        return hasDoc;
    };

    self.loadGeometry = function (geometry) {
        var geometryObservable = self.site().extent().geometry();
        geometryObservable.decimalLatitude(exists(geometry, 'decimalLatitude')),
        geometryObservable.decimalLongitude(exists(geometry, 'decimalLongitude')),
        geometryObservable.datum(exists(geometry, 'datum')),
        geometryObservable.type(exists(geometry, 'type')),
        geometryObservable.radius(exists(geometry, 'radius')),
        geometryObservable.areaKmSq(exists(geometry, 'areaKmSq')),
        geometryObservable.coordinates(exists(geometry, 'coordinates')),
        geometryObservable.centre(exists(geometry, 'centre')),
        geometryObservable.bbox(exists(geometry, 'bbox')),
        geometryObservable.pid(exists(geometry, 'pid')),
        geometryObservable.name(exists(geometry, 'name')),
        geometryObservable.layerName(exists(geometry, 'layerName'))

        latSubscriber = geometryObservable.decimalLatitude.subscribe(updateSiteMarkerPosition);
        lngSubscriber = geometryObservable.decimalLongitude.subscribe(updateSiteMarkerPosition);

        if (!_.isEmpty(geometry) && self.site().extent().source() != 'none') {
            var validGeoJson = Biocollect.MapUtilities.featureToValidGeoJson(geometry);
            self.map.setGeoJSON(validGeoJson);
            self.showPointAttributes(geometry.type == "Point");
        }
        return geometryObservable;
    };

    self.newPointOfInterest = function () {
        var centre = self.map.getCentre();
        createPointOfInterest({
            name: "Point of interest #" + (self.pointsOfInterest().length + 1),
            geometry: {
                decimalLatitude: centre.lat,
                decimalLongitude: centre.lng
            }
        }, false);
    };

    // systematic
    self.newTransectPart = function () {
        var centre = self.map.getCentre();
        createTransectPart({
            name: "S" + (self.transectParts().length + 1),
            geometry: {
                decimalLatitude: centre.lat,
                decimalLongitude: centre.lng
            }
        }, false);
    };

    self.refreshCoordinates = function () {
        updateSiteMarkerPosition();
    };

    function createPointOfInterest(poi, hasDocuments) {
        var pointOfInterest = new PointOfInterest(poi, hasDocuments);

        pointOfInterest.geometry().decimalLatitude.subscribe(self.renderPointsOfInterest);
        pointOfInterest.geometry().decimalLongitude.subscribe(self.renderPointsOfInterest);

        pointOfInterest.marker = ALA.MapUtils.createMarker(poi.geometry.decimalLatitude, poi.geometry.decimalLongitude, pointOfInterest.name, {
            icon: pointOfInterestIcon,
            draggable: true
        });
        pointOfInterest.marker.on("dragend", pointOfInterest.dragEvent);
        pointOfInterestMarkers.addLayer(pointOfInterest.marker);

        self.pointsOfInterest.push(pointOfInterest);
    }
    // systematic
    function createTransectPart(part, hasDocuments) {

        var transectPart = new TransectPart(part, hasDocuments);
        getTransectPart();

        transectPart.geometry().decimalLatitude.subscribe(self.renderPointsOfInterest);
        transectPart.geometry().decimalLongitude.subscribe(self.renderPointsOfInterest);

        transectPart.marker = ALA.MapUtils.createMarker(part.geometry.decimalLatitude, part.geometry.decimalLongitude, transectPart.name, {
            icon: pointOfInterestIcon,
            draggable: true
        });
        transectPart.marker.on("dragend", transectPart.dragEvent);
        pointOfInterestMarkers.addLayer(transectPart.marker);

        self.transectParts.push(transectPart);
        console.log(self.transectParts);
    }

    self.renderPointsOfInterest = function () {
        pointOfInterestMarkers.clearLayers();

        self.pointsOfInterest().forEach(function (pointOfInterest) {
            var marker  = ALA.MapUtils.createMarker(
                pointOfInterest.geometry().decimalLatitude(),
                pointOfInterest.geometry().decimalLongitude(),
                pointOfInterest.name,
                {icon: pointOfInterestIcon, draggable: true}
            );

            marker.on("dragend", pointOfInterest.dragEvent);

            pointOfInterestMarkers.addLayer(marker);
        });
    };

    // systematic 
    self.renderTransectParts = function () {
        
    };

    self.removePointOfInterest = function (pointOfInterest) {
        if (pointOfInterest.hasPhotoPointDocuments) {
            return;
        }
        self.pointsOfInterest.remove(pointOfInterest);
        self.renderPointsOfInterest();
    };

    self.toJS = function() {
        var js = ko.toJS(self.site);

        // legacy support - it was possible to have no extent for a site. This step will delete geometry before saving.
        if(js.extent.source == 'none'){
            delete js.extent.geometry;
        }

        js.poi = [];
        self.pointsOfInterest().forEach(function (poi) {
            js.poi.push(poi.toJSON())
        });
        js.geoIndex = Biocollect.MapUtilities.constructGeoIndexObject(js);

        //systematic 
        js.transectParts = [];
        self.transectParts().forEach(function (transectPart) {
            js.transectParts.push(transectPart.toJSON())
        });
        js.geoIndex = Biocollect.MapUtilities.constructGeoIndexObject(js);

        return js;
    };

    self.modelAsJSON = function () {
        return JSON.stringify(self.toJS());
    };

    self.saved = function () {
        return self.site().siteId();
    };

    self.isValid = function(mandatory) {
        var valid = true;

        if (mandatory) {
            var js = self.toJS();
            valid = js && js.extent && js.extent.geometry && js.extent.geometry.type && js.extent.geometry.type != null && js.extent.geometry.type != "";
        }

        return valid;
    };

    function initialiseViewModel() {
        var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
        var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
        var options =  {
            autoZIndex: false,
            preserveZIndex: true,
            addLayersControlHeading: true,
            maxZoom: 20,
            wmsLayerUrl: mapOptions.spatialWms + "/wms/reflect?",
            wmsFeatureUrl: mapOptions.featureService + "?featureId=",
            drawOptions: mapOptions.drawOptions,
            showReset: false,
            baseLayer: baseLayersAndOverlays.baseLayer,
            otherLayers: baseLayersAndOverlays.otherLayers,
            overlays: baseLayersAndOverlays.overlays,
            overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault
        };

        for (var option in mapOptions) {
            if (mapOptions.hasOwnProperty(option)){
                options[option] = mapOptions[option];
            }
        }

        if(mapOptions.readonly){
            var readonlyProps = {
                drawControl: false,
                singleMarker: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                draggableMarkers: false,
                showReset: false
            };
            for(var prop in readonlyProps){
                options[prop] = readonlyProps[prop]
            }
        }

        self.map = new ALA.Map(mapContainerId, options);

        if(!mapOptions.readonly){
            var regionSelector = Biocollect.MapUtilities.createKnownShapeMapControl(self.map, mapOptions.featuresService, mapOptions.regionListUrl);
            self.map.addControl(regionSelector);
        }

        self.map.addButton("<span class='fa fa-undo reset-map' title='Reset map'></span>", function () {
            self.map.resetMap();
            pointOfInterestMarkers.clearLayers();
            self.pointsOfInterest([]);
            self.transectParts([]);
            self.loadGeometry({});
            self.loadSite(site || {});
        }, "bottomright");



        self.map.registerListener("draw:created", function (event) {
            if (event.layerType == ALA.MapConstants.LAYER_TYPE.MARKER) {
                updatePointLatLng(event.layer.getLatLng().lat, event.layer.getLatLng().lng);
            }
        });

        // We'll track the points of interest as a separate feature group manually attached to the underlying map
        // implementation so that we can take advantage of the single-layer controls provided by ALA.Map to control the
        // site region.
        self.map.getMapImpl().addLayer(pointOfInterestMarkers);

        self.loadSite(site);

        self.map.subscribe(listenToSiteChanges);
    }

    function getSiteMarker() {
        return self.map.getAllMarkers().length == 1 ? self.map.getAllMarkers()[0] : null;
    }

    function listenToSiteChanges() {
        var siteMarker = getSiteMarker();

        if (siteMarker) {
            siteMarker.bindPopup(self.site().name());
            siteMarker.on("dragend", function (event) {
                updatePointLatLng(event.target.getLatLng().lat, event.target.getLatLng().lng);
            });
            updatePointLatLng(siteMarker.getLatLng().lat, siteMarker.getLatLng().lng);

            self.map.fitBounds();

            self.showPointAttributes(true);
        } else {
            var bounds = self.map.getBounds();
            updatePointLatLng(bounds ? bounds.getCenter().lat : null, bounds ? bounds.getCenter().lng : null);
            self.showPointAttributes(false);
        }

        updateGeometry();
    }

    function updatePointLatLng(lat, lng) {
        latSubscriber.dispose();
        lngSubscriber.dispose();
        if (self.site() && self.site().extent) {
            self.site().extent().geometry().decimalLatitude(lat);
            self.site().extent().geometry().decimalLongitude(lng);
            latSubscriber = self.site().extent().geometry().decimalLatitude.subscribe(updateSiteMarkerPosition);
            lngSubscriber = self.site().extent().geometry().decimalLongitude.subscribe(updateSiteMarkerPosition);
        }
    }

    function updateSiteMarkerPosition() {
        var siteMarker = getSiteMarker();

        var geometry = self.site().extent().geometry();
        if (siteMarker && geometry.decimalLatitude() && geometry.decimalLongitude()) {
            siteMarker.setLatLng(new L.LatLng(geometry.decimalLatitude(), geometry.decimalLongitude()));
            self.map.fitBounds();
        }
    }

    function updateGeometry() {
        var geoJson = self.map.getGeoJSON();

        if (geoJson && geoJson.features && geoJson.features.length > 0) {
            var feature = geoJson.features[0];
            var geometryType = feature.geometry.type;
            var latLng = null;
            var lat;
            var lng;
            var bounds = self.map.getBounds();
            if (geometryType === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
                // the ALA Map plugin uses valid GeoJSON, which specifies coordinates as [lng, lat]
                lat = feature.geometry.coordinates[1];
                lng = feature.geometry.coordinates[0];
                self.site().extent().geometry().centre(latLng);
            } else if (bounds) {
                lat = bounds.getCenter().lat;
                lng = bounds.getCenter().lng;
            }

            var geoType = determineExtentType(feature);
            self.site().extent().geometry().type(geoType);
            self.site().extent().source(geoType == "Point" ? "Point" : geoType == "pid" ? "pid" : "drawn");
            self.site().extent().geometry().radius(feature.properties.radius);

            // the feature created by a WMS layer will have the area in the 'area_km' property
            if (feature.properties.area_km) {
                self.site().extent().geometry().areaKmSq(feature.properties.area_km);
            } else {
                self.site().extent().geometry().areaKmSq(ALA.MapUtils.calculateAreaKmSq(feature));
            }
            self.site().extent().geometry().coordinates(feature.geometry.coordinates);

            self.site().extent().geometry().bbox(exists(feature.properties, 'bbox'));
            self.site().extent().geometry().pid(exists(feature.properties, 'pid'));
            self.site().extent().geometry().name(exists(feature.properties, 'name'));
            self.site().extent().geometry().fid(exists(feature.properties, 'fid'));
            self.site().extent().geometry().layerName(exists(feature.properties, 'fieldname'));

        } else {
            self.loadGeometry({});
        }
    }
    function getTransectPart() {
        var geoJson = self.map.getGeoJSON();

        if (geoJson && geoJson.features && geoJson.features.length > 0) {
            var feature = geoJson.features[0];
            var geometryType = feature.geometry.type;
            var latLng = null;
            var lat;
            var lng;
            var bounds = self.map.getBounds();
            if (geometryType === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
                // the ALA Map plugin uses valid GeoJSON, which specifies coordinates as [lng, lat]
                lat = feature.geometry.coordinates[1];
                lng = feature.geometry.coordinates[0];
                self.site().extent().geometry().centre(latLng);
            } else if (bounds) {
                lat = bounds.getCenter().lat;
                lng = bounds.getCenter().lng;
            }

            var geoType = determineExtentType(feature);
            self.site().extent().geometry().type(geoType);
            self.site().extent().source(geoType == "Point" ? "Point" : geoType == "pid" ? "pid" : "drawn");
            self.site().extent().geometry().radius(feature.properties.radius);

            // the feature created by a WMS layer will have the area in the 'area_km' property
            if (feature.properties.area_km) {
                self.site().extent().geometry().areaKmSq(feature.properties.area_km);
            } else {
                self.site().extent().geometry().areaKmSq(ALA.MapUtils.calculateAreaKmSq(feature));
            }
            self.site().extent().geometry().coordinates(feature.geometry.coordinates);

            self.site().extent().geometry().bbox(exists(feature.properties, 'bbox'));
            self.site().extent().geometry().pid(exists(feature.properties, 'pid'));
            self.site().extent().geometry().name(exists(feature.properties, 'name'));
            self.site().extent().geometry().fid(exists(feature.properties, 'fid'));
            self.site().extent().geometry().layerName(exists(feature.properties, 'fieldname'));

        } else {
            self.loadGeometry({});
        }
    }

    function determineExtentType(geoJsonFeature) {
        var type = null;

        if (geoJsonFeature.geometry.type === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
            if (geoJsonFeature.properties.radius) {
                type = ALA.MapConstants.DRAW_TYPE.CIRCLE_TYPE;
            } else {
                type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
            }
        } else if (geoJsonFeature.geometry.type === ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE) {
            if (geoJsonFeature.properties.pid) {
                type = "pid";
            } else {
                type = ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE;
            }
        } else if (geoJsonFeature.geometry.type == ALA.MapConstants.DRAW_TYPE.LINE_TYPE) {
            type = geoJsonFeature.geometry.type
        }

        return type;
    }

    initialiseViewModel();
};

var PointOfInterest = function (data, hasDocuments) {
    var self = this;

    self.marker = null;
    self.poiId = ko.observable(exists(data, 'poiId'));
    self.name = ko.observable(exists(data, 'name'));
    self.type = ko.observable(exists(data, 'type'));
    self.description = ko.observable(exists(data, 'description'));

    if (!_.isUndefined(data.geometry)) {
        self.geometry = ko.observable({
            type: ALA.MapConstants.DRAW_TYPE.POINT_TYPE,
            decimalLatitude: ko.observable(exists(data.geometry, 'decimalLatitude')),
            decimalLongitude: ko.observable(exists(data.geometry, 'decimalLongitude')),
            uncertainty: ko.observable(exists(data.geometry, 'uncertainty')),
            precision: ko.observable(exists(data.geometry, 'precision')),
            datum: ko.observable(exists(data.geometry, 'datum')),
            bearing: ko.observable(exists(data.geometry, 'bearing'))
        });
    }
    self.hasPhotoPointDocuments = hasDocuments;

    self.dragEvent = function (event) {
        var lat = event.target.getLatLng().lat;
        var lng = event.target.getLatLng().lng;
        self.geometry().decimalLatitude(lat);
        self.geometry().decimalLongitude(lng);
    };

    self.hasCoordinate = function () {
        return !isNaN(self.geometry().decimalLatitude()) && !isNaN(self.geometry().decimalLongitude());
    };

    self.toJSON = function () {
        var js = {
            poiId: self.poiId(),
            name: self.name(),
            type: self.type(),
            description: self.description(),
            geometry: ko.toJS(self.geometry)
        };

        if (self.hasCoordinate()) {
            js.geometry.coordinates = [js.geometry.decimalLatitude, js.geometry.decimalLongitude];
        }
        return js;
    };
};

// systematic
var TransectPart = function (data, hasDocuments) {
    var self = this;

    self.marker = null;
    self.poiId = ko.observable(exists(data, 'poiId'));
    self.name = ko.observable(exists(data, 'name'));
    self.type = ko.observable(exists(data, 'type'));
    self.detail = ko.observable(exists(data, 'detail'));
    self.habitat = ko.observable(exists(data, 'habitat'));
    self.description = ko.observable(exists(data, 'description'));

    if (!_.isUndefined(data.geometry)) {
        self.geometry = ko.observable({
            type: ALA.MapConstants.DRAW_TYPE.LINE_TYPE,
            coordinates: []
        });
    }
    self.hasPhotoPointDocuments = hasDocuments;

    self.toJSON = function () {
        var js = {
            poiId: self.poiId(),
            name: self.name(),
            type: self.type(),
            habitat: self.habitat(),
            detail: self.detail(),
            description: self.description(),
            geometry: ko.toJS(self.geometry)
        };

        if (self.hasCoordinate()) {
            js.geometry.coordinates = [js.geometry.decimalLatitude, js.geometry.decimalLongitude];
        }
        return js;
    };
};
